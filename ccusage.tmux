#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/helpers.sh"

# ccusage interpolation strings
ccusage_interpolations=(
  "\#{ccusage_today_cost}"
  "\#{ccusage_yesterday_cost}"
  "\#{ccusage_month_cost}"
  "\#{ccusage_last_month_cost}"
  "\#{ccusage_today_tokens}"
  "\#{ccusage_yesterday_tokens}"
  "\#{ccusage_today_input_tokens}"
  "\#{ccusage_today_output_tokens}"
  "\#{ccusage_today_models}"
  "\#{ccusage_total_cost}"
  "\#{ccusage_total_tokens}"
  "\#{ccusage_total_input_tokens}"
  "\#{ccusage_total_output_tokens}"
)

# ccusage commands
ccusage_commands=(
  "#($CURRENT_DIR/scripts/ccusage_today_cost.sh)"
  "#($CURRENT_DIR/scripts/ccusage_yesterday_cost.sh)"
  "#($CURRENT_DIR/scripts/ccusage_month_cost.sh)"
  "#($CURRENT_DIR/scripts/ccusage_last_month_cost.sh)"
  "#($CURRENT_DIR/scripts/ccusage_today_tokens.sh)"
  "#($CURRENT_DIR/scripts/ccusage_yesterday_tokens.sh)"
  "#($CURRENT_DIR/scripts/ccusage_today_input_tokens.sh)"
  "#($CURRENT_DIR/scripts/ccusage_today_output_tokens.sh)"
  "#($CURRENT_DIR/scripts/ccusage_today_models.sh)"
  "#($CURRENT_DIR/scripts/ccusage_total_cost.sh)"
  "#($CURRENT_DIR/scripts/ccusage_total_tokens.sh)"
  "#($CURRENT_DIR/scripts/ccusage_total_input_tokens.sh)"
  "#($CURRENT_DIR/scripts/ccusage_total_output_tokens.sh)"
)

# Get tmux option value
get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local option_value="$(tmux show-option -gqv "$option")"
  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

# Set tmux option
set_tmux_option() {
  local option="$1"
  local value="$2"
  tmux set-option -gq "$option" "$value"
}

# Do interpolation
do_interpolation() {
  local all_interpolated="$1"
  local interpolated="$all_interpolated"
  
  for (( i=0; i<${#ccusage_interpolations[@]}; i++ )); do
    interpolated="${interpolated/${ccusage_interpolations[$i]}/${ccusage_commands[$i]}}"
  done
  
  echo "$interpolated"
}

# Update tmux option
update_tmux_option() {
  local option="$1"
  local option_value="$(get_tmux_option "$option")"
  local new_option_value="$(do_interpolation "$option_value")"
  set_tmux_option "$option" "$new_option_value"
}

main() {
  update_tmux_option "status-right"
  update_tmux_option "status-left"
}

main
