#!/bin/sh

# Functions to display error or info and quit
die() { printf "waloml: [ERROR] %s colorsceme cannot be set!!\n" "$1" >&2; exit 1 ;}
process() { [ "$VERBOSE" = true ] && printf "waloml: %s colorsheme is applied!!\n" "$1" ;}
write_toml() { tomlq -i -t "$1" "$(echo $2 | sed "s|~|$HOME|g")" >/dev/null || die "tomq cannot process the file $2";}

# Load pywal colors
. "$PYWAL16_OUT_DIR/colors.sh"

# declare programs script/s and other variables
SCRIPT_DIR="`dirname $0`/scripts/programs"
TERM_DIR="$SCRIPT_DIR/terminals"
HELP_TXT="Usage: bash $0 --alacritty=[CONFIG], --dunst=[CONFIG], --i3status-rs=[CONFIG]"
OPTS=$(getopt -o -v --long verbose,alacritty::,dunst::,i3status-rs:: -- "$@")
eval set -- "$OPTS" ; [ -z $1 ] && echo "$HELP_TXT"

while true; do
  case "$1" in
    --verbose)
      VERBOSE=true; shift ;;
    --alacritty)
      . "$TERM_DIR/alacritty.sh" "${2:-$HOME/.config/alacritty.toml}" && process "Alacritty"
      shift 2 ;;
    --dunst)
     . "$SCRIPT_DIR/dunst.sh" "${2:-$HOME/.config/dunst/dunstrc}" && process "Dunst" &
      shift 2 ;;
    --i3status-rs)
      . "$SCRIPT_DIR/i3status_rs.sh" "${2:-$HOME/.config/i3status-rs/config.toml}" && process "i3status_rs" &
      shift 2 ;;
    --)
      shift; break ; exit 0 ;;
    *)
      echo "$HELP_TXT"; break ;;
  esac
done
