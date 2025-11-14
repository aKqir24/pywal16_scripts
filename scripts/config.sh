#!/bin/bash

# Default options config values
VERBOSE=false SETUP=false GUI=false LOAD=false

# Write config file
verbose "Writting & verifying config file"
[ -e "$WALLPAPER_CONF_PATH" ] || touch "$WALLPAPER_CONF_PATH"
[ -d "$PYWAL16_OUT_DIR" ] || mkdir -p "$PYWAL16_OUT_DIR"

# Read the config
verbose "Reading config file"
assignTEMPCONF() {
	tables=('wallpaper' 'theming' 'pywal16')
	JSON_TOML_OUTPUT=$( tomlq '.' "$WALLPAPER_CONF_PATH" )
	reader() { jq -r ".$1" <<< "$JSON_TOML_OUTPUT" ; }
	for section in "${tables[@]}"; do
		case $section in
			"${tables[0]}") keys=( "cycle" "type" "path" "mode" "animated" ) ;;
			"${tables[1]}") keys=( "gtk" "icons" "mode" "accent" ) ;;
			"${tables[2]}") keys=( "backend" "light" "colorscheme" ) ;;
		esac
		for key in "${keys[@]}"; do
			value="$(reader "$section"."$key")"
			declare -g "${section}_$key=$value"	
		done
	done
}

# Save config then read it
saveCONFIG() {
	verbose "Saving configurations"
	[ -z "$ANIMATED_WALLPAPER" ] && ANIMATED_WALLPAPER=false
	[ -z "$PYWAL_BACKEND" ] && PYWAL_BACKEND="wal"
	[ -z "$WALLPAPER_CYCLE" ] && WALLPAPER_CYCLE="static"
	[ -z "$THEME_MODE" ] && THEME_MODE="dark"
	[ -z "$THEME_ACCENT" ] && THEME_ACCENT_COLOR="color2" || \
		THEME_ACCENT_COLOR="color$THEME_ACCENT"

	tomlq -i -t "
		.wallpaper.cycle = \"$WALLPAPER_CYCLE\" |
		.wallpaper.type = \"$WALLPAPER_TYPE\" |
		.wallpaper.path = \"$WALLPAPER_PATH\" |
		.wallpaper.mode = \"$WALLPAPER_MODE\" |
		.wallpaper.animated = $ANIMATED_WALLPAPER |
		.theming.gtk = $THEMING_GTK |
		.theming.icons = $THEMING_ICONS |
		.theming.mode = \"$THEME_MODE\" |
		.theming.accent = \"$THEME_ACCENT_COLOR\" |
		.pywal16.backend = \"$PYWAL_BACKEND\" |
		.pywal16.light = $PYWAL_LIGHT |
		.pywal16.colorscheme = \"$PYWAL_COLORSCHEME\"" \
			"$WALLPAPER_CONF_PATH"
}
