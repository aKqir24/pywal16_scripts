# Wallpaper selection method
[ -d "$WALLPAPER_FOLDER" ] && [ -d "$wallpaperIMG" ] && \
	wallpaperPATH=$WALLPAPER_FOLDER || wallpaperPATH="$wallpaperIMG"

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
