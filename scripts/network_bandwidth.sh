#!/usr/bin/env bash

get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value
  option_value="$(tmux show-option -gqv "$option")"
  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}
# current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# source "$current_dir"/utils.sh
INTERVAL="1" # update interval in seconds
network_name=$(tmux show-option -gqv "@dracula-network-name")
show_upload=$(get_tmux_option "@dracula-network-show-upload" false)
main() {
  while true; do
    output_download=""
    output_upload=""
    output_download_unit=""
    output_upload_unit=""

    initial_download=$(cat /sys/class/net/"$network_name"/statistics/rx_bytes)
    # if $show_upload; then
    #   initial_upload=$(cat /sys/class/net/"$network_name"/statistics/tx_bytes)
    # fi
    sleep $INTERVAL

    final_download=$(cat /sys/class/net/"$network_name"/statistics/rx_bytes)
    # if $show_upload; then
    #   final_upload=$(cat /sys/class/net/"$network_name"/statistics/tx_bytes)
    # fi

    total_download_bps=$(expr "$final_download" - "$initial_download")
    # if $show_upload; then
    #   total_upload_bps=$(expr "$final_upload" - "$initial_upload")
    # fi

    if [ "$total_download_bps" -gt 1073741824 ]; then
      output_download=$(echo "$total_download_bps 1024" | awk '{printf "%.2f \n", $1/($2 * $2 * $2)}')
      output_download_unit="gB/s"
    elif [ "$total_download_bps" -gt 1048576 ]; then
      output_download=$(echo "$total_download_bps 1024" | awk '{printf "%.2f \n", $1/($2 * $2)}')
      output_download_unit="mB/s"
    else
      output_download=$(echo "$total_download_bps 1024" | awk '{printf "%.2f \n", $1/$2}')
      output_download_unit="kB/s"
    fi
    output="↓ $output_download $output_download_unit"
    # if $show_upload; then
    #   if [ "$total_upload_bps" -gt 1073741824 ]; then
    #     output_upload=$(echo "$total_download_bps 1024" | awk '{printf "%.2f \n", $1/($2 * $2 * $2)}')
    #     output_upload_unit="gB/s"
    #   elif [ "$total_upload_bps" -gt 1048576 ]; then
    #     output_upload=$(echo "$total_upload_bps 1024" | awk '{printf "%.2f \n", $1/($2 * $2)}')
    #     output_upload_unit="mB/s"
    #   else
    #     output_upload=$(echo "$total_upload_bps 1024" | awk '{printf "%.2f \n", $1/$2}')
    #     output_upload_unit="kB/s"
    #   fi
    #   output="$output • ↑ $output_upload $output_upload_unit"
    # fi
    echo "$output"
  done
}
main
