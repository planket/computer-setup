#!/bin/bash

# Simple dotfiles symlink setup script
set -e

DOTFILES_DIR="/home/josh/code/computer-setup/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=== Dotfiles Symlink Setup ==="
echo "Dotfiles: $DOTFILES_DIR"
echo "Backup: $BACKUP_DIR"
echo ""

# Check dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${RED}Error: $DOTFILES_DIR not found${NC}"
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to create symlink
create_symlink() {
    local src="$1"
    local dest="$2"
    local name=$(basename "$dest")
    
    # Backup existing file
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo -e "${YELLOW}Backing up: $name${NC}"
        cp -r "$dest" "$BACKUP_DIR/"
    fi
    
    # Remove existing symlink
    if [ -L "$dest" ]; then
        rm "$dest"
    fi
    
    # Create symlink
    ln -s "$src" "$dest"
    echo -e "${GREEN}Linked: $name -> $src${NC}"
}

# Link dotfiles from root directory
echo "Linking dotfiles..."
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
    
    # Skip .config, handle separately
    if [ "$basename_file" = ".config" ]; then
        continue
    fi
    
    create_symlink "$file" "$HOME/$basename_file"
done

# Link .config items
if [ -d "$DOTFILES_DIR/.config" ]; then
    echo ""
    echo "Linking .config items..."
    mkdir -p "$HOME/.config"
    
    for item in "$DOTFILES_DIR/.config"/*; do
        if [ -e "$item" ]; then
            basename_item=$(basename "$item")
            create_symlink "$item" "$HOME/.config/$basename_item"
        fi
    done
fi

echo ""
echo -e "${GREEN}=== Done! ===${NC}"
echo "Backup location: $BACKUP_DIR"

# Remove backup if empty
if [ -z "$(ls -A $BACKUP_DIR)" ]; then
    rmdir "$BACKUP_DIR"
    echo "(No files were backed up)"
fi
