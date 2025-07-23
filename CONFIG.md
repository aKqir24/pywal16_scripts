# Configuration File
If you don't want bloat in your system like me, sometimes, you can just 
edit the config file in your '$HOME/.config/walsetup.conf'. I still working on
how to make a '--config' option, but for now that's the only option.

`wallpaper_path`=[ IMAGE_FILE | IMAGE_FOLDER ]
  - It is the path either to an wallpaper file directory or folder
    that this script uses. Note, when using a wallpaper folder you 
	need to define th wallpaper_cycle also.

`wallpaper_cycle`=[iterative, recursive]
  - How a wallpaper is choosen in a wallpaper folder.

`type`=[ None | Image | Solid ]
  - Sets your wallpaper wit these options, none basically means don't
    set my wallpaper.

`mode`=[ center | fill | tile | full | cover ]
  - How the wallpaper behaves when it is applied by the available setter

`backend`=[ wal | colorz | haishoku | okthief | modern_colorthief | colorthief ]
  - What backend pywal will use in generating a colorscheme.

`gtk_apply`=[ true | false ]
  - Generate a gtk theme then apply it.

`gtk_accent`=[0-15]
  - The primary color used in gtk_apply, eg: primary and active

`gen_color16`=[ lighten | darken ]
  - pywal16's new 16 colorsheme generation
