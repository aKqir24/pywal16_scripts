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

