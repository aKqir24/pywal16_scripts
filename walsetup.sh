#!/bin/bash

# Import all the scripts
SCRIPT_PATH="$(pwd)/scripts"
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
SETUPS=(  wallSELC "Wallpaper Selection Method" on\
		  wallBACK "Pywal Backend To Use" off\
		  wallTYPE "Wallpaper Setup Type" on\
		  wallGTK "Gtk Theme Adaptation" on\
		  wallICONS "Icon Theme Adaptation" on \
		  wallCLR16 "16 Color Output" on )

BACKENDS=( wal wal on colorz colorz off haishoku haishoku off \
		   okthief okthief off modern_colorthief modern_colorthief off \
		   schemer2 schemer2 off colorthief colorthief off )

TYPE=( "None" "Solid" "Image" )
MODE=( center "Center" off fill "Fill" on tile "Tile" off full "Full" off cover "Scale" off )
GTKCOLORS=() ; for clrno in {0..15}; do GTKCOLORS+=($clrno) ;done

# GUI Configuration
if [ "$CONFIG_MODE" = true ]; then	
	verbose "Running kdialog for configuration..."
	ToCONFIG=$( kdialog --checklist "Available Configs" "${SETUPS[@]}" --separate-output )
	[ -z "$ToCONFIG" ] && cancelCONFIG
    for config in $ToCONFIG; do
      case "$config" in
		wallICONS) unset WALL_ICONS ; WALL_ICONS=true \
			WALL_ICONS_MODE=$(kdialog --yes-label "light" --no-label "dark" \
			--yesno "Select an icon mode, it can be either:" && echo "dark" || echo "light")
		;;
		wallGTK) 
		  unset WALL_GTK; WALL_GTK=true\
		  GTK_ACCENT_COLOR=$(kdialog --yesno "Change current gtk accent color?" && \
			kdialog --combobox "Gtk Accent Color:" "${GTKCOLORS[@]}" || \
			[ -z "$wallpaperGTKAC" ] && echo 2 || echo "$wallpaperGTKAC" || cancelCONFIG )
		  ;;
        wallSELC)
          WALL_SELECT=$(kdialog --yes-label "From Image" --no-label "From Folder" \
             --yesno "Changing your pywal Wallpaper Method?" && echo "image" || echo "folder")
          ;;
        wallBACK)
          WALL_BACK=$(kdialog --radiolist "Pywal Backend In Use" "${BACKENDS[@]}" || cancelCONFIG )
          ;;
        wallTYPE)
          WALL_TYPE=$(kdialog --combobox "Wallpaper Setup Type" "${TYPE[@]}" || cancelCONFIG )
          [ "$WALL_TYPE" = "Image" ] && \
          	WALL_MODE=$(kdialog --radiolist "Wallpaper Setup Mode" ${MODE[@]} || exit 0) || WALL_MODE=none
          ;;
		wallCLR16)
			WALL_CLR16=$(kdialog --yes-label "Darken" --no-label "Lighten" \
			--yesno "Generating 16 Colors must be either:" && echo "darken" || echo "lighten" )
		  ;;
        esac
    done
else
	verbose "Using the previously configured settings"
	GTK_ACCENT_COLOR="$wallpaperGTKAC"
	WALL_ICONS_MODE="$wallpaperICONSCLR"
	WALL_ICONS="$wallpaperICONS"
	WALL_GTK="$wallpaperGTK"
	WALL_BACK="$wallpaperBACK"
	WALL_TYPE="$wallpaperTYPE"
	WALL_MODE="$wallpaperMODE"
	WALL_CLR16="$wallpaperCLR16"
	WALL_CYCLE="$wallpaperCYCLE"
fi

# Wallpaper selection
verbose "Identifying wallpaper mode!"
if [ "$CONFIG_MODE" = "false" ] && [ -z "$WALL_SELECT" ]; then
	[ -d "$wallpaperIMG" ] && WALL_SELECT="folder"
	[ -f "$wallpaperIMG" ] && WALL_SELECT="image"
fi

case "$WALL_SELECT" in
	"folder")
		if [ "$CONFIG_MODE" = true ]; then
			WALL_CHANGE_FOLDER=$(kdialog --yesno "Do you want to change the wallpaper folder?" && echo "YES")
			WALL_CYCLE=$(kdialog --yes-label "Orderly" --no-label "Randomly" --yesno \
				"How to choose you wallpaper in a folder?" && echo "iterative" || echo "recursive" )
		fi
		[ -d "$wallpaperIMG" ] && wallSTARTfolder=$wallpaperIMG || llSTARTfolder=$HOME 
		if [ ! -d "$wallpaperIMG" ]; then
			kdialog --msgbox "To use random wallpapers, you need to select a folder containing them."
			WALLPAPER_FOLDER=$(kdialog --getexistingdirectory "$wallSTARTfolder" || exit 0)
		elif [ "$WALL_CHANGE_FOLDER" = "YES" ]; then
			WALLPAPER_FOLDER=$(kdialog --getexistingdirectory "$wallSTARTfolder" || exit 0)
		else
			WALLPAPER_FOLDER="$wallpaperIMG"
		fi
		;;
	"image")
		[ "$CONFIG_MODE" = true ] && WALLPAPER=$(kdialog --getopenfilename "$PYWAL16_OUT_DIR" || echo "$wallpaperIMG") || WALLPAPER="$wallpaperIMG"
		;;
	*)
		kdialog --msgbox "Wallpaper type is not configured!\nSo wallpaper is not set..."
		bash $0 --gui ; exit || rm WALLPAPER_PATH_TEMP
		;;
esac

# Only save the config when configured!
[ "$CONFIG_MODE" = true ] && saveCONFIG ;

# Check if --color16 option is enabled
[ -z "$wallpaperCLR16" ] && genCLR16op="" || verbose "Enabling 16 colors in pywal..."; \
	genCLR16op="--cols16 $wallpaperCLR16"

# call the pywal to get colorsheme
applyWAL "$wallpaperPATH" "$wallpaperBACK" "$genCLR16op" "$wallpaperCYCLE" || \
	$( kdialog --msgbox "Backend is not found, using default instead!!" ; 
		 applyWAL "$wallpaperPATH" "wal" "$genCLR16op" "$wallpaperCYCLE" )

# Make a wallpaper cache to expand the features in setting the wallpaper
[ -f "${PYWAL16_OUT_DIR}/colors.sh" ] && . "${PYWAL16_OUT_DIR}/colors.sh"
[ -f "$wallpaper_CACHE" ] && rm $wallpaper_CACHE
case "$wallpaper" in
	*.png) cp $wallpaper $wallpaper_CACHE ;;
	*.gif) convert $wallpaper -coalesce -flatten $wallpaper_CACHE >/dev/null ;;
	*)     convert $wallpaper $wallpaper_CACHE >/dev/null ;;
esac

# Finalize Process and making them faster by Functions
linkCONF_DIR & setwallpaperTYPE && verbose "Process finished!!"	
