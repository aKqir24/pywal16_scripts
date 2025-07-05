#!/bin/bash

# Manage Options
HELP_MESSAGE="
Usage: $0 [OPTIONS]
  --gui: To launch a configuration dialogs and apply the configurations.
  --verbose: To show log messages when each step of the script is executed.
  --help: to show how to use this script.
  *: 'not putting any options' loads/applies the configurations."

OPTS=$(getopt -o -v --long verbose,gui,help -- "$@")
eval set -- "$OPTS"
while true; do
	case "$1" in
		--gui) CONFIG_MODE=true; shift ;;
		--verbose) VERBOSE=true; shift ;;
		--help) echo "wallsetup: $HELP_MESSAGE"; shift;;
		--) shift; break ;;
	esac
done

#kdialog --msgbox "Please launch the GUI for configuration: \n$0 --gui"
# Check for required dependencies
verbose() { [ "$VERBOSE" = true ] && echo "walsetup: $1"; }
command -v kdialog >/dev/null || { echo "kdialog is not installed. Please install it!"; exit 1; } 
DEFAULT_PYWAL16_OUT_DIR=$HOME/.cache/wal
# Check for PYWAL16_OUT_DIR
if [ -z "$PYWAL16_OUT_DIR" ]; then
	kdialog --msgbox "The 'PYWAL16_OUT_DIR' environment variable is not defined!\n
	Adding it in your .bashrc file"
	echo "export PYWAL16_OUT_DIR=$DEFAULT_PYWAL16_OUT_DIR" >> "$HOME"/.bashrc || \
		$(kdialog --error "The 'PYWAL16_OUT_DIR' environment variable is not defined! 
			You can define it in your '.bashrc', '.xinitrc', '.profile', etc. using:
			export PYWAL16_OUT_DIR=/path/to/folder" ; exit 1 )
	verbose "Setting up output directory"
fi

# Write config file
verbose "Writting & verifying config file"
WALLPAPER_CONF_PATH="$HOME/.config/walsetup.conf"
[ -e "$WALLPAPER_CONF_PATH" ] || touch "$WALLPAPER_CONF_PATH"
# Expand $PYWAL16_OUT_DIR
PYWAL16_OUT_DIR=$(eval echo "$PYWAL16_OUT_DIR")
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
	rm -r $DEFAULT_PYWAL16_OUT_DIR
	wal --backend "$2" -i "$1" $3 -n --out-dir "$PYWAL16_OUT_DIR" >/dev/null || \
		$(kdialog --msgbox "pywal ran into an error!\nplease run bash $0 --gui first" ; exit 1)

	# Still pywalfox uses 'The Default OutDir in pywal so just link them to the default'
	if [ -d "$DEFAULT_PYWAL16_OUT_DIR" ]; then
		for outFile in "$PYWAL16_OUT_DIR"/*; do
			filename=$(basename "$outFile")
			if [ ! -e "$DEFAULT_PYWAL16_OUT_DIR/$filename" ]; then
				ln -s "$outFile" "$DEFAULT_PYWAL16_OUT_DIR/" >/dev/null
			fi
		done
	fi

	# Apply gtk theme
	verbose "Generating & setting gtk theme!"
	[ "$wallpaperGTK" = true ] && bash "$(dirname $0)/theming/gtk/generate.sh" "@color$wallpaperGTKAC"
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
	cancelCONFIG() { verbose "Configuration Gui was canceled!, it might cause some problems when loading the configuration!"; exit 0; }
	ToCONFIG=$( kdialog --checklist "Available Configs" "${SETUPS[@]}" --separate-output )
	[ -z "$ToCONFIG" ] && cancelCONFIG
    for config in $ToCONFIG; do
        case "$config" in
			wallGTK) 
				unset WALL_GTK; WALL_GTK=true;\
				GTK_ACCENT_COLOR=$(kdialog --combobox "Gtk Accent Color:" "${GTKCOLORS[@]}" || cancelCONFIG ) 
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
                ;;
			wallCLR16)
				WALL_CLR16=$(kdialog --yes-label "Darken" --no-label "Lighten" \
					--yesno "Generating 16 Colors must be either:" && echo "darken" || echo "lighten" )
				;;
        esac
    done

    [ "$WALL_TYPE" = "Image" ] && \
		WALL_MODE=$(kdialog --radiolist "Wallpaper Setup Mode" ${MODE[@]} || exit 0) || WALL_MODE=none

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

# Save config
verbose "Saving configurations"
[ -z "$WALL_BACK" ] && WALL_BACK="wal"
[ -z "$WALL_GTK_ACCENT_COLOR" ] && WALL_GTK_ACCENT_COLOR=2
[ -z "$WALLPAPER" ] && [ -e "$WALLPAPER_FOLDER" ] && WALLPAPER="$WALLPAPER_FOLDER" 

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

# Select a random wallpaper from folder or use static
if [ -d "$WALLPAPER_FOLDER" ] && [ -d "$wallpaperIMG" ]; then
    wallpaperIMAGE=$(find "$wallpaperIMG" -type f | shuf -n 1)
else
    wallpaperIMAGE="$wallpaperIMG"
fi

if [ -z "$WALL_CLR16" ] || [ -z "$wallpaperCLR16" ] ; then
	genCLR16op=""
else
	verbose "Enabling 16 colors in pywal..."
	genCLR16op="--cols16 $wallpaperCLR16"
fi

# Set background
wallsetERROR() { kdialog --error "Failed to set wallpaper..."; exit 1; }
# Function to apply wallpaper using various setters and mapped modes
set_wallpaper_with_mode() {
    local image_path="$1"

    # Mode mappings
    case "$wallpaperMODE" in
        "fill")
            xWallMode="zoom"; fehMode="fill"; nitrogenMode="auto"; swayMode="fill"
            hsetrootMode="-fill"; xfceMode=5; gnomeMode="zoom"; pcmanfmMode="fit"
            ;;
        "full")
            xWallMode="maximize"; fehMode="max"; nitrogenMode="scaled"; swayMode="fit"
            hsetrootMode="-full"; xfceMode=4; gnomeMode="scaled"; pcmanfmMode="stretch"
            ;;
        "tile")
            xWallMode="tile"; fehMode="tile"; nitrogenMode="tiled"; swayMode="tile"
            hsetrootMode="-tile"; xfceMode=1; gnomeMode="wallpaper"; pcmanfmMode="tile"
            ;;
        "center")
            xWallMode="center"; fehMode="centered"; nitrogenMode="centered"; swayMode="center"
            hsetrootMode="-center"; xfceMode=2; gnomeMode="centered"; pcmanfmMode="center"
            ;;
        "cover")
            xWallMode="stretch"; fehMode="scale"; nitrogenMode="zoom"; swayMode="stretch"
            hsetrootMode="-full"; xfceMode=5; gnomeMode="zoom"; pcmanfmMode="stretch"
            ;;
        *)
            xWallMode="zoom"; fehMode="fill"; nitrogenMode="auto"; swayMode="fill"
            hsetrootMode="-fill"; xfceMode=5; gnomeMode="zoom"; pcmanfmMode="fit"
            ;;
    esac
	
    if command -v xwallpaper >/dev/null; then
        xwallpaper "--$xWallMode" "$image_path" --daemon || wallsetERROR
    elif command -v hsetroot >/dev/null; then
        hsetroot "$hsetrootMode" "$image_path" || wallsetERROR
    elif command -v feh >/dev/null; then
        feh --bg-"$fehMode" "$image_path" || wallsetERROR
    elif command -v nitrogen >/dev/null; then
        nitrogen --set-$nitrogenMode "$image_path" || wallsetERROR
    elif command -v swaybg >/dev/null; then
        swaybg -i "$image_path" --mode "$swayMode" || wallsetERROR
    elif command -v xfconf-query >/dev/null; then
        xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-style --set $xfceMode &&
        xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-path --set "$image_path" || \
		wallsetERROR 1
	elif command -v gnome-shell >/dev/null; then
        gsettings set org.gnome.desktop.background picture-uri "file://$image_path" &&
        gsettings set org.gnome.desktop.background picture-options "$gnomeMode" || \
		wallsetERROR
    elif command -v pcmanfm >/dev/null; then
        pcmanfm --set-wallpaper "$image_path" --wallpaper-mode "$pcmanfmMode" || wallsetERROR
    else
        kdialog --error "No supported wallpaper setter found!"
        return 1
    fi
}

# Declare A variable and convert the image to png to avoid format errors in some wallpaper setters...
wallpaper_CACHE="$PYWAL16_OUT_DIR/wallpaper.png"
case "$wallpaperIMAGE" in
	*.png) rm $wallpaper_CACHE ; cp $wallpaperIMAGE $wallpaper_CACHE ;;
	*.gif) convert $wallpaperIMAGE -coalesce -flatten $wallpaper_CACHE ;;
	*)     convert $wallpaperIMAGE $wallpaper_CACHE ;;
esac

# Apply wallpaper colors with pywal16
applyWAL "$wallpaper_CACHE" "$wallpaperBACK" "$genCLR16op" || \
	kdialog --msgbox "Backend is not found, using default instead!!" \
	applyWAL "$wallpaper_CACHE" "wal" "$genCLR16op"	

wallSETError() { kdialog --msgbox "No Wallpaper setter found!\nSo wallpaper is not set..."; }
verbose "Settings wallpaper..."
case "$wallpaperTYPE" in
    "Solid")
        solidwallpaperCACHE=$PYWAL16_OUT_DIR/wallpaper.solid.png
        [ -f "${PYWAL16_OUT_DIR}/colors.sh" ] && . "${PYWAL16_OUT_DIR}/colors.sh"
        convert -size 80x80 xc:"$color8" "$solidwallpaperCACHE"
        set_wallpaper_with_mode "$solidwallpaperCACHE" || wallSETError
        ;;
    "Image")
        set_wallpaper_with_mode "$wallpaper_CACHE" || wallSETError
        ;;
	*) kdialog --msgbox "Wallpaper type is not configured!\nSo wallpaper is not set...";; 
esac
verbose "Process finished!!"
