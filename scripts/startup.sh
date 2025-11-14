#!/bin/sh

# Check for required dependencies
command -v wal > /dev/null || echo "pywal16 is not installed, Please install it!"
if [ $LOAD = false ]; then
	if [ "$SETUP" = true ] && command -v kdialog >/dev/null; then
		echo "kdialog is not installed, Please install it!" ; exit 1
	elif [ "$SETUP" = false ] && command -v python3 >/dev/null; then
		echo "python is not installed, Please install it!" ; exit 1
	fi
fi

# Check for PYWAL16_OUT_DIR
if [ -z "$PYWAL16_OUT_DIR" ] || [ ! -d "$PYWAL16_OUT_DIR" ]; then
	kdialog --msgbox "The 'PYWAL16_OUT_DIR' environment variable is not defined!\n
	Adding it in your .bashrc file"
	echo "export PYWAL16_OUT_DIR=$DEFAULT_PYWAL16_OUT_DIR" >> "$HOME"/.bashrc || \
		$(kdialog --error "The 'PYWAL16_OUT_DIR' environment variable is not defined!\n
			You can define it in your '.bashrc', '.xinitrc', '.profile', etc. using:\n
			export PYWAL16_OUT_DIR=/path/to/folder" ; exit 1 )
	verbose "Setting up output directory"
fi

# Check for PYWAL16_OUT_DIR temp folder
if [ ! -d "$PYWAL16_OUT_DIR/templates" ] && [ -d "$PYWAL16_OUT_DIR" ]; then
	mkdir -p $PYWAL16_OUT_DIR/templates
else
	mkdir -p $DEFAULT_PYWAL16_OUT_DIR/templates
fi

# Check if some features are already present
INSTALLED_TAG='(installed)'
[ -f "$HOME/.icons/pywal/index.theme" ] && ICON_INS_TAG="$INSTALLED_TAG"
[ -f "$HOME/.themes/pywal/index.theme" ] && GTK_INS_TAG="$INSTALLED_TAG"
