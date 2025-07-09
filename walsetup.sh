#!/bin/bash

# Manage Options
HELP_MESSAGE="
Info:
'walsetup.sh' is a wrapper for pywal16 purely in shell script and made by aKqir24,
to ease the configuration in pywal, also it adds more functionality in pywal16 which
are writen in the https://github.com/aKqir24/pywal16_scripts.

Usage: $0 [OPTIONS]
  --gui: To launch a configuration dialogs and apply the configurations.
  --verbose: To show log messages when each step of the script is executed.
  --help: to show how to use this script.
  *: 'not putting any options' loads/applies the configurations.

Advanced:
If you don't want bloat in your system like me, sometimes, you can just 
edit the config file in your '$HOME/.config/walsetup.conf'. I still working on
how to make a '--config' option, but for now that's the only option.

wallpaper_path=[ IMAGE_FILE | IMAGE_FOLDER ]
  - It is the path either to an wallpaper file directory or folder
    that this script uses. Note, when using a wallpaper folder you 
	need to define th wallpaper_cycle also.

wallpaper_cycle=[iterative, recursive]
  - How a wallpaper is choosen in a wallpaper folder.

type=[ None | Image | Solid ]
  - Sets your wallpaper wit these options, none basically means don't
    set my wallpaper.

mode=[ center | fill | tile | full | cover ]
  - How the wallpaper behaves when it is applied by the available setter

backend=[ wal | colorz | haishoku | okthief | modern_colorthief | colorthief ]
  - What backend pywal will use in generating a colorscheme.

gtk_apply=[ true | false ]
  - Generate a gtk theme then apply it.

gtk_accent=[0-15]
  - The primary color used in gtk_apply, eg: primary and active

gen_color16=[ lighten | darken ]
  - pywal16's new 16 colorsheme generation"

# Default Values
VERBOSE=false
CONFIG_MODE=false
DEFAULT_PYWAL16_OUT_DIR=$HOME/.cache/wal
WALLPAPER_CONF_PATH="$HOME/.config/walsetup.conf"
wallpaper_CACHE="$PYWAL16_OUT_DIR/wallpaper.png"

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
            gtk_apply) wallpaperGTK=$val ;;
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
	verbose "Running 'pywal' for colorscheme... "
	wal --$4 --backend "$2" -i "$1" $3 -n --out-dir "$PYWAL16_OUT_DIR" >/dev/null || pywalerror 	
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
	if grep -q "^Net/ThemeName " $xsettingsd_config; then
		sed -i 's|\(Net/ThemeName \)"[^"]*"|\1"pywal"|' $xsettingsd_config
	else
		echo 'Net/ThemeName "pywal"' >> $xsettingsd_config
	fi
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
# TODO: Also make a cli configuration options
else
	verbose "Using the previously configured settings"
	GTK_ACCENT_COLOR="$wallpaperGTKAC"
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
			WALL_CYCLE=$(kdialog --yes-label "Orderly" --no-label "Randomly" \
			--yesno "How to choose you wallpaper in a folder?" && echo "iterative" || echo "recursive" )
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

# Save config then read it
saveCONFIG() {
	verbose "Saving configurations"
	[ -z "$WALL_BACK" ] && WALL_BACK="wal"
	[ -z "$WALL_GTK_ACCENT_COLOR" ] && WALL_GTK_ACCENT_COLOR=2
	[ -z "$WALLPAPER" ] && [ -d "$WALLPAPER_FOLDER" ] && WALLPAPER="$WALLPAPER_FOLDER"
	
	conf_variables=( wallpaper_path wallpaper_cycle type mode backend gtk_apply gtk_accent gen_color16 )
	for v in ${conf_variables[@]}; do
		grep -q "^$v=" $WALLPAPER_CONF_PATH || echo "$v=" >> $WALLPAPER_CONF_PATH
	done

	sed -i \
		-e 's|\('${conf_variables[0]}'=\)[^ ]*|\1'$WALLPAPER'|' \
		-e 's|\('${conf_variables[1]}'=\)[^ ]*|\1'$WALL_CYCLE'|' \
		-e 's|\('${conf_variables[2]}'=\)[^ ]*|\1'$WALL_TYPE'|' \
		-e 's|\('${conf_variables[3]}'=\)[^ ]*|\1'$WALL_MODE'|' \
		-e 's|\('${conf_variables[4]}'=\)[^ ]*|\1'$WALL_BACK'|' \
		-e 's|\('${conf_variables[5]}'=\)[^ ]*|\1'$WALL_GTK'|' \
		-e 's|\('${conf_variables[6]}'=\)[^ ]*|\1'$GTK_ACCENT_COLOR'|' \
		-e 's|\('${conf_variables[7]}'=\)[^ ]*|\1'$WALL_CLR16'|' \
		$WALLPAPER_CONF_PATH

assignTEMPCONF
}

# Only save the config when configured!
[ "$CONFIG_MODE" = true ] && saveCONFIG

# Wallpaper selection method
[ -d "$WALLPAPER_FOLDER" ] && [ -d "$wallpaperIMG" ] && \
	wallpaperPATH=$WALLPAPER_FOLDER || wallpaperPATH="$wallpaperIMG"

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

# set the wallpaperIMAGE in display
setwallpaperTYPE() {
	verbose "Settings wallpaper..."
	case "$wallpaperTYPE" in
		"Solid")
			convert -size 10x10 xc:"$color8" "$wallpaper_CACHE"
			set_wallpaper_with_mode "$wallpaper_CACHE" || wallSETTERError ;;
		"Image") set_wallpaper_with_mode "$wallpaper_CACHE" || wallSETTERError ;;
		*) kdialog --msgbox "Wallpaper type is not configured!\nSo wallpaper is not set...";; 
	esac
}

# Finalize Process and making them faster by Functions
linkCONF_DIR & setwallpaperTYPE && verbose "Process finished!!"	
