# ============================
# PowerShell Script: setup.ps1
# Purpose: Install apps + disable AI/telemetry
# Run as Administrator
# ============================

$installResults = @{}

# Track current phase to resume post-reboot
$setupPhaseFile = "$env:TEMP\windows_setup_phase.txt"
$phase = if (Test-Path $setupPhaseFile) { Get-Content $setupPhaseFile } else { "phase1" }

# --- Define central dotfiles/config folder ---
$dotfilesRoot = "$HOME\.dotfiles"
$configRoot = "$HOME\.config"

if (-not (Test-Path $configRoot)) {
    New-Item -Path $configRoot -ItemType Directory | Out-Null
    Write-Host "Created config directory at $configRoot" -ForegroundColor Cyan
}

if ($phase -eq "phase1") {
    # --- Apps via Winget ---
    $apps = @(
        "Valve.Steam",
        "Mozilla.Firefox",
        "Google.Chrome",
        "Bitwarden.Bitwarden",
        "Discord.Discord",
        "Microsoft.PowerToys",
        "Piriform.CCleaner",
        "wez.wezterm",
        "Microsoft.VisualStudioCode",
        "Neovim.Neovim",
        "RedHat.Podman",
        "Python.Python.3.12",
        "Unigine.HeavenBenchmark",
        "Git.Git",
        "AutoHotkey.AutoHotkey",
        "LibreHardwareMonitor.LibreHardwareMonitor"
    )

    foreach ($app in $apps) {
        $isInstalled = winget list --id $app -e | Where-Object { $_ -match $app }
        if ($isInstalled) {
            Write-Host "$app is already installed." -ForegroundColor Yellow
            $installResults[$app] = "Already Installed"
        } else {
            Write-Host "Installing $app..." -ForegroundColor Cyan
            try {
                winget install --id $app -e --accept-source-agreements --accept-package-agreements
                $installResults[$app] = "Installed"
            } catch {
                Write-Host "❌ Failed to install $app." -ForegroundColor Red
                $installResults[$app] = "Failed"
            }
        }
    }

    # --- Add LibreHardwareMonitor to Startup ---
    $lhmPath = "$Env:ProgramFiles\LibreHardwareMonitor\LibreHardwareMonitor.exe"
    if (Test-Path $lhmPath) {
        Write-Host "Adding LibreHardwareMonitor to startup..." -ForegroundColor Cyan
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\LibreHardwareMonitor.lnk")
        $Shortcut.TargetPath = $lhmPath
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

    # --- Configure Git and Sync Dotfiles ---
    if (-Not (Test-Path $dotfilesRoot)) {
        Write-Host "Cloning dotfiles..." -ForegroundColor Cyan
        git clone https://github.com/abhijeet8900/machine-setup $dotfilesRoot
    } else {
        Write-Host "Dotfiles already present at $dotfilesRoot" -ForegroundColor Yellow
    }

    Write-Host "Setting global Git config..." -ForegroundColor Cyan
    git config --global user.name "Abhijeet Tilekar"
    git config --global user.email "you@example.com"
    git config --global core.editor "nvim"

    # Proceed to Phase 2 after reboot
    "phase2" | Set-Content $setupPhaseFile
    Write-Host "🔁 Restarting system to continue setup..." -ForegroundColor Magenta
    shutdown /r /t 5
    exit
}

if ($phase -eq "phase2") {
    # --- Enable required features for WSL ---
    Write-Host "Enabling WSL-related features..." -ForegroundColor Cyan
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

    # --- Enable WSL if not already installed ---
    $wslStatus = wsl --status 2>&1
    if ($wslStatus -match "has no installed distributions") {
        Write-Host "Installing WSL and Ubuntu..." -ForegroundColor Cyan
        wsl --install
    } else {
        Write-Host "WSL is already installed." -ForegroundColor Yellow
    }

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

    # Cleanup
    Remove-Item $setupPhaseFile -Force -ErrorAction SilentlyContinue

    # --- Report Summary ---
    Write-Host "`n==== Installation Summary ====" -ForegroundColor Cyan
    foreach ($entry in $installResults.GetEnumerator()) {
        Write-Host "$($entry.Key): $($entry.Value)"
    }

    Write-Host "`n✅ Setup Complete. Please restart your system to apply all changes." -ForegroundColor Green
}
