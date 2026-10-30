#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/theme"
CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
MODE_FILE="$STATE_DIR/mode"

mkdir -p "$STATE_DIR"

get_mode() {
    if [[ -f "$MODE_FILE" ]]; then
        local m
        m="$(<"$MODE_FILE")"
        [[ "$m" == "day" ]] && { printf "day"; return; }
    fi
    # Default to Night mode
    printf "night"
}

apply_links() {
    local mode="$1"
    printf "%s" "$mode" >| "$MODE_FILE"

    if [[ -d "$CFG_DIR/waybar" && ! -L "$CFG_DIR/waybar" ]]; then
        ln -sfn "tokens-${mode}.css" "$CFG_DIR/waybar/tokens.css"
    fi
    if [[ -d "$CFG_DIR/rofi" && ! -L "$CFG_DIR/rofi" ]]; then
        ln -sfn "tokens-${mode}.rasi" "$CFG_DIR/rofi/tokens.rasi"
    fi
}

apply_wallpaper() {
    local mode="$1"
    local wp="$CFG_DIR/hypr/wallpaper-${mode}.png"
    [[ -f "$wp" ]] || return 0

    if pgrep -x hyprpaper >/dev/null 2>&1; then
        hyprctl hyprpaper preload "$wp" >/dev/null 2>&1 || true
        hyprctl hyprpaper wallpaper ",$wp" >/dev/null 2>&1 || true
        hyprctl hyprpaper wallpaper "eDP-1,$wp" >/dev/null 2>&1 || true
    fi
}

apply_system_theme() {
    local mode="$1"
    if command -v gsettings >/dev/null 2>&1; then
        if [[ "$mode" == "night" ]]; then
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' >/dev/null 2>&1 || true
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' >/dev/null 2>&1 || true
        else
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' >/dev/null 2>&1 || true
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' >/dev/null 2>&1 || true
        fi
    fi
}

apply_runtime() {
    local mode="$1"
    apply_links "$mode"
    apply_wallpaper "$mode"
    apply_system_theme "$mode"

    if command -v makoctl >/dev/null 2>&1 && pgrep -x mako >/dev/null 2>&1; then
        if [[ "$mode" == "night" ]]; then
            makoctl mode -s night >/dev/null 2>&1 || true
        else
            makoctl mode -s default >/dev/null 2>&1 || true
        fi
    fi

    if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        hyprctl reload >/dev/null 2>&1 || true
    fi

    if pgrep -x waybar >/dev/null 2>&1; then
        pkill -RTMIN+8 -x waybar 2>/dev/null || true
        pkill -SIGUSR2 -x waybar 2>/dev/null || true
    fi
}

case "${1:-status}" in
    status)
        mode="$(get_mode)"
        if [[ "$mode" == "night" ]]; then
            printf '{"text":" ■ NIGHT ","tooltip":"Mode: NIGHT · Bunker Charcoal (#242220)\\nClick to switch to DAY mode","class":"night"}\n'
        else
            printf '{"text":" ■ DAY ","tooltip":"Mode: DAY · Parchment &amp; Olive (#d1cdb7)\\nClick to switch to NIGHT mode","class":"day"}\n'
        fi
        ;;
    init)
        mode="$(get_mode)"
        apply_runtime "$mode"
        ;;
    set)
        target="${2:-night}"
        [[ "$target" == "day" ]] || target="night"
        apply_runtime "$target"
        ;;
    toggle)
        current="$(get_mode)"
        if [[ "$current" == "day" ]]; then
            next="night"
            label="NIGHT · Bunker Charcoal"
        else
            next="day"
            label="DAY · Parchment & Olive"
        fi
        apply_runtime "$next"
        command -v notify-send >/dev/null 2>&1 && \
            notify-send -a "System" "Display Mode Updated" "Active profile: ${label}" || true
        ;;
esac
