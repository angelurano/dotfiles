#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
WOB_FIFO="$RUNTIME_DIR/yorha-wob.fifo"

ensure_wob() {
    mkdir -p "$RUNTIME_DIR"
    if [[ ! -p "$WOB_FIFO" ]]; then
        rm -f "$WOB_FIFO"
        mkfifo "$WOB_FIFO"
    fi

    if ! pgrep -x wob >/dev/null 2>&1; then
        # Keep FIFO opened O_RDWR on stdin so single writers never send EOF to wob
        nohup sh -c 'exec 3<>"$1"; exec wob <&3' _ "$WOB_FIFO" >/dev/null 2>&1 &
        sleep 0.05
    fi
}

push_wob() {
    local payload="$1"
    ensure_wob
    # Open O_RDWR as a guard so even if wob dies unexpectedly, the shell never blocks
    exec 4<>"$WOB_FIFO"
    printf '%s\n' "$payload" >&4
    exec 4>&-
}

emit_volume() {
    local out pct
    out="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
    [[ -n "$out" ]] || return 0
    pct="$(awk '{ v = int($2 * 100 + 0.5); if (v < 0) v = 0; if (v > 100) v = 100; print v }' <<< "$out")"
    if [[ "$out" == *"[MUTED]"* ]]; then
        push_wob "${pct} muted"
    else
        push_wob "${pct}"
    fi
}

emit_brightness() {
    local pct
    pct="$(brightnessctl -m 2>/dev/null | awk -F, '{ gsub(/%/, "", $4); print int($4 + 0.5) }' || true)"
    [[ -n "$pct" ]] || return 0
    (( pct < 0 )) && pct=0
    (( pct > 100 )) && pct=100
    push_wob "${pct} brightness"
}

case "${1:-}" in
    ensure)
        ensure_wob
        ;;
    vol-up)
        wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
        emit_volume
        ;;
    vol-down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        emit_volume
        ;;
    vol-mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        emit_volume
        ;;
    bri-up)
        brightnessctl -n2 set +5% >/dev/null
        emit_brightness
        ;;
    bri-down)
        brightnessctl -n2 set 5%- >/dev/null
        emit_brightness
        ;;
    *)
        printf 'Usage: %s {ensure|vol-up|vol-down|vol-mute|bri-up|bri-down}\n' "$0" >&2
        exit 1
        ;;
esac
