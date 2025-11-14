#!/bin/bash

# DEFAULT PATHS FOR CONFIG:
THEMING_ASSETS="$(pwd)/assets"
DEFAULT_PYWAL16_OUT_DIR="$HOME/.cache/wal"
WALLPAPER_CONF_PATH="$HOME/.config/walset.toml"
WALLPAPER_CACHE="$PYWAL16_OUT_DIR/wallpaper.png"

# ARRAY OF THE PATHS TO PROGRAMS SCRIPTS
for program in "terminal" "notification" "status" "launcher"; do
	PROGRAMS_DIR+=("$SCRIPT_PATH/programs/$program")
done

# GTK THEMING PATHS
USER_THEME_FOLDER="$HOME/.themes/pywal"
GTK_WORK_DIR="$THEMING_ASSETS/gtk"
BASE_THEME_FOLDER="$GTK_WORK_DIR/base"
for gtk_file in \
	"gtk-2.0/gtkrc" "gtk-3.0/gtk.css" "gtk-3.20/gtk.css" \
	"gtk-4.0/gtk.css" "general/dark.css"; do
	GTK_CSS_FILES+=("$BASE_THEME_FOLDER/$gtk_file")
done

# GTK ICONS PATHS
ICONS_WORK_DIR="$THEMING_ASSETS/icons"
USER_ICONS_FOLDER="$HOME/.icons/pywal"
USER_MAIN_ICONS="$USER_ICONS_FOLDER/places/scalable"
BASE_PLACES_ICONS="$ICONS_WORK_DIR/base/main/places/scalable"
BASE_FOLDER_ICONS="$ICONS_WORK_DIR/base/templates/places/scalable/folders"
PYWAL_ICON_TEMPLATE="$PYWAL16_OUT_DIR/templates/"
