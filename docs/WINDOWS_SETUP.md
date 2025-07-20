# 🖥️ Windows Setup Script

A fully automated PowerShell script to configure a Windows machine for development, gaming, and daily use.  
It installs essential applications, configures developer settings, disables telemetry, and sets up hardware monitoring.

---

## 🚀 Features

✅ Installs essential software:
- **Browsers**: Firefox  
- **Dev Tools**: VS Code, Neovim, Podman, NVM, Python  
- **System**: LibreHardwareMonitor, OpenRGB, PowerToys, CCleaner  
- **Gaming**: Steam, NVIDIA App, MSI Afterburner, Unigine Heaven Benchmark  
- **Utilities**: Bitwarden, Discord, WezTerm  

✅ Configures:
- [x] LibreHardwareMonitor & OpenRGB to autostart
- [x] Developer Mode
- [x] WSL with Ubuntu
- [x] OpenSSH Server

✅ Disables:
- Windows Copilot
- Cortana and Bing Search
- Location Access
- Typing Insights
- Ads, Suggestions, Widgets
- Telemetry and Feedback

---

## 📦 Requirements

- Windows 10/11 (Admin access required)
- PowerShell 5.1 or newer
- Internet connection
- Git + Winget available (Winget is preinstalled on recent versions of Windows)

---

## 🛠️ How to Use

> 🧑‍💻 Run in **PowerShell as Administrator**

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
irm https://raw.githubusercontent.com/abhijeet8900/machine-setup/main/windows/setup.ps1 | iex
