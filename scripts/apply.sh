# Function to apply wallpaper using pywal16
applyWAL() {
	[ "$4" = "static" ] && wallCYCLE="" || wallCYCLE="--$4"
	[ $theming_mode = "light" ] && colorscheme="-l" || colorscheme=""
	wal $wallCYCLE $colorscheme --backend "$2" -i "$1" $3 -n --out-dir "$PYWAL16_OUT_DIR" >/dev/null || pywalerror
	verbose "Running 'pywal' for colorscheme... " & generateGTKTHEME & generateICONSTHEME ; sleep 1
	reloadTHEMES &
}

# To clean the theme folder when option = false
clean_theme_folder() { [ -e $"$1" ] && rm -r $1 ; }

# Apply gtk theme / reload gtk theme
generateGTKTHEME() {
	verbose "Generating & setting gtk theme!" &
	theme_folder="$HOME/.themes/pywal"
	if [ $theming_gtk = true ]; then
		[ -z "$GTK_INS_TAG" ] && bash "$script_dir/theming/gtk/generate.sh" "@$theming_accent"
	else
		clean_theme_folder $theme_folder & 
	fi
}

generateICONSTHEME() {
	verbose "Generating & setting icon theme!" &
	icons_folder="$HOME/.icons/pywal"
	if [ $theming_icons = true ]; then
		[ -z "$ICON_INS_TAG" ] && bash "$script_dir/theming/icons/generate.sh" "$theming_mode"
	else
		clean_theme_folder $icons_folder &
	fi	
}

# Set Icon Theme's Name
setGTK_THEME() {
	verbose "Reloading Gtk Theme..."	
	if grep -q "^Net/ThemeName " $1; then
		sed -i 's|\(Net/ThemeName \)"[^"]*"|\1"pywal"|' "$1"
	else
		echo 'Net/ThemeName "pywal"' >> $1
	fi
}

setICON_THEME() {
	verbose "Reloading Icon Theme..."	
	if grep -q "^Net/IconThemeName " $1; then
		sed -i 's|\(Net/IconThemeName \)"[^"]*"|\1"pywal"|' "$1"
	else
		echo 'Net/IconThemeName "pywal"' >> $1
	fi
}

# Reload Gtk themes using xsettingsd
reloadTHEMES() {
	local default_xsettings_config="$HOME/.xsettingsd.conf"
	local xsettingsd_config="$HOME/.config/xsettingsd/xsettingsd.conf"
	[ -f $xsettingsd_config ] || xsettingsd_config=$default_xsettings_config
	setGTK_THEME "$xsettingsd_config" & setICON_THEME "$xsettingsd_config" 
	command -v xsettingsd >/dev/null && pkill xsettingsd >/dev/null 2>&1 ;\
		xsettingsd -c $xsettingsd_config >/dev/null 2>&1 &
}

# Still pywalfox uses 'The Default OutDir in pywal so just link them to the default'
linkCONF_DIR() {	
	if [ -d "$DEFAULT_PYWAL16_OUT_DIR" ]; then
		for outFile in "$PYWAL16_OUT_DIR"/*; do
			local filename=`basename "$outFile"`
			if [ ! -e "$DEFAULT_PYWAL16_OUT_DIR/$filename" ]; then
				ln -s "$outFile" "$DEFAULT_PYWAL16_OUT_DIR/" >/dev/null
			fi
		done
	fi
}

applyToPrograms() {
	bash "$script_dir/theming/programs/genrate.sh"	
}
