#
# ~/.bash_profile — login shells only (tty login, `ssh host`, `bash -l`).
#
# Nothing but the handoff: everything real lives in ~/.bashrc so that login and
# non-login shells behave identically. PATH additions belong there too, guarded
# against duplicates — an unguarded export here stacked a second copy of
# ~/.lmstudio/bin onto every login shell's PATH.
#
[[ -f ~/.bashrc ]] && . ~/.bashrc
