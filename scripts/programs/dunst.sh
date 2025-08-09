write_toml "
.global.background = \"$color0\" |
.global.foreground = \"$color15\" |
.global.frame_color = \"$color2\" |
.urgency_low.background = \"$color0\" |
.urgency_low.foreground = \"$color15\" |
.urgency_low.frame_color = \"$color3\" |
.urgency_critical.background = \"$color0\" |
.urgency_critical.foreground = \"$color15\" |
.urgency_critical.frame_color = \"$color1\"" "$1" 

if pgrep -x dunst; then 
	pkill dunst && dunst &>/dev/null
fi
