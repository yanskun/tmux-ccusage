#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

# Get today's total cost
today=$(get_today)
json_data=$(get_ccusage_daily_data "$today")
cost=$(extract_json_value "$json_data" "totals.totalCost")
format_cost "$cost"