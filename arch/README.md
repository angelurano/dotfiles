# Arch Linux + Hyprland

Lightweight **Arch Linux + Hyprland** configuration deployed directly into `$XDG_CONFIG_HOME` (`~/.config`) using **GNU Stow**, with a switchable Day/Night theme inspired by *NieR:Automata*.

---

## 1. Core Packages (`pacman`)

```bash
sudo pacman -S --needed \
  hyprland uwsm hypridle hyprpolkitagent xdg-desktop-portal-hyprland \
  waybar rofi mako wob hyprpaper wl-clipboard cliphist grim slurp \
  kitty zsh fzf eza bat bat-extras fd ripgrep zoxide yazi btop fastfetch \
  impala bluetui brightnessctl playerctl stow jq \
  poppler ffmpegthumbnailer swayimg vlc vlc-plugin-ffmpeg vlc-plugin-freetype vlc-plugin-ass \
  earlyoom pacman-contrib udiskie udisks2 exfatprogs
```

---

## 2. Deployment (GNU Stow)

All directories under `common/` and `arch/` map directly into `~/.config/<app>`.

### Step 1 — Pre-create Runtime Directories

Creating these directories before running `stow` prevents runtime state and machine-local files from folding into the Git repository:

```bash
mkdir -p \
  ~/.config/waybar \
  ~/.config/rofi \
  ~/.config/wob \
  ~/.config/gtk-3.0 \
  ~/.config/gtk-4.0 \
  ~/.config/herdr/plugins/config/tdi.worktree-setup \
  ~/.config/systemd/user \
  ~/.config/btop/themes
```

### Step 2 — Link Configurations & Initialize Theme State

```bash
stow --restow -d ~/dotfiles -t ~/.config common arch
~/.config/hypr/scripts/theme.sh init
```

> [!NOTE]
> * `common/.stow-local-ignore` excludes overlapping presets (`ohmyposh`, `herdr`, `yazi`, `README.md`) so the `arch/` configurations take precedence automatically.
> * To load Zsh config directly from `~/.config/zsh` without a `~/.zshrc` stub, export `ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"` in your system `zshenv`.
> * See [common/herdr/README.md](../common/herdr/README.md) for Herdr plugin setup.

---

## 3. Session & User Services (`UWSM` + `systemd --user`)

When launching Hyprland via **UWSM** (`Hyprland (uwsm-managed)`), `arch/uwsm/env` and `arch/uwsm/env-hyprland` are loaded automatically. Enable the desired user units:

```bash
systemctl --user daemon-reload
systemctl --user enable \
  waybar.service \
  mako.service \
  hyprpolkitagent.service \
  hypridle.service \
  hyprpaper.service
```

---

## 4. Keybindings Reference

* **`SUPER + ...`** → **Hyprland** (Window manager & launchers)
* **`CTRL + b`, `CTRL + h/j/k/l`** → **Herdr & Neovim** (pane/split navigation)
* **`ALT + h/j/k/l`** → **Neovim** (line/selection move)
* **`CTRL + SHIFT + ...`** → **Kitty** (clipboard, font zoom)

### Hyprland (`SUPER`)

| Shortcut | Action |
| :--- | :--- |
| `SUPER + Return` | Launch `Kitty` (`zsh`) |
| `SUPER + Shift + Return` | Launch `Kitty` attached to `Herdr` |
| `SUPER + Q` | Close active window |
| `SUPER + Space` / `SUPER + D` | Application launcher (`rofi -show drun`) |
| `SUPER + Tab` | Window switcher (`rofi -show window`) |
| `SUPER + Escape` | System menu (`Network`, `Audio`, `Bluetooth`, `USB`, power actions) |
| `CTRL + Shift + Escape` | Floating `btop` system monitor |
| `SUPER + Shift + T` | Toggle **Day** / **Night** theme |
| `SUPER + E` | Floating `Yazi` file manager |
| `SUPER + B` | Launch browser (`$BROWSER`) |
| `SUPER + V` | Clipboard history (`cliphist` + `rofi`) |
| `SUPER + h / j / k / l` | Focus window Left / Down / Up / Right |
| `SUPER + Shift + h / j / k / l` | Move window Left / Down / Up / Right |
| `SUPER + Alt + h / j / k / l` | Direct window resize (`±36px`) |
| `SUPER + R` | Enter `RESIZE` submap (`Esc` / `Enter` to exit) |
| `SUPER + 1..0` | Switch to Workspace `1..10` |
| `SUPER + Shift + 1..0` | Move active window to Workspace `1..10` |
| `SUPER + S` / `SUPER + Shift + S` | Toggle / Move window to `bunker` scratchpad |
| `SUPER + F` / `SUPER + Shift + F` | Maximize (keep Waybar) / Fullscreen |
| `SUPER + T` / `SUPER + U` | Toggle Floating / Toggle split orientation |
| `Print` | Area screenshot (`grim` + `slurp`) to clipboard |
| `SUPER + Print` | Fullscreen screenshot to `~/downloads/screenshots/` + clipboard |
| `SUPER + M` | Display / HDMI menu |
| `SUPER + Shift + M` | Exit Hyprland session (`uwsm stop`) |

### Waybar Controls
* **Left accent bar** → Application launcher (`rofi -show drun`).
* **`[ DAY ]` / `[ NIGHT ]`** → Toggle Day/Night theme.
* **`■ HDMI`** *(when an external display is connected)* → Click for Display menu; right-click toggles HDMI audio.
* **`NET` / `BT` / `CPU` / `MEM` / `VOL`** → Floating `impala`, `bluetui`, `btop`, `wiremix` (right-click `VOL` toggles mute).
* **`■ SYSTEM`** → System operations menu.
