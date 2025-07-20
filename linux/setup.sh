#!/bin/bash
# ============================
# Linux Setup Script: setup.sh
# Purpose: Install dev tools and configure Linux
# ============================

set -e  # Exit on any error

echo "🐧 Starting Linux Development Environment Setup..."

# Detect Linux distribution
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "❌ Cannot detect Linux distribution!"
    exit 1
fi

echo "📋 Detected distribution: $DISTRO"

# --- Update package manager ---
echo "🔄 Updating package manager..."
case $DISTRO in
    ubuntu|debian)
        sudo apt update && sudo apt upgrade -y
        INSTALL_CMD="sudo apt install -y"
        ;;
    fedora)
        sudo dnf update -y
        INSTALL_CMD="sudo dnf install -y"
        ;;
    arch|manjaro)
        sudo pacman -Syu --noconfirm
        INSTALL_CMD="sudo pacman -S --noconfirm"
        ;;
    *)
        echo "⚠️ Unsupported distribution: $DISTRO"
        echo "This script supports Ubuntu/Debian, Fedora, and Arch Linux"
        exit 1
        ;;
esac

# --- Install essential packages ---
echo "📦 Installing essential development tools..."

case $DISTRO in
    ubuntu|debian)
        packages=(
            "git"
            "curl"
            "wget"
            "neovim"
            "python3"
            "python3-pip"
            "nodejs"
            "npm"
            "build-essential"
            "htop"
            "tree"
            "jq"
            "unzip"
            "software-properties-common"
            "apt-transport-https"
            "ca-certificates"
            "gnupg"
            "lsb-release"
        )
        ;;
    fedora)
        packages=(
            "git"
            "curl"
            "wget"
            "neovim"
            "python3"
            "python3-pip"
            "nodejs"
            "npm"
            "@development-tools"
            "htop"
            "tree"
            "jq"
            "unzip"
        )
        ;;
    arch|manjaro)
        packages=(
            "git"
            "curl"
            "wget"
            "neovim"
            "python"
            "python-pip"
            "nodejs"
            "npm"
            "base-devel"
            "htop"
            "tree"
            "jq"
            "unzip"
        )
        ;;
esac

for package in "${packages[@]}"; do
    echo "📦 Installing $package..."
    $INSTALL_CMD "$package"
done

# --- Install Podman ---
echo "🐳 Installing Podman..."
case $DISTRO in
    ubuntu|debian)
        # Add Podman repository
        curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$(lsb_release -rs)/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$(lsb_release -rs)/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:unstable.list > /dev/null
        sudo apt update
        sudo apt install -y podman
        ;;
    fedora)
        sudo dnf install -y podman
        ;;
    arch|manjaro)
        sudo pacman -S --noconfirm podman
        ;;
esac

# --- Install VS Code ---
echo "💻 Installing Visual Studio Code..."
case $DISTRO in
    ubuntu|debian)
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        sudo apt update
        sudo apt install -y code
        ;;
    fedora)
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo dnf install -y code
        ;;
    arch|manjaro)
        # Install from AUR using yay if available, otherwise use snap
        if command -v yay &> /dev/null; then
            yay -S --noconfirm visual-studio-code-bin
        else
            echo "⚠️ Installing VS Code via snap (consider installing yay for AUR access)"
            sudo pacman -S --noconfirm snapd
            sudo snap install code --classic
        fi
        ;;
esac

# --- Install additional GUI applications (if desktop environment detected) ---
if [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
    echo "🖥️ Desktop environment detected, installing GUI applications..."
    
    case $DISTRO in
        ubuntu|debian)
            # Add Flathub repository
            sudo apt install -y flatpak
            sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            
            # Install GUI apps via Flatpak
            flatpak install -y flathub org.mozilla.firefox
            flatpak install -y flathub com.google.Chrome
            flatpak install -y flathub com.bitwarden.desktop
            flatpak install -y flathub com.discordapp.Discord
            flatpak install -y flathub com.valvesoftware.Steam
            ;;
        fedora)
            sudo dnf install -y firefox google-chrome-stable discord steam
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm firefox chromium discord steam
            ;;
    esac
fi

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
    ["$dotfiles_dir/.bashrc"]="$HOME/.bashrc"
    ["$dotfiles_dir/.zshrc"]="$HOME/.zshrc"
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

# --- Install Oh My Zsh (if zsh is available) ---
if command -v zsh &> /dev/null; then
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "🐚 Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
fi

# --- Setup development environment ---
echo "🔧 Setting up development environment..."

# Install Node Version Manager (nvm)
if [[ ! -d "$HOME/.nvm" ]]; then
    echo "📦 Installing Node Version Manager..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
fi

echo "✅ Linux setup complete!"
echo "📝 You may need to restart your terminal or log out/in for all changes to take effect."
echo "🔄 Run 'source ~/.bashrc' or 'source ~/.zshrc' to reload your shell configuration."
