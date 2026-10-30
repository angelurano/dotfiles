#!/usr/bin/env bash
set -euo pipefail

CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

options=(
    "■  Display Mode (Day / Night)"
    "■  Network"
    "■  Audio"
    "■  Bluetooth"
    "■  Status Monitor"
    "■  Suspend"
    "■  Exit Session"
    "■  Reboot"
    "■  Shutdown"
)

choice="$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "System" -no-show-icons -theme "$CFG_DIR/rofi/yorha-sys.rasi")" || exit 0

run_tui() {
    if command -v uwsm >/dev/null 2>&1 && uwsm check is-active hyprland.desktop >/dev/null 2>&1; then
        exec uwsm app -- kitty --class floating_tui -e "$1"
    else
        exec kitty --class floating_tui -e "$1"
    fi
}

case "$choice" in
    *"Display Mode"*)
        exec "$CFG_DIR/hypr/scripts/theme.sh" toggle
        ;;
    *"Network"*)
        run_tui impala
        ;;
    *"Audio"*)
        run_tui wiremix
        ;;
    *"Bluetooth"*)
        run_tui bluetui
        ;;
    *"Status Monitor"*)
        run_tui btop
        ;;
    *"Suspend"*)
        exec systemctl suspend
        ;;
    *"Exit Session"*)
        if command -v uwsm >/dev/null 2>&1 && uwsm check is-active hyprland.desktop >/dev/null 2>&1; then
            exec uwsm stop
        else
            exec hyprctl dispatch 'hl.dsp.exit()'
        fi
        ;;
    *"Reboot"*)
        exec systemctl reboot
        ;;
    *"Shutdown"*)
        exec systemctl poweroff
        ;;
esac
