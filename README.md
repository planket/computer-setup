# computer-setup
repo of dotfiles and the like to set up new computers

# terminal profile saving and loading instructions
Save settings:

dconf dump /org/gnome/terminal/ > gnome_terminal_settings_backup.txt

Load the saved settings:

dconf load /org/gnome/terminal/ < gnome_terminal_settings_backup.txt

