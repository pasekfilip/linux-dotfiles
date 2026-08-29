# =============================================================================
# ~/.bashrc  —  symlinked here from ~/dotfiles/bash/.bashrc (stow package: bash)
#
# WHICH STARTUP FILE RUNS WHEN
#
#   login shell               /etc/profile → /etc/profile.d/*.sh →
#   (tty login, `ssh host`,   ~/.bash_profile → which sources this file
#    `bash -l`)
#
#   interactive shell         this file only
#   (new ghostty window,
#    new tmux pane)
#
#   `ssh host cmd`,           this file only, and NOT interactively: bash
#   `bash -lc '...'`          sources ~/.bashrc when it sees stdin is a network
#   (bar modules, hooks)      socket, and -l adds the profile chain on top
#
#   `#!/usr/bin/env bash`     nothing. Scripts inherit the environment, not this
#   scripts                   file — the aliases and functions here don't exist
#                             there. Only `export`ed variables cross over.
#
# The third case is the one that bites: no terminal is attached, so anything
# that prints (fastfetch) or touches the tty (stty, bind) lands in some other
# program's stdout — that greeting once rendered inside the Omarchy bar. Hence
# the interactive gate in the middle of this file. Above the gate runs in every
# shell; below it runs only when a human is typing.
#
# Reload:   exec bash        (`source ~/.bashrc` re-runs every eval and would
#                             re-append PATH entries)
# Inspect:  type -a <name>   alias, function, or binary?
#           alias | declare -F | shopt | bind -p | grep -i <key>
# =============================================================================

# -----------------------------------------------------------------------------
# Environment — every shell, interactive or not
# -----------------------------------------------------------------------------
# env-bootstrap is Omarchy's single source of truth for OMARCHY_PATH and the
# PATH additions (~/.local/bin, mise shims). It is idempotent, and it is also
# sourced by /etc/profile.d/omarchy.sh and the uwsm session — so it runs twice
# on a login shell by design. Sourcing it here is what covers the shells that
# skip the profile chain entirely (ssh commands, bar modules, hooks).
#
# It replaces the hand-rolled /etc/omarchy.conf block that used to live here:
# same job, one copy, and it also handles the dev-link PATH case.
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] &&
    source /usr/share/omarchy/default/bash/env-bootstrap

# LM Studio's CLI. Guarded: a bare `export PATH="$PATH:..."` adds a duplicate
# entry every time the file is re-sourced, and between here and ~/.bash_profile
# this one had stacked up four deep.
case ":$PATH:" in
*":$HOME/.lmstudio/bin:"*) ;;
*) export PATH="$PATH:$HOME/.lmstudio/bin" ;;
esac

# -----------------------------------------------------------------------------
# Interactive gate
# -----------------------------------------------------------------------------
# `$-` is the set of active shell flags; it contains `i` only in an interactive
# shell. Returning here is the same line /etc/skel/.bashrc draws, and it is why
# nothing below needs a `[[ $- == *i* ]]` guard of its own any more.
#
# The trade-off: a non-interactive `bash -lc` no longer picks up Omarchy's shell
# functions (ssh, tdl, hdl, compress, ...). Commands still resolve, because PATH
# was set above. A script that genuinely wants those functions should source the
# chain itself:  source "$OMARCHY_PATH/default/bash/rc"
[[ $- != *i* ]] && return

# -----------------------------------------------------------------------------
# Omarchy defaults
# -----------------------------------------------------------------------------
# One line, a lot of machinery. Read the parts with:
#   bat /usr/share/omarchy/default/bash/{envs,shell,aliases,functions,init}
#
#   envs        EDITOR/SUDO_EDITOR (omarchy-launch-editor), BROWSER, BAT_THEME,
#               bat as the man pager, locale fallback for ssh sessions
#   shell       history (histappend, ignoreboth, 32768 lines), bash-completion,
#               `set +h` — no command hashing, because mise swaps binaries
#               underfoot and a hashed path would go stale
#   aliases     ls/lsa/lt/lta via eza, ff/eff/sff (fzf+bat pickers), `cd` → zd
#               (falls through to zoxide when the arg isn't a directory),
#               ..  ...  ....,  g/gcm/gcam/gcad, d, r, t, h, n(), mup,
#               a/c/cx/cy/ic/ix/icx for the AI CLIs
#   functions   everything in default/bash/fns/ — an `ssh` wrapper that disarms
#               leftover mouse/alt-screen escapes and auto-reconnects a dropped
#               session, the tmux layout builders (tdl/tds/tdlm/tsl), herdr
#               helpers (hdl/hds/hdlm/hsl), drives (iso2sd/format-drive),
#               git worktrees (rsw/lsw/dsw), compress, ga/gd/fip/dip/lip
#   init        mise activate, starship prompt, zoxide, fzf completion and
#               keybindings (Ctrl-t, Ctrl-r, Alt-c), lazy `try`, completions
#   inputrc     readline, applied with `bind -f`: ↑/↓ search history by prefix,
#               Tab cycles candidates, case-insensitive completion
#
# Override, don't edit: /usr/share/omarchy is package-owned and any change there
# is lost on the next `omarchy update`. Redefine below instead — whatever comes
# later wins, and `type -a <name>` shows which definition is live.
source "$OMARCHY_PATH/default/bash/rc"

# -----------------------------------------------------------------------------
# My aliases
# -----------------------------------------------------------------------------
alias cx='printf "\033[2J\033[3J\033[H" && claude'
alias lsg='ls -lg' # `ls` is eza here, so: long listing + group column
alias vi='nvim'
alias ctl='systemctl'

# ripgrep in place of grep. What changes: rg recurses by default, honours
# .gitignore (-uu to look anyway), and prints line numbers unasked. The sharp
# edge is `-E` — extended regex to grep, --encoding to rg, and it eats the next
# argument. Scripts are unaffected: aliases expand in interactive shells only.
alias grep='rg'

# Models and agents
alias o='ollama'
alias orun='ollama run qwen3.5:9b-q8_0'
alias pns='pi --no-session'
alias pro='pi --tools read,grep,find,ls,web_fetch,web_search'
alias pchat='pi --system-prompt " " --tools web_search,web_fetch'

# A greeting in every new shell. Off: tmux opens a lot of them.
# fastfetch

# -----------------------------------------------------------------------------
# Keys and terminal modes
# -----------------------------------------------------------------------------
# Ctrl-f: fuzzy-pick a project from zoxide and attach its tmux session. `bind -x`
# runs a command and redraws the prompt; plain `bind` can only stuff text into
# the line editor. Inside tmux the same picker is prefix+f (see tmux.conf).
bind -x '"\C-f": tmux-sessionizer'

# Ctrl-S is the tty's XOFF (software flow control): it halts all output until
# Ctrl-Q (XON) resumes it, which looks exactly like a frozen terminal. Nothing
# in this setup wants flow control, and Ctrl+Shift+S (tmux split-right) is a
# thumb-slip away. `-t 0` because an interactive shell can still be started
# without a tty (`bash -ic` in a pipe), and stty errors out there.
[[ -t 0 ]] && stty -ixon
