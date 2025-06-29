#!/bin/bash

# Check for required dependencies
command -v kdialog >/dev/null || { echo "kdialog is not installed. Please install it!"; exit 1; } 
DEFAULT_PYWAL16_OUT_DIR=~/.cache/wal
# Check for PYWAL16_OUT_DIR
if [ -z "$PYWAL16_OUT_DIR" ]; then
	kdialog --msgbox "The 'PYWAL16_OUT_DIR' environment variable is not defined!\n
	Adding it in your .bashrc file"
	echo "export PYWAL16_OUT_DIR=$DEFAULT_PYWAL16_OUT_DIR" >> .bashrc || \
		$(kdialog --error "The 'PYWAL16_OUT_DIR' environment variable is not defined! 
			You can define it in your '.bashrc', '.xinitrc', '.profile', etc. using:
			export PYWAL16_OUT_DIR=/path/to/folder" ; exit 1 )
fi

WALLPAPER_CONF_PATH="$HOME/.config/walsetup.conf"
[ -e "$WALLPAPER_CONF_PATH" ] || touch "$WALLPAPER_CONF_PATH"
[ -d $PYWALL16_OUT_DIR ] || mkdir -p $PYWALL16_OUT_DIR

# Function to apply wallpaper using pywal16
applyWAL() {
    wal --backend "$2" -i "$1" $3 -n --out-dir "$PYWAL16_OUT_DIR"

	# Still pywalfox uses 'The Default OutDir in pywal so just link them to the default'
	if [ -d "$DEFAULT_PYWAL16_OUT_DIR" ]; then
		for outFile in "$PYWAL16_OUT_DIR"/*; do
			filename=$(basename "$outFile")
			if [ ! -e "$DEFAULT_PYWAL16_OUT_DIR/$filename" ]; then
				ln -s "$outFile" "$DEFAULT_PYWAL16_OUT_DIR/"
			fi
		done
	fi
}

# Function to read a specific value from the config
readCONFFILE() {
    grep "^$1=" "$WALLPAPER_CONF_PATH" | cut -d '=' -f 2-
}

# Assign configuration values
assignTEMPCONF() {
	wallpaperCLR16=$(readCONFFILE gen_color16)
	wallpaperSCRP=$(readCONFFILE custom_script)
    wallpaperSELC=$(readCONFFILE select)
    wallpaperIMG=$(readCONFFILE wallpaper_path)
    wallpaperTYPE=$(readCONFFILE type)
    wallpaperMODE=$(readCONFFILE mode)
    wallpaperBACK=$(readCONFFILE backend)
}

assignTEMPCONF

# Config labels
SETUPS=( wallSELC "Wallpaper Selection Method" on\
		  wallBACK "Pywal Backend To Use" off\
		  wallTYPE "Wallpaper Setup Type" on\
		  wallSRCP "Add A External Script" off\
		  wallCLR16 "16 Color Output" on
)

BACKENDS=( wal wal on colorz colorz off haishoku haishoku off \
		   okthief okthief off modern_colorthief modern_colorthief off \
		   schemer2 schemer2 off colorthief colorthief off
)

TYPE=( "Not Set" "Solid Color" "Image File" )

MODE=( center "Center" off fill "Fill" on tile "Tile" off full "Full" off cover "Scale" off )

# GUI Configuration
if [ "$1" = "--gui" ]; then
    ToCONFIG=$(kdialog --geometry 300x190-0-0 --checklist "Available Configs" "${SETUPS[@]}" --separate-output || echo "cancel")
    for config in $ToCONFIG; do
        case "$config" in
			wallSRCP)
				WALL_SCRP=$(kdialog --textinputbox "Add A Custom External Script:" || exit)
				;;
            wallSELC)
                WALL_SELECT=$(kdialog --yes-label "Select Wallpaper" --no-label "Random Wallpaper" \
                    --yesno "Changing your pywal Wallpaper Method?" && echo "static" || echo "random")
                ;;
            wallBACK)
                WALL_BACK=$(kdialog --geometry 300x200-0-0 --radiolist "Pywal Backend In Use" "${BACKENDS[@]}" || exit)
                ;;
            wallTYPE)
                WALL_TYPE=$(kdialog --geometry 300x100-0-0 --combobox "Wallpaper Setup Type" "${TYPE[@]}" || exit)
                ;;
			wallCLR16)
				WALL_CLR16=$(kdialog --yes-label "Darken" --no-label "Lighten" \
					--yesno "Generating 16 Colors must be either:" && echo "darken" || echo "lighten" )
				;;
        esac
    done

    [ "$WALL_TYPE" = "Image File" ] && \
		WALL_MODE=$(kdialog --geometry 280x170-0-0 --radiolist "Wallpaper Setup Mode" ${MODE[@]} || exit 0) || WALL_MODE=none
else
	WALL_SCRP="$wallpaperSCRP"
    WALL_BACK="$wallpaperBACK"
    WALL_SELECT="$wallpaperSELC"
    WALL_TYPE="$wallpaperTYPE"
    WALL_MODE="$wallpaperMODE"
	WALL_CLR16="$wallpaperCLR16"
fi

# Wallpaper selection
case "$WALL_SELECT" in
	"random")
		[ "$1" = "--gui" ] && WALL_CHANGE_FOLDER=$(kdialog --yesno "Do you want to change the random wallpaper folder?" && echo "YES")
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
		[ "$1" = "--gui" ] && WALLPAPER=$(kdialog --getopenfilename "$PYWAL16_OUT_DIR" || echo "$wallpaperIMG") || WALLPAPER="$wallpaperIMG"
		;;
	"cancel")
		exit 0 ;;
	*)
		kdialog --msgbox "Please launch the GUI for configuration: \n$0 --gui"
		bash $0 --gui ; exit || rm WALLPAPER_PATH_TEMP
		;;
esac

# Save config
[ -z "$WALL_BACK" ] && WALL_BACK="wal"
[ -z "$WALLPAPER" ] && [ -e "$WALLPAPER_FOLDER" ] && WALLPAPER="$WALLPAPER_FOLDER" 

cat > "$WALLPAPER_CONF_PATH" <<EOF
wallpaper_path=$WALLPAPER
type=$WALL_TYPE
mode=$WALL_MODE
select=$WALL_SELECT
backend=$WALL_BACK
custom_sript=$WALL_SCRP
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
	genCLR16op="--cols16 $wallpaperCLR16"
fi

wallSETtry() { 
	kdialog --msgbox "No Wallpaper setter found!\nSo wallpaper is not set..."
}

# Set background
# Function to apply wallpaper using various setters and mapped modes
set_wallpaper_with_mode() {
    local image_path="$1"

    # Map modes for each setter
    case "$wallpaperMODE" in
        "fill") xWallMode="zoom"; fehMode="fill"; nitrogenMode="auto"; swayMode="fill";;
        "full") xWallMode="maximize"; fehMode="max"; nitrogenMode="scaled"; swayMode="fit";;
        "tile") xWallMode="tile"; fehMode="tile"; nitrogenMode="tiled"; swayMode="tile";;
        "center") xWallMode="center"; fehMode="centered"; nitrogenMode="centered"; swayMode="center";;
        "cover") xWallMode="stretch"; fehMode="scale"; nitrogenMode="zoom"; swayMode="stretch";;
        *) xWallMode="zoom"; fehMode="fill"; nitrogenMode="auto"; swayMode="fill";;
    esac

    if command -v xwallpaper >/dev/null; then
        xwallpaper "--$xWallMode" "$image_path" --daemon && return 0
    elif command -v hsetroot >/dev/null; then
        hsetroot "-$wallpaperMODE" "$image_path" && return 0
    elif command -v feh >/dev/null; then
        feh --bg-"$fehMode" "$image_path" && return 0
    elif command -v nitrogen >/dev/null; then
        nitrogen --set-$nitrogenMode "$image_path" && return 0
    elif command -v swaybg >/dev/null; then
        swaybg -i "$image_path" --mode "$swayMode" && return 0
    elif command -v hyprctl >/dev/null; then
        hyprctl hyprpaper unload all
        hyprctl hyprpaper preload "$image_path"
        hyprctl hyprpaper wallpaper "eDP-1,$image_path" && return 0
    elif command -v xfconf-query >/dev/null; then
        xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-style --set 5
        xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-path --set "$image_path" && return 0
    elif command -v gsettings >/dev/null; then
        gsettings set org.gnome.desktop.background picture-uri "file://$image_path"
        gsettings set org.gnome.desktop.background picture-options "$wallpaperMODE" && return 0
    elif command -v pcmanfm >/dev/null; then
        pcmanfm --set-wallpaper "$image_path" && return 0
    else
        kdialog --error "No supported wallpaper setter found!" && return 1
    fi
}

# Declare A variable and convert the image to png to avoid format errors in some wallpaper setters...
wallpaper_CACHE=$PYWAL16_OUT_DIR/wallpaper.png
convert "$wallpaperIMAGE" "$wallpaper_CACHE"

# Apply wallpaper colors with pywal16
applyWAL "$wallpaper_CACHE" "$wallpaperBACK" "$genCLR16op" || \
	kdialog --msgbox "Backend is not found, using default instead!!" \
	applyWAL "$$wallpaper_CACHE" "wal" "$genCLR16op" || \
	$(kdialog --msgbox "The native pywal is not compatible, please update pywal16 v3.8.x where this script uses --colrs16 to be used!" || exit 1)

case "$wallpaperTYPE" in
    "Solid Color")
        solidwallpaperCACHE=$PYWAL16_OUT_DIR/wallpaper.solid.png
        [ -f "${PYWAL16_OUT_DIR}/colors.sh" ] && . "${PYWAL16_OUT_DIR}/colors.sh"
        convert -size 80x80 xc:"$color8" "$solidwallpaperCACHE"
        set_wallpaper_with_mode "$solidwallpaperCACHE" || wallSETError
        ;;
    "Image File")
        set_wallpaper_with_mode "$wallpaper_CACHE" || wallSETError
        ;;
esac
