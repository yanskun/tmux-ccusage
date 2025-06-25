#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

# Get today's output tokens
today=$(get_today)
json_data=$(get_ccusage_daily_data "$today")
tokens=$(extract_json_value "$json_data" "totals.outputTokens")
format_tokens "$tokens"