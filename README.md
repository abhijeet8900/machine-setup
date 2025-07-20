
🧰 machine-setup

Cross-platform setup scripts for Windows, macOS, and Linux. Automates installation of development tools, applies system tweaks, and manages dotfiles.

## 🛠 What it does

**Windows:**
- Installs apps via winget (Steam, Chrome, VS Code, Neovim, Podman, etc.)
- Sets up WSL, OpenSSH, Developer Mode
- Applies registry tweaks (disable telemetry, Copilot, ads)
- Multi-phase setup with automatic restart handling

**macOS:**
- Installs tools via Homebrew (CLI tools + GUI apps)
- Configures system preferences (show hidden files, key repeat, etc.)
- Sets up Oh My Zsh

**Linux:**
- Supports Ubuntu/Debian, Fedora, and Arch Linux
- Installs packages via native package managers
- Sets up Podman, VS Code, and GUI apps (if desktop detected)
- Installs Node Version Manager (nvm)

**All Platforms:**
- Clones dotfiles and creates symlinks
- Configures Git with user settings
- Links configuration files: `.gitconfig`, `nvim/`, `wezterm/`, etc.

## 📂 Project Structure

```
machine-setup/
├── README.md                    # This file
├── windows/
│   └── setup.ps1               # Windows PowerShell script
├── macos/
│   └── setup.sh                # macOS bash script  
├── linux/
│   └── setup.sh                # Linux bash script
├── docs/
│   └── WINDOWS_SETUP.md        # Windows-specific documentation
├── configs/                    # (Reserved for future config files)
└── resources/                  # (Reserved for additional resources)
```

## ▶️ Quick Start

### Windows
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iwr -useb https://raw.githubusercontent.com/abhijeet8900/machine-setup/main/windows/setup.ps1 | iex
```

### macOS
```bash
curl -fsSL https://raw.githubusercontent.com/abhijeet8900/machine-setup/main/macos/setup.sh | bash
```

### Linux
```bash
curl -fsSL https://raw.githubusercontent.com/abhijeet8900/machine-setup/main/linux/setup.sh | bash
```

## 📋 Requirements

**Windows:**
- Windows 10/11 with Administrator access
- PowerShell 5.1 or newer
- Internet connection

**macOS:**
- macOS 10.15+ (Catalina or newer)
- Internet connection
- Xcode Command Line Tools (installed automatically)

**Linux:**
- Ubuntu/Debian, Fedora, or Arch Linux
- sudo access
- Internet connection

## 🔧 Customization

Before running the scripts, you may want to:

1. **Update Git configuration** in the scripts:
   - Change `user.name` and `user.email` to your details
   
2. **Modify application lists** to match your preferences:
   - Windows: Edit the `$apps` array in `windows/setup.ps1`
   - macOS: Edit `brew_packages` and `cask_apps` arrays in `macos/setup.sh`
   - Linux: Edit `packages` array in `linux/setup.sh`

3. **Review dotfiles setup** to ensure paths match your repository structure

## 🚨 Important Notes

- **Windows script requires Administrator privileges**
- **All scripts will modify system settings** - review before running
- **Dotfiles are cloned from this repository** - fork if you want custom configs
- **Scripts are idempotent** - safe to run multiple times

## 📖 Documentation

- [Windows Setup Guide](docs/WINDOWS_SETUP.md) - Detailed Windows script documentation

## 🤝 Contributing

Feel free to submit issues and pull requests to improve cross-platform compatibility or add new features.
