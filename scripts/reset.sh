#!/bin/bash

# Remove pywal generated files
remove_files() {
	verbose "Reset pywal generated files..."
	PATHS_TO_REMOVE=(
		"$DEFAULT_PYWAL16_OUT_DIR" "$PYWAL16_OUT_DIR"
		"$USER_THEME_FOLDER" "$USER_ICONS_FOLDER")
	
	for FILE_PATH in "${PATHS_TO_REMOVE[@]}"; do
		rm -rf "$FILE_PATH"
	done
}

remove_files
