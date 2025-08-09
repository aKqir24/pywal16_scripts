#!/bin/bash

# Import all the scripts
SCRIPT_PATH="`dirname $0`/scripts"
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

# Check for required dependencies
command -v wal > /dev/null || echo "pywal16 is not installed, Please install it!"
if [ "$CONFIG_MODE" = true ]; then
	if ! command -v kdialog >/dev/null; then
		echo "kdialog is not installed, Please install it!"
		exit 1
	fi
fi

# Functions than is defined to handle disagreements, errors, and info's
verbose() { [ "$VERBOSE" = true ] && echo "walsetup: $1"; }
wallsetERROR() { kdialog --error "Failed to set wallpaper..."; exit 1; }
pywalerror() { kdialog --msgbox "pywal ran into an error!\nplease run 'bash $0 --gui' first" ; exit 1 ; }
wallSETTERError() { kdialog --msgbox "No Wallpaper setter found!\nSo wallpaper is not set..."; }
cancelCONFIG() { verbose "Configuration Gui was canceled!, it might cause some problems when loading the configuration!"; exit 0; }

# Check for PYWAL16_OUT_DIR
if [ -z "$PYWAL16_OUT_DIR" -o ! -d "$PYWAL16_OUT_DIR" ]; then
	kdialog --msgbox "The 'PYWAL16_OUT_DIR' environment variable is not defined!\n
	Adding it in your .bashrc file"
	echo "export PYWAL16_OUT_DIR=$DEFAULT_PYWAL16_OUT_DIR" >> "$HOME"/.bashrc || \
		$(kdialog --error "The 'PYWAL16_OUT_DIR' environment variable is not defined!\n
			You can define it in your '.bashrc', '.xinitrc', '.profile', etc. using:\n
			export PYWAL16_OUT_DIR=/path/to/folder" ; exit 1 )
	verbose "Setting up output directory"
fi

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

# Function to apply wallpaper using pywal16
applyWAL() {
	[ -z $4 ] && wallCYCLE="" || wallCYCLE="--$4"
	verbose "Running 'pywal' for colorscheme... " & generateGTKTHEME & generateICONSTHEME
	wal $wallCYCLE --backend "$2" -i "$1" $3 -n --out-dir "$PYWAL16_OUT_DIR" >/dev/null || pywalerror 
	reloadTHEMES &
}

# Apply gtk theme / reload gtk theme
generateGTKTHEME() {
	verbose "Generating & setting gtk theme!" &
	if [ "$wallpaperGTK" = true ]; then
		bash "$(dirname $0)/theming/gtk/generate.sh" "@color$wallpaperGTKAC"
	else
		rm -r "$HOME/.themes/pywal"
	fi
}

generateICONSTHEME() {
	verbose "Generating & setting icon theme!" &
	if [ "$wallpaperICONS" = true ]; then 
		bash "$(dirname $0)/theming/icons/generate.sh" "$wallpaperICONSCLR"
	else
		rm -r "$HOME/.icons/pywal"
	fi	
}

# Set Icon Theme's Name
setGTK_THEME() {
	verbose "Reloading Gtk Theme..."	
	if grep -q "^Net/ThemeName " $1; then
		sed -i 's|\(Net/ThemeName \)"[^"]*"|\1"pywal"|' $1
	else
		echo 'Net/ThemeName "pywal"' >> $1
	fi
}

setICON_THEME() {
	verbose "Reloading Icon Theme..."	
	if grep -q "^Net/IconThemeName  " $1; then
		sed -i 's|\(Net/IconThemeName \)"[^"]*"|\1"pywal"|' $1
	else
		echo 'Net/IconThemeName "pywal"' >> $1
	fi
}

# Reload Gtk themes using xsettingsd
reloadTHEMES() {
	local default_xsettings_config="$HOME/.xsettingsd.conf"
	local xsettingsd_config="$HOME/.config/xsettingsd/xsettingsd.conf"
	[ -f $xsettingsd_config ] || xsettingsd_config=$default_xsettings_config
	setGTK_THEME $xsettingsd_config & setICON_THEME $xsettingsd_config 
	command -v xsettingsd >/dev/null && pkill xsettingsd >/dev/null 2>&1 ;\
		xsettingsd -c $xsettingsd_config >/dev/null 2>&1 &
}

# Still pywalfox uses 'The Default OutDir in pywal so just link them to the default'
linkCONF_DIR() {	
	if [ -d "$DEFAULT_PYWAL16_OUT_DIR" ]; then
		for outFile in "$PYWAL16_OUT_DIR"/*; do
			local filename=$(basename "$outFile")
			if [ ! -e "$DEFAULT_PYWAL16_OUT_DIR/$filename" ]; then
				ln -s "$outFile" "$DEFAULT_PYWAL16_OUT_DIR/" >/dev/null
			fi
		done
	fi
}

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
