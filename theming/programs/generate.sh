#!/bin/sh

# Functions to display error or info and quit
process() { verbose "$1 colorsceme is applied!" ;}
die() { verbose "$1 colorsceme cannot be processed!" >&2; exit 1 ;}
write_toml() { tomlq -i -t "$1" "$(echo $2 | sed "s|~|$HOME|g")" >/dev/null || die "$2";}

# Setup the used options whis is the programs
OPTS=$(getopt -o -v --long alacritty::,dunst::,i3status-rs::,rofi:: -- "$@")
eval set -- "$OPTS" ; [ -z $1 ] && echo "$HELP_TXT"

# Compare the options and run the scripts
while true; do
	option="${1//--/}"
	case "$1" in
		--alacritty)
			CONFIG_DIR="${2:-$HOME/.config/$option.toml}" && process "$option" &
			shift 2 ;;
		--dunst)
			CONFIG_DIR="${2:-$HOME/.config/$option/dunstrc}" && process "$option" &
			shift 2 ;;
		--i3status-rs)
			CONFIG_DIR="${2:-$HOME/.config/$option/config.toml}" && process "$option" &
			shift 2 ;;
		--rofi)
			CONFIG_DIR="${2:-$HOME/.config/$option/config.rasi}" && process "$option" &
			shift 2 ;;
		--)
			shift; break ; exit 0 ;;
	esac
	. "${PROGRAMS_DIR[0]}/$option.sh" "$CONFIG_DIR"
done
