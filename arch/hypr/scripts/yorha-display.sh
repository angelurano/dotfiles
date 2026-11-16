#!/usr/bin/env bash
# YoRHa display controller: external monitor layout, modes, profiles and HDMI audio.
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/displays"
CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
PROFILES="$STATE_DIR/profiles.json"
SESSION="$STATE_DIR/session.json"
INTERNAL="eDP-1"
INTERNAL_MODE="1366x768@59.99500"
CARD_PREFIX="alsa_card.pci"

mkdir -p "$STATE_DIR"
[[ -f "$PROFILES" ]] || echo '{}' >"$PROFILES"

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send -a "Display" "$1" "${2:-}" || true
}

refresh_waybar() {
    pkill -RTMIN+9 -x waybar 2>/dev/null || true
}

# --- Monitor queries ---------------------------------------------------------

mons_json() { hyprctl monitors all -j; }

ext_name() { # first connected external output (enabled or user-disabled)
    mons_json | jq -r --arg i "$INTERNAL" \
        '[.[] | select(.name != $i and .name != "FALLBACK")][0].name // empty'
}

ext_field() { # name, jq-expression
    mons_json | jq -r --arg n "$1" ".[] | select(.name == \$n) | $2"
}

current_mode() { # name -> WxH@R
    ext_field "$1" '"\(.width)x\(.height)@\(.refreshRate)"'
}

# --- Session / profile state -------------------------------------------------

session_get() { jq -r --arg k "$1" --arg d "$2" '.[$k] // $d' "$SESSION" 2>/dev/null || echo "$2"; }

session_init() { # desc mode
    jq -n --arg d "$1" --arg m "$2" \
        '{desc:$d, layout:"right", mode:$m, scale:"1", overscan:"0"}' >"$SESSION"
}

session_set() { # key value
    local tmp
    tmp="$(mktemp)"
    jq --arg k "$1" --arg v "$2" '.[$k] = $v' "$SESSION" >"$tmp" && mv "$tmp" "$SESSION"
}

# --- Applying settings -------------------------------------------------------

lua_monitor() { hyprctl eval "hl.monitor($1)" >/dev/null; }

apply_session() { # name
    local name="$1" layout mode scale overscan pos extra="" px py
    layout="$(session_get layout right)"
    mode="$(session_get mode "$(current_mode "$name")")"
    scale="$(session_get scale 1)"
    overscan="$(session_get overscan 0)"

    case "$layout" in
        right)  pos="auto-right" ;;
        above)  pos="auto-up" ;;
        *)      pos="auto" ;;
    esac

    if [[ "$overscan" != "0" ]]; then
        read -r w h < <(ext_field "$name" '"\(.width) \(.height)"')
        px=$((w * overscan / 100))
        py=$((h * overscan / 100))
        extra=", reserved_area = { top = $py, bottom = $py, left = $px, right = $px }"
    fi

    case "$layout" in
        mirror)
            lua_monitor "{ output = \"$INTERNAL\", mode = \"$INTERNAL_MODE\", position = \"0x0\", scale = 1, disabled = false }"
            lua_monitor "{ output = \"$name\", mode = \"$mode\", position = \"auto\", scale = $scale, disabled = false, mirror = \"$INTERNAL\"$extra }"
            ;;
        clamshell)
            lua_monitor "{ output = \"$name\", mode = \"$mode\", position = \"0x0\", scale = $scale, disabled = false, mirror = \"\"$extra }"
            lua_monitor "{ output = \"$INTERNAL\", disabled = true }"
            ;;
        laptop)
            lua_monitor "{ output = \"$INTERNAL\", mode = \"$INTERNAL_MODE\", position = \"0x0\", scale = 1, disabled = false }"
            lua_monitor "{ output = \"$name\", disabled = true }"
            ;;
        *)
            lua_monitor "{ output = \"$INTERNAL\", mode = \"$INTERNAL_MODE\", position = \"0x0\", scale = 1, disabled = false }"
            lua_monitor "{ output = \"$name\", mode = \"$mode\", position = \"$pos\", scale = $scale, disabled = false, mirror = \"\"$extra }"
            ;;
    esac
    sync_wallpaper
    refresh_waybar
}

sync_wallpaper() {
    local wp
    wp="$(readlink -f "${XDG_STATE_HOME:-$HOME/.local/state}/theme/wallpaper" 2>/dev/null || true)"
    [[ -f "$wp" ]] || return 0
    hyprctl hyprpaper wallpaper ",$wp,cover" >/dev/null 2>&1 || true
}

load_for_device() { # name -> loads profile (if any) or current state into SESSION
    local name="$1" desc
    desc="$(ext_field "$name" .description)"
    if jq -e --arg d "$desc" 'has($d)' "$PROFILES" >/dev/null; then
        jq --arg d "$desc" '.[$d] + {desc:$d}' "$PROFILES" >"$SESSION"
        return 0
    fi
    if [[ "$(session_get desc "")" != "$desc" ]]; then
        session_init "$desc" "$(current_mode "$name")"
    fi
    return 1
}

# --- Audio -------------------------------------------------------------------

audio_card() {
    pactl --format=json list cards | jq -r --arg p "$CARD_PREFIX" \
        '[.[] | select(.name | startswith($p))][0].name // empty'
}

hdmi_profile() { # best available HDMI stereo profile with analog input
    pactl --format=json list cards | jq -r --arg p "$CARD_PREFIX" '
        [.[] | select(.name | startswith($p))][0].profiles
        | to_entries
        | map(select(.key | test("^output:hdmi-stereo(-extra[0-9]+)?\\+input:analog-stereo$")) | select(.value.available != false))
        | sort_by(-.value.priority)
        | .[0].key // empty'
}

audio_hdmi() {
    local card prof
    card="$(audio_card)"
    prof="$(hdmi_profile)"
    [[ -n "$card" && -n "$prof" ]] || return 1
    pactl set-card-profile "$card" "$prof"
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 1 2>/dev/null || true
}

audio_laptop() {
    local card
    card="$(audio_card)"
    [[ -n "$card" ]] || return 0
    pactl set-card-profile "$card" "output:analog-stereo+input:analog-stereo"
}

audio_is_hdmi() {
    local card
    card="$(audio_card)"
    pactl --format=json list cards | jq -e --arg c "$card" \
        '.[] | select(.name == $c) | .active_profile | startswith("output:hdmi")' >/dev/null
}

# --- Commands ----------------------------------------------------------------

cmd_hotplug_add() {
    local name="${1:-$(ext_name)}" desc
    [[ -n "$name" ]] || exit 0
    sleep 1
    load_for_device "$name" || true
    apply_session "$name"
    audio_hdmi || true
    sync_wallpaper
    refresh_waybar
    desc="$(ext_field "$name" .description)"
    notify "External Display Connected" "$desc · $(current_mode "$name") · Audio: HDMI"
}

cmd_hotplug_remove() {
    audio_laptop || true
    # A user-disabled output (Laptop Only layout) stays listed: keep its session
    if [[ -z "$(ext_name)" ]]; then
        rm -f "$SESSION"
        notify "External Display Disconnected" "Audio restored to laptop speakers."
    fi
    refresh_waybar
}

cmd_init() {
    local name
    name="$(ext_name)"
    if [[ -z "$name" ]]; then
        refresh_waybar
        return 0
    fi
    sleep 1
    load_for_device "$name" || true
    apply_session "$name"
    sync_wallpaper
    refresh_waybar
}

cmd_status() {
    local name mode desc layout audio mirror icon_audio
    name="$(ext_name)"
    if [[ -z "$name" ]]; then
        printf '{"text":"","class":"disconnected","tooltip":""}\n'
        return 0
    fi
    desc="$(ext_field "$name" .description)"
    if [[ "$(ext_field "$name" .disabled)" == "true" ]]; then
        printf '{"text":" ■ HDMI OFF ","class":"connected","tooltip":"Output: %s (%s)\\nLayout: laptop only\\n\\nClick: Display menu"}\n' "$name" "$desc"
        return 0
    fi
    mode="$(current_mode "$name")"
    mirror="$(ext_field "$name" .mirrorOf)"
    audio="LAPTOP"
    audio_is_hdmi && audio="HDMI"
    local h="${mode%%@*}"
    h="${h##*x}"
    local label="HDMI ${h}p"
    [[ "$mirror" != "none" ]] && label="HDMI MIRROR"
    layout="$(session_get layout right)"
    printf '{"text":" ■ %s ","class":"connected","tooltip":"Output: %s (%s)\\nMode: %s\\nLayout: %s\\nAudio: %s\\n\\nClick: Display menu\\nRight-click: Toggle audio"}\n' \
        "$label" "$name" "$desc" "$mode" "$layout" "$audio"
}

cmd_auto() { # reset to safe defaults: smart mode, extend right, scale 1, no overscan
    local name="${1:-$(ext_name)}"
    [[ -n "$name" ]] || exit 0
    lua_monitor "{ output = \"$INTERNAL\", mode = \"$INTERNAL_MODE\", position = \"0x0\", scale = 1, disabled = false }"
    lua_monitor "{ output = \"$name\", disabled = false, mirror = \"\" }"
    sleep 1
    hyprctl eval "YoRHaDisplays.auto(\"$name\")" >/dev/null
    sleep 2
    session_init "$(ext_field "$name" .description)" "$(current_mode "$name")"
    apply_session "$name"
    notify "Display Auto" "$name · $(current_mode "$name") · Extend Right"
}

cmd_toggle_audio() {
    if audio_is_hdmi; then
        audio_laptop
        notify "Audio Output" "Laptop speakers"
    elif audio_hdmi; then
        notify "Audio Output" "HDMI display"
    else
        notify "Audio Output" "No HDMI audio sink available."
    fi
    refresh_waybar
}

rofi_menu() { # prompt, mesg, [lines]
    rofi -dmenu -i -p "$1" -mesg "$2" -no-show-icons \
        -theme "$CFG_DIR/rofi/yorha-display.rasi" -theme-str "listview { lines: ${3:-9}; }"
}

cmd_menu() {
    local name desc mode
    name="$(ext_name)"
    if [[ -z "$name" ]]; then
        notify "Display" "No external display connected."
        exit 0
    fi
    load_for_device "$name" || true
    desc="$(ext_field "$name" .description)"
    mode="$(current_mode "$name")"

    local options=(
        "■  Auto (Safe Defaults)"
        "■  Layout: Extend Right"
        "■  Layout: Extend Above"
        "■  Layout: Mirror Laptop"
        "■  Layout: External Only"
        "■  Layout: Laptop Only"
        "■  Resolution / Refresh"
        "■  Scale"
        "■  TV Overscan Margin"
        "■  Audio: Toggle HDMI / Laptop"
        "■  Save Profile for This Device"
        "■  Forget Saved Profile"
    )
    local choice
    choice="$(printf '%s\n' "${options[@]}" | rofi_menu "Display" "OUT: $name · $desc · $mode" 12)" || exit 0

    case "$choice" in
        *"Auto"*)           cmd_auto "$name" ;;
        *"Extend Right"*)   session_set layout right;     apply_session "$name" ;;
        *"Extend Above"*)   session_set layout above;     apply_session "$name" ;;
        *"Mirror Laptop"*)  session_set layout mirror;    apply_session "$name" ;;
        *"External Only"*)  session_set layout clamshell; apply_session "$name" ;;
        *"Laptop Only"*)    session_set layout laptop;    apply_session "$name" ;;
        *"Resolution"*)
            local m
            m="$(mons_json | jq -r --arg n "$name" \
                '.[] | select(.name == $n) | .availableModes | map(sub("Hz$"; "")) | unique_by(.) | .[]' \
                | sort -t x -k1,1nr -k2,2nr | rofi_menu "Mode" "Available modes for $name" 9)" || exit 0
            session_set mode "$m"
            apply_session "$name"
            ;;
        *"Scale"*)
            local s
            s="$(printf '%s\n' 1 1.25 1.5 2 | rofi_menu "Scale" "Current: $(session_get scale 1)" 4)" || exit 0
            session_set scale "$s"
            apply_session "$name"
            ;;
        *"Overscan"*)
            local o
            o="$(printf '%s\n' "0  (off)" "2  (%)" "4  (%)" "6  (%)" | rofi_menu "Overscan" "Keeps windows away from TV edges" 4)" || exit 0
            session_set overscan "${o%% *}"
            apply_session "$name"
            ;;
        *"Audio"*)
            cmd_toggle_audio
            ;;
        *"Save Profile"*)
            local tmp
            tmp="$(mktemp)"
            jq --arg d "$desc" --slurpfile s "$SESSION" \
                '.[$d] = ($s[0] | del(.desc))' "$PROFILES" >"$tmp" && mv "$tmp" "$PROFILES"
            notify "Display Profile Saved" "$desc"
            ;;
        *"Forget Saved"*)
            local tmp
            tmp="$(mktemp)"
            jq --arg d "$desc" 'del(.[$d])' "$PROFILES" >"$tmp" && mv "$tmp" "$PROFILES"
            notify "Display Profile Removed" "$desc"
            ;;
    esac
}

case "${1:-status}" in
    init)           cmd_init ;;
    hotplug-add)    cmd_hotplug_add "${2:-}" ;;
    hotplug-remove) cmd_hotplug_remove ;;
    status)         cmd_status ;;
    toggle-audio)   cmd_toggle_audio ;;
    auto)           cmd_auto "${2:-}" ;;
    menu)           cmd_menu ;;
    *)
        echo "usage: $0 {init|hotplug-add|hotplug-remove|status|toggle-audio|auto|menu}" >&2
        exit 2
        ;;
esac
