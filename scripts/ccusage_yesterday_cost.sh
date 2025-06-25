#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

# Get yesterday's total cost
yesterday=$(get_yesterday)
if [ -n "$yesterday" ]; then
  json_data=$(get_ccusage_daily_data "$yesterday")
  cost=$(extract_json_value "$json_data" "totals.totalCost")
  format_cost "$cost"
else
  echo "\$0.00"
fi