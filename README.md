![Prev](prev.gif)

<img src="thumb.png" align="center"></img>

A bash script using the kdialog library to ease the configuration in [pywal16](https://github.com/eylles/pywal16).

> [!important] 
> The script may work in the using the normal `pywal` but it may fail to complete some steps of this script, so please use this fork of pywal called [pywal16](https://github.com/eylles/pywal16) in order to complete some steps in the script.

## SETUP
_**DEPENDENCIES**_
- `pywal16`
- `kdialog`
- `imagemagick`
- `yq`
- `xsettingsd`
- A wallpaper setter (optional):
  - `feh`
  - `hsetroot`
  - `xwallpaper`
  - `nitrogen`

- Debian ( or Other Debian based distro )
```bash
  sudo apt install kdialog pipx yq imagemagick xwallpaper
  pipx install pywal16
```

- Arch ( AUR )
```bash
  # You can use something else that works for you like paru
  yay -S kdialog pywal16 yq imagemagick xwallpaper
```
Other linux based distro might be different, so it may take to update this `README.md` file...
To load the changes set from the GUI...
<br>
## USAGE
Run the following commands in your terminal:
```bash
  git clone https://github.com/aKqir24/pywal16_scripts.git
  cd ~/pywal16_scripts
```
### walsetup (pywal+setup)
A simple script to implement `pywal16` colors and making the configuration much easier.

**This script includes:**
- Dialog configuration along with pywal options
- Uses the pywal16 option to either have a wallpaper in a folder or just an image.
- A wallpaper can be set either to `solid_color` or `image`
- Wallpaper setup options include[ fill, scale, max, fit, etc ]
- Dialog configuration with the --gui option explained below 
- Gtk theming based [wpgtk's templates](https://github.com/deviantfero/wpgtk-templates) as base theme.
- Icon colors based [Flat-Remix](https://github.com/daniruiz/Flat-Remix) icon pack.
- Relod gtk and icon themes using `xsettingd`.

```bash
  bash walsetup.sh --help # For more information 
  bash walsetup.sh --gui # To Configure it
  bash walsetup.sh # To Only Load the recent configuration
```

### waloml (pywal+toml)
It fetches the generated pywal16 colors, and apply it to these specific programs.
> [!Important]
> Make sure you run the `walsetup` script first before running this script.
```bash
  # Change i3status-rs theme
  bash waloml.sh --i3status-rs=[CONFIG_FILE]

  # Change Alacritty colors_
  bash waloml.sh --alacritty=[CONFIG_FILE]

  # Change Dunst Colors_
  bash waloml.sh --dunst=[CONFIG_FILE]
```

## EXTRA
This script was especially made for i3wm using the debian 13 linux distro, so I highly recommend you check it out.

If you happen to use .xinit with i3wm and with or not my [dotfiles](https://aKqir24/.files), I already prepared the script for this here, just put it in you `.xinit file` or just look into my [dotfiles](https://aKqir24/.files):

```bash
bash $HOME/(script_folder)/walsetup.sh # To load the configuration!!
bash $HOME/(script_folder)/waloml.sh --alacritty --dunst \
	--i3status-rs=~/.files/.config/i3/status/config.toml
exec i3
```
> [!note]
> Not all are covered like changing the values of a wm config file, in this script yet, so feel free to commit some improvements to it...

## Future Plans
Things that I might add:
- [x] `walsetup` add verbose option.
- [ ] `walsetup` add a custom config_dir option.
- [ ] `walsetup` custom bg-color & bgsetup setup.
- [x] `walsetup` wallpaper setter support in some de's.
- [x] `walsetup` Full icon pywal adptation support.
- [x] `waloml` improve adding options.
- [ ] `waloml` support for more terminals & appplications.
- [x] `waloml` fix dunst color generation.
