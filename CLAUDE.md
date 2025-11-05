# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal computer setup repository containing dotfiles, configuration files, and automation scripts for setting up new Linux systems. The primary target is **Omarchy** (an opinionated Arch Linux + Hyprland setup by DHH/Basecamp), but also includes legacy Sway configurations. It manages shell configurations (bash/zsh with oh-my-zsh), window manager setups, editor configurations (vim/neovim), and system package lists.

## Key Commands

### Quick Setup Scripts

```bash
# 1. Simple dotfiles symlink (shell configs only)
./simple_symlink.sh

# 2. Omarchy-specific configuration (Hyprland, terminal, browser, keybinds)
./omarchy_setup.sh

# 3. Legacy: Full dotfiles with backups (includes Sway configs)
./dotfiles_setup.sh
```

### Script Purposes

**`simple_symlink.sh`** - Minimal shell configuration
- Symlinks shell dotfiles (`.bashrc`, `.zshrc`, `.gitconfig`, `.p10k.zsh`) to `$HOME`
- Does NOT link window manager configs (Sway/Hyprland)
- No backups, just direct symlinks
- Use this for quick shell setup without window manager changes

**`omarchy_setup.sh`** - Omarchy/Hyprland configuration
- Configures terminal: **Kitty** (Omarchy defaults to Alacritty)
- Configures browser: **Firefox** (Omarchy defaults to Chromium)
- Configures Claude Code keybind: **SUPER+SHIFT+A**
- Sets `TERMINAL=kitty` environment variable in `~/.config/hypr/envs.conf`
- Uses `xdg-settings` to set default browser
- Modifies `~/.config/hypr/bindings.conf` with proper Hyprland `bindd` syntax
- Creates timestamped backups before changes

**`dotfiles_setup.sh`** - Legacy full setup (Sway-based)
- Creates timestamped backups in `~/.dotfiles_backup_YYYYMMDD_HHMMSS/`
- Symlinks all dotfiles AND Sway/Waybar/Wofi configs
- For systems using Sway instead of Hyprland

### GNOME Terminal Profile Management
```bash
# Save terminal settings
dconf dump /org/gnome/terminal/ > gnome_terminal_settings_backup.txt

# Load terminal settings
dconf load /org/gnome/terminal/ < gnome_terminal_settings_backup.txt
```

## Repository Structure

### Dotfiles Directory (`.dotfiles/`)
Contains all dotfiles for symlinking:
- **Shell configs**: `.bashrc`, `.zshrc`, `.p10k.zsh`, `.zshrc.pre-oh-my-zsh`
- **Git config**: `.gitconfig` (uses GitHub noreply email for privacy)
- **Legacy Sway configs**: `sway/config`, `waybar/`, `wofi/` (not used on Omarchy)

### Package/Program Lists
- `apt-packages.txt` - APT packages to install (btop, neovim, zsh, docker, kicad, etc.)
- `program-list` - Manual install programs (qbittorrent, protonvpn, etc.)
- `git-repos.txt` - Git repos to clone (oh-my-zsh, powerlevel10k, vim plugins)

### Configuration Files
- `init.vim` - Neovim/Vim configuration (manual copy needed)
- `gnome_terminal_settings_backup.txt` - GNOME Terminal dconf settings

## Architecture Notes

### Omarchy (Hyprland) Integration

**Omarchy** is an opinionated Arch + Hyprland distribution by DHH (Ruby on Rails creator). Key details:

- **Config location**: `~/.config/hypr/`
- **Modular structure**: Omarchy uses separate config files sourced into main `hyprland.conf`:
  - `bindings.conf` - Application keybinds (USER EDITABLE)
  - `envs.conf` - Environment variables (USER EDITABLE)
  - `monitors.conf`, `input.conf`, `looknfeel.conf`, `autostart.conf` (USER EDITABLE)
  - Default configs in `~/.local/share/omarchy/default/hypr/` (DO NOT EDIT)
  - Theme configs in `~/.config/omarchy/current/theme/`

- **Keybind syntax**: Uses Hyprland's `bindd` (bind with description)
  ```
  bindd = MODS, KEY, Description, exec, command
  ```
  Example: `bindd = SUPER SHIFT, B, Browser, exec, $browser`

- **Browser launcher**: `omarchy-launch-browser` script automatically detects default browser via `xdg-settings`
  - Supports Firefox, Zen, Librewolf (uses `--private-window`)
  - Falls back to Chromium-style browsers (uses `--incognito`)

- **Terminal**: Uses `$TERMINAL` environment variable wrapped with `uwsm` (Universal Wayland Session Manager)
  - Format: `$terminal = uwsm app -- $TERMINAL`

### Dotfiles Management Strategy

**Symlink-based approach** (not copy-based):
- Dotfiles live in the repo, symlinked to `$HOME`
- Edits to dotfiles automatically tracked in git
- Easy version control of all configuration changes
- `simple_symlink.sh` only links shell configs, not window manager configs

### Shell Configuration

- **Primary shell**: zsh with oh-my-zsh framework
- **Theme**: powerlevel10k (cloned via git-repos.txt)
- **Config files**:
  - `.zshrc` - Main zsh configuration
  - `.p10k.zsh` - Powerlevel10k theme settings
  - `.bashrc` - Bash fallback configuration
  - `.zshrc.pre-oh-my-zsh` - Backup of pre-oh-my-zsh config

### Legacy: Sway Window Manager Setup

The `.dotfiles/` directory contains Sway configs (Wayland compositor):
- Sway config with keybinds using `bindsym` syntax
- Waybar for status bar
- Wofi for application launching
- **Note**: These are NOT used on Omarchy (which uses Hyprland)

### Git Configuration

The `.gitconfig` uses GitHub's noreply email address for privacy:
- Email: `3517946+planket@users.noreply.github.com`
- Name: Joshua Plank

## Important Paths

All scripts assume the repository is cloned to:
```
/home/josh/code/computer-setup/
```

The `DOTFILES_DIR` variable is hardcoded to this path in all scripts.

## Omarchy Default Keybinds (Post-Setup)

After running `omarchy_setup.sh`:
- `SUPER+RETURN` - Terminal (kitty)
- `SUPER+SHIFT+B` - Browser (firefox)
- `SUPER+SHIFT+A` - Claude Code
- `SUPER+SHIFT+F` - File manager (Nautilus)
- `SUPER+SHIFT+N` - Editor
- `SUPER+D` - Application launcher

## Notes for Future Maintenance

1. **Omarchy updates**: Omarchy is actively developed. Keybind formats may change. The `omarchy_setup.sh` script detects the current format before making changes.

2. **Config precedence**: User configs in `~/.config/hypr/` override Omarchy defaults in `~/.local/share/omarchy/default/`. Always edit user configs, never defaults.

3. **Environment variables**: Changes to `envs.conf` require logout/login or Hyprland reload to take effect.

4. **Browser changes**: Use `xdg-settings set default-web-browser <browser>.desktop` or Omarchy's "Setup > Defaults" menu.
