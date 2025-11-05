#!/bin/bash
# Omarchy-specific Hyprland configuration setup
# Configures: kitty terminal, firefox browser, claude code keybind

set -e

HYPR_BINDINGS="$HOME/.config/hypr/bindings.conf"
HYPR_ENVS="$HOME/.config/hypr/envs.conf"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo "=== Omarchy Hyprland Configuration Setup ==="
echo ""

# Check if running on Omarchy
if [ ! -d "$HOME/.local/share/omarchy" ]; then
    echo -e "${YELLOW}Warning: Omarchy directory not found. This script is designed for Omarchy.${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if Hyprland bindings config exists
if [ ! -f "$HYPR_BINDINGS" ]; then
    echo -e "${RED}Error: Hyprland bindings config not found at $HYPR_BINDINGS${NC}"
    echo "Make sure you're running this on an Omarchy installation."
    exit 1
fi

# Create backup
BACKUP_FILE="${HYPR_BINDINGS}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$HYPR_BINDINGS" "$BACKUP_FILE"
echo -e "${BLUE}✓ Created backup: $BACKUP_FILE${NC}"
echo ""

# 1. Configure Terminal to Kitty
echo "=== Configuring Terminal (Kitty) ==="

# Set TERMINAL environment variable
if ! grep -q "^env = TERMINAL,kitty" "$HYPR_ENVS"; then
    echo "env = TERMINAL,kitty" >> "$HYPR_ENVS"
    echo -e "${GREEN}✓ Added TERMINAL=kitty to envs.conf${NC}"
else
    echo -e "${BLUE}Terminal already set to kitty in envs.conf${NC}"
fi

# Also set system-wide default via XDG
if command -v xdg-settings &> /dev/null; then
    export TERMINAL=kitty
    echo -e "${GREEN}✓ Set TERMINAL environment variable${NC}"
fi

echo ""

# 2. Configure Browser to Firefox
echo "=== Configuring Browser (Firefox) ==="

# Set default browser via xdg-settings
if command -v xdg-settings &> /dev/null; then
    xdg-settings set default-web-browser firefox.desktop
    echo -e "${GREEN}✓ Set default browser to Firefox via xdg-settings${NC}"
else
    echo -e "${YELLOW}Warning: xdg-settings not found, skipping browser configuration${NC}"
fi

# Verify the browser keybind uses the omarchy-launch-browser script
if grep -q '^\$browser = omarchy-launch-browser' "$HYPR_BINDINGS"; then
    echo -e "${BLUE}Browser keybind correctly uses omarchy-launch-browser (will use Firefox)${NC}"
elif ! grep -q '^\$browser' "$HYPR_BINDINGS"; then
    # Add browser variable if it doesn't exist
    sed -i '1a $browser = omarchy-launch-browser' "$HYPR_BINDINGS"
    echo -e "${GREEN}✓ Added browser variable${NC}"
fi

echo ""

# 3. Configure Claude Code keybind
echo "=== Configuring Claude Code (SUPER+SHIFT+A) ==="

# Check if Claude Code keybind already exists
if grep -q "^bindd.*SUPER SHIFT, A.*Claude" "$HYPR_BINDINGS"; then
    echo -e "${BLUE}Claude Code keybind already exists${NC}"

    # Verify it's using the correct command
    current_line=$(grep "^bindd.*SUPER SHIFT, A.*Claude" "$HYPR_BINDINGS")
    if [[ "$current_line" =~ "bash claude" ]] || [[ "$current_line" =~ "claude" ]]; then
        echo -e "${GREEN}✓ Claude Code keybind is correctly configured${NC}"
        # Fix if it's using "bash claude" instead of just "claude"
        if [[ "$current_line" =~ "bash claude" ]]; then
            sed -i 's|\(bindd = SUPER SHIFT, A, Claude Code, exec, \$terminal -e \)bash claude|\1claude|' "$HYPR_BINDINGS"
            echo -e "${GREEN}✓ Fixed Claude Code command (removed 'bash')${NC}"
        fi
    else
        echo -e "${YELLOW}Warning: Claude Code keybind exists but may be misconfigured${NC}"
        echo "Current: $current_line"
    fi
else
    # Remove old chatgpt/gpt keybinds if they exist
    sed -i '/chatgpt\|ChatGPT/d' "$HYPR_BINDINGS"

    # Add Claude Code keybind after the browser keybind section
    if ! grep -q "^bindd = SUPER SHIFT, A, Claude Code" "$HYPR_BINDINGS"; then
        # Find the line with browser keybind and add Claude after it
        sed -i '/^bindd = SUPER SHIFT, B, Browser/a \\nbindd = SUPER SHIFT, A, Claude Code, exec, $terminal -e claude' "$HYPR_BINDINGS"
        echo -e "${GREEN}✓ Added Claude Code keybind${NC}"
    fi
fi

echo ""

# Validation
echo "=== Validation ==="
echo ""

echo -e "${BLUE}Terminal Configuration:${NC}"
grep "^env = TERMINAL" "$HYPR_ENVS" 2>/dev/null || echo "  (Using default)"
echo "  Current: $TERMINAL"

echo ""
echo -e "${BLUE}Browser Configuration:${NC}"
xdg-settings get default-web-browser
grep "^\$browser" "$HYPR_BINDINGS" | head -1

echo ""
echo -e "${BLUE}Application Keybinds:${NC}"
grep "^bindd = SUPER" "$HYPR_BINDINGS" | grep -E "(Terminal|Browser|Claude)" | head -5

echo ""
echo -e "${GREEN}=== Configuration Complete! ===${NC}"
echo ""
echo -e "${YELLOW}To apply changes:${NC}"
echo "  1. Logout and login again (to apply environment variables)"
echo "  2. Or reload Hyprland: SUPER+SHIFT+C then type 'reload'"
echo ""
echo -e "${BLUE}Keybinds:${NC}"
echo "  SUPER+RETURN      - Terminal (kitty)"
echo "  SUPER+SHIFT+B     - Browser (firefox)"
echo "  SUPER+SHIFT+A     - Claude Code"
echo ""
echo -e "${BLUE}Tip:${NC} Omarchy's browser launcher automatically detects your default browser."
echo "You can also change it via: Setup > Defaults"
