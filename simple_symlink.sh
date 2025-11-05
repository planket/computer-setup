#!/bin/bash
# Simple dotfiles symlink script - creates symlinks without backups

set -e

DOTFILES_DIR="/home/josh/code/computer-setup/.dotfiles"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Simple Dotfiles Symlink Setup ==="
echo "Dotfiles: $DOTFILES_DIR -> $HOME"
echo ""

# Check dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${RED}Error: $DOTFILES_DIR not found${NC}"
    exit 1
fi

# Function to create symlink
create_symlink() {
    local src="$1"
    local dest="$2"
    local name=$(basename "$dest")

    # Remove existing file or symlink
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        rm -rf "$dest"
    fi

    # Create symlink
    ln -s "$src" "$dest"
    echo -e "${GREEN}✓ Linked: $name${NC}"
}

# Link dotfiles from root directory
echo "Linking shell configuration files..."
for file in "$DOTFILES_DIR"/.*; do
    basename_file=$(basename "$file")

    # Skip special entries
    if [ "$basename_file" = "." ] || [ "$basename_file" = ".." ] || [ "$basename_file" = ".git" ]; then
        continue
    fi

    # Skip if doesn't exist
    if [ ! -e "$file" ]; then
        continue
    fi

    # Skip directories (sway, waybar, wofi) - these are window manager specific
    if [ -d "$file" ]; then
        continue
    fi

    create_symlink "$file" "$HOME/$basename_file"
done

echo ""
echo -e "${GREEN}=== Done! ===${NC}"
echo -e "${YELLOW}Note: Window manager configs (Sway/Hyprland) are not linked automatically.${NC}"
echo -e "${YELLOW}Use omarchy_setup.sh for Omarchy/Hyprland-specific configuration.${NC}"
