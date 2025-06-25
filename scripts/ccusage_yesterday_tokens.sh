#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

# Get yesterday's total tokens
yesterday=$(get_yesterday)
if [ -n "$yesterday" ]; then
  json_data=$(get_ccusage_daily_data "$yesterday")
  tokens=$(extract_json_value "$json_data" "totals.totalTokens")
  format_tokens "$tokens"
else
  echo "0"
fi