# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.
if [[ -f /etc/omarchy.conf ]]; then
    source /etc/omarchy.conf
    export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
    export OMARCHY_PATH=/usr/share/omarchy
fi
source "$OMARCHY_PATH/default/bash/rc"

alias lsg='ls -lg'
alias grep='rg'
alias vi='nvim'
alias o='ollama'
alias pns='pi --no-session'
alias pro='pi --tools read,grep,find,ls,web_fetch,web_search'
alias pchat='pi --system-prompt " " --tools web_search,web_fetch'
alias orun='ollama run qwen3.5:9b-q8_0'
alias ctl='systemctl'
# Interactive shells only. Bar modules, hooks, and `ssh host cmd` all run
# `bash -lc`, which sources this file; an unguarded greeting lands in their
# stdout (it showed up rendered inside the Omarchy bar).
# [[ $- == *i* ]] && fastfetch

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
#
# Use VSCode instead of neovim as your default editor
# export EDITOR="code"
#
# Set a custom prompt with the directory revealed (alternatively use https://starship.rs)
# PS1="\W \[\e]0;\w\a\]$PS1"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/filip/.lmstudio/bin"
# End of LM Studio CLI section

# Ctrl-f: fuzzy-pick a project (zoxide) and attach to its tmux session.
# Guarded because `bind` only exists in interactive shells, and this file is
# also sourced by `bash -lc` for bar modules and `ssh host cmd`.
[[ $- == *i* ]] && bind -x '"\C-f": tmux-sessionizer'
