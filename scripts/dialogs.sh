# Config option labels
SETUPS=( wallBACK "Backend In Use" off \
		 wallTYPE "Set Wallpaper" on \
		 wallANIM "Animated Wallpapers" on \
		 wallGTK "Install Gtk Theme $GTK_INS_TAG" off \
		 wallICONS "Install Icon Theme $ICON_INS_TAG" off \
		 wallCLR16 "Generate Light Colors" on )

	BACKENDS=(	"wal" "colorz" "haishoku" "okthief" \
				"modern_colorthief" "schemer2" "colorthief" )

	TYPE=( none "None" off solid "Solid" off image "Image" on )
	MODE=( center "Center" off fill "Fill" on tile "Tile" off full "Full" off cover "Scale" off )
	GTKCOLORS=() && for color_number in {0..15}; do GTKCOLORS+=($color_number) ; done

# Start Configuration dialogs
verbose "Running kdialog for configuration..." &
ToCONFIG=$( kdialog --checklist "Available Configs" "${SETUPS[@]}" --separate-output )
assignTEMPCONF >/dev/null && [ -z "$ToCONFIG" ] && cancelCONFIG ; select_wallpaper
theming_values() {
	THEME_MODE=$( kdialog --yes-label "Light" --no-label "Dark" \
				  --yesno "Select an theme mode, it can be either:" && echo "light" || echo "dark")
	THEME_ACCENT=$( kdialog --yesno "Change current gtk accent color?" && \
					kdialog --combobox "Gtk Accent Color:" "${GTKCOLORS[@]}" || \
					echo "$theming_accent" || cancelCONFIG )
}

# Configuration Dialogs
for config in $ToCONFIG; do
	if [ $config = wallGTK -o $config = wallICONS ]; then
		theming_values >/dev/null ; unset -f theming_values
		theming_values() { echo "" ; }	
	fi
	case "$config" in
		wallICONS) unset THEMING_ICONS ; THEMING_ICONS=true ;;
		wallGTK) unset THEMING_GTK ; THEMING_GTK=true ;;
		wallANIM) unset ANIMATED_WALLPAPER ; ANIMATED_WALLPAPER=true ;;
		wallBACK) PYWAL_BACKEND=$(kdialog --combobox "Pywal Backend In Use" "${BACKENDS[@]}" || cancelCONFIG ) ;;
		wallTYPE)
			WALLPAPER_TYPE=$(kdialog --radiolist "Wallpaper Setup Type" "${TYPE[@]}" || cancelCONFIG)
			WALLPAPER_MODE=$(kdialog --radiolist "Wallpaper Setup Mode" "${MODE[@]}" || cancelCONFIG) ;;
		wallCLR16)
			unset PYWAL_LIGHT ; PYWAL_LIGHT=true
			PYWAL_COLORSCHEME=$(kdialog --yes-label "Darken" --no-label "Lighten" --yesno \
			"Generating 16 Colors must be either:" && echo "darken" || echo "lighten" ) ;;
    esac
done

# Wallpaper select config
wall_select_options() {
	case "$WALL_SELECT" in
		"folder")
			if [ "$SETUP" = true ]; then
				WALLPAPER_CYCLE=$( kdialog --yes-label "Orderly" --no-label "Randomly" --yesno \
							"How to choose you wallpaper in a folder?" && echo "iterative" || echo "recursive" )
				WALL_CHANGE_FOLDER=$(kdialog --yesno "Do you want to change the wallpaper folder?" && echo "YES")	
			fi
			[ -d "$wallpaper_path" ] && START_FOLDER=$wallpapers_path || START_FOLDER=$HOME
			if [ "$WALL_CHANGE_FOLDER" = "YES" ]; then
				WALLPAPER_FOLDER=$(kdialog --getexistingdirectory "$START_FOLDER" || exit 0)
			elif [ ! -d "$wallpaper_path" ]; then
				kdialog --msgbox "To set wallpapers from a directory, you need to select a folder containing them."
				WALLPAPER_FOLDER=$(kdialog --getexistingdirectory "$START_FOLDER" || exit 0)	
			fi
			;;
		"image")
			[ "$SETUP" = true ] && WALLPAPER_IMAGE=$(kdialog --getopenfilename \
				"$START_FOLDER" || echo "$wallpaper_path")
			;;
		*)
			kdialog --msgbox "Wallpaper type is not configured!\nSo wallpaper is not set..."
			bash $0 --setup ; exit || rm $WALLPAPER_CACHE
	esac
}
