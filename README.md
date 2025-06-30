<h1 align="center"> pywal16_scripts </h1>

A bash script using the kdialog library to ease the configuration in [pywal16](https://github.com/eylles/pywal16).

> [!important] 
> The script may work in the using the normal `pywal` but it may fail to complete some steps of this script, so please use this fork of pywal called [pywal16](https://github.com/eylles/pywal16) in order to complete some steps in the script.

## SETUP
_**DEPENDENCIES**_
- `pywal16`
- `kdialog`
- `imagemagick`
- `yq`
- A wallpaper setter (optional):
  - `feh`
  - `hsetroot`
  - `xwallpaper`

- Debian
```bash
  sudo apt install kdialog pipx yq imagemagick xwallpaper
  pipx install pywal16
```

- Arch ( AUR )
```bash
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
A simple bash script that makes use of kdialog to configure `pywal16`, so that you don't need to type a lot of commands. In addition, I added some features like wallpapers now be able to be solid or not, a setting for the wallpaper to be either fill, scale, and etc, then I added a script to generate gtk themes after pywal16 is done executing using [wpgtk's templates](https://github.com/deviantfero/wpgtk-templates) for generating them...
```bash
  bash walsetup.sh --gui #To Configure it
  bash walsetup.sh #To Only Load the recent configuration
```
### waloml (pywal+toml)
- _Change i3status-rs theme_
```bash
  waloml.sh --i3status-rs [CONFIG_FILE]
  bash wal.sh
```
- _Change Alacritty colors_
```bash
  bash waloml.sh --alacritty [CONFIG_FILE]
```
- _Change Dunst Colors_
```bash
  bash waloml.sh --dunst
  pkill dunst ; dunst & 
```
## Future Plans
Things that I might add:

- `walsetup` custom bg-color&bgsetup setup
- `walsetup` support in de's
- `walsetup` Full icon pywal adptation support
- `waloml` support for more terminals & appplications
