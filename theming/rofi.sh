#!/bin/sh
ROFI_THEME_FILE=$HOME/.config/rofi/colors.rasi
[ -e $ROFI_THEME_FILE ] || touch $ROFI_THEME_FILE
if . "${PYWAL16_OUT_DIR}/colors.sh"; then
  echo "Wal Colors Script Found!!, exporting..."
else
  die "Wal colors not found, exiting script. Have you executed Wal before?"
fi
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

echo Colorsheme is Applied!!
