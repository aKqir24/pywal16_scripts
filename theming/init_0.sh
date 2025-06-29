# i3status-rust
bash $PYWAL16_OUT_DIR/theming/toml_theming.sh --i3status-rs\
	~/.config/i3/status/config.toml

# Alacritty
bash $PYWAL16_OUT_DIR/theming/toml_theming.sh --alacritty

# Dunst
bash $PYWAL16_OUT_DIR/theming/toml_theming.sh --dunst
pkill dunst ; dunst & 

# Rofi Launcher
sh $PYWAL16_OUT_DIR/theming/rofi.sh

# Firefox Based Browsers
pywalfox update ; pywalfox dark &

# GTK Theme colors
sh $PYWAL16_OUT_DIR/theming/gtk/gen_gtk_2.sh
sh $PYWAL16_OUT_DIR/theming/gtk/gen_gtk_3.sh
sh $PYWAL16_OUT_DIR/theming/gtk/gen_gtk_3.20.sh
killall -HUP xsettingsd || xsettingsd &
