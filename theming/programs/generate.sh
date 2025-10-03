#!/bin/sh

# Functions to display error or info and quit
die() { verbose "$1 colorsceme cannot be processed!" >&2; exit 1 ;}
process() { verbose "$1 colorsceme is applied!" ;}
write_toml() { tomlq -i -t "$1" "$(echo $2 | sed "s|~|$HOME|g")" >/dev/null || die "$2";}

# Load pywal colors
. "$PYWAL16_OUT_DIR/colors.sh"

# declare programs script/s and other variables
SCRIPT_DIR="`dirname $0`/scripts/programs"
PROGRAMS_DIR=( "$SCRIPT_DIR/terminal" "$SCRIPT_DIR/notification" 
			   "$SCRIPT_DIR/status" "$SCRIPT_DIR/launcher" )
OPTS=$(getopt -o -v --long alacritty::,dunst::,i3status-rs::,rofi:: -- "$@")
eval set -- "$OPTS" ; [ -z $1 ] && echo "$HELP_TXT"

while true; do
  case "$1" in
    --alacritty)
      . "${PROGRAMS_DIR[0]}/alacritty.sh" "${2:-$HOME/.config/alacritty.toml}" && \
		  process "Alacritty" &
      shift 2 ;;
    --dunst)
     . "${PROGRAMS_DIR[1]}/dunst.sh" "${2:-$HOME/.config/dunst/dunstrc}" && \
		 process "Dunst" &
      shift 2 ;;
    --i3status-rs)
      . "${PROGRAMS_DIR[2]}/i3status_rs.sh" "${2:-$HOME/.config/i3status-rs/config.toml}" && \
		  process "i3status_rs" &
      shift 2 ;;
	--rofi)
     . "${PROGRAMS_DIR[3]}/rofi.sh" "${2:-$HOME/.config/rofi/config.rasi}" && \
		 process "Rofi" &
      shift 2 ;;
    --)
      shift; break ; exit 0 ;;
  esac
done
