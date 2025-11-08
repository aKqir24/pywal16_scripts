# Wallpaper selection
select_wallpaper() {
	verbose "Identifying wallpaper mode!"
	if [ $CONFIG_MODE = false ] && [ -z "$WALL_SELECT" ]; then
		[ -d "$wallpaper_path" ] && WALL_SELECT="folder"
		[ -f "$wallpaper_path" ] && WALL_SELECT="image"
	else
		WALL_SELECT=$( kdialog --yes-label "From Image" --no-label "From Folder" \
			       --yesno "Changing your pywal Wallpaper Selection Method?" && echo "image" || echo "folder")
	fi

	case "$WALL_SELECT" in
		"folder")
			if [ "$CONFIG_MODE" = true ]; then
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
			else
				WALLPAPER_FOLDER="$wallpaper_path"
			fi
			;;
		"image")
			[ "$CONFIG_MODE" = true ] && WALLPAPER_IMAGE=$(kdialog --getopenfilename \
				"$START_FOLDER" || echo "$wallpaper_path") || WALLPAPER_IMAGE="$wallpaper_path"
			;;
		*)
			kdialog --msgbox "Wallpaper type is not configured!\nSo wallpaper is not set..."
			bash $0 --gui ; exit || rm $WALLPAPER_CACHE
	esac

	# Wallpaper selection method
	if [ -d "$WALLPAPER_FOLDER" ]; then
		WALLPAPER_PATH=$WALLPAPER_FOLDER
	elif [ -f "$WALLPAPER_IMAGE" ]; then
		WALLPAPER_PATH=$WALLPAPER_IMAGE
	else
		WALLPAPER_PATH="$wallpaper_path"
	fi
}

# Function to apply wallpaper using various setters and mapped modes
set_wallpaper_with_mode() {
    local image_path="$1"

    # Mode mappings
    case "$wallpaper_mode" in
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

# set the wallpaperIMAGE in display
setup_wallpaper() {
	verbose "Setting the wallpaper..."
	case "$wallpaper" in
		*.png) cp $wallpaper $WALLPAPER_CACHE ;;
		*.gif) convert $wallpaper -coalesce -flatten $WALLPAPER_CACHE>/dev/null ;;
		*)  convert $wallpaper $WALLPAPER_CACHE>/dev/null
	esac
	case "$wallpaper_type" in
		"solid")
			convert -size 10x10 xc:"$color8" "$WALLPAPER_CACHE"
			set_wallpaper_with_mode "$WALLPAPER_CACHE" || wallSETTERError ;;
		"image") set_wallpaper_with_mode "$WALLPAPER_CACHE" || wallSETTERError ;;
		*) kdialog --msgbox "Wallpaper type is not configured!\nSo wallpaper is not set...";; 
	esac
}
