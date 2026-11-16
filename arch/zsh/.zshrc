HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=5000
SAVEHIST=4000

mkdir -p "$XDG_STATE_HOME/zsh" "$XDG_CACHE_HOME/zsh"

HISTORY_IGNORE="(l|ls|ll|la|lA|cd|cd ..|z|zi|z ..|pwd|clear|exit|poweroff|reboot|history|nvim|y)"

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_NO_STORE
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY_TIME

setopt INTERACTIVE_COMMENTS
unsetopt BEEP
KEYTIMEOUT=1

zshaddhistory() {
	local line="${1%%$'\n'}"
	[[ ${#line} -lt 3 ]] && return 2
	return 0
}

# --- TTY 16-Color Palette ---
if [[ "$TERM" == "linux" ]]; then
	printf '\e]P01C1B19\e]P1CD664D\e]P28A9A7B\e]P3DFC48C\e]P47F9A95\e]P5A08A9E\e]P69E9985\e]P7DAD4BB\e]P84E4B42\e]P9E06C55\e]PA9CB08C\e]PBEBD29F\e]PC96B2AD\e]PDB69FB4\e]PEB8B39F\e]PFF2EFE0'
	clear
fi

# --- CLI Palette (Eza / Bat / LS) ---
export EZA_COLORS="\
di=1;38;2;138;154;123:\
ex=1;38;2;163;179;148:\
ln=38;2;127;154;149:\
or=1;38;2;222;218;196;48;2;205;102;77:\
fi=38;2;209;205;183:\
ur=38;2;223;196;140:uw=38;2;205;102;77:ux=38;2;138;154;123:ue=38;2;138;154;123:\
gr=38;2;200;194;169:gw=38;2;205;102;77:gx=38;2;138;154;123:\
tr=38;2;110;106;94:tw=38;2;205;102;77:tx=38;2;110;106;94:\
uu=38;2;200;194;169:gu=38;2;158;153;133:\
sn=38;2;223;196;140:sb=38;2;158;153;133:\
da=38;2;142;137;120:\
hd=4;38;2;200;194;169:\
ga=38;2;138;154;123:gm=38;2;223;196;140:gd=38;2;205;102;77:gv=38;2;127;154;149:gt=38;2;155;126;136:gi=38;2;110;106;94:\
xx=38;2;110;106;94"

# --- Modern CLI Aliases ---
alias sudo='sudo '
alias vi='nvim'
alias vim='nvim'
alias v='nvim'
alias h='herdr'

if (( $+commands[batman] )); then
	alias man='batman'
fi

if (( $+commands[eza] )); then
	alias ls='eza --icons --group-directories-first'
	alias l='eza -blFG --icons --git --group-directories-first'
	alias ll='eza -l --icons --git --group-directories-first'
	alias la='eza -la --icons --git --group-directories-first'
	alias lA='eza -lbA --icons --git --group-directories-first'
	alias tree='eza --tree --icons --group-directories-first'
else
	alias ls='ls --color=auto'
	alias l='ls -CF'
	alias ll='ls -lh'
	alias la='ls -lah'
	alias lA='ls -lAh'
fi

if (( $+commands[bat] )); then
	alias cat='bat --paging=never'
fi

# Yazi wrapper (changes directory when exiting with 'q', keeps CWD with 'Q')
if (( $+commands[yazi] )); then
	function y() {
		local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
		yazi "$@" --cwd-file="$tmp"
		if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
			builtin cd -- "$cwd"
		fi
		rm -f -- "$tmp"
	}
fi

# --- FZF Integration ---
if (( $+commands[fzf] )); then
	export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git --exclude node_modules --exclude .devenv --exclude .direnv'
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
	export FZF_ALT_C_COMMAND='fd --type=d --hidden --strip-cwd-prefix --exclude .git --exclude node_modules'
	export FZF_DEFAULT_OPTS='--height 45% --layout=reverse --border=sharp --prompt="█▌ ◆ " --pointer="◆" --marker="■" --color=bg+:#35322d,bg:#242220,spinner:#DFC48C,hl:#8A9A7B,fg:#d1cdb7,header:#8A9A7B,info:#9E9985,pointer:#8A9A7B,marker:#cd664d,fg+:#dedac4,prompt:#8A9A7B,hl+:#A3B394,border:#4e4b42'
	export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :200 {} 2>/dev/null || eza --tree --color=always {} | head -100'"
	export FZF_ALT_C_OPTS="--preview 'eza --tree --icons --color=always {} | head -100'"
	source <(fzf --zsh)
fi

# --- Completions (24h cached dump + cached herdr completions) ---
if (( $+commands[herdr] )); then
	local _herdr_comp="$XDG_CACHE_HOME/zsh/_herdr"
	if [[ ! -s "$_herdr_comp" || "$commands[herdr]" -nt "$_herdr_comp" ]]; then
		herdr completion zsh >| "$_herdr_comp" 2>/dev/null || true
	fi
	fpath=("$XDG_CACHE_HOME/zsh" $fpath)
fi

ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"
autoload -Uz compinit

() {
	setopt local_options extended_glob
	if [[ ! -f "$ZSH_COMPDUMP" || -n ${ZSH_COMPDUMP}(#qN.mh+24) ]]; then
		compinit -d "$ZSH_COMPDUMP"
	else
		compinit -C -d "$ZSH_COMPDUMP"
	fi
}

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# --- Tool Hooks ---
if (( $+commands[zoxide] )); then
	eval "$(zoxide init zsh)"
fi

if (( $+commands[fnm] )); then
	eval "$(fnm env --use-on-cd --version-file-strategy=recursive --shell zsh)"
fi

if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
	source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6e6a5e'
fi

if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	ZSH_HIGHLIGHT_STYLES[default]='fg=#d1cdb7'
	ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#cd664d,bold'
	ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#c8c2a9,bold'
	ZSH_HIGHLIGHT_STYLES[alias]='fg=#8A9A7B,bold'
	ZSH_HIGHLIGHT_STYLES[builtin]='fg=#8A9A7B,bold'
	ZSH_HIGHLIGHT_STYLES[function]='fg=#A3B394,bold'
	ZSH_HIGHLIGHT_STYLES[command]='fg=#8A9A7B,bold'
	ZSH_HIGHLIGHT_STYLES[precommand]='fg=#DFC48C,underline'
	ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#c8c2a9'
	ZSH_HIGHLIGHT_STYLES[path]='fg=#c8c2a9,underline'
	ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#7F9A95'
	ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#7F9A95'
	ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#DFC48C'
	ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#DFC48C'
	ZSH_HIGHLIGHT_STYLES[comment]='fg=#6e6a5e,italic'
fi

if (( $+commands[oh-my-posh] )); then
	eval "$(oh-my-posh init zsh --config "$XDG_CONFIG_HOME/ohmyposh/conf.toml")"
fi
