#!/bin/zsh

INSTALL_DIR="$HOME/.zsh-history-autocomplete"
ZSH_CONFIG="$HOME/.zshrc"
SOURCE_LINE="source ${INSTALL_DIR}/init.zsh"
REPO_URL="https://raw.githubusercontent.com/end-y/zsh-history-autocomplete/main/src"
SRC_FILES=(config.zsh history.zsh highlight.zsh suggestion.zsh menu.zsh init.zsh)

# Uninstall with -d flag
if [[ "$1" == "-d" || "$1" == "--delete" || "$1" == "--uninstall" ]]; then
    if [[ -d "$INSTALL_DIR" ]]; then
        rm -rf "$INSTALL_DIR"
        sed -i '' "/source.*zsh-history-autocomplete/d" "$ZSH_CONFIG"
        echo "Uninstalled successfully."
        echo "Restart your terminal for changes to take effect."
    else
        echo "Zsh History Autocomplete is not installed."
    fi
    exit 0
fi

echo "Installing Zsh History Autocomplete..."

# Clean up old single-file install if it exists
OLD_SCRIPT="$HOME/.zsh_history_autocomplete.sh"
if [[ -f "$OLD_SCRIPT" ]]; then
    rm "$OLD_SCRIPT"
    sed -i '' "/source.*zsh_history_autocomplete\.sh/d" "$ZSH_CONFIG"
    echo "Removed old single-file installation."
fi

if [[ -d "$INSTALL_DIR" ]]; then
    echo "Zsh History Autocomplete is already installed."
    echo -n "Do you want to reinstall? (y/N): "
    read REPLY
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$INSTALL_DIR"
    else
        echo "Aborted."
        exit 0
    fi
fi

mkdir -p "$INSTALL_DIR"

# Try local copy first (for development), otherwise download from GitHub
SCRIPT_DIR="$(cd "$(dirname "$0" 2>/dev/null)" 2>/dev/null && pwd)"

if [[ -n "$SCRIPT_DIR" && -f "${SCRIPT_DIR}/src/init.zsh" ]]; then
    cp "${SCRIPT_DIR}/src/"*.zsh "$INSTALL_DIR/"
else
    echo "Downloading files..."
    for file in "${SRC_FILES[@]}"; do
        if ! curl -fsSL "${REPO_URL}/${file}" -o "${INSTALL_DIR}/${file}"; then
            echo "Failed to download ${file}. Aborting."
            rm -rf "$INSTALL_DIR"
            exit 1
        fi
    done
fi

echo "Installed to $INSTALL_DIR"

# Add source line to .zshrc
if ! grep -qF "$SOURCE_LINE" "$ZSH_CONFIG" 2>/dev/null; then
    echo "$SOURCE_LINE" >> "$ZSH_CONFIG"
    echo "Updated $ZSH_CONFIG"
else
    echo "$ZSH_CONFIG is already configured."
fi

echo ""
echo "Zsh History Autocomplete is now installed."
echo "Restart your terminal or run: source ${INSTALL_DIR}/init.zsh"
echo ""
echo "Configuration (add to .zshrc before the source line):"
echo "  ZSH_AUTOCOMPLETE_MAX_SUGGESTIONS=5   # max suggestions"
echo "  ZSH_AUTOCOMPLETE_FUZZY=1             # fuzzy matching (0=off)"
