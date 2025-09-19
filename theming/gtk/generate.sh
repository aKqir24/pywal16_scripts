#!/bin/sh

# Get current script directory
WORK_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_FOLDER="$WORK_DIR/base"

GTK_CSS_FILES=(
  "$BASE_FOLDER/gtk-2.0/gtkrc"
  "$BASE_FOLDER/gtk-3.0/gtk.css"
  "$BASE_FOLDER/gtk-3.20/gtk.css"
  "$BASE_FOLDER/gtk-4.0/gtk.css"
  "$BASE_FOLDER/general/dark.css"
)

# Copy the base theme directory in .themes
USER_THEME_FOLDER="$HOME/.themes/pywal"

[ -d $USER_THEME_FOLDER ] || mkdir -p $USER_THEME_FOLDER
for themeFile in $(find $BASE_FOLDER -mindepth 1 -maxdepth 1); do
	FULL_THEME_FILE_DIR="$USER_THEME_FOLDER/$(basename $themeFile)"
	[ -e "$FULL_THEME_FILE_DIR" ] && rm -r "$FULL_THEME_FILE_DIR"
	cp -r "$themeFile" "$USER_THEME_FOLDER/"
done

# since pywal16 does not recognize the gtk-4.0 css file
# I am forced to do it this way, but be removed in the future 
apply_gtk4_colors() {
	. "${PYWAL16_OUT_DIR}/colors.sh"

	# Apply sed in-place
	sed -i \
		-e "s/{color0}/$color0/g;" \
		-e "s/{color1}/$color1/g;" \
		-e "s/{color2}/$color2/g;" \
		-e "s/{color3}/$color3/g;" \
		-e "s/{color4}/$color4/g;" \
		-e "s/{color5}/$color5/g;" \
		-e "s/{color6}/$color6/g;" \
		-e "s/{color7}/$color7/g;" \
		-e "s/{color8}/$color8/g;" \
		-e "s/{color9}/$color9/g;" \
		-e "s/{color10}/$color10/g;" \
		-e "s/{color11}/$color11/g;" \
		-e "s/{color12}/$color12/g;" \
		-e "s/{color13}/$color13/g;" \
		-e "s/{color14}/$color14/g;" \
		-e "s/{color15}/$color15/g;" \
		"$1"
}

for gtkCSSFile in "${GTK_CSS_FILES[@]}"; do

  # File & Folder Paths
  dir_name="$(dirname $gtkCSSFile)"
  base_name="$(basename $dir_name)"
  base_filename="$(basename $dir_name.base)"
  base_file="$gtkCSSFile.base"

  # Identify the css file
  case "$base_filename" in
	  "gtk-3.0.base") gtk_tmp_file="gtk-3.0.base";;
	  "gtk-3.20.base") gtk_tmp_file="gtk-3.20.base";;
	  "gtk-4.0.base") gtk_tmp_file="gtk-4.0.base";;
	  *) gtk_tmp_file="$(basename $base_file)"
  esac

  # Remove/Copy base to working file
  [ -z "$1" ] && activeColor="@color2" || activeColor="$1"

  # Apply colors
  sed -i "s/{active}/$activeColor/g" "$base_file"
  temp_file_path="$PYWAL16_OUT_DIR/templates/$gtk_tmp_file"
  theme_style_file="$USER_THEME_FOLDER/$base_name/$(basename $gtkCSSFile)"
  [ ! -e "$temp_file_path" ] && ln -s "$base_file" "$temp_file_path"
  [ ! -e "$theme_style_file" ] && ln -s "$PYWAL16_OUT_DIR/$gtk_tmp_file" "$theme_style_file" ;

  # gtk-4 has its own seperate generation
  if [ $gtk_tmp_file = "gtk-4.0.base" ]; then
	  ln -s "$temp_file_path" "$PYWAL16_OUT_DIR/$gtk_tmp_file"
	  apply_gtk4_colors $temp_file_path
  fi
done


