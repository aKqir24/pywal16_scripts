#!/bin/bash

# Check for required dependencies
command -v kdialog >/dev/null || { echo "kdialog is not installed. Please install it!"; exit 1; } 

# Check for PYWAL16_OUT_DIR
if [ -z "$PYWAL16_OUT_DIR" ]; then
	kdialog --msgbox "The 'PYWAL16_OUT_DIR' environment variable is not defined!\n
	Adding it in your .bashrc file"
	echo "export PYWAL16_OUT_DIR=~/.cache/wal" >> .bashrc || \
		$(kdialog --error "The 'PYWAL16_OUT_DIR' environment variable is not defined! 
			You can define it in your '.bashrc', '.xinitrc', '.profile', etc. using:
			export PYWAL16_OUT_DIR=/path/to/folder" ; exit 1 )
fi

WALLPAPER_PATH_TEMP="${PYWAL16_OUT_DIR}/walsetup.cfg"
[ -e "$WALLPAPER_PATH_TEMP" ] || touch "$WALLPAPER_PATH_TEMP"
[ -d "$PYWALL16_OUT_DIR" ] || mkdir -p 

# Function to apply wallpaper using pywal16
applyWAL() {
    wal --backend "$2" -i "$1" -n --cols16 lighten --out-dir "$PYWAL16_OUT_DIR"
}

# Function to read a specific value from the config
readTEMPCONF() {
    grep "^$1=" "$WALLPAPER_PATH_TEMP" | cut -d '=' -f 2-
}

# Assign configuration values
assignTEMPCONF() {
	wallpaperSCRP=$(readTEMPCONF custom_script)
    wallpaperSELC=$(readTEMPCONF select)
    wallpaperIMG=$(readTEMPCONF wallpaper_path)
    wallpaperTYPE=$(readTEMPCONF type)
    wallpaperMODE=$(readTEMPCONF mode)
    wallpaperBACK=$(readTEMPCONF backend)
}

assignTEMPCONF

# Config labels
SETUPS=( wallSELC "Wallpaper Selection Method" on\
		  wallBACK "Pywal Backend To Use" off\
		  wallTYPE "Wallpaper Setup Type" on\
		  wallSRCP "ADD a External Script" off
)

BACKENDS=( wal wal on colorz colorz off haishoku haishoku off \
		   okthief okthief off modern_colorthief modern_colorthief off \
		   schemer2 schemer2 off colorthief colorthief off
)

TYPE=( "Not Set" "Solid Color" "Image File" )

# GUI Configuration
if [ "$1" = "--gui" ]; then
    ToCONFIG=$(kdialog --geometry 300x120-0-0 --checklist "Available Configs" "${SETUPS[@]}" --separate-output)
    for config in $ToCONFIG; do
        case "$config" in
			wallSRCP)
				WALL_SCRP=$(kdialog --textinputbox "Add You Custom External Script:" || exit)
				;;
            wallSELC)
                WALL_SELECT=$(kdialog --yes-label "Select Wallpaper" --no-label "Select Randomly" \
                    --yesnocancel "Changing your pywal Wallpaper Method?" && echo "static" || echo "random")
                ;;
            wallBACK)
                WALL_BACK=$(kdialog --geometry 300x200-0-0 --radiolist "Pywal Backend In Use" "${BACKENDS[@]}" || exit)
                ;;
            wallTYPE)
                WALL_TYPE=$(kdialog --geometry 300x100-0-0 --combobox "Wallpaper Setup Type" "${TYPE[@]}" || exit)
                ;;
        esac
    done

    [ "$WALL_TYPE" = "Image File" ] && WALL_MODE=$(kdialog --geometry 280x170-0-0 --radiolist "Wallpaper Setup Mode" \
        center "Center" off fill "Fill" on tile "Tile" off full "Full" off cover "Scale" off || exit) || WALL_MODE="none"
else
	WALL_SCRP="$wallpaperSCRP"
    WALL_BACK="$wallpaperBACK"
    WALL_SELECT="$wallpaperSELC"
    WALL_TYPE="$wallpaperTYPE"
    WALL_MODE="$wallpaperMODE"
fi

# Wallpaper selection
if [ "$WALL_SELECT" = "random" ]; then
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
elif [ "$WALL_SELECT" = "static" ]; then
    [ "$1" = "--gui" ] && WALLPAPER=$(kdialog --getopenfilename "$PYWAL16_OUT_DIR" || echo "$wallpaperIMG") || WALLPAPER="$wallpaperIMG"
else
    kdialog --msgbox "Please launch the GUI for configuration: $0 --gui"
    bash $0 --gui ; exit || rm WALLPAPER_PATH_TEMP
fi

# Save config
[ -z "$WALL_BACK" ] && WALL_BACK="wal"
[ -z "$WALLPAPER" ] && [ -e "$WALLPAPER_FOLDER" ] && WALLPAPER="$WALLPAPER_FOLDER" 
cat > "$WALLPAPER_PATH_TEMP" <<EOF
wallpaper_path=$WALLPAPER
type=$WALL_TYPE
mode=$WALL_MODE
select=$WALL_SELECT
backend=$WALL_BACK
custom_sript=$WALL_SCRP
EOF

assignTEMPCONF

# Select a random wallpaper from folder or use static
if [ -d "$WALLPAPER_FOLDER" ] && [ -d "$wallpaperIMG" ]; then
    wallpaperIMAGE=$(find "$wallpaperIMG" -type f | shuf -n 1)
else
    wallpaperIMAGE="$wallpaperIMG"
fi

# Apply wallpaper colors with pywal16
applyWAL "$wallpaperIMAGE" "$wallpaperBACK" || \
	kdialog --msgbox "Backend is not found, using default instead!!" ;\
	applyWAL "$wallpaperIMAGE" "wal" || \
	$(kdialog --msgbox "The native pywal is not compatible, please update pywal16 v3.8.x where this script uses --colrs16 to be used!" || exit)

# Set background
case "$wallpaperTYPE" in
    "Solid Color")	
        [ -f "${PYWAL16_OUT_DIR}/colors.sh" ] && . "${PYWAL16_OUT_DIR}/colors.sh"
        convert -size 80x80 xc:"$color8" ~/.cache/solid.png
        command -v hsetroot >/dev/null && hsetroot -solid "$color8"
        command -v feh >/dev/null && feh --bg-fill ~/.cache/solid.png
        ;;
    "Image File")
        case "$wallpaperMODE" in
            "full") fehWALLmode="max" ;;
            "cover") fehWALLmode="scale" ;;
            *) fehWALLmode="$wallpaperMODE" ;;
        esac
        command -v hsetroot >/dev/null && hsetroot "-$wallpaperMODE" "$wallpaperIMAGE"
        command -v feh >/dev/null && feh --bg-"$fehWALLmode" "$wallpaperIMAGE"
        ;;
esac
