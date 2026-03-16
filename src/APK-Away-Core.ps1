#region Phase 1: Core Functions

function Get-MockPackageData {
    [CmdletBinding()]
    param()
    
    Write-Verbose "Generating mock package data for demo mode..."
    
    $mockPackages = @(
        # High Risk System Packages
        [PSCustomObject]@{ Package = "com.android.systemui"; IsInstalled = $true; ApkPath = "/system/priv-app/SystemUI/SystemUI.apk" }
        [PSCustomObject]@{ Package = "com.android.phone"; IsInstalled = $true; ApkPath = "/system/priv-app/TeleService/TeleService.apk" }
        [PSCustomObject]@{ Package = "com.samsung.android.knox.containeragent"; IsInstalled = $true; ApkPath = "/system/priv-app/KnoxContainer/KnoxContainer.apk" }
        [PSCustomObject]@{ Package = "com.google.android.gms"; IsInstalled = $true; ApkPath = "/system/priv-app/GmsCore/GmsCore.apk" }
        [PSCustomObject]@{ Package = "com.android.vending"; IsInstalled = $true; ApkPath = "/system/priv-app/Phonesky/Phonesky.apk" }
        
        # Medium Risk
        [PSCustomObject]@{ Package = "com.samsung.android.messaging"; IsInstalled = $true; ApkPath = "/system/app/SamsungMessages/SamsungMessages.apk" }
        [PSCustomObject]@{ Package = "com.google.android.apps.photos"; IsInstalled = $true; ApkPath = "/system/app/Photos/Photos.apk" }
        [PSCustomObject]@{ Package = "com.samsung.android.calendar"; IsInstalled = $true; ApkPath = "/system/app/Calendar/Calendar.apk" }
        [PSCustomObject]@{ Package = "com.android.chrome"; IsInstalled = $true; ApkPath = "/system/app/Chrome/Chrome.apk" }
        [PSCustomObject]@{ Package = "com.google.android.apps.maps"; IsInstalled = $true; ApkPath = "/product/app/Maps/Maps.apk" }
        
        # Low Risk - Bloatware
        [PSCustomObject]@{ Package = "com.facebook.system"; IsInstalled = $true; ApkPath = "/system/app/Facebook/Facebook.apk" }
        [PSCustomObject]@{ Package = "com.facebook.services"; IsInstalled = $true; ApkPath = "/system/app/FBServices/FBServices.apk" }
        [PSCustomObject]@{ Package = "com.facebook.appmanager"; IsInstalled = $true; ApkPath = "/system/app/FBAppManager/FBAppManager.apk" }
        [PSCustomObject]@{ Package = "com.att.personalcloud"; IsInstalled = $true; ApkPath = "/system/app/ATTCloud/ATTCloud.apk" }
        [PSCustomObject]@{ Package = "com.att.myWireless"; IsInstalled = $true; ApkPath = "/system/app/myATT/myATT.apk" }
        [PSCustomObject]@{ Package = "com.amazon.mShop.android.shopping"; IsInstalled = $true; ApkPath = "/product/app/Amazon/Amazon.apk" }
        [PSCustomObject]@{ Package = "com.samsung.android.game.gametools"; IsInstalled = $true; ApkPath = "/system/app/GameTools/GameTools.apk" }
        [PSCustomObject]@{ Package = "com.samsung.android.bixby.agent"; IsInstalled = $true; ApkPath = "/system/app/BixbyAgent/BixbyAgent.apk" }
        [PSCustomObject]@{ Package = "com.microsoft.office.excel"; IsInstalled = $true; ApkPath = "/product/app/Excel/Excel.apk" }
        [PSCustomObject]@{ Package = "com.netflix.mediaclient"; IsInstalled = $true; ApkPath = "/system/app/Netflix/Netflix.apk" }
        
        # User Apps
        [PSCustomObject]@{ Package = "com.spotify.music"; IsInstalled = $true; ApkPath = "/data/app/Spotify/Spotify.apk" }
        [PSCustomObject]@{ Package = "com.whatsapp"; IsInstalled = $true; ApkPath = "/data/app/WhatsApp/WhatsApp.apk" }
        [PSCustomObject]@{ Package = "com.reddit.frontpage"; IsInstalled = $true; ApkPath = "/data/app/Reddit/Reddit.apk" }
        [PSCustomObject]@{ Package = "com.twitter.android"; IsInstalled = $true; ApkPath = "/data/app/Twitter/Twitter.apk" }
        [PSCustomObject]@{ Package = "org.mozilla.firefox"; IsInstalled = $true; ApkPath = "/data/app/Firefox/Firefox.apk" }
    )
    
    Write-Verbose "Generated $($mockPackages.Count) mock packages"
    return $mockPackages
}

<#
.SYNOPSIS
    Scans installed packages from connected Android device

.DESCRIPTION
    Executes 'adb shell pm list packages -f' to get all installed packages
    Parses output to extract package names and APK paths

.OUTPUTS
    Array of package objects with Package and ApkPath properties

.EXAMPLE
    $packages = Get-InstalledPackages
#>
function Get-InstalledPackages {
    [CmdletBinding()]
    param()
    
    # Demo mode - return mock data
    if ($Script:DemoMode) {
        Write-Verbose "Demo mode: Using mock package data"
        Start-Sleep -Milliseconds 800  # Simulate scan time
        return Get-MockPackageData
    }
    
    Write-Verbose "Scanning packages from Android device..."
    
    # Check if ADB exists
    if (-not (Test-Path $Script:Config.AdbPath)) {
        throw "ADB not found at: $($Script:Config.AdbPath)"
    }
    
    # Check if device is connected
    try {
        $devices = & $Script:Config.AdbPath devices 2>&1
        if ($devices -notmatch 'device$') {
            throw "No Android device connected. Please connect device and enable USB debugging."
        }
    }
    catch {
        throw "Failed to communicate with ADB: $_"
    }
    
    # Get package list
    try {
        $output = & $Script:Config.AdbPath shell pm list packages -f 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            throw "ADB command failed: $output"
        }
        
        $packages = @()
        foreach ($line in $output) {
            # Parse format: package:/path/to/app.apk=com.package.name
            if ($line -match '^package:(.+)=(.+)$') {
                $packages += [PSCustomObject]@{
                    Package = $matches[2].Trim()
                    ApkPath = $matches[1].Trim()
                    IsInstalled = $true
                }
            }
        }
        
        Write-Verbose "Found $($packages.Count) packages"
        return $packages
    }
    catch {
        throw "Failed to scan packages: $_"
    }
}

<#
.SYNOPSIS
    Loads package research data from Excel file

.DESCRIPTION
    Reads FE_APP_LIST.xlsx and returns research data including
    package names, app names, risk levels, and categories

.PARAMETER ExcelPath
    Path to the Excel file containing package research

.OUTPUTS
    Array of research objects with Package, AppName, WillBreak, and Type properties

.EXAMPLE
    $research = Import-PackageDatabase -ExcelPath "C:\Data\FE_APP_LIST.xlsx"
#>
function Import-PackageDatabase {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$ExcelPath = $Script:Config.ExcelPath
    )
    
    Write-Verbose "Loading package database from Excel..."
    
    # Check if file exists
    if (-not (Test-Path $ExcelPath)) {
        throw "Excel file not found: $ExcelPath"
    }
    
    try {
        # Import main research sheet
        $data = Import-Excel -Path $ExcelPath -WorksheetName "FE_APP_LIST" -ErrorAction Stop
        
        Write-Verbose "Loaded $($data.Count) package research entries"
        
        # Normalize data structure
        $research = @()
        foreach ($row in $data) {
            $research += [PSCustomObject]@{
                Package = $row.Package
                AppName = $row.'App Name'
                WillBreak = $row.'Will Break'
                Type = $row.Type
            }
        }
        
        return $research
    }
    catch {
        throw "Failed to load Excel data: $_"
    }
}

<#
.SYNOPSIS
    Merges phone package scan with Excel research data

.DESCRIPTION
    Performs a left join to combine phone packages (primary source)
    with Excel research data (lookup). Flags unknown packages.

.PARAMETER PhonePackages
    Array of packages from Get-InstalledPackages

.PARAMETER ExcelData
    Array of research data from Import-PackageDatabase

.OUTPUTS
    Array of merged package objects with all available information

.EXAMPLE
    $merged = Merge-PackageData -PhonePackages $phone -ExcelData $excel
#>
function Merge-PackageData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [array]$PhonePackages,
        
        [Parameter(Mandatory=$true)]
        [array]$ExcelData
    )
    
    Write-Verbose "Merging phone data with research database..."
    
    # Create lookup hashtable for fast matching
    $researchLookup = @{}
    foreach ($item in $ExcelData) {
        if ($item.Package) {
            $researchLookup[$item.Package] = $item
        }
    }
    
    # Merge data
    $merged = @()
    foreach ($pkg in $PhonePackages) {
        $research = $researchLookup[$pkg.Package]
        
        if ($research) {
            # Package found in research database
            $merged += [PSCustomObject]@{
                Package = $pkg.Package
                AppName = $research.AppName
                WillBreak = $research.WillBreak
                Type = $research.Type
                ApkPath = $pkg.ApkPath
                IsInstalled = $pkg.IsInstalled
                IsResearched = $true
            }
        }
        else {
            # Unknown package (not in research database)
            $merged += [PSCustomObject]@{
                Package = $pkg.Package
                AppName = "Unknown"
                WillBreak = "Unknown"
                Type = "Unknown"
                ApkPath = $pkg.ApkPath
                IsInstalled = $pkg.IsInstalled
                IsResearched = $false
            }
        }
    }
    
    Write-Verbose "Merged data: $($merged.Count) total, $($merged.Where({$_.IsResearched}).Count) researched, $($merged.Where({-not $_.IsResearched}).Count) unknown"
    
    return $merged
}

<#
.SYNOPSIS
    Backs up APK file from Android device

.DESCRIPTION
    Pulls APK file from device to specified backup location before removal

.PARAMETER PackageName
    Name of the package to backup

.PARAMETER BackupPath
    Destination folder for backup

.OUTPUTS
    PSCustomObject with Success status and BackupFile path

.EXAMPLE
    Backup-PackageApk -PackageName "com.example.app" -BackupPath "C:\Backup"
#>
function Backup-PackageApk {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageName,
        
        [Parameter(Mandatory=$true)]
        [string]$BackupPath
    )
    
    Write-Verbose "Backing up APK for: $PackageName"
    
    # Demo mode - simulate backup
    if ($Script:DemoMode) {
        Start-Sleep -Milliseconds 300
        $backupFile = Join-Path $BackupPath "$PackageName.apk"
        return [PSCustomObject]@{
            Success = $true
            Message = "Backup successful (DEMO)"
            BackupFile = $backupFile
        }
    }
    
    # Create backup directory if it doesn't exist
    if (-not (Test-Path $BackupPath)) {
        try {
            New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
            Write-Verbose "Created backup directory: $BackupPath"
        }
        catch {
            return [PSCustomObject]@{
                Success = $false
                Message = "Failed to create backup directory: $_"
                BackupFile = $null
            }
        }
    }
    
    try {
        # Get APK path on device
        $pathOutput = & $Script:Config.AdbPath shell pm path $PackageName 2>&1
        
        if ($pathOutput -notmatch '^package:(.+)$') {
            return [PSCustomObject]@{
                Success = $false
                Message = "Failed to get APK path: $pathOutput"
                BackupFile = $null
            }
        }
        
        $apkPath = $matches[1].Trim()
        $backupFile = Join-Path $BackupPath "$PackageName.apk"
        
        # Pull APK from device
        Write-Verbose "Pulling APK from: $apkPath"
        $pullOutput = & $Script:Config.AdbPath pull $apkPath $backupFile 2>&1
        
        if ($LASTEXITCODE -eq 0 -and (Test-Path $backupFile)) {
            return [PSCustomObject]@{
                Success = $true
                Message = "Backup successful"
                BackupFile = $backupFile
            }
        }
        else {
            return [PSCustomObject]@{
                Success = $false
                Message = "Failed to pull APK: $pullOutput"
                BackupFile = $null
            }
        }
    }
    catch {
        return [PSCustomObject]@{
            Success = $false
            Message = "Backup error: $_"
            BackupFile = $null
        }
    }
}

<#
.SYNOPSIS
    Removes/uninstalls package from Android device

.DESCRIPTION
    Executes 'adb shell pm uninstall --user 0' to remove package
    Optionally backs up APK before removal

.PARAMETER PackageName
    Name of the package to remove

.PARAMETER BackupFirst
    If specified, backs up APK before removal

.PARAMETER BackupPath
    Destination folder for backup (required if BackupFirst is specified)

.OUTPUTS
    PSCustomObject with Success status and detailed Message

.EXAMPLE
    Remove-Package -PackageName "com.example.app" -BackupFirst -BackupPath "C:\Backup"
#>
function Remove-Package {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageName,
        
        [Parameter(Mandatory=$false)]
        [switch]$BackupFirst,
        
        [Parameter(Mandatory=$false)]
        [string]$BackupPath = $Script:Config.DefaultBackupPath
    )
    
    Write-Verbose "Removing package: $PackageName"
    
    # Demo mode - simulate removal
    if ($Script:DemoMode) {
        Start-Sleep -Milliseconds 500
        # 95% success rate in demo
        $success = (Get-Random -Minimum 1 -Maximum 100) -le 95
        return [PSCustomObject]@{
            Success = $success
            Message = if ($success) { "Successfully removed $PackageName (DEMO)" } else { "Simulated failure (DEMO)" }
            Package = $PackageName
            BackupPerformed = $BackupFirst.IsPresent
            BackupFile = $null
        }
    }
    
    # Backup if requested
    if ($BackupFirst) {
        Write-Verbose "Backup requested, backing up first..."
        $backupResult = Backup-PackageApk -PackageName $PackageName -BackupPath $BackupPath
        
        if (-not $backupResult.Success) {
            Write-Warning "Backup failed: $($backupResult.Message)"
            # Continue with removal anyway, but note the backup failure
        }
        else {
            Write-Verbose "Backup completed: $($backupResult.BackupFile)"
        }
    }
    
    # Uninstall package
    try {
        $output = & $Script:Config.AdbPath shell pm uninstall --user 0 $PackageName 2>&1
        
        if ($output -match 'Success' -or $LASTEXITCODE -eq 0) {
            return [PSCustomObject]@{
                Success = $true
                Message = "Successfully removed $PackageName"
                Package = $PackageName
                BackupPerformed = $BackupFirst.IsPresent
                BackupFile = if ($BackupFirst -and $backupResult.Success) { $backupResult.BackupFile } else { $null }
            }
        }
        else {
            return [PSCustomObject]@{
                Success = $false
                Message = "Failed to remove: $output"
                Package = $PackageName
                BackupPerformed = $BackupFirst.IsPresent
                BackupFile = if ($BackupFirst -and $backupResult.Success) { $backupResult.BackupFile } else { $null }
            }
        }
    }
    catch {
        return [PSCustomObject]@{
            Success = $false
            Message = "Removal error: $_"
            Package = $PackageName
            BackupPerformed = $BackupFirst.IsPresent
            BackupFile = if ($BackupFirst -and $backupResult.Success) { $backupResult.BackupFile } else { $null }
        }
    }
}

#endregion

#region Logging Functions

<#
.SYNOPSIS
    Writes operation to log file and GUI

.PARAMETER Level
    Log level (INFO, WARNING, ERROR, SUCCESS)

.PARAMETER Message
    Log message

.EXAMPLE
    Write-OperationLog -Level "INFO" -Message "Scanned 534 packages"
#>
function Write-OperationLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'SUCCESS', 'BACKUP', 'REMOVE')]
        [string]$Level,
        
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    
    # Create log directory if needed
    if (-not (Test-Path $Script:Config.LogDir)) {
        New-Item -ItemType Directory -Path $Script:Config.LogDir -Force | Out-Null
    }
    
    # Generate log entry
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$timestamp] ${Level}: $Message"
    
    # Write to current session log file
    $logFile = Join-Path $Script:Config.LogDir "apk-away_$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $entry
    
    # Write to console with color
    $color = switch ($Level) {
        'ERROR' { 'Red' }
        'WARNING' { 'Yellow' }
        'SUCCESS' { 'Green' }
        'INFO' { 'Cyan' }
        default { 'White' }
    }
    Write-Host $entry -ForegroundColor $color
}

#endregion

#region Configuration Management

<#
.SYNOPSIS
    Loads application settings from JSON config file

.DESCRIPTION
    Reads configuration from apk-away-config.json
    Returns default settings if file doesn't exist

.OUTPUTS
    Hashtable with configuration settings

.EXAMPLE
    $settings = Get-AppSettings
#>
function Get-AppSettings {
    [CmdletBinding()]
    param()
    
    $configFile = $Script:Config.ConfigFile
    
    if (Test-Path $configFile) {
        try {
            $json = Get-Content $configFile -Raw | ConvertFrom-Json
            
            # Convert JSON object to hashtable
            $settings = @{
                ExcelPath = $json.excelPath
                DefaultBackupPath = $json.defaultBackupPath
                AdbPath = $json.adbPath
                LogEnabled = $json.logEnabled
                AutoBackup = $json.autoBackup
                ConfirmBeforeRemoval = $json.confirmBeforeRemoval
                WindowSize = $json.windowSize
                LastUsed = $json.lastUsed
            }
            
            Write-Verbose "Loaded settings from: $configFile"
            return $settings
        }
        catch {
            Write-Warning "Failed to load config file, using defaults: $_"
            return $null
        }
    }
    
    return $null
}

<#
.SYNOPSIS
    Saves application settings to JSON config file

.DESCRIPTION
    Writes current configuration to apk-away-config.json

.PARAMETER Settings
    Hashtable containing settings to save

.EXAMPLE
    Save-AppSettings -Settings $config
#>
function Save-AppSettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Settings
    )
    
    $configFile = $Script:Config.ConfigFile
    
    try {
        # Add timestamp
        $Settings.LastUsed = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        
        # Convert to JSON and save
        $Settings | ConvertTo-Json | Set-Content $configFile -Encoding UTF8
        
        Write-Verbose "Settings saved to: $configFile"
        return $true
    }
    catch {
        Write-Warning "Failed to save settings: $_"
        return $false
    }
}

<#
.SYNOPSIS
    Initializes configuration with defaults or loads from file

.DESCRIPTION
    Checks for existing config file and loads it, or creates default configuration

.OUTPUTS
    Hashtable with configuration settings

.EXAMPLE
    Initialize-Configuration
#>
function Initialize-Configuration {
    [CmdletBinding()]
    param()
    
    # Try to load existing config
    $settings = Get-AppSettings
    
    if ($settings) {
        # Update Script:Config with loaded settings
        $Script:Config.ExcelPath = $settings.ExcelPath
        $Script:Config.DefaultBackupPath = $settings.DefaultBackupPath
        $Script:Config.AdbPath = $settings.AdbPath
        
        Write-Verbose "Configuration loaded from file"
    }
    else {
        # Create default config
        $settings = @{
            ExcelPath = $Script:Config.ExcelPath
            DefaultBackupPath = $Script:Config.DefaultBackupPath
            AdbPath = $Script:Config.AdbPath
            LogEnabled = $true
            AutoBackup = $true
            ConfirmBeforeRemoval = $true
            WindowSize = "1200x800"
            LastUsed = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        }
        
        # Save default config
        Save-AppSettings -Settings $settings | Out-Null
        Write-Verbose "Default configuration created"
    }
    
    return $settings
}

#endregion

#region Error Handling and Validation

<#
.SYNOPSIS
    Shows formatted error dialog to user

.PARAMETER Title
    Dialog title

.PARAMETER Message
    Main error message

.PARAMETER Details
    Additional error details (optional)

.EXAMPLE
    Show-ErrorDialog -Title "Connection Error" -Message "Failed to connect to device" -Details $_.Exception.Message
#>
function Show-ErrorDialog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Title,
        
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$Details
    )
    
    $fullMessage = $Message
    if ($Details) {
        $fullMessage += "`n`nDetails:`n$Details"
    }
    
    [System.Windows.Forms.MessageBox]::Show(
        $fullMessage,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
}

<#
.SYNOPSIS
    Validates that ADB is accessible and device is connected

.OUTPUTS
    Returns $true if valid, $false with error message if not

.EXAMPLE
    $result = Test-AdbConnection
#>
function Test-AdbConnection {
    [CmdletBinding()]
    param()
    
    # Check if ADB exists
    if (-not (Test-Path $Script:Config.AdbPath)) {
        return [PSCustomObject]@{
            Success = $false
            Message = "ADB not found at: $($Script:Config.AdbPath)"
            Suggestion = "Install Android SDK Platform Tools and update the path in configuration."
        }
    }
    
    # Check if device is connected
    try {
        $devices = & $Script:Config.AdbPath devices 2>&1
        
        # Look for device in the output (excluding header)
        $deviceLines = $devices | Where-Object { $_ -match '\tdevice$' }
        
        if ($deviceLines.Count -eq 0) {
            return [PSCustomObject]@{
                Success = $false
                Message = "No Android device connected"
                Suggestion = "Connect your Android device via USB and enable USB debugging in Developer Options."
            }
        }
        
        return [PSCustomObject]@{
            Success = $true
            Message = "ADB connection OK"
            DeviceCount = $deviceLines.Count
        }
    }
    catch {
        return [PSCustomObject]@{
            Success = $false
            Message = "Failed to communicate with ADB: $($_.Exception.Message)"
            Suggestion = "Restart ADB server: adb kill-server && adb start-server"
        }
    }
}

<#
.SYNOPSIS
    Validates that Excel file exists and is readable

.OUTPUTS
    Returns validation result object

.EXAMPLE
    $result = Test-ExcelFile
#>
function Test-ExcelFile {
    [CmdletBinding()]
    param()
    
    if (-not (Test-Path $Script:Config.ExcelPath)) {
        return [PSCustomObject]@{
            Success = $false
            Message = "Excel file not found: $($Script:Config.ExcelPath)"
            Suggestion = "Package data will show as 'Unknown' without the research file."
            IsCritical = $false
        }
    }
    
    try {
        # Try to read the file
        $test = Import-Excel -Path $Script:Config.ExcelPath -WorksheetName "FE_APP_LIST" -StartRow 1 -EndRow 1 -ErrorAction Stop
        
        return [PSCustomObject]@{
            Success = $true
            Message = "Excel file OK"
        }
    }
    catch {
        return [PSCustomObject]@{
            Success = $false
            Message = "Excel file is not readable: $($_.Exception.Message)"
            Suggestion = "Make sure the file is not open in Excel and is not corrupted."
            IsCritical = $false
        }
    }
}

#endregion
