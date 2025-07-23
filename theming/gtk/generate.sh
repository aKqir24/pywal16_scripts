#!/bin/sh
# Export The Colorscheme
. "${PYWAL16_OUT_DIR}/colors.sh" || exit 1

# Get current script directory
WORK_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_FOLDER="$WORK_DIR/base"

GTK_CSS_FILES=(
  "$BASE_FOLDER/gtk-2.0/gtkrc"
  "$BASE_FOLDER/gtk-3.20/gtk.css"
  "$BASE_FOLDER/general/dark.css"
)

for gtkCSSFile in "${GTK_CSS_FILES[@]}"; do
  base_file="$gtkCSSFile.base"

  # Make sure both files exist
  [ -e "$gtkCSSFile" ] || touch "$gtkCSSFile"
  [ -e "$base_file" ] || continue

  # Remove/Copy base to working file
  rm "$gtkCSSFile" ; cp "$base_file" "$gtkCSSFile"
  [ -z "$1" ] && activeColor="@color2" || activeColor="$1"

  # Apply colors
  sed -i \
    -e "s/{color0}/$color0/g" \
    -e "s/{color1}/$color1/g" \
    -e "s/{color2}/$color2/g" \
    -e "s/{color3}/$color3/g" \
    -e "s/{color4}/$color4/g" \
    -e "s/{color5}/$color5/g" \
    -e "s/{color6}/$color6/g" \
    -e "s/{color7}/$color7/g" \
    -e "s/{color8}/$color8/g" \
    -e "s/{color9}/$color9/g" \
    -e "s/{color10}/$color10/g" \
    -e "s/{color11}/$color11/g" \
    -e "s/{color12}/$color12/g" \
    -e "s/{color13}/$color13/g" \
    -e "s/{color14}/$color14/g" \
    -e "s/{color15}/$color15/g" \
	-e "s/{active}/$activeColor/g" \
    "$gtkCSSFile"
done

# Copy the base theme directory in .themes
USER_THEME_FOLDER="$HOME/.themes/pywal"

[ -d $USER_THEME_FOLDER ] || mkdir -p $USER_THEME_FOLDER
for themeFile in $(find $BASE_FOLDER -mindepth 1 -maxdepth 1); do
	FULL_THEME_FILE_DIR="$USER_THEME_FOLDER/$(basename $themeFile)"
	[ -e "$FULL_THEME_FILE_DIR" ] && rm -r "$FULL_THEME_FILE_DIR"
	cp -r "$themeFile" "$USER_THEME_FOLDER/"
done
