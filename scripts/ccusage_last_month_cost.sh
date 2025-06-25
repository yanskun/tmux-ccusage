#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

# Get last month's total cost
last_month=$(get_last_month)
if [ -n "$last_month" ]; then
  json_data=$(get_ccusage_monthly_data "$last_month")
  cost=$(extract_json_value "$json_data" "totals.totalCost")
  format_cost "$cost"
else
  echo "\$0.00"
fi