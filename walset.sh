#!/bin/bash

# Import all the scripts
SCRIPT_PATH="$(dirname "$0")/scripts"
SCRIPT_FILES=(paths messages config startup wallpaper apply)
for script in "${SCRIPT_FILES[@]}"; do . "$SCRIPT_PATH/$script.sh"; done

# Options To be used
OPTS=$(getopt -o -v --long verbose,reset,load,setup,gui,help -- "$@") ; eval set -- "$OPTS"
while true; do
	case "$1" in
		--verbose) VERBOSE=true; shift ;;
		--gui) GUI=true; shift;;
		--setup) SETUP=true; shift;;
		--reset) RESET=true; shift ;;
		--load) LOAD=true; shift;;
		--help) echo "$HELP_MESSAGE"; exit 0;;
		--) shift; break ;;
	esac
done

# Verify reset option
$RESET && . "$SCRIPT_PATH/reset.sh"

# GUI dialog Configuration
if $GUI && $SETUP; then
	VERBOSE=true ; verbose "You can only select one of the config optios." ; exit 1
elif $SETUP; then
	. "$SCRIPT_PATH/dialogs.sh"
elif $GUI; then
	VERBOSE=true ; verbose "The '--gui' option is still in development..." ; exit 1
else
	if $LOAD; then
		verbose "Using the previously configured settings" ; assignTEMPCONF 
	else
		$RESET || echo "$HELP_MESSAGE"; exit 0	
	fi
fi

# Only save the config when configured!
[ "$SETUP" = true ] || [ "$GUI" = true ] && saveCONFIG ; assignTEMPCONF

# Check if --color16 option is enabled
$pywal16_light && verbose "Enabling 16 colors in pywal..."; \
	PYWAL_GENERATE_LIGHT="--cols16 $pywal16_colorscheme"

# call the pywal to get colorsheme
applyWAL "$wallpaper_path" "$pywal16_backend" "$PYWAL_GENERATE_LIGHT" "$wallpaper_cycle" || \
	$( kdialog --msgbox "Backend is not found, using default instead!!" ; 
		 applyWAL "$wallpaper_path" "wal" "$PYWAL_GENERATE_LIGHT" "$wallpaper_cycle" )

# Make a wallpaper cache to expand the features in setting the wallpaper
[ -f "${PYWAL16_OUT_DIR}/colors.sh" ] && . "${PYWAL16_OUT_DIR}/colors.sh"
[ -f "$WALLPAPER_CACHE" ] && rm "$WALLPAPER_CACHE"

# Finalize Process and making them faster by Functions
linkCONF_DIR & select_wallpaper ; setup_wallpaper && verbose "Process finished!!"	
