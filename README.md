
🧰 machine-setup

Personal setup scripts for Windows. Automates install of dev/gaming tools, applies system tweaks, and links dotfiles.
🛠 What it does

    Installs apps via winget (Steam, Chrome, VS Code, Neovim, Podman, etc.)

    Sets up WSL, OpenSSH, Developer Mode

    Applies registry tweaks (disable telemetry, Copilot, ads)

    Clones .dotfiles/ and symlinks:

        .bashrc, .zshrc, .gitconfig, nvim/, wezterm/

    Restarts and resumes automatically (multi-phase setup)

📂 Folder Structure

`
machine-setup/
├── setup.ps1 # Windows setup script
├── setup-mac.sh # (WIP) macOS setup
├── setup-linux.sh # (WIP) Linux setup
├── .dotfiles/ # Common config
│ ├── .bashrc
│ ├── .zshrc
│ ├── .gitconfig
│ ├── wezterm/
│ └── nvim/
`
▶️ Run on Windows

`powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iwr -useb https://raw.githubusercontent.com/abhijeet8900/machine-setup/main/setup.ps1 | iex
`
