![Prev](prev.gif)

<img src="thumb.png" align="center"></img>

A bash script using the kdialog library to ease the configuration in [pywal16](https://github.com/eylles/pywal16).

> [!important] 
> The script may work in the using the normal `pywal` but it may fail to complete some steps of this script, so please use this fork of pywal called [pywal16](https://github.com/eylles/pywal16) in order to complete some steps in the script, also the wallpapers are not uploaded in the repo, so please configure the wallpaper directory first.

## FEATURES
> [!warning]
> The gtk4 theming is still on testing process, and gtk3 has inconsistency in some programs like `bleachbit`. So better use gtk2 programs to if you want clean theming.

- Gui Dialog configuration along with pywal options.
- Pywal colors to some configurable programs. ( as toml config arrays )
- Uses the pywal16 option to either have a wallpaper in a folder or just an image.
- A wallpaper can be set either to `solid_color` or `image`
- Wallpaper setup options include[ fill, scale, max, fit, etc ]
- Dialog configuration with the --gui option explained below 
- Gtk theming based [wpgtk's templates](https://github.com/deviantfero/wpgtk-templates) as base theme.
- Icon colors based [Flat-Remix](https://github.com/daniruiz/Flat-Remix) icon pack.
- Relod gtk and icon themes using `xsettingd`.

## SETUP
_**DEPENDENCIES**_
- `pywal16`
- `kdialog`
- `imagemagick`
- `yq`
- `xsettingsd` (optional)
- A wallpaper setter (optional):
  - `feh`
  - `hsetroot`
  - `xwallpaper`
  - `nitrogen`
 
_**DISTRO**_
  - Debian ( or Other Debian based distro )
  ```bash
  sudo apt install kdialog pipx yq imagemagick xwallpaper
  pipx install pywal16
  ```

  - Arch / AUR
  ```bash
  # You can use something else that works for you like paru
  yay -S kdialog pywal16 yq imagemagick xwallpaper
  ```

## USAGE
Run the following commands in your terminal:

```bash
  git clone https://github.com/aKqir24/pywal16_scripts.git
  cd ~/pywal16_scripts
```

then use these option to configure it:

```bash
  bash walsetup.sh --help # For more information 
  bash walsetup.sh --gui # To Configure it
  bash walsetup.sh # To Only Load the recent configuration
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

## FUTURE PLANS
Things that I might add:
- [x] Add verbose option.
- [ ] Merge `waloml` & `walsetup` into one.
- [ ] Live wallpaper support either in GIF or MP4 fomat.
- [ ] Add a custom config_dir option.
- [ ] Custom bg-color & bgsetup setup.
- [x] Improve wallpaper setter support in some de's.
- [x] Full icon pywal adptation support
- [ ] Theming support for more terminals & appplications configs.
- [x] Fix dunst color generation.
