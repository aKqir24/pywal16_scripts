# Config option labels
SETUPS=( wallBACK "Backend In Use" off \
		 wallTYPE "Set Wallpaper" on \
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
