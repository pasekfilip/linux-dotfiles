#!/bin/bash

# Bootstrap this machine from linux-dotfiles, on top of a fresh Omarchy install.
#
#   ./install.sh              run every step
#   ./install.sh stow ssh     run only the named steps
#
# Steps: packages stow shell ssh syncthing gaming
#
# Safe to re-run: packages already present are skipped, stow is restowed, and
# anything already set up (ssh key, syncthing unit) is left alone. A real file
# sitting where a stow symlink should go — Omarchy's defaults on a fresh
# install, or a symlink that `sed -i` (e.g. `omarchy font set`) turned back into
# a file — is moved to ~/.dotfiles-backup/<timestamp>/ before linking.

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

step() { printf '\n\e[1;34m==> %s\e[0m\n' "$*"; }
note() { printf '    %s\n' "$*"; }

# Package list files: one name per line, '#' comments allowed.
read_list() { grep -vE '^\s*(#|$)' "$1" | awk '{print $1}'; }

do_packages() {
  step "Packages"
  mapfile -t pkgs < <(read_list "$repo/packages.txt")
  mapfile -t aur < <(read_list "$repo/packages-aur.txt")
  ((${#pkgs[@]})) && omarchy pkg add "${pkgs[@]}"
  ((${#aur[@]})) && omarchy pkg aur add "${aur[@]}"
  return 0
}

# Every top-level directory is a stow package.
stow_packages() {
  local d
  for d in "$repo"/*/; do
    basename "$d"
  done
}

do_stow() {
  step "Stow"
  local pkg target
  while read -r pkg; do
    # Dry run first; stow reports each blocking file as
    #   * cannot stow <src> over existing target <target> since ...
    #   * existing target is not owned by stow: <target>
    while read -r target; do
      [[ -n $target ]] || continue
      mkdir -p "$backup_dir/$(dirname "$target")"
      mv "$HOME/$target" "$backup_dir/$target"
      note "backed up ~/$target"
    done < <(stow -n --no-folding -d "$repo" -t "$HOME" "$pkg" 2>&1 |
      sed -nE 's/.*over existing target (.+) since .*/\1/p; s/.*existing target is not owned by stow: (.+)$/\1/p')

    stow -R --no-folding -d "$repo" -t "$HOME" "$pkg"
    note "linked $pkg"
  done < <(stow_packages)

  [[ -d $backup_dir ]] && note "replaced files are in $backup_dir"
  return 0
}

do_shell() {
  step "Omarchy shell config"
  # shell.json / shell.toml are copies, not symlinks — see omarchy/.stow-local-ignore.
  "$repo/omarchy/sync-shell-config" --restore
}

do_ssh() {
  step "SSH"
  mkdir -p -m 700 "$HOME/.ssh/config.d"
  chmod 700 "$HOME/.ssh"
  # Link the config here too, so `./install.sh ssh` works without the stow step.
  stow -R --no-folding -d "$repo" -t "$HOME" ssh

  if [[ -f $HOME/.ssh/id_ed25519 ]]; then
    note "key exists: ~/.ssh/id_ed25519"
  else
    ssh-keygen -t ed25519 -C "$USER@$(hostname)" -f "$HOME/.ssh/id_ed25519"
  fi

  read -rp "    Copy the key to 'odin' now (asks for its password)? [y/N] " ans
  [[ $ans == [yY]* ]] && ssh-copy-id -i "$HOME/.ssh/id_ed25519.pub" odin
  return 0
}

do_syncthing() {
  step "Syncthing"
  omarchy pkg add syncthing
  systemctl --user enable --now syncthing.service

  local id=""
  for _ in {1..10}; do
    id=$(syncthing cli show system 2>/dev/null | sed -nE 's/.*"myID": "([^"]+)".*/\1/p') && [[ -n $id ]] && break
    sleep 1
  done
  # Pre-add odin with a fixed address: ufw drops the LAN discovery broadcasts,
  # so "dynamic" never finds it. Outbound to odin:22000 works fine.
  # Its ID is read over ssh (run the ssh step first) rather than kept in the repo.
  local odin
  odin=$(ssh -o BatchMode=yes -o ConnectTimeout=5 odin 'syncthing cli show system' 2>/dev/null |
    sed -nE 's/.*"myID": "([^"]+)".*/\1/p')
  if [[ -z $odin ]]; then
    note "Couldn't read odin's device ID over ssh — add odin manually in the UI."
  elif ! syncthing cli config devices list 2>/dev/null | grep -qx "$odin"; then
    syncthing cli config devices add --device-id "$odin" --name odin \
      --addresses "tcp://$(ssh -G odin | awk '$1 == "hostname" {print $2}'):22000"
    note "Added odin ($odin)"
  fi

  note "This device ID: ${id:-<not ready yet — run: syncthing cli show system>}"
  note "Add it on odin's Syncthing UI. Its GUI listens on localhost only, so tunnel:"
  note "  ssh -L 8385:localhost:8384 odin   →   http://localhost:8385"
  note "Local UI: http://localhost:8384"
}

do_gaming() {
  step "Gaming"
  # Omarchy picks the right lib32 Vulkan drivers for the detected GPU.
  omarchy-cmd-present steam || omarchy install gaming steam
}

all_steps=(packages stow shell ssh syncthing gaming)
steps=("$@")
((${#steps[@]})) || steps=("${all_steps[@]}")

for s in "${steps[@]}"; do
  if ! declare -F "do_$s" >/dev/null; then
    echo "Unknown step: $s (have: ${all_steps[*]})" >&2
    exit 1
  fi
done

for s in "${steps[@]}"; do
  "do_$s"
done

step "Done"
note "Relaunch Hyprland so env changes (GDK_SCALE etc.) apply: Omarchy menu → System → Relaunch"
