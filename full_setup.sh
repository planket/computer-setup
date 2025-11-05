#!/bin/bash

# Dotfiles symlink setup script with package installation
# This script creates symlinks from your home directory to your dotfiles
# and installs essential packages

set -e

DOTFILES_DIR="/home/josh/code/computer-setup/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Spinner function
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to run command with spinner
run_with_spinner() {
    local msg=$1
    shift
    echo -ne "${BLUE}${msg}${NC}"
    "$@" > /tmp/setup_output 2>&1 &
    spinner $!
    wait $!
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e " ${GREEN}✓${NC}"
    else
        echo -e " ${RED}✗${NC}"
        echo -e "${RED}Error output:${NC}"
        cat /tmp/setup_output
        return $exit_code
    fi
}

# Detect package manager
detect_package_manager() {
    if command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v apt &> /dev/null; then
        echo "apt"
    else
        echo "unknown"
    fi
}

echo -e "${CYAN}"
echo "╔════════════════════════════════════════╗"
echo "║   Dotfiles & Package Setup Script     ║"
echo "╔════════════════════════════════════════╝"
echo -e "${NC}"
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${RED}✗ Error: Dotfiles directory not found at $DOTFILES_DIR${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Dotfiles directory found${NC}"

# Detect package manager
PKG_MGR=$(detect_package_manager)
echo -e "${GREEN}✓ Detected package manager: $PKG_MGR${NC}"
echo ""

# Install packages
echo -e "${CYAN}═══ Installing Packages ═══${NC}"
echo ""

if [ "$PKG_MGR" = "pacman" ]; then
    echo -e "${YELLOW}→ Updating package database...${NC}"
    run_with_spinner "Syncing package database" sudo pacman -Sy --noconfirm
    
    PACKAGES="fzf zsh zoxide eza octave docker neovim"
    
    for pkg in $PACKAGES; do
        if pacman -Qi $pkg &> /dev/null; then
            echo -e "${GREEN}✓ $pkg already installed${NC}"
        else
            run_with_spinner "Installing $pkg" sudo pacman -S --noconfirm $pkg
        fi
    done
    
    # Install powerlevel10k from AUR or manual installation
    echo -e "${BLUE}→ Setting up Powerlevel10k...${NC}"
    if [ ! -d "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        run_with_spinner "Cloning Powerlevel10k" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k
    else
        echo -e "${GREEN}✓ Powerlevel10k already installed${NC}"
    fi
    
elif [ "$PKG_MGR" = "apt" ]; then
    echo -e "${YELLOW}→ Updating package lists...${NC}"
    run_with_spinner "Updating package lists" sudo apt update
    
    # Standard packages
    PACKAGES="fzf zsh zoxide octave docker.io neovim"
    
    for pkg in $PACKAGES; do
        if dpkg -l | grep -q "^ii  $pkg "; then
            echo -e "${GREEN}✓ $pkg already installed${NC}"
        else
            run_with_spinner "Installing $pkg" sudo apt install -y $pkg
        fi
    done
    
    # Install eza (requires special handling on apt systems)
    if command -v eza &> /dev/null; then
        echo -e "${GREEN}✓ eza already installed${NC}"
    else
        echo -e "${BLUE}→ Installing eza...${NC}"
        run_with_spinner "Adding eza repository" sudo mkdir -p /etc/apt/keyrings
        run_with_spinner "Downloading eza GPG key" wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        run_with_spinner "Updating package lists" sudo apt update
        run_with_spinner "Installing eza" sudo apt install -y eza
    fi
    
    # Install powerlevel10k
    echo -e "${BLUE}→ Setting up Powerlevel10k...${NC}"
    if [ ! -d "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        run_with_spinner "Cloning Powerlevel10k" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k
    else
        echo -e "${GREEN}✓ Powerlevel10k already installed${NC}"
    fi
else
    echo -e "${RED}✗ Unsupported package manager. Skipping package installation.${NC}"
fi

echo ""
echo -e "${CYAN}═══ Setting Up Dotfiles Symlinks ═══${NC}"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"
echo -e "${GREEN}✓ Backup directory created: $BACKUP_DIR${NC}"
echo ""

# Function to create symlink
create_symlink() {
    local src="$1"
    local dest="$2"
    local name=$(basename "$dest")
    
    # If destination exists and is not a symlink
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo -e "${YELLOW}  ⚠ Backing up existing: $name${NC}"
        mv "$dest" "$BACKUP_DIR/"
    fi
    
    # If destination is a symlink, remove it
    if [ -L "$dest" ]; then
        echo -e "${YELLOW}  ⚠ Removing old symlink: $name${NC}"
        rm "$dest"
    fi
    
    # Create the symlink
    ln -s "$src" "$dest"
    echo -e "${GREEN}  ✓ Linked: $name${NC}"
}

# Find all dotfiles (including those in subdirectories)
cd "$DOTFILES_DIR"

echo -e "${BLUE}→ Processing root dotfiles...${NC}"
# Process files in the root of dotfiles directory
file_count=0
for file in "$DOTFILES_DIR"/.*; do
    basename_file=$(basename "$file")
    
    # Skip . and .. and .git directory
    if [ "$basename_file" = "." ] || [ "$basename_file" = ".." ] || [ "$basename_file" = ".git" ]; then
        continue
    fi
    
    # Skip if not a file or directory
    if [ ! -e "$file" ]; then
        continue
    fi
    
    # Skip .config directory as we handle it separately
    if [ "$basename_file" = ".config" ]; then
        continue
    fi
    
    src="$file"
    dest="$HOME/$basename_file"
    
    create_symlink "$src" "$dest"
    ((file_count++))
done

if [ $file_count -eq 0 ]; then
    echo -e "${YELLOW}  No dotfiles found in root${NC}"
fi

# Handle .config directory specially if it exists
if [ -d "$DOTFILES_DIR/.config" ]; then
    echo ""
    echo -e "${BLUE}→ Processing .config directory...${NC}"
    
    # Ensure .config exists in home
    mkdir -p "$HOME/.config"
    
    # Link each item in .config separately
    config_count=0
    for item in "$DOTFILES_DIR/.config"/*; do
        if [ -e "$item" ]; then
            basename_item=$(basename "$item")
            src="$item"
            dest="$HOME/.config/$basename_item"
            create_symlink "$src" "$dest"
            ((config_count++))
        fi
    done
    
    if [ $config_count -eq 0 ]; then
        echo -e "${YELLOW}  No config files found${NC}"
    fi
fi

echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║          Setup Complete! 🎉            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Packages installed${NC}"
echo -e "${GREEN}✓ Dotfiles linked${NC}"
echo -e "${BLUE}  Backup location: $BACKUP_DIR${NC}"

# Remove backup directory if empty
if [ -z "$(ls -A $BACKUP_DIR)" ]; then
    rmdir "$BACKUP_DIR"
    echo -e "${BLUE}  (No files were backed up)${NC}"
fi

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Run 'chsh -s \$(which zsh)' to set Zsh as your default shell"
echo -e "  2. Log out and back in for shell change to take effect"
echo -e "  3. Configure Powerlevel10k with 'p10k configure'"
echo -e "  4. Add yourself to docker group: sudo usermod -aG docker \$USER"
echo ""
