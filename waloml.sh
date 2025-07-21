#!/bin/sh

# Function to display error and quit
die() { printf "waloml: [ERROR] %s colorsceme cannot be set!!\n" "$1" >&2; exit 1 ;}

# Function to echo while in process
process() { [ "$VERBOSE" = true ] && printf "waloml: %s colorsheme is applied!!\n" "$1"; }

# Function to change toml string value
write_toml() { tomlq -i -t "$1" "$(echo $2 | sed "s|~|$HOME|g")" >/dev/null || die "tomq cannot process the file $2"; }

# Load pywal colors
. "$PYWAL16_OUT_DIR/colors.sh"

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
  process "Dunst"
}

changeAlacrittyCONF() {
  write_toml "
.colors.primary.background = \"$color0\" |
.colors.primary.foreground = \"$color15\" |
.colors.cursor.text = \"$color0\" |
.colors.cursor.cursor = \"$color7\" |
.colors.vi_mode_cursor.text = \"$color0\" |
.colors.vi_mode_cursor.cursor = \"$color15\" |
.colors.search.matches.foreground = \"$color0\" |
.colors.search.matches.background = \"$color15\" |
.colors.search.focused_match.foreground = \"CellBackground\" |
.colors.search.focused_match.background = \"CellForeground\" |
.colors.line_indicator.foreground = \"None\" |
.colors.line_indicator.background = \"None\" |
.colors.footer_bar.foreground = \"$color15\" |
.colors.footer_bar.background = \"$color7\" |
.colors.selection.text = \"CellBackground\" |
.colors.selection.background = \"CellForeground\" |

.colors.normal.black = \"$color0\" |
.colors.normal.red = \"$color1\" |
.colors.normal.green = \"$color2\" |
.colors.normal.yellow = \"$color3\" |
.colors.normal.blue = \"$color4\" |
.colors.normal.magenta = \"$color5\" |
.colors.normal.cyan = \"$color6\" |
.colors.normal.white = \"$color7\" |

.colors.bright.black = \"$color8\" |
.colors.bright.red = \"$color9\" |
.colors.bright.green = \"$color10\" |
.colors.bright.yellow = \"$color11\" |
.colors.bright.blue = \"$color12\" |
.colors.bright.magenta = \"$color13\" |
.colors.bright.cyan = \"$color14\" |
.colors.bright.white = \"$color15\"" "$1"
  process "Alacritty"
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
