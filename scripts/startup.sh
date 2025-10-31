# Check for required dependencies
command -v wal > /dev/null || echo "pywal16 is not installed, Please install it!"
if [ "$CONFIG_MODE" = true ]; then
	if ! command -v kdialog >/dev/null; then
		echo "kdialog is not installed, Please install it!"
		exit 1
	fi
fi

# Check for PYWAL16_OUT_DIR
if [ -z "$PYWAL16_OUT_DIR" -o ! -d "$PYWAL16_OUT_DIR" ]; then
	kdialog --msgbox "The 'PYWAL16_OUT_DIR' environment variable is not defined!\n
	Adding it in your .bashrc file"
	echo "export PYWAL16_OUT_DIR=$DEFAULT_PYWAL16_OUT_DIR" >> "$HOME"/.bashrc || \
		$(kdialog --error "The 'PYWAL16_OUT_DIR' environment variable is not defined!\n
			You can define it in your '.bashrc', '.xinitrc', '.profile', etc. using:\n
			export PYWAL16_OUT_DIR=/path/to/folder" ; exit 1 )
	verbose "Setting up output directory"
fi

# Check if some features are already present
INSTALLED_TAG='(installed)'
[ -f "$HOME/.icons/pywal/index.theme" ] && ICON_INS_TAG="$INSTALLED_TAG"
[ -f "$HOME/.themes/pywal/index.theme" ] && GTK_INS_TAG="$INSTALLED_TAG"`
