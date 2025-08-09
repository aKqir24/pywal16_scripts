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

# Config option labels
SETUPS=(  wallBACK "Backend In Use" off \
		  wallTYPE "Setting Wallpaper" on \
		  wallGTK "Install Gtk Theme" off \
		  wallICONS "Install Icon Theme" off \
		  wallCLR16 "Generate Light Colors" on )

BACKENDS=(	"wal" "colorz" "haishoku" "okthief" \
			"modern_colorthief" "schemer2" "colorthief" )

TYPE=( none "None" off solid "Solid" off image "Image" on )
MODE=( center "Center" off fill "Fill" on tile "Tile" off full "Full" off cover "Scale" off )
GTKCOLORS=() ; for color_no in {0..15}; do GTKCOLORS+=($color_no) ;done

# GUI dialog Configuration
if [ "$CONFIG_MODE" = true ]; then	
	verbose "Running kdialog for configuration..."
	ToCONFIG=$( kdialog --checklist "Available Configs" "${SETUPS[@]}" --separate-output )
	assignTEMPCONF >/dev/null ; select_wallpaper ; [ -z "$ToCONFIG" ] && cancelCONFIG
	theming_values() {
		THEME_MODE=$( kdialog --yes-label "Light" --no-label "Dark" \
					  --yesno "Select an theme mode, it can be either:" && echo "light" || echo "dark")
		THEME_ACCENT=$( kdialog --yesno "Change current gtk accent color?" && \
						kdialog --combobox "Gtk Accent Color:" "${GTKCOLORS[@]}" || \
						echo "$theming_accent" || cancelCONFIG )
	}
    for config in $ToCONFIG; do
		if [ $config = wallGTK -o $config = wallICONS ]; then
			theming_values >/dev/null ; unset -f theming_values
			theming_values() { echo "" ; }	
		fi
		case "$config" in
			wallICONS) unset THEMING_ICONS ; THEMING_ICONS=true ;;
			wallGTK) unset THEMING_GTK ; THEMING_GTK=true ;;
			wallBACK) PYWAL_BACKEND=$(kdialog --combobox "Pywal Backend In Use" "${BACKENDS[@]}" || cancelCONFIG ) ;;
			wallTYPE)
				WALLPAPER_TYPE=$(kdialog --radiolist "Wallpaper Setup Type" "${TYPE[@]}" || cancelCONFIG)
				WALLPAPER_MODE=$(kdialog --radiolist "Wallpaper Setup Mode" "${MODE[@]}" || exit 0) ;;
			wallCLR16)
				unset PYWAL_LIGHT ; PYWAL_LIGHT=true
				PYWAL_COLORSCHEME=$(kdialog --yes-label "Darken" --no-label "Lighten" --yesno \
				"Generating 16 Colors must be either:" && echo "darken" || echo "lighten" ) ;;
        esac
    done
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
