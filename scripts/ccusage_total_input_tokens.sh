#\!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

# Get total tokens (all time)
ccusage_cmd=$(find_ccusage)
if [ -n "$ccusage_cmd" ] ; then
  json_data=$("$ccusage_cmd" daily --json 2>/dev/null)
  tokens=$(extract_json_value "$json_data" "totals.inputTokens")
  format_tokens "$tokens"
else
  echo "0"
fi
