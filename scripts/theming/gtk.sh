#!/bin/sh

# Copy the base theme directory in .themes
[ -d $USER_THEME_FOLDER ] || mkdir -p $USER_THEME_FOLDER
for themeFile in $(find $BASE_THEME_FOLDER -mindepth 1 -maxdepth 1); do
	FULL_THEME_FILE_DIR="$USER_THEME_FOLDER/$(basename $themeFile)"
	[ -e "$FULL_THEME_FILE_DIR" ] && rm -r "$FULL_THEME_FILE_DIR"
	cp -r "$themeFile" "$USER_THEME_FOLDER/"
done

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
  [ ! -e "$theme_style_file" ] && ln -s "$PYWAL16_OUT_DIR/$gtk_tmp_file" "$theme_style_file"
done
