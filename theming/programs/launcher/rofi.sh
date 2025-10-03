#!/bin/sh

# Verify the import in the config file
ROFI_THEME_FILE=$HOME/.config/rofi/colors.rasi
[ -e $ROFI_THEME_FILE ] || touch $ROFI_THEME_FILE
grep -q '@import "colors.rasi"' "$1" || echo "$ROFI_THEME_FILE" >> "$1"

cat > $ROFI_THEME_FILE <<EOF
*{
	/* Colorscheme */
	background-alt:					$color8;
	background:						$color0;
	foreground:						$color15;
	selected:						$color2;
	active:							$color2;
	urgent:							$color3;
	alert:							$color1;
	disabled:						$color7;
}

EOF
