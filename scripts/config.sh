#!/bin/bash

# Default Config Values
VERBOSE=false
CONFIG_MODE=false
DEFAULT_PYWAL16_OUT_DIR=$HOME/.cache/wal
WALLPAPER_CONF_PATH="$HOME/.config/walsetup.conf"
wallpaper_CACHE="$PYWAL16_OUT_DIR/wallpaper.png"

# Write config file
verbose "Writting & verifying config file"
[ -e "$WALLPAPER_CONF_PATH" ] || touch "$WALLPAPER_CONF_PATH"
[ -d "$PYWAL16_OUT_DIR" ] || mkdir -p "$PYWAL16_OUT_DIR"

# Read/Write config
verbose "Reading config file"
assignTEMPCONF() {
    while IFS='=' read -r key val; do
        case "$key" in
			gtk_accent) wallpaperGTKAC=$val ;;
            gen_color16) wallpaperCLR16=$val ;;
            gtk_theme) wallpaperGTK=$val ;;
			icon_theme_mode) wallpaperICONSCLR=$val ;;
			icon_theme) wallpaperICONS=$val ;;
            wallpaper_path) wallpaperIMG=$val ;;
			wallpaper_cycle) wallpaperCYCLE=$val ;;
            type) wallpaperTYPE=$val ;;
            mode) wallpaperMODE=$val ;;
            backend) wallpaperBACK=$val ;;
        esac
    done < "$WALLPAPER_CONF_PATH"
}

assignTEMPCONF

# Save config then read it
saveCONFIG() {
	verbose "Saving configurations"
	[ -z "$WALL_BACK" ] && WALL_BACK="wal"
	[ -z "$WALL_GTK_ACCENT_COLOR" ] && WALL_GTK_ACCENT_COLOR=2
	[ -z "$WALLPAPER" ] && [ -d "$WALLPAPER_FOLDER" ] && WALLPAPER="$WALLPAPER_FOLDER"
	
	conf_variables=( wallpaper_path wallpaper_cycle type mode backend gtk_theme gtk_accent gen_color16 icon_theme icon_theme_mode )
	for v in ${conf_variables[@]}; do
		grep -q "^$v=" $WALLPAPER_CONF_PATH || echo "$v=" >> $WALLPAPER_CONF_PATH
	done

	sed -i \
		-e 's|\('${conf_variables[0]}'=\)[^ ]*|\1'$WALLPAPER'|' \
		-e 's|\('${conf_variables[1]}'=\)[^ ]*|\1'$WALL_CYCLE'|' \
		-e 's|\('${conf_variables[2]}'=\)[^ ]*|\1'$WALL_TYPE'|' \
		-e 's|\('${conf_variables[3]}'=\)[^ ]*|\1'$WALL_MODE'|' \
		-e 's|\('${conf_variables[4]}'=\)[^ ]*|\1'$WALL_BACK'|' \
		-e 's|\('${conf_variables[5]}'=\)[^ ]*|\1'$WALL_GTK'|' \
		-e 's|\('${conf_variables[6]}'=\)[^ ]*|\1'$GTK_ACCENT_COLOR'|' \
		-e 's|\('${conf_variables[7]}'=\)[^ ]*|\1'$WALL_CLR16'|' \
		-e 's|\('${conf_variables[8]}'=\)[^ ]*|\1'$WALL_ICONS'|' \
		-e 's|\('${conf_variables[9]}'=\)[^ ]*|\1'$WALL_ICONS_MODE'|' \
		$WALLPAPER_CONF_PATH
    assignTEMPCONF
}
