# Function to apply wallpaper using pywal16
applyWAL() {
	[ -z "$4" ] && wallCYCLE="" || wallCYCLE="--$4"
	verbose "Running 'pywal' for colorscheme... " & generateGTKTHEME & generateICONSTHEME
	wal $wallCYCLE --backend "$2" -i "$1" $3 -n --out-dir "$PYWAL16_OUT_DIR" >/dev/null || pywalerror 
	reloadTHEMES &
}

# Apply gtk theme / reload gtk theme
generateGTKTHEME() {
	verbose "Generating & setting gtk theme!" &
	if [ "$wallpaperGTK" = true ]; then
		bash "$(dirname $0)/theming/gtk/generate.sh" "@color$wallpaperGTKAC"
	else
		rm -r "$HOME/.themes/pywal"
	fi
}

generateICONSTHEME() {
	verbose "Generating & setting icon theme!" &
	if [ "$wallpaperICONS" = true ]; then 
		bash "$(dirname $0)/theming/icons/generate.sh" "$wallpaperICONSCLR"
	else
		rm -r "$HOME/.icons/pywal"
	fi	
}

# Set Icon Theme's Name
setGTK_THEME() {
	verbose "Reloading Gtk Theme..."	
	if grep -q "^Net/ThemeName " $1; then
		sed -i 's|\(Net/ThemeName \)"[^"]*"|\1"pywal"|' $1
	else
		echo 'Net/ThemeName "pywal"' >> $1
	fi
}

setICON_THEME() {
	verbose "Reloading Icon Theme..."	
	if grep -q "^Net/IconThemeName  " $1; then
		sed -i 's|\(Net/IconThemeName \)"[^"]*"|\1"pywal"|' $1
	else
		echo 'Net/IconThemeName "pywal"' >> $1
	fi
}

# Reload Gtk themes using xsettingsd
reloadTHEMES() {
	local default_xsettings_config="$HOME/.xsettingsd.conf"
	local xsettingsd_config="$HOME/.config/xsettingsd/xsettingsd.conf"
	[ -f $xsettingsd_config ] || xsettingsd_config=$default_xsettings_config
	setGTK_THEME $xsettingsd_config & setICON_THEME $xsettingsd_config 
	command -v xsettingsd >/dev/null && pkill xsettingsd >/dev/null 2>&1 ;\
		xsettingsd -c $xsettingsd_config >/dev/null 2>&1 &
}

# Still pywalfox uses 'The Default OutDir in pywal so just link them to the default'
linkCONF_DIR() {	
	if [ -d "$DEFAULT_PYWAL16_OUT_DIR" ]; then
		for outFile in "$PYWAL16_OUT_DIR"/*; do
			local filename=$(basename "$outFile")
			if [ ! -e "$DEFAULT_PYWAL16_OUT_DIR/$filename" ]; then
				ln -s "$outFile" "$DEFAULT_PYWAL16_OUT_DIR/" >/dev/null
			fi
		done
	fi
}
