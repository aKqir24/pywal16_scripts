<h1 align="center"> walsetup </h1>

A bash script using the kdialog library to ease the configuration in [pywal16](https://github.com/eylles/pywal16).

> [!important] 
> The script may work in the using the normal `pywal` but it may fail to complete some steps of this script, so please use this fork of pywal called [pywal16](https://github.com/eylles/pywal16) in order to complete some steps in the script.

## SETUP
First install kdialog & other dependencies:

- Debian
```bash
  sudo apt install kdialog python3-pip
  pip install pywal16 --break-system-packages
```

- Arch
```bash
  yay -S kdialog 
```

Run the following commands in your terminal:
```bash
  git clone https://github.com/aKqir24/walconfdialog.git
  cd ~/walsetup
  bash wallconfdialog.sh --gui
```


