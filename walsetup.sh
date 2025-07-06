#!/bin/bash

# Manage Options
HELP_MESSAGE="
Usage: $0 [OPTIONS]
  --gui: To launch a configuration dialogs and apply the configurations.
  --verbose: To show log messages when each step of the script is executed.
  --help: to show how to use this script.
  *: 'not putting any options' loads/applies the configurations."

# Options To be used
OPTS=$(getopt -o -v --long verbose,gui,help -- "$@") ; eval set -- "$OPTS"
while true; do
	case "$1" in
		--gui) CONFIG_MODE=true; shift ;;
		--verbose) VERBOSE=true; shift ;;
		--help) echo "wallsetup: $HELP_MESSAGE"; shift;;
		--) shift; break ;;
	esac
done

# Check for required dependencies
command -v kdialog >/dev/null || { echo "kdialog is not installed. Please install it!"; exit 1; }

# Functions than is defined to handle disagreements, errors, and info's
verbose() { [ "$VERBOSE" = true ] && echo "walsetup: $1"; }
wallsetERROR() { kdialog --error "Failed to set wallpaper..."; exit 1; }
wallSETTERError() { kdialog --msgbox "No Wallpaper setter found!\nSo wallpaper is not set..."; }
cancelCONFIG() { verbose "Configuration Gui was canceled!, it might cause some problems when loading the configuration!"; exit 0; }

# Check for PYWAL16_OUT_DIR
DEFAULT_PYWAL16_OUT_DIR=$HOME/.cache/wal
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
WALLPAPER_CONF_PATH="$HOME/.config/walsetup.conf"
[ -e "$WALLPAPER_CONF_PATH" ] || touch "$WALLPAPER_CONF_PATH"
[ -d "$PYWAL16_OUT_DIR" ] || mkdir -p "$PYWAL16_OUT_DIR"

# Read/Write config
verbose "Reading config file"
assignTEMPCONF() {
    while IFS='=' read -r key val; do
        case "$key" in
						gtk_accent) wallpaperGTKAC=$val ;;
            gen_color16) wallpaperCLR16=$val ;;
            gtk_apply) wallpaperGTK=$val ;;
            select) wallpaperSELC=$val ;;
            wallpaper_path) wallpaperIMG=$val ;;
            type) wallpaperTYPE=$val ;;
            mode) wallpaperMODE=$val ;;
            backend) wallpaperBACK=$val ;;
        esac
    done < "$WALLPAPER_CONF_PATH"
}

assignTEMPCONF

# Function to apply wallpaper using pywal16
applyWAL() {
	verbose "Running 'pywal' for colorscheme... "
	wal --backend "$2" -i "$1" $3 -n --out-dir "$PYWAL16_OUT_DIR" >/dev/null || \
		$(kdialog --msgbox "pywal ran into an error!\nplease run bash $0 --gui first" ; exit 1)
	generateGTKTHEME
}

# Apply gtk theme / reload gtk theme
generateGTKTHEME() {
	verbose "Generating & setting gtk theme!"
	[ "$wallpaperGTK" = true ] && bash "$(dirname $0)/theming/gtk/generate.sh" "@color$wallpaperGTKAC"
	reloadGTK_ICONS &
}

# TODO: Generate Icon Color theme

# Reload Gtk themes using xsettingsd
reloadGTK_ICONS() {
	verbose "Reloading Gtk Theme..."
	local default_xsettings_config="$HOME/.xsettingsd.conf"
	local xsettingsd_config="$HOME/.config/xsettingsd/xsettingsd.conf"
	[ -f $xsettingsd_config ] || xsettingsd_config=$default_xsettings_config
	sed -i 's|\(Net/ThemeName \)"[^"]*"|\1"pywal"|' $xsettingsd_config
	command -v xsettingsd >/dev/null && pkill xsettingsd >/dev/null ;\
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

# Config labels
SETUPS=( wallSELC "Wallpaper Selection Method" on\
		  wallBACK "Pywal Backend To Use" off\
		  wallTYPE "Wallpaper Setup Type" on\
		  wallGTK "Gtk Theme Adaptation" on\
		  wallCLR16 "16 Color Output" on
)

BACKENDS=( wal wal on colorz colorz off haishoku haishoku off \
		   okthief okthief off modern_colorthief modern_colorthief off \
		   schemer2 schemer2 off colorthief colorthief off
)

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
				wallGTK) 
					unset WALL_GTK; WALL_GTK=true;\
					GTK_ACCENT_COLOR=$(kdialog --yesno "Change current gtk accent color?" && \
					kdialog --combobox "Gtk Accent Color:" "${GTKCOLORS[@]}" || echo "$wallpaperGTKAC" || cancelCONFIG )
					;;
        wallSELC)
          WALL_SELECT=$(kdialog --yes-label "Select Wallpaper" --no-label "Random Wallpaper" \
             --yesno "Changing your pywal Wallpaper Method?" && echo "static" || echo "random")
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
	WALL_GTK="$wallpaperGTK"
  WALL_BACK="$wallpaperBACK"
  WALL_SELECT="$wallpaperSELC"
  WALL_TYPE="$wallpaperTYPE"
  WALL_MODE="$wallpaperMODE"
	WALL_CLR16="$wallpaperCLR16"
fi

# Wallpaper selection
verbose "Identifying wallpaper mode!"
case "$WALL_SELECT" in
	"random")
		[ "$CONFIG_MODE" = true ] && WALL_CHANGE_FOLDER=$(kdialog --yesno "Do you want to change the random wallpaper folder?" && echo "YES")
		[ -d "$wallpaperIMG" ] && wallSTARTfolder=$wallpaperIMG || llSTARTfolder=$HOME 
		if [ ! -d "$wallpaperIMG" ]; then
			kdialog --msgbox "To use random wallpapers, you need to select a folder containing them."
			WALLPAPER_FOLDER=$(kdialog --getexistingdirectory "$wallSTARTfolder" || exit)
		elif [ "$WALL_CHANGE_FOLDER" = "YES" ]; then
			WALLPAPER_FOLDER=$(kdialog --getexistingdirectory "$wallSTARTfolder" || exit)
		else
			WALLPAPER_FOLDER="$wallpaperIMG"
		fi
		;;
	"static")
		[ "$CONFIG_MODE" = true ] && WALLPAPER=$(kdialog --getopenfilename "$PYWAL16_OUT_DIR" || echo "$wallpaperIMG") || WALLPAPER="$wallpaperIMG"
		;;
	"")	
		kdialog --msgbox "Wallpaper type is not configured!\nSo wallpaper is not set..."
		bash $0 --gui ; exit || rm WALLPAPER_PATH_TEMP
		;;
esac

# Save config then read it
saveCONFIG() {
	verbose "Saving configurations"
	[ -z "$WALL_BACK" ] && WALL_BACK="wal" &
	[ -z "$WALL_GTK_ACCENT_COLOR" ] && WALL_GTK_ACCENT_COLOR=2 &
	[ -z "$WALLPAPER" ] && [ -e "$WALLPAPER_FOLDER" ] && WALLPAPER="$WALLPAPER_FOLDER" &

cat > "$WALLPAPER_CONF_PATH" <<EOF
wallpaper_path=$WALLPAPER
type=$WALL_TYPE
mode=$WALL_MODE
select=$WALL_SELECT
backend=$WALL_BACK
gtk_apply=$WALL_GTK
gtk_accent=$GTK_ACCENT_COLOR
gen_color16=$WALL_CLR16
EOF

assignTEMPCONF
}

# Only save the config when configured!
[ "$CONFIG_MODE" = true ] && saveCONFIG

# Select a random wallpaper from folder or use static
[ -d "$WALLPAPER_FOLDER" ] && [ -d "$wallpaperIMG" ] && \
  wallpaperIMAGE=$(find "$wallpaperIMG" -type f | shuf -n 1) || wallpaperIMAGE="$wallpaperIMG"

[ -z "$WALL_CLR16" ] || [ -z "$wallpaperCLR16" ] && genCLR16op="" || verbose "Enabling 16 colors in pywal..." \
	genCLR16op="--cols16 $wallpaperCLR16"

# Function to apply wallpaper using various setters and mapped modes
set_wallpaper_with_mode() {
    local image_path="$1"

    # Mode mappings
    case "$wallpaperMODE" in
        "fill")
            local xWallMode="zoom"; local fehMode="fill"; local nitrogenMode="auto"; local swayMode="fill"
            local hsetrootMode="-fill"; local xfceMode=5; local gnomeMode="zoom"; local pcmanfmMode="fit"
            ;;
        "full")
            local xWallMode="maximize"; local fehMode="max"; local nitrogenMode="scaled"; local swayMode="fit"
            local hsetrootMode="-full"; local xfceMode=4; local gnomeMode="scaled"; local pcmanfmMode="stretch"
            ;;
        "tile")
            local xWallMode="tile"; local fehMode="tile"; local nitrogenMode="tiled"; local swayMode="tile"
            local hsetrootMode="-tile"; local xfceMode=1; local gnomeMode="wallpaper"; local pcmanfmMode="tile"
            ;;
        "center")
            local xWallMode="center"; local fehMode="centered"; local nitrogenMode="centered"; local swayMode="center"
            local hsetrootMode="-center"; local xfceMode=2; local gnomeMode="centered"; local pcmanfmMode="center"
            ;;
        "cover")
            local xWallMode="stretch"; local fehMode="scale"; local nitrogenMode="zoom"; local swayMode="stretch"
            local hsetrootMode="-full"; local xfceMode=5; local gnomeMode="zoom"; local pcmanfmMode="stretch"
            ;;
        *)
            local xWallMode="zoom"; local fehMode="fill"; local nitrogenMode="auto"; local swayMode="fill"
            local hsetrootMode="-fill"; local xfceMode=5; local gnomeMode="zoom"; local pcmanfmMode="fit"
            ;;
    esac
	
	# Set wallpaper with mode according to the available wallpaper setter
	local WALL_SETTERS=( xwallpaper hsetroot feh nitrogen swaybg xfconf-query gnome-shell pcmanfm )
	for wallSETTER in "${WALL_SETTERS[@]}"; do
		if command -v $wallSETTER >/dev/null; then
			local CH_WALLSETTER="$wallSETTER"
			break
		fi
	done
    case "$CH_WALLSETTER" in 
		"${WALL_SETTERS[0]}") xwallpaper "--$xWallMode" "$image_path" --daemon || wallsetERROR;;
        "${WALL_SETTERS[1]}") hsetroot "$hsetrootMode" "$image_path" || wallsetERROR;;
        "${WALL_SETTERS[2]}") feh --bg-"$fehMode" "$image_path" || wallsetERROR;;
        "${WALL_SETTERS[3]}") nitrogen --set-$nitrogenMode "$image_path" || wallsetERROR;;
        "${WALL_SETTERS[4]}") swaybg -i "$image_path" --mode "$swayMode" || wallsetERROR;;
		"${WALL_SETTERS[5]}")
			xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-style --set $xfceMode &&
			xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-path --set "$image_path" || \
			wallsetERROR 1
		;;
		"${WALL_SETTERS[6]}")
			gsettings set org.gnome.desktop.background picture-uri "file://$image_path" &&
			gsettings set org.gnome.desktop.background picture-options "$gnomeMode" || wallsetERROR
		;;
		"${WALL_SETTERS[7]}") pcmanfm --set-wallpaper "$image_path" --wallpaper-mode "$pcmanfmMode" || wallsetERROR ;;
		*) kdialog --error "No supported wallpaper setter found!" return 1 ;;
	esac
}

# Declare A variable and convert the image to png to avoid format errors in some wallpaper setters...
wallpaper_CACHE="$PYWAL16_OUT_DIR/wallpaper.png" ; [ -f "$wallpaper_CACHE" ] && rm $wallpaper_CACHE
case "$wallpaperIMAGE" in
	*.png) cp $wallpaperIMAGE $wallpaper_CACHE ;;
	*.gif) convert $wallpaperIMAGE -coalesce -flatten $wallpaper_CACHE >/dev/null ;;
	*)     convert $wallpaperIMAGE $wallpaper_CACHE >/dev/null ;;
esac

# Apply wallpaper colors with pywal16
callTOAPPLYpywal() {
	applyWAL "$wallpaper_CACHE" "$wallpaperBACK" "$genCLR16op" || \
		$( kdialog --msgbox "Backend is not found, using default instead!!" ; 
			 applyWAL "$wallpaper_CACHE" "wal" "$genCLR16op" )
}

# set the wallpaperIMAGE in display
setwallpaperTYPE() {
	verbose "Settings wallpaper..."
	case "$wallpaperTYPE" in
		"Solid")
			local solidwallpaperCACHE=$PYWAL16_OUT_DIR/wallpaper.solid.png
			[ -f "${PYWAL16_OUT_DIR}/colors.sh" ] && . "${PYWAL16_OUT_DIR}/colors.sh"
			convert -size 80x80 xc:"$color8" "$solidwallpaperCACHE"
			set_wallpaper_with_mode "$solidwallpaperCACHE" || wallSETTERError
			;;
		"Image") set_wallpaper_with_mode "$wallpaper_CACHE" || wallSETTERError ;;
		*) kdialog --msgbox "Wallpaper type is not configured!\nSo wallpaper is not set...";; 
	esac
}

# Finalize Process and making them faster by Functions
setwallpaperTYPE & linkCONF_DIR & callTOAPPLYpywal
verbose "Process finished!!"
