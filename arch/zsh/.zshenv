export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="bat --paging=always"
export BROWSER="brave-origin"


export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

export NODE_REPL_HISTORY="$XDG_STATE_HOME/node/node_repl_history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export npm_config_cache="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_PREFIX="$XDG_DATA_HOME/npm"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"

export BUN_INSTALL="$XDG_DATA_HOME/bun"
export BUN_INSTALL_CACHE_DIR="$XDG_CACHE_HOME/bun"

export COPILOT_HOME="$XDG_CONFIG_HOME/copilot"

export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export PYTHONUSERBASE="$XDG_DATA_HOME/python"

export GDBHISTFILE="$XDG_STATE_HOME/gdb/history"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export _ZO_DATA_DIR="$XDG_DATA_HOME/zoxide"

typeset -U path PATH
path=(
	"$HOME/.local/bin"
	"$BUN_INSTALL/bin"
	"$PNPM_HOME"
	"$NPM_CONFIG_PREFIX/bin"
	$path
	"$CARGO_HOME/bin"
)
export PATH
