# Variables that contain settings & paths
mode="$1"
WORK_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_ICONS_FOLDER="$HOME/.icons/pywal"
USER_MAIN_ICONS="$USER_ICONS_FOLDER/places/scalable"
BASE_PLACES_ICONS="$WORK_DIR/base/main/places/scalable"
BASE_FOLDER_ICONS="$WORK_DIR/base/templates/places/scalable/folders"
PYWAL_ICON_TEMPLATE="$PYWAL16_OUT_DIR/templates/"
BASE_ICON_PATHS=("$WORK_DIR/base/$mode" "$WORK_DIR/base/main")

# Get hash from the index.file
get_hash() { echo `sha256sum $1 | cut -d' ' -f1` ; }

# Copy the base icons
[ -d $USER_ICONS_FOLDER ] || mkdir -p $USER_ICONS_FOLDER

for icon_path in "${BASE_ICON_PATHS[@]}"; do
	for some_icons in $icon_path/*; do
		[ -f "$some_icons" ] && [ "`get_hash $some_icons`" = \
			"`get_hash $USER_ICONS_FOLDER/$(basename $some_icons)`" ] && break
		cp -r "$some_icons" "$USER_ICONS_FOLDER/"
	done
done

# Replace the base icons with the pywal one 
[ -e $USER_ICONS_FOLDER ] || mkdir -p "$USER_MAIN_ICONS"

# Link the pywal generated folder icons
for user_icon in $BASE_FOLDER_ICONS/*; do
	ICON_NAME="$(basename $user_icon)" ; ICON_PATH="$USER_MAIN_ICONS/$ICON_NAME"
	[ -e "$PYWAL_ICON_TEMPLATE/$ICON_NAME" ] || ln -s "$user_icon" "$PYWAL_ICON_TEMPLATE"
	[ -h "$ICON_PATH" ] || ln -s "$PYWAL16_OUT_DIR/$ICON_NAME" "$ICON_PATH"
done
