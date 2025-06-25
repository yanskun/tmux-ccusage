#!/usr/bin/env bash

# Helper functions for ccusage tmux plugin

# Find ccusage executable
find_ccusage() {
  if command -v ccusage >/dev/null 2>&1; then
    echo "ccusage"
  elif [ -f "$HOME/.local/share/mise/installs/node/23.6.0/bin/ccusage" ]; then
    echo "$HOME/.local/share/mise/installs/node/23.6.0/bin/ccusage"
  elif [ -f "$HOME/.local/bin/ccusage" ]; then
    echo "$HOME/.local/bin/ccusage"
  elif [ -f "/usr/local/bin/ccusage" ]; then
    echo "/usr/local/bin/ccusage"
  elif [ -f "/opt/homebrew/bin/ccusage" ]; then
    echo "/opt/homebrew/bin/ccusage"
  else
    # Try to find in mise installations
    find "$HOME/.local/share/mise/installs/node" -name "ccusage" -type f 2>/dev/null | head -1
  fi
}

# Get ccusage daily JSON data for a specific date
get_ccusage_daily_data() {
  local date="$1"
  local since_date="$date" 
  local until_date="$date"
  local ccusage_cmd=$(find_ccusage)
  
  if [ -n "$ccusage_cmd" ]; then
    "$ccusage_cmd" daily --json --since "$since_date" --until "$until_date" 2>/dev/null
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
    "$ccusage_cmd" monthly --json --since "$since_date" --until "$until_date" 2>/dev/null
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

# Format cost for display (add $ prefix)
format_cost() {
  local cost="$1"
  if [ -z "$cost" ] || [ "$cost" = "0" ]; then
    echo "\$0.00"
  else
    printf "\$%.4f" "$cost"
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