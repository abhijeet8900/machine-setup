#!/bin/bash
# ============================
# macOS Setup Script: setup.sh
# Purpose: Install dev tools and configure macOS
# ============================

set -e  # Exit on any error

echo "🍎 Starting macOS Development Environment Setup..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS only!"
    exit 1
fi

# --- Install Homebrew if not present ---
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew already installed"
    brew update
fi

# --- Install Applications via Homebrew ---
echo "🔧 Installing development tools..."

# CLI Tools
brew_packages=(
    "git"
    "neovim"
    "python@3.12"
    "node"
    "podman"
    "wget"
    "curl"
    "tree"
    "htop"
    "jq"
)

for package in "${brew_packages[@]}"; do
    if brew list "$package" &>/dev/null; then
        echo "✅ $package already installed"
    else
        echo "📦 Installing $package..."
        brew install "$package"
    fi
done

# GUI Applications via Homebrew Cask
echo "🖥️ Installing GUI applications..."

cask_apps=(
    "visual-studio-code"
    "firefox"
    "google-chrome"
    "bitwarden"
    "discord"
    "steam"
    "wezterm"
    "stats"  # System monitor for macOS
)

for app in "${cask_apps[@]}"; do
    if brew list --cask "$app" &>/dev/null; then
        echo "✅ $app already installed"
    else
        echo "📦 Installing $app..."
        brew install --cask "$app"
    fi
done

# --- Configure Git ---
echo "⚙️ Configuring Git..."
git config --global user.name "Abhijeet Tilekar"
git config --global user.email "you@example.com"
git config --global core.editor "nvim"
git config --global init.defaultBranch "main"

# --- Clone and Setup Dotfiles ---
dotfiles_dir="$HOME/.dotfiles"
config_dir="$HOME/.config"

if [[ ! -d "$dotfiles_dir" ]]; then
    echo "📁 Cloning dotfiles..."
    git clone https://github.com/abhijeet8900/machine-setup "$dotfiles_dir"
else
    echo "✅ Dotfiles already present at $dotfiles_dir"
fi

# Create .config directory if it doesn't exist
mkdir -p "$config_dir"

# --- Setup symlinks for dotfiles ---
echo "🔗 Setting up dotfiles symlinks..."

declare -A dotfile_links=(
    ["$dotfiles_dir/.gitconfig"]="$HOME/.gitconfig"
    ["$dotfiles_dir/nvim"]="$config_dir/nvim"
    ["$dotfiles_dir/wezterm"]="$config_dir/wezterm"
)

for source in "${!dotfile_links[@]}"; do
    target="${dotfile_links[$source]}"
    if [[ -e "$source" ]]; then
        if [[ ! -L "$target" ]]; then
            echo "🔗 Linking $source → $target"
            ln -sf "$source" "$target"
        else
            echo "✅ Link already exists: $target"
        fi
    else
        echo "⚠️ Source not found: $source"
    fi
done

# --- macOS System Preferences ---
echo "🔧 Configuring macOS system preferences..."

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable automatic spelling correction
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Set fast key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Restart Finder to apply changes
killall Finder

# --- Install Oh My Zsh (optional) ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "🐚 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "✅ macOS setup complete!"
echo "📝 You may need to restart some applications or log out/in for all changes to take effect."
