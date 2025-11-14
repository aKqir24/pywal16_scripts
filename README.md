![Prev](prev.gif)

<img src="thumb.png" align="center"></img>

A bash script using the kdialog library to ease the configuration in [pywal16](https://github.com/eylles/pywal16).

> [!important] 
> The script may work in the using the normal `pywal` but it may fail to complete some steps of this script, so please use this fork of pywal called [pywal16](https://github.com/eylles/pywal16) in order to complete some steps in the script, also the wallpapers are not uploaded in the repo, so please configure the wallpaper directory first.

## FEATURES
- Gui Dialog configuration along with pywal options.
- Pywal colors to some configurable programs. ( as toml config arrays )
- Uses the pywal16 option to either have a wallpaper in a folder or just an image.
- A wallpaper can be set either to `solid_color` or `image`
- Wallpaper setup options include[ fill, scale, max, fit, etc ]
- Dialog configuration with the --gui option explained below 
- Gtk theming based [Flat-Remix-GTK](https://github.com/daniruiz/Flat-Remix-GTK) as base theme.
- Icon colors based [Flat-Remix](https://github.com/daniruiz/Flat-Remix) icon pack.
- Reload gtk and icon themes using `xsettingd`.

## SETUP
_**DEPENDENCIES**_
- `pywal16`
- `kdialog`
- `imagemagick`
- `yq`
- `xsettingsd` (optional)
- `python` & `python-gi`(for gui configuration)
- A wallpaper setter (optional):
  - `feh`
  - `hsetroot`
  - `xwallpaper`
  - `nitrogen`
  - `xgifwallpaper` (for gif wallpaper animations)
 
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
  --gui: To launch a configuration GUI and apply the configurations.
  --setup: Show dialogs that sets up the configurations in order.
  --reset: To remove all set features, and set them all to default.
  --verbose: To show log messages when each step of the script is executed.
  --help: to show how to use this script.
  --load:loads/applies the configurations
```
> [!note]
> Not all are covered like changing the values of a wm config file, in this script yet, so feel free to commit some improvements to it...

## FUTURE PLANS
Things that I might add:
- [x] Add verbose option.
- [x] Merge `waloml` & `walsetup` into one.
- [x] Live wallpaper support in GIF.
- [ ] Add a custom config_dir option.
- [ ] Custom bg-color & bgsetup setup.
- [x] Improve wallpaper setter support in some de's.
- [x] Full icon pywal adptation support
- [ ] Theming support for more terminals & appplications configs.
- [x] Fix dunst color generation.

## SPEACIAL THANKS
- `deviantfero`: [wpgtk's templates](https://github.com/deviantfero/wpgtk-templates) for the _gtk2/3_ base theme.
- `daniruiz`: [Flat-Remix-GTK](https://github.com/daniruiz/Flat-Remix-GTK) for the _gtk4_ base theme.
- `daniruiz`: [Flat-Remix-Icon_Pack](https://github.com/daniruiz/Flat-Remix) for the base icon pack.
- `eylles`: [build-gradience.py](https://github.com/eylles/pywal16-libadwaita/blob/master/scripts/build-gradience.py) it helped me fixed the _gtk4_ issue.
- `eylles`: [pywal16](https://github.com/eylles/pywal16) which make this program possible.
