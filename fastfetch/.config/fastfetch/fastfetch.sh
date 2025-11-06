#!/usr/bin/env bash

# --- Default Action: Run this if the script is called without 'logo' ---
# If no arguments are provided, just run fastfetch directly.
# We've changed '--logo-type kitty' to '--logo-type wezterm' for you.
if [ -z "${*}" ]; then
  clear
  exec fastfetch --logo-type wezterm
  exit
fi

# --- Logo Randomizer Logic ---

# This function finds and prints the path to a single random image.
# It's called when you run the script with the 'logo' argument.
random_logo() {
  # Standard locations for config and data files.
  local confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
  local dataDir="${XDG_DATA_HOME:-$HOME/.local/share}"

  # --- EDIT THIS LIST ---
  # Add the full paths to the directories where you store your logos.
  # The script will search inside these for image files.
  local image_dirs=(
    "${confDir}/fastfetch/icons"   # <-- A great place for custom logos
    "$HOME/Pictures/Logos"       # <-- Add any other folder you want
    "$HOME/Wallpapers"           # <-- Or a wallpaper folder
  )

  # We also add your personal profile picture if it exists.
  [ -f "$HOME/.face.icon" ] && image_dirs+=("$HOME/.face.icon")

  # Find all common image files in the specified directories and pick one at random.
  # The '-maxdepth 1' option means it won't search in subdirectories.
  find -L "${image_dirs[@]}" -maxdepth 1 -type f \
    \( -name "*.png" -o -name "*.icon" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) 2>/dev/null | shuf -n 1
}


# --- Main Logic ---
# This part reads the first argument you give the script.
case $1 in
  logo)
    # If the argument is 'logo', run our function to find a random image.
    random_logo
    ;;
  *)
    # If the argument is something else, display a help message.
    echo "Usage: ${0##*/} [command]"
    echo "Commands:"
    echo "  logo    Output a path to a random logo image"
    ;;
esac
