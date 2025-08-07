# Manage Options
HELP_MESSAGE="
Info:
'walsetup.sh' is a wrapper for pywal16 purely in shell script and made by aKqir24,
to ease the configuration in pywal, also it adds more functionality in pywal16 which
are writen in the https://github.com/aKqir24/pywal16_scripts.

Usage: $0 [OPTIONS]
  --gui: To launch a configuration dialogs and apply the configurations.
  --verbose: To show log messages when each step of the script is executed.
  --help: to show how to use this script.
  *: 'not putting any options' loads/applies the configurations.
"

# Functions than is defined to handle disagreements, errors, and info's
verbose() { [ "$VERBOSE" = true ] && echo "walsetup: $1"; }
wallsetERROR() { kdialog --error "Failed to set wallpaper..."; exit 1; }
pywalerror() { kdialog --msgbox "pywal ran into an error!\nplease run 'bash $0 --gui' first" ; exit 1 ; }
wallSETTERError() { kdialog --msgbox "No Wallpaper setter found!\nSo wallpaper is not set..."; }
cancelCONFIG() { verbose "Configuration Gui was canceled!, it might cause some problems when loading the configuration!"; exit 0; }
