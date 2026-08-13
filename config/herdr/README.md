# Herdr Configuration

Configuration and plugin setup for **Herdr**, a terminal multiplexer for coding agents.

## Plugin Installation & Setup

When bootstrapping a new machine, register the installed plugins via the Herdr CLI:

### 1. Smart Navigation (`herdr-nvim-nav` fork)
Enables low-latency seamless `CTRL+h/j/k/l` navigation between Neovim splits and Herdr panes:

```bash
herdr plugin install angelurano/herdr-nvim-nav --ref ec047fd6d8d0269d54a34e9405af28d8aad4c8f0 --yes
```

### 2. Worktree Setup (`tdi.worktree-setup` - Pinned)
Automates project initialization (`.env` copy, `direnv allow`, etc.) on `worktree.created`. Pinned to audited commit `4527a11`:

```bash
herdr plugin install tdi/herdr-worktree-setup --ref 4527a11bd5444dbce34c3d4f459b49d704cc12a7 --yes
```

> **Configuration Symlink**: Automatically managed via Home Manager on Linux/WSL2 (`home-manager switch`) and via `Sync-Dotfiles` on Windows PowerShell.
>
> Manual symlink command (`ln -s`):
> ```bash
> mkdir -p ~/.config/herdr/plugins/config/tdi.worktree-setup
> ln -s ~/dotfiles/config/herdr/worktree-setup.toml ~/.config/herdr/plugins/config/tdi.worktree-setup/config.toml
> ```

## Keybindings Quick Reference

| Action | Shortcut | Description |
| :--- | :--- | :--- |
| **Smart Navigation** | `CTRL+h/j/k/l` | Navigate Neovim splits & Herdr panes |
| **Goto** | `CTRL+B + p` | Jump to any pane or location |
| **Open Worktree** | `CTRL+B + g` | Search and open an existing worktree |
| **New Worktree** | `CTRL+B + Shift+G` | Interactive prompt to create a worktree |
| **Workspace Picker** | `CTRL+B + w` | Floating picker for active workspaces/worktrees |
| **Next Agent** | `CTRL+B + a` | Focus next active coding agent |
| **Previous Agent** | `CTRL+B + Shift+A` | Focus previous active coding agent |
| **Switch Workspace**| `CTRL+B + Alt+1..9` | Jump directly to workspace N |
| **Switch Tab** | `CTRL+B + 1..9` | Jump directly to tab N |
