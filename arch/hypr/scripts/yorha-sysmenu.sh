#!/usr/bin/env bash
set -euo pipefail

CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

options=(
    "■  Display Mode (Day / Night)"
    "■  Displays / HDMI"
    "■  Network"
    "■  Audio"
    "■  Bluetooth"
    "■  USB Drives"
    "■  Status Monitor"
    "■  Suspend"
    "■  Exit Session"
    "■  Reboot"
    "■  Shutdown"
)

choice="$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "System" -no-show-icons -theme "$CFG_DIR/rofi/yorha-sys.rasi")" || exit 0

notify_usb() {
    command -v notify-send >/dev/null 2>&1 && notify-send -a "USB" "$1" "${2:-}" || true
}

run_tui() {
    local arg="${2:-}"
    if [[ -n "$arg" ]]; then
        exec kitty --single-instance --class floating_tui -e "$1" "$arg"
    else
        exec kitty --single-instance --class floating_tui -e "$1"
    fi
}

usb_menu() {
    local entries=()
    while IFS=$'\t' read -r path size label fstype mnt; do
        [[ -n "$path" ]] || continue
        if [[ -n "$mnt" ]]; then
            entries+=("■  Eject   ${path}  (${label}, ${size})  —  ${mnt}")
            entries+=("■  Open    ${path}  (${label})  in Yazi  —  ${mnt}")
        else
            entries+=("■  Mount   ${path}  (${label}, ${size}, ${fstype})")
        fi
    done < <(
        lsblk -J -o NAME,PATH,SIZE,LABEL,FSTYPE,MOUNTPOINT,RM,TRAN,TYPE 2>/dev/null \
        | jq -r '
            [
                .blockdevices[]
                | select((.rm == true or .tran == "usb") and (.name | test("^(zram|loop|mmcblk0boot)") | not))
                | if ((.children? // []) | length) > 0 then .children[] else . end
                | select(.fstype != null and .fstype != "swap")
            ][]
            | [
                .path,
                (.size // "?"),
                (.label // "USB"),
                (.fstype // "?"),
                (.mountpoint // "")
            ]
            | @tsv'
    )

    if (( ${#entries[@]} == 0 )); then
        notify_usb "USB Drives" "No removable storage devices detected."
        exit 0
    fi

    if printf '%s\n' "${entries[@]}" | grep -q "■  Eject "; then
        entries+=("■  Eject All USB Drives")
    fi

    local sel dev mnt lines
    lines=${#entries[@]}
    (( lines > 10 )) && lines=10
    sel="$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -p "USB" -no-show-icons \
        -theme "$CFG_DIR/rofi/yorha-sys.rasi" \
        -theme-str 'textbox-section-title { content: "USB"; } textbox-section-sub { content: "—  Removable Storage"; } listview { lines: '"$lines"'; }')" || exit 0

    case "$sel" in
        "■  Eject All USB Drives")
            udiskie-umount -da >/dev/null 2>&1 || true
            notify_usb "USB Safely Removed" "All removable drives powered off."
            ;;
        "■  Eject "*)
            dev="$(awk '{print $3}' <<< "$sel")"
            udiskie-umount -d "$dev" >/dev/null
            notify_usb "USB Safely Removed" "$dev powered off and safe to unplug."
            ;;
        "■  Open "*)
            mnt="${sel##*—  }"
            run_tui yazi "$mnt"
            ;;
        "■  Mount "*)
            dev="$(awk '{print $3}' <<< "$sel")"
            udiskie-mount "$dev" >/dev/null
            mnt="$(lsblk -nr -o MOUNTPOINT "$dev" | head -n1)"
            notify_usb "USB Mounted" "${dev} → ${mnt:-mounted}"
            ;;
    esac
}

case "$choice" in
    *"Displays / HDMI"*)
        exec "$CFG_DIR/hypr/scripts/yorha-display.sh" menu
        ;;
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
    *"USB Drives"*)
        usb_menu
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
