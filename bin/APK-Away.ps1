#Requires -Version 7.0
<#
.SYNOPSIS
    APK Away - Android Package Manager GUI Tool

.DESCRIPTION
    PowerShell GUI tool for managing Android packages.
    - Scans packages from connected device via ADB
    - Loads research data from Excel file
    - Provides GUI for safe package removal
    - Backs up APKs before removal
    - Color-coded risk levels

.NOTES
    Author: Dad
    Version: 1.0
    Date: 2026-03-15
    
    Requirements:
    - PowerShell 7+
    - ImportExcel module
    - ADB (Android SDK Platform Tools)
    - Connected Android device with USB debugging enabled

.PARAMETER DemoMode
    Runs in demo mode with mock data (no device required)

.EXAMPLE
    .\APK-Away.ps1
    Launches the GUI application

.EXAMPLE
    .\APK-Away.ps1 -DemoMode
    Launches in demo mode with mock data (no phone needed)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$DemoMode
)

#region Configuration
$Script:Config = @{
    ExcelPath = "C:\Users\Dad\OneDrive\ADP\FE_APP_LIST.xlsx"
    AdbPath = "C:\Users\Dad\OneDrive\Workspace\Tools\AndroidSDK\platform-tools\adb.exe"
    DefaultBackupPath = "C:\Users\Dad\Workspace\APK_Backups"
    LogDir = Join-Path $PSScriptRoot "Logs"
    ConfigFile = Join-Path $PSScriptRoot "apk-away-config.json"
}

# Set demo mode flag
$Script:DemoMode = $DemoMode.IsPresent
#endregion

#region Module Checks
# Ensure ImportExcel module is available
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Warning "ImportExcel module not found. Attempting to install..."
    try {
        Install-Module ImportExcel -Scope CurrentUser -Force -ErrorAction Stop
        Write-Host "ImportExcel module installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to install ImportExcel module. Please install manually: Install-Module ImportExcel"
        exit 1
    }
}
#endregion

#region Load Modules
# Determine script location (handle both development and deployed scenarios)
$ScriptRoot = $PSScriptRoot
$SrcPath = Join-Path $ScriptRoot "..\src"

# If running from bin folder, use relative path to src
if (Test-Path $SrcPath) {
    $CoreModule = Join-Path $SrcPath "APK-Away-Core.ps1"
    $GUIModule = Join-Path $SrcPath "APK-Away-GUI.ps1"
}
else {
    # Fallback: modules should be in same directory (deployed scenario)
    $CoreModule = Join-Path $ScriptRoot "APK-Away-Core.ps1"
    $GUIModule = Join-Path $ScriptRoot "APK-Away-GUI.ps1"
}

# Load core functions
if (Test-Path $CoreModule) {
    Write-Verbose "Loading core module: $CoreModule"
    . $CoreModule
}
else {
    Write-Error "Core module not found: $CoreModule"
    exit 1
}

# Load GUI module
if (Test-Path $GUIModule) {
    Write-Verbose "Loading GUI module: $GUIModule"
    . $GUIModule
}
else {
    Write-Error "GUI module not found: $GUIModule"
    exit 1
}
#endregion

#region Main Entry Point

# Launch GUI application
if ($MyInvocation.InvocationName -ne '.') {
    # Display banner
    if ($DemoMode) {
        Write-Host "`nAPK Away - Android Package Manager v1.0 [DEMO MODE]" -ForegroundColor Magenta
        Write-Host "=" * 50 -ForegroundColor Magenta
        Write-Host "`n⚠ Running in DEMO MODE with mock data (no device required)" -ForegroundColor Yellow
        Write-Host "  All operations are simulated. No actual changes will be made.`n" -ForegroundColor Yellow
    }
    else {
        Write-Host "`nAPK Away - Android Package Manager v1.0" -ForegroundColor Cyan
        Write-Host "=" * 50 -ForegroundColor Cyan
    }
    
    # Initialize configuration
    Write-Host "`nLoading configuration..." -ForegroundColor Cyan
    $Script:AppSettings = Initialize-Configuration
    
    # Skip ADB checks in demo mode
    if (-not $DemoMode) {
        # Check ADB
        if (-not (Test-Path $Script:Config.AdbPath)) {
            Write-Host "`n⚠ ADB not found at: $($Script:Config.AdbPath)" -ForegroundColor Yellow
            Write-Host "Please install Android SDK Platform Tools or update the path in the script." -ForegroundColor Yellow
            Write-Host "`nTip: Run with -DemoMode to test without ADB:`n  .\APK-Away.ps1 -DemoMode`n" -ForegroundColor Cyan
            Write-Host "Press any key to exit..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 1
        }
        
        # Check Excel file
        if (-not (Test-Path $Script:Config.ExcelPath)) {
            Write-Host "`n⚠ Excel research file not found at: $($Script:Config.ExcelPath)" -ForegroundColor Yellow
            Write-Host "The tool will work without it, but packages won't have risk/category info." -ForegroundColor Yellow
            Write-Host "`nContinue anyway? (Y/N): " -NoNewline -ForegroundColor Yellow
            $response = Read-Host
            if ($response -ne 'Y' -and $response -ne 'y') {
                exit 0
            }
        }
    }
    
    Write-Host "`n✓ Prerequisites OK - Launching GUI..." -ForegroundColor Green
    Write-Host ""
    
    # Create log directory
    if (-not (Test-Path $Script:Config.LogDir)) {
        New-Item -ItemType Directory -Path $Script:Config.LogDir -Force | Out-Null
    }
    
    # Launch GUI
    Show-ApkAwayGUI
    
    # Save settings on exit
    Write-Verbose "Saving configuration on exit..."
    Save-AppSettings -Settings $Script:AppSettings | Out-Null
}

#endregion
