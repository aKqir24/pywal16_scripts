#!/bin/sh

# Functions to display error or info and quit
die() { printf "waloml: [ERROR] %s colorsceme cannot be set!!\n" "$1" >&2; exit 1 ;}
process() { [ "$VERBOSE" = true ] && printf "waloml: %s colorsheme is applied!!\n" "$1" ;}
write_toml() { tomlq -i -t "$1" "$(echo $2 | sed "s|~|$HOME|g")" >/dev/null || die "tomq cannot process the file $2";}

# Load pywal colors
. "$PYWAL16_OUT_DIR/colors.sh"

# Load terminal/s functions
TERM_DIR="$(pwd)/scripts/terminals"
. "$TERM_DIR/alacritty.sh"

# Functions to write the toml config
changeI3status_rustCONF() {
  write_toml "
.theme.overrides.idle_bg = \"$color0\" |
.theme.overrides.idle_fg = \"$color15\" |
.theme.overrides.info_bg = \"$color15\" |
.theme.overrides.info_fg = \"$color0\" |
.theme.overrides.good_bg = \"$color2\" |
.theme.overrides.good_fg = \"$color0\" |
.theme.overrides.warning_bg = \"$color3\" |
.theme.overrides.warning_fg = \"$color0\" |
.theme.overrides.critical_bg = \"$color1\" |
.theme.overrides.critical_fg = \"$color0\" |
.theme.overrides.alternating_tint_bg = \"$color0\" |
.theme.overrides.alternating_tint_fg = \"$color0\"" "$1"
  process "i3status_rs"
}

changeDunstCONF() {
  write_toml "
.global.background = \"$color0\" |
.global.foreground = \"$color15\" |
.global.frame_color = \"$color2\" |

.urgency_low.background = \"$color0\" |
.urgency_low.foreground = \"$color15\" |
.urgency_low.frame_color = \"$color3\" |

.urgency_critical.background = \"$color0\" |
.urgency_critical.foreground = \"$color15\" |
.urgency_critical.frame_color = \"$color1\"" "$1"
  pgrep -x dunst && pkill dunst ; dunst &>/dev/null 
  process "Dunst"
}

HELP_TXT="Usage: bash $0 --alacritty=[CONFIG], --dunst=[CONFIG], --i3status-rs=[CONFIG]"
OPTS=$(getopt -o -v --long verbose,alacritty::,dunst::,i3status-rs:: -- "$@")
eval set -- "$OPTS" ; [ -z $1 ] && echo "$HELP_TXT"

while true; do
  case "$1" in
    --verbose)
      VERBOSE=true; shift ;;
    --alacritty)
      changeAlacrittyCONF "${2:-$HOME/.config/alacritty.toml}" &
      shift 2 ;;
    --dunst)
      changeDunstCONF "${2:-$HOME/.config/dunst/dunstrc}" &
      shift 2 ;;
    --i3status-rs)
      changeI3status_rustCONF "${2:-$HOME/.config/i3status-rs/config.toml}" &
      shift 2 ;;
    --)
      shift; break ;;
    *)
      echo "$HELP_TXT"; break ;;
  esac
done
