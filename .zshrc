typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/cachyos-zsh-config/cachyos-config.zsh

# =======================
# Useful Zsh Options
# =======================

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CDABLE_VARS

# Completion
setopt MENU_COMPLETE
setopt AUTO_LIST
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt GLOB_COMPLETE
setopt LIST_AMBIGUOUS
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Correction
setopt CORRECT
setopt CORRECT_ALL

# Globbing
setopt EXTENDED_GLOB
setopt GLOB_STAR_SHORT
setopt NUMERIC_GLOB_SORT

# Other
setopt IGNORE_EOF
setopt NO_BEEP
setopt NO_HUP
setopt CHECK_JOBS
setopt LONG_LIST_JOBS

# Vi mode
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^F' history-incremental-search-forward
bindkey '^P' up-line-or-search
bindkey '^N' down-line-or-search
bindkey '^U' backward-kill-line
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^W' backward-kill-word
bindkey '^H' backward-delete-char

# Enable color support
autoload -U colors && colors

# PATH additions
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="/home/nasser/.bun/bin:$PATH"
export PATH="/home/nasser/.cargo/bin:$PATH"


# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
if [[ ":$PATH:" != *":$PNPM_HOME:"* ]]; then
    export PATH="$PNPM_HOME:$PATH"
fi

# opam configuration
if [ -f '/home/deck/.opam/opam-init/init.zsh' ]; then
    source '/home/deck/.opam/opam-init/init.zsh'
fi

# Environment variables
export EDITOR="fresh"
export VISUAL="fresh"
export GTK_USE_PORTAL=1
export GDK_DEBUG=portals
export YAZI_CONFIG_HOME="$HOME/.config/yazi-zellij"
export BROWSER="zen"

# Fresh + Zellij + Yazi integration
export ZELLIJ_DEFAULT_LAYOUT="with_sidebar"

# Aliases
alias micro="env TERM=xterm-256color micro"
alias lg='lazygit'

# Custom functions

# agentic - run uv agent in ~/.agents directory
agentic() {
    local original_pwd=$(pwd)
    cd ~/.agents
    uv run main.py "$@"
    cd "$original_pwd"
}

# y - yazi file picker
y() {
    local tmp=$(mktemp)
    yazi --cwd-file "$tmp" "$@"
    if [[ -s "$tmp" ]]; then
        cd "$(cat "$tmp")"
    fi
    rm -f "$tmp"
}

# zi - interactive cd with zoxide
zi() {
    cd "$(zoxide query -i)"
}

# ff - search files with fzf and open in fresh
ff() {
    local file=$(fzf)
    if [[ -n "$file" ]]; then
        fresh "$file"
    fi
}

# rgf - search content with rg + fzf and open in fresh
rgf() {
    local result=$(rg --line-number . "$@" | fzf | cut -d: -f1-2)
    if [[ -n "$result" ]]; then
        fresh "$result"
    fi
}

# fish_command_not_found - run search on command not found
fish_command_not_found() {
    uv run ~/scripts/search.py "$@"
}

# clipboard - get clipboard via kitten
clipboard() {
    kitten clipboard --get-clipboard "$@"
}

# Shell integrations (if installed)
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# System info greeting (run after p10k to avoid console output warning)
if [[ $- == *i* ]] && [[ -z "$INSIDE_EMACS" ]] && command -v fastfetch &>/dev/null; then
    fastfetch --logo none \
        --kitty-icat ~/Downloads/gem_transparent.png \
        --logo-width 25 --logo-height 30 \
        --structure title:os:kernel:uptime:shell:de:wm:cpu:gpu:memory:disk:packages:terminal 2>/dev/null
fi

# OpenClaw Completion
source "/home/nasser/.openclaw/completions/openclaw.zsh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/nasser/scripts/google-cloud-sdk/path.zsh.inc' ]; then . '/home/nasser/scripts/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/nasser/scripts/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/nasser/scripts/google-cloud-sdk/completion.zsh.inc'; fi
