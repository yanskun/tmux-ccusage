#!/usr/bin/env bash

# Helper functions for ccusage tmux plugin

# Find ccusage executable (with security validation)
find_ccusage() {
  local ccusage_path=""
  
  # Try bunx ccusage first (handles "Need to install the following packages" automatically)
  if command -v bunx >/dev/null 2>&1; then
    # Test if bunx ccusage works
    if bunx ccusage --version >/dev/null 2>&1 || bunx ccusage --help >/dev/null 2>&1; then
      ccusage_path="bunx ccusage"
    fi
  fi
  
  # Fallback to npx ccusage
  if [ -z "$ccusage_path" ] && command -v npx >/dev/null 2>&1; then
    # Test if npx ccusage works
    if npx ccusage --version >/dev/null 2>&1 || npx ccusage --help >/dev/null 2>&1; then
      ccusage_path="npx ccusage"
    fi
  fi
  
  # Fallback to direct command in PATH
  if [ -z "$ccusage_path" ] && command -v ccusage >/dev/null 2>&1; then
    ccusage_path="ccusage"
  fi
  
  # Fallback to known safe installation locations
  if [ -z "$ccusage_path" ]; then
    local safe_paths=(
      "$HOME/.local/share/mise/installs/node/23.6.0/bin/ccusage"
      "$HOME/.local/bin/ccusage"
      "/usr/local/bin/ccusage" 
      "/opt/homebrew/bin/ccusage"
    )
    
    for path in "${safe_paths[@]}"; do
      if [ -f "$path" ] && [ -x "$path" ]; then
        ccusage_path="$path"
        break
      fi
    done
    
    # Last resort: find in mise installations (with constraints)
    if [ -z "$ccusage_path" ] && [ -d "$HOME/.local/share/mise/installs/node" ]; then
      local found_path
      found_path=$(find "$HOME/.local/share/mise/installs/node" -maxdepth 3 -name "ccusage" -type f -executable 2>/dev/null | head -1)
      if [ -n "$found_path" ] && [[ "$found_path" == "$HOME/.local/share/mise/installs/node"* ]]; then
        ccusage_path="$found_path"
      fi
    fi
  fi
  
  # Validate the found executable
  if [ -n "$ccusage_path" ]; then
    # For bunx/npx ccusage, skip validation to avoid double execution
    if [[ "$ccusage_path" == "bunx ccusage" ]] || [[ "$ccusage_path" == "npx ccusage" ]]; then
      echo "$ccusage_path"
    else
      # Basic sanity check for direct commands
      if $ccusage_path --version >/dev/null 2>&1 || $ccusage_path --help >/dev/null 2>&1; then
        echo "$ccusage_path"
      fi
    fi
  fi
}

# Get ccusage daily JSON data for a specific date
get_ccusage_daily_data() {
  local date="$1"
  local since_date="$date" 
  local until_date="$date"
  local ccusage_cmd=$(find_ccusage)
  
  if [ -n "$ccusage_cmd" ]; then
    if [[ "$ccusage_cmd" == "bunx ccusage" ]]; then
      bunx ccusage daily --json --since "$since_date" --until "$until_date" 2>/dev/null
    elif [[ "$ccusage_cmd" == "npx ccusage" ]]; then
      npx ccusage daily --json --since "$since_date" --until "$until_date" 2>/dev/null
    else
      "$ccusage_cmd" daily --json --since "$since_date" --until "$until_date" 2>/dev/null
    fi
  else
    echo "{\"daily\":[], \"totals\":{}}"
  fi
}

# Get ccusage monthly JSON data for a specific month
get_ccusage_monthly_data() {
  local year_month="$1"
  local since_date="${year_month}01"
  local until_date="${year_month}31"
  local ccusage_cmd=$(find_ccusage)
  
  if [ -n "$ccusage_cmd" ]; then
    if [[ "$ccusage_cmd" == "bunx ccusage" ]]; then
      bunx ccusage monthly --json --since "$since_date" --until "$until_date" 2>/dev/null
    elif [[ "$ccusage_cmd" == "npx ccusage" ]]; then
      npx ccusage monthly --json --since "$since_date" --until "$until_date" 2>/dev/null
    else
      "$ccusage_cmd" monthly --json --since "$since_date" --until "$until_date" 2>/dev/null
    fi
  else
    echo "{\"monthly\":[], \"totals\":{}}"
  fi
}

# Extract value from JSON using basic shell tools
extract_json_value() {
  local json="$1"
  local path="$2"
  
  # Check if jq is available (more reliable JSON parsing)
  if command -v jq >/dev/null 2>&1; then
    case "$path" in
      "totals.totalCost")
        echo "$json" | jq -r '.totals.totalCost // 0'
        ;;
      "totals.totalTokens")
        echo "$json" | jq -r '.totals.totalTokens // 0'
        ;;
      "totals.inputTokens")
        echo "$json" | jq -r '.totals.inputTokens // 0'
        ;;
      "totals.outputTokens")
        echo "$json" | jq -r '.totals.outputTokens // 0'
        ;;
      "daily.modelsUsed")
        # Get unique models from all daily entries
        echo "$json" | jq -r '.daily[].modelsUsed[]?' | sort -u | tr '\n' ' ' | sed 's/ $//'
        ;;
      *)
        echo "0"
        ;;
    esac
  else
    # Fallback to basic shell tools (improved regex patterns)
    case "$path" in
      "totals.totalCost")
        echo "$json" | sed -n 's/.*"totals":[^}]*"totalCost":\([0-9.]*\).*/\1/p' | head -1
        ;;
      "totals.totalTokens") 
        echo "$json" | sed -n 's/.*"totals":[^}]*"totalTokens":\([0-9]*\).*/\1/p' | head -1
        ;;
      "totals.inputTokens")
        echo "$json" | sed -n 's/.*"totals":[^}]*"inputTokens":\([0-9]*\).*/\1/p' | head -1
        ;;
      "totals.outputTokens")
        echo "$json" | sed -n 's/.*"totals":[^}]*"outputTokens":\([0-9]*\).*/\1/p' | head -1
        ;;
      "daily.modelsUsed")
        echo "$json" | grep -o '"modelsUsed":\[[^]]*\]' | sed 's/"modelsUsed":\[//;s/\]//;s/"//g;s/,/ /g' | head -1
        ;;
      *)
        echo "0"
        ;;
    esac
  fi
}

# Format cost for display (add $ prefix, round to 2 decimal places)
format_cost() {
  local cost="$1"
  if [ -z "$cost" ] || [ "$cost" = "0" ]; then
    echo "\$0.00"
  else
    printf "\$%.2f" "$cost"
  fi
}

# Format tokens for display (add K/M suffix for large numbers)
format_tokens() {
  local tokens="$1"
  if [ -z "$tokens" ] || [ "$tokens" = "0" ]; then
    echo "0"
  elif [ "$tokens" -gt 1000000 ]; then
    echo "$(( tokens / 1000000 ))M"
  elif [ "$tokens" -gt 1000 ]; then
    echo "$(( tokens / 1000 ))K"
  else
    echo "$tokens"
  fi
}

# Get today's date in YYYYMMDD format
get_today() {
  date +%Y%m%d
}

# Get yesterday's date in YYYYMMDD format  
get_yesterday() {
  if command -v gdate >/dev/null 2>&1; then
    # macOS with GNU coreutils
    gdate -d "yesterday" +%Y%m%d
  else
    # Standard date command
    date -d "yesterday" +%Y%m%d 2>/dev/null || date -v-1d +%Y%m%d 2>/dev/null || echo ""
  fi
}

# Get current month in YYYYMM format
get_current_month() {
  date +%Y%m
}

# Get last month in YYYYMM format
get_last_month() {
  if command -v gdate >/dev/null 2>&1; then
    # macOS with GNU coreutils
    gdate -d "last month" +%Y%m
  else
    # Standard date command
    date -d "last month" +%Y%m 2>/dev/null || date -v-1m +%Y%m 2>/dev/null || echo ""
  fi
}
