<h1 align="center"> walsetup </h1>

A bash script using the kdialog library to ease the configuration in [pywal16](https://github.com/eylles/pywal16).

> [!important] 
> The script may work in the using the normal `pywal` but it may fail to complete some steps of this script, so please use this fork of pywal called [pywal16](https://github.com/eylles/pywal16) in order to complete some steps in the script.

## SETUP
_**DEPENDENCIES**_
- `pywal16`
- `kdialog`
- A wallpaper setter (optional):
  - `feh`
  - `hsetroot`
  - `xwallpaper`

- Debian
```bash
  sudo apt install kdialog pipx
  pipx install pywal16
```

- Arch ( AUR )
```bash
  yay -S kdialog pywal16
```
Other linux based distro might be different, so it may take to update this `README` file...
To load the changes set from the GUI...
<br>
## USAGE
Run the following commands in your terminal:
```bash
  git clone https://github.com/aKqir24/walconfdialog.git
  cd ~/walsetup
  bash wallsetup.sh --gui # To setup the config first
```
After closing the GUI run:
```bash
  bash wallsetup.sh 
```
