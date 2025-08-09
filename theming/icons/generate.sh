# Variables that contain settings & paths
mode="$1"
WORK_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_ICONS_FOLDER="$HOME/.icons/pywal"
USER_MAIN_ICONS="$USER_ICONS_FOLDER/places/scalable"
BASE_PLACES_ICONS="$WORK_DIR/base/main/places/scalable"
PYWAL_ICON_TEMPLATE="$PYWAL16_OUT_DIR/templates/"
BASE_ICON_PATHS=("$WORK_DIR/base/$mode" "$WORK_DIR/base/main")

# Copy the base icons
[ -d $USER_ICONS_FOLDER ] || mkdir -p $USER_ICONS_FOLDER
for icon_path in "${BASE_ICON_PATHS[@]}"; do
	for some_icons in $icon_path/*; do
		THEME_FILES="$USER_MAIN_ICONS/$(basename $some_icons)"
		case "$icon_path" in
			"${icon_path[0]}") [ -f $THEME_FILES ] && rm -r $THEME_FILES ;;
		esac
			cp -r "$some_icons" "$USER_ICONS_FOLDER/"
	done
done

# Replace the base icons with the pywal one 
[ -e $USER_ICONS_FOLDER ] || mkdir -p "$USER_MAIN_ICONS"

# Link the pywal generated icons
for user_icon in $BASE_PLACES_ICONS/*; do
	ICON_NAME="`basename $user_icon`"
	ICON_PATH="$USER_MAIN_ICONS/$ICON_NAME"
	link_icons() { ln -s "$PYWAL16_OUT_DIR/$ICON_NAME" "$USER_MAIN_ICONS"; }
	[ -e "$PYWAL_ICON_TEMPLATE/$ICON_NAME" ] || ln -s "$user_icon" "$PYWAL_ICON_TEMPLATE"
	if [ -h "$ICON_PATH" ]; then 
		break
	else
		rm "$USER_MAIN_ICONS/*" && link_icons
	fi
done
