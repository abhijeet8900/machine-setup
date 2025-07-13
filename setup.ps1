# ============================
# PowerShell Script: setup.ps1
# Purpose: Install apps + disable AI/telemetry
# Run as Administrator
# ============================

# --- Apps via Winget ---
$apps = @(
    "Valve.Steam",
    "Mozilla.Firefox",
    "Google.Chrome",
    "Bitwarden.Bitwarden",
    "Discord.Discord",
    "Microsoft.PowerToys",
    "Piriform.CCleaner",
    "Wez.WezTerm",
    "Microsoft.VisualStudioCode",
    "Neovim.Neovim",
    "RedHat.Podman",
    "Podman.PodmanDesktop",
    "CoreyButler.NVMforWindows",
    "Python.Python.3",
    "MSI.Afterburner",
    "Unigine.HeavenBenchmark",
    "Git.Git"
)

foreach ($app in $apps) {
    $isInstalled = winget list --id $app -e | Where-Object { $_ -match $app }
    if ($isInstalled) {
        Write-Host "$app is already installed." -ForegroundColor Yellow
    } else {
        Write-Host "Installing $app..." -ForegroundColor Cyan
        winget install --id $app -e --accept-source-agreements --accept-package-agreements
    }
}

# --- Configure Git and Sync Dotfiles ---
$dotfilesDir = "$HOME\.dotfiles"
if (-Not (Test-Path $dotfilesDir)) {
    Write-Host "Cloning dotfiles..." -ForegroundColor Cyan
    git clone https://github.com/abhijeet8900/machine-setup $dotfilesDir
} else {
    Write-Host "Dotfiles already present at $dotfilesDir" -ForegroundColor Yellow
}

# Optional: configure global git settings
Write-Host "Setting global Git config..." -ForegroundColor Cyan
git config --global user.name "Abhijeet Tilekar"
git config --global user.email "you@example.com"
git config --global core.editor "nvim"

# --- Install LibreHardwareMonitor ---
$lhmRepo = "https://github.com/LibreHardwareMonitor/LibreHardwareMonitor/releases/download/v0.9.2/LibreHardwareMonitor.zip"
$lhmDest = "$env:ProgramFiles\LibreHardwareMonitor"
$lhmZip = "$env:TEMP\LibreHardwareMonitor.zip"

if (-Not (Test-Path "$lhmDest\LibreHardwareMonitor.exe")) {
    Write-Host "Downloading LibreHardwareMonitor..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $lhmRepo -OutFile $lhmZip -ErrorAction Stop
        Write-Host "Extracting LibreHardwareMonitor..." -ForegroundColor Cyan
        Expand-Archive -Path $lhmZip -DestinationPath $lhmDest -Force
    } catch {
        Write-Host "❌ Failed to download LibreHardwareMonitor. Please check the URL or your connection." -ForegroundColor Red
    }
}

# --- Add LibreHardwareMonitor to Startup ---
$lhmExe = "$lhmDest\LibreHardwareMonitor.exe"
if (Test-Path $lhmExe) {
    Write-Host "Adding LibreHardwareMonitor to startup..." -ForegroundColor Cyan
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\LibreHardwareMonitor.lnk")
    $Shortcut.TargetPath = $lhmExe
    $Shortcut.Arguments = "--minimized"
    $Shortcut.Save()
}

# --- Create shortcut if OpenRGB is installed ---
$openrgb = "$Env:ProgramFiles\OpenRGB\OpenRGB.exe"
if (Test-Path $openrgb) {
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\OpenRGB.lnk")
    $Shortcut.TargetPath = $openrgb
    $Shortcut.Save()
}

# --- Enable required features for WSL ---
Write-Host "Enabling WSL-related features..." -ForegroundColor Cyan
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

# --- Enable WSL ---
Write-Host "Installing WSL and Ubuntu..." -ForegroundColor Cyan
wsl --install

# --- Enable OpenSSH Server ---
Write-Host "Installing OpenSSH Server..." -ForegroundColor Cyan
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# --- Enable Developer Mode ---
Write-Host "Enabling Developer Mode..." -ForegroundColor Cyan
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"

# --- Disable Copilot, AI, Ads, Telemetry, Suggestions, Widgets ---
Write-Host "Disabling AI and telemetry features..." -ForegroundColor Yellow

# Copilot
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows" -Name "WindowsCopilot" -Force
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -PropertyType DWord -Value 1 -Force

# Cortana and Bing Search
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /t REG_DWORD /d 0 /f
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v IsDynamicSearchBoxEnabled /t REG_DWORD /d 0 /f

# Ads
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f

# Typing Insights
Reg Add "HKCU\Software\Microsoft\Input\TIPC" /v Enabled /t REG_DWORD /d 0 /f

# Location Access
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v Value /t REG_SZ /d Deny /f

# Feedback / Telemetry
Reg Add "HKCU\Software\Microsoft\Siuf\Rules" /v NumberOfSIUFInPeriod /t REG_DWORD /d 0 /f
Reg Add "HKCU\Software\Microsoft\Siuf\Rules" /v PeriodInDays /t REG_DWORD /d 0 /f
Reg Add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

# Suggested Apps in Start Menu
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f

# Widgets (Windows Web Experience Pack)
winget uninstall "Windows Web Experience Pack"

Write-Host "✅ Setup Complete. Please restart your system to apply all changes." -ForegroundColor Green
