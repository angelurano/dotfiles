# pyright: reportAny=false, reportExplicitAny=false, reportUnusedCallResult=false
#!/usr/bin/env python3
import json
import os
import subprocess
import sys

def main() -> None:
    if len(sys.argv) < 2:
        sys.exit(1)

    direction = sys.argv[1].lower()
    key_map = {"left": "ctrl+h", "down": "ctrl+j", "up": "ctrl+k", "right": "ctrl+l"}

    if direction not in key_map:
        sys.exit(1)

    is_vim = False
    pane_id = os.getenv("HERDR_PANE_ID")

    try:
        cmd = ["herdr", "pane", "process-info", "--current"]
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=2)
        if res.returncode == 0:
            data = json.loads(res.stdout)
            info = data.get("result", {}).get("process_info", {})
            if not pane_id:
                pane_id = info.get("pane_id")
            procs = info.get("foreground_processes", [])
            for proc in procs:
                name = proc.get("name", "").lower()
                cmdline = proc.get("cmdline", "").lower()
                if "nvim" in name or "vim" in name or "nvim" in cmdline or "vim" in cmdline:
                    is_vim = True
                    break
    except Exception:
        pass

    if not is_vim and pane_id:
        try:
            cmd = ["herdr", "pane", "get", pane_id]
            res = subprocess.run(cmd, capture_output=True, text=True, timeout=2)
            if res.returncode == 0:
                data = json.loads(res.stdout)
                pane_info = data.get("result", {}).get("pane", {})
                title = pane_info.get("terminal_title", "").lower()
                if "nvim" in title or "vim" in title:
                    is_vim = True
        except Exception:
            pass

    target_key = key_map[direction]
    if is_vim and pane_id:
        subprocess.run(["herdr", "pane", "send-keys", pane_id, target_key])
    else:
        subprocess.run(["herdr", "pane", "focus", "--direction", direction])

if __name__ == "__main__":
    main()
