write_toml "
.colors.primary.background = \"$color0\" |
.colors.primary.foreground = \"$color15\" |
.colors.cursor.text = \"$color0\" |
.colors.cursor.cursor = \"$color7\" |
.colors.vi_mode_cursor.text = \"$color0\" |
.colors.vi_mode_cursor.cursor = \"$color15\" |
.colors.search.matches.foreground = \"$color0\" |
.colors.search.matches.background = \"$color15\" |
.colors.search.focused_match.foreground = \"CellBackground\" |
.colors.search.focused_match.background = \"CellForeground\" |
.colors.line_indicator.foreground = \"None\" |
.colors.line_indicator.background = \"None\" |
.colors.footer_bar.foreground = \"$color15\" |
.colors.footer_bar.background = \"$color7\" |
.colors.selection.text = \"CellBackground\" |
.colors.selection.background = \"CellForeground\" |

.colors.normal.black = \"$color0\" |
.colors.normal.red = \"$color1\" |
.colors.normal.green = \"$color2\" |
.colors.normal.yellow = \"$color3\" |
.colors.normal.blue = \"$color4\" |
.colors.normal.magenta = \"$color5\" |
.colors.normal.cyan = \"$color6\" |
.colors.normal.white = \"$color7\" |

.colors.bright.black = \"$color8\" |
.colors.bright.red = \"$color9\" |
.colors.bright.green = \"$color10\" |
.colors.bright.yellow = \"$color11\" |
.colors.bright.blue = \"$color12\" |
.colors.bright.magenta = \"$color13\" |
.colors.bright.cyan = \"$color14\" |
.colors.bright.white = \"$color15\"" "$1" &
