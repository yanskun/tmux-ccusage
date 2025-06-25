#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

# Get this month's total cost
current_month=$(get_current_month)
json_data=$(get_ccusage_monthly_data "$current_month")
cost=$(extract_json_value "$json_data" "totals.totalCost")
format_cost "$cost"