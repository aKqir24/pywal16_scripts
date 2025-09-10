#!/bin/bash

# Import all the scripts
SCRIPT_PATH="$(dirname $0)/scripts"
SCRIPT_FILES=(messages config startup wallpaper apply)
for script in ${SCRIPT_FILES[@]}; do . "$SCRIPT_PATH/$script.sh"; done

# Options To be used
OPTS=$(getopt -o -v --long verbose,gui,help -- "$@") ; eval set -- "$OPTS"
while true; do
	case "$1" in
		--gui) CONFIG_MODE=true; shift ;;
		--verbose) VERBOSE=true; shift ;;
		--help) echo "wallsetup: $HELP_MESSAGE"; exit 0; shift;;
		--) shift; break ;;
	esac
done

# GUI dialog Configuration
if [ "$CONFIG_MODE" = true ]; then
	. "$SCRIPT_PATH/dialogs.sh"
	else
	verbose "Using the previously configured settings"
	assignTEMPCONF ; select_wallpaper 
fi

# Only save the config when configured!
[ "$CONFIG_MODE" = true ] && saveCONFIG ; assignTEMPCONF

# Check if --color16 option is enabled
[ "$pywal16_light" = true ] && verbose "Enabling 16 colors in pywal..."; \
	PYWAL_GENERATE_LIGHT="--cols16 $pywal_colorscheme"

# call the pywal to get colorsheme
applyWAL "$wallpaper_path" "$pywal16_backend" "$PYWAL_GENERATE_LIGHT" "$wallpaper_cycle" || \
	$( kdialog --msgbox "Backend is not found, using default instead!!" ; 
		 applyWAL "$wallpaper_path" "wal" "$PYWAL_GENERATE_LIGHT" "$wallpaper_cycle" )

# Make a wallpaper cache to expand the features in setting the wallpaper
[ -f "${PYWAL16_OUT_DIR}/colors.sh" ] && . "${PYWAL16_OUT_DIR}/colors.sh"
[ -f "$WALLPAPER_CACHE" ] && rm $WALLPAPER_CACHE
case "$wallpaper" in
	*.png) cp $wallpaper $WALLPAPER_CACHE ;;
	*.gif) convert $wallpaper -coalesce -flatten $WALLPAPER_CACHE>/dev/null ;;
	*)  convert $wallpaper $WALLPAPER_CACHE>/dev/null
esac

# Finalize Process and making them faster by Functions
linkCONF_DIR & setup_wallpaper && verbose "Process finished!!"	
