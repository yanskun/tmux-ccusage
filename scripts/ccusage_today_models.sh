#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

# Get today's models used
today=$(get_today)
json_data=$(get_ccusage_daily_data "$today")
models=$(extract_json_value "$json_data" "daily.modelsUsed")

# Format models for display (truncate if too long)
if [ -z "$models" ] || [ "$models" = "0" ]; then
  echo "none"
else
  # Replace commas with spaces and limit length
  formatted=$(echo "$models" | tr ',' ' ' | sed 's/^ *//;s/ *$//')
  if [ ${#formatted} -gt 20 ]; then
    echo "${formatted:0:17}..."
  else
    echo "$formatted"
  fi
fi