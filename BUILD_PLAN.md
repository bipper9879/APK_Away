# APK_Away Build Plan

**Version:** 1.0  
**Target:** PowerShell GUI Tool  
**Status:** ✅ V1.0 Complete - Enhancement Phase

---

## Build Order

### Phase 1: Core Functions (No GUI)
Build and test individual functions first.

#### Function 1: ADB Package Scanner
```powershell
function Get-InstalledPackages {
    # Scan packages from connected Android device
    # Input: None (uses ADB)
    # Output: Array of package objects
    # Test: adb shell pm list packages -f
}
```

**Implementation:**
- Execute `adb shell pm list packages -f`
- Parse output: `package:/path/to/apk=com.package.name`
- Extract package name and APK path
- Return structured data

**Test Cases:**
- Device connected
- Device not connected
- No ADB in PATH
- Empty package list

---

#### Function 2: Excel Data Loader
```powershell
function Import-PackageDatabase {
    param([string]$ExcelPath)
    # Load FE_APP_LIST.xlsx research data
    # Input: Path to Excel file
    # Output: Array of package research objects
}
```

**Implementation:**
- Use ImportExcel module
- Read FE_APP_LIST sheet
- Return objects with: Package, AppName, WillBreak, Type
- Handle missing file gracefully

**Test Cases:**
- File exists and valid
- File doesn't exist
- File corrupted
- ImportExcel module not installed

---

#### Function 3: Data Merger
```powershell
function Merge-PackageData {
    param($PhonePackages, $ExcelData)
    # Combine phone scan with Excel research
    # Input: Two arrays (phone packages, Excel data)
    # Output: Merged array with all info
}
```

**Implementation:**
- Left join: Phone packages (primary) + Excel data (lookup)
- Match on package name
- Flag unknown packages (not in Excel)
- Return enhanced package objects

**Fields:**
- Package (from phone)
- AppName (from Excel or "Unknown")
- WillBreak (from Excel or "Unknown")
- Type (from Excel or "Unknown")
- IsInstalled (true for all)
- ApkPath (from phone scan)

---

#### Function 4: APK Backup
```powershell
function Backup-PackageApk {
    param([string]$PackageName, [string]$BackupPath)
    # Pull APK from device before removal
    # Input: Package name, destination folder
    # Output: Success/failure, backed up file path
}
```

**Implementation:**
- Get APK path: `adb shell pm path <package>`
- Parse path from output
- Pull file: `adb pull <path> <BackupPath>\<package>.apk`
- Verify file copied successfully
- Return backup file location

**Test Cases:**
- Package exists on device
- Package doesn't exist
- Destination folder doesn't exist (create it)
- Insufficient disk space (catch error)

---

#### Function 5: Package Uninstaller
```powershell
function Remove-Package {
    param([string]$PackageName, [switch]$BackupFirst)
    # Uninstall package via ADB
    # Input: Package name, backup flag
    # Output: Success/failure result object
}
```

**Implementation:**
- If $BackupFirst: Call Backup-PackageApk
- Execute: `adb shell pm uninstall --user 0 <package>`
- Parse result: "Success" or error message
- Log operation with timestamp
- Return result object

**Test Cases:**
- Package exists and removable
- Package is system critical (may fail)
- Package already removed
- Backup succeeds/fails

---

### Phase 2: GUI Development

#### Main Form Structure
```powershell
$form = New-Object System.Windows.Forms.Form
$form.Text = "APK Away - Android Package Manager"
$form.Size = New-Object System.Drawing.Size(1200, 800)
$form.StartPosition = "CenterScreen"
```

**Components:**
1. **Top Panel** - Controls
   - Scan Phone button
   - Backup Path textbox + Browse button
   - Remove Selected button
   - Filter dropdown (All, High Risk, Medium, Low, User Apps)
   
2. **DataGridView** - Package list (main area)
   - Columns: [Checkbox] Package | App Name | Risk | Type | Actions
   - Sortable by all columns
   - Color-coded rows by risk
   - Checkbox for selection
   
3. **Bottom Panel** - Status
   - Status label (last operation result)
   - Progress bar
   - Log textbox (operation history)

---

#### DataGridView Configuration
```powershell
$grid = New-Object System.Windows.Forms.DataGridView
$grid.Dock = [System.Windows.Forms.DockStyle]::Fill
$grid.AllowUserToAddRows = $false
$grid.AllowUserToDeleteRows = $false
$grid.ReadOnly = $false  # Allow checkbox column
$grid.SelectionMode = 'FullRowSelect'
$grid.MultiSelect = $true
$grid.AutoSizeColumnsMode = 'Fill'

# Columns
$grid.Columns.Add((New-DataGridViewCheckBoxColumn -Name "Select" -HeaderText ""))
$grid.Columns.Add("Package", "Package")
$grid.Columns.Add("AppName", "App Name")
$grid.Columns.Add("WillBreak", "Risk")
$grid.Columns.Add("Type", "Type")
$grid.Columns.Add("ApkPath", "APK Path")
```

---

#### Color Coding Logic
```powershell
foreach ($row in $grid.Rows) {
    $risk = $row.Cells['WillBreak'].Value
    
    switch ($risk) {
        'High'   { $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::LightCoral }
        'Medium' { $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::LightYellow }
        'Low'    { $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::LightGreen }
        default  { $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::White }
    }
}
```

---

### Phase 3: Event Handlers

#### Scan Phone Button
```powershell
$btnScan.Add_Click({
    # Show "Scanning..." message
    $packages = Get-InstalledPackages
    $excelData = Import-PackageDatabase -ExcelPath $excelPath
    $mergedData = Merge-PackageData -PhonePackages $packages -ExcelData $excelData
    
    # Populate DataGridView
    $grid.Rows.Clear()
    foreach ($pkg in $mergedData) {
        $grid.Rows.Add($false, $pkg.Package, $pkg.AppName, $pkg.WillBreak, $pkg.Type, $pkg.ApkPath)
    }
    
    # Apply color coding
    Apply-ColorCoding
    
    # Update status
    $lblStatus.Text = "Found $($mergedData.Count) packages"
})
```

---

#### Remove Selected Button
```powershell
$btnRemove.Add_Click({
    # Get selected rows
    $selected = @()
    foreach ($row in $grid.Rows) {
        if ($row.Cells['Select'].Value -eq $true) {
            $selected += $row
        }
    }
    
    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No packages selected")
        return
    }
    
    # Confirm
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Remove $($selected.Count) package(s)?",
        "Confirm Removal",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        # Process each package
        $progressBar.Maximum = $selected.Count
        $progressBar.Value = 0
        
        foreach ($row in $selected) {
            $package = $row.Cells['Package'].Value
            $backupPath = $txtBackup.Text
            
            # Backup if path specified
            $backup = $false
            if ($backupPath) {
                $backup = $true
                Backup-PackageApk -PackageName $package -BackupPath $backupPath
            }
            
            # Uninstall
            $result = Remove-Package -PackageName $package
            
            # Log
            Add-LogEntry -Message "$package - $($result.Message)"
            
            # Update progress
            $progressBar.Value++
        }
        
        # Refresh list
        $btnScan.PerformClick()
    }
})
```

---

### Phase 4: Logging System

#### Log File Structure
```
Logs/
  apk-away_20260315_143022.log
  apk-away_20260315_150133.log
```

#### Log Entry Format
```
[2026-03-15 14:30:22] INFO: Scanned device, found 534 packages
[2026-03-15 14:31:05] BACKUP: com.facebook.system -> C:\Backup\com.facebook.system.apk
[2026-03-15 14:31:10] REMOVE: com.facebook.system - Success
[2026-03-15 14:31:15] ERROR: com.android.systemui - Failure (cannot remove system)
```

#### Implementation
```powershell
function Write-OperationLog {
    param([string]$Level, [string]$Message)
    
    $logDir = Join-Path $PSScriptRoot "Logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFile = Join-Path $logDir "apk-away_$timestamp.log"
    
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Level: $Message"
    Add-Content -Path $logFile -Value $entry
    
    # Also display in GUI log textbox
    $txtLog.AppendText("$entry`r`n")
}
```

---

### Phase 5: Configuration & Settings

#### Config File: `apk-away-config.json`
```json
{
    "excelPath": "C:\\Users\\Dad\\OneDrive\\ADP\\FE_APP_LIST.xlsx",
    "defaultBackupPath": "C:\\Users\\Dad\\Workspace\\APK_Backups",
    "adbPath": "C:\\Users\\Dad\\Workspace\\Tools\\AndroidSDK\\platform-tools\\adb.exe",
    "logEnabled": true,
    "autoBackup": true,
    "confirmBeforeRemoval": true,
    "colorCoding": {
        "high": "#FFB6C1",
        "medium": "#FFFFE0",
        "low": "#90EE90"
    }
}
```

#### Load/Save Settings
```powershell
function Get-AppSettings {
    $configFile = Join-Path $PSScriptRoot "apk-away-config.json"
    if (Test-Path $configFile) {
        return Get-Content $configFile | ConvertFrom-Json
    }
    return $null  # Use defaults
}

function Save-AppSettings {
    param($Settings)
    $configFile = Join-Path $PSScriptRoot "apk-away-config.json"
    $Settings | ConvertTo-Json | Set-Content $configFile
}
```

---

### Phase 6: Error Handling

#### Common Errors to Handle
1. **ADB not found** - Guide user to install/configure
2. **No device connected** - Show connection instructions
3. **Permission denied** - USB debugging not enabled
4. **Package not found** - Already removed or never existed
5. **Excel file missing** - Prompt to specify location
6. **ImportExcel module missing** - Auto-install prompt

#### Error Display
```powershell
function Show-ErrorDialog {
    param([string]$Title, [string]$Message, [string]$Details)
    
    [System.Windows.Forms.MessageBox]::Show(
        "$Message`n`nDetails: $Details",
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
}
```

---

## File Structure

```
C:\Users\Dad\Workspace\Scripts\
│
├── APK-Away.ps1              # Main GUI script
├── APK-Away-Functions.ps1    # Core functions module
├── apk-away-config.json      # User settings
│
└── Logs\
    ├── apk-away_20260315_143022.log
    └── apk-away_20260315_150133.log

C:\Users\Dad\Workspace\APK_Backups\    # Default backup location
├── com.facebook.system.apk
├── com.att.personalcloud.apk
└── ...
```

---

## Build Status

### ✅ Completed (March 13-15, 2026)

**Phase 1: Core Functions**
- ✅ Get-InstalledPackages - Scans Android device via ADB
- ✅ Import-PackageDatabase - Loads Excel research data
- ✅ Merge-PackageData - Combines phone + research data
- ✅ Backup-PackageApk - Pulls APK before removal
- ✅ Remove-Package - Uninstalls via ADB (user 0 only)
- ✅ Get-MockPackageData - Demo mode with 25 sample packages

**Phase 2: GUI Layout**
- ✅ Windows Forms GUI (1200x800, dynamic sizing)
- ✅ DataGridView with 6 columns
- ✅ Top control panel (scan, backup path, filter, remove)
- ✅ Bottom status panel (status, progress bar, log)
- ✅ Color-coded risk levels (Red/Yellow/Green/White)

**Phase 3: Event Handlers**
- ✅ Scan Phone button with ADB validation
- ✅ Remove Selected button with confirmation
- ✅ Filter dropdown (All, High/Medium/Low Risk, System/User)
- ✅ Select All checkbox with warning dialog
- ✅ Browse button for backup path
- ✅ Form closing event

**Phase 4: Logging**
- ✅ Write-OperationLog function
- ✅ Timestamped log files in Scripts\Logs\
- ✅ In-GUI log viewer (bottom panel)

**Phase 5: Configuration**
- ✅ Get-AppSettings - Load JSON config
- ✅ Save-AppSettings - Persist settings
- ✅ Initialize-Configuration - Default values
- ✅ Config file: apk-away-config.json

**Phase 6: Error Handling**
- ✅ Show-ErrorDialog - Formatted error messages
- ✅ Test-AdbConnection - Validates ADB and device
- ✅ Test-ExcelFile - Validates research file

**Additional Features**
- ✅ Demo Mode (-DemoMode parameter) for testing without device
- ✅ High-risk confirmation dialogs
- ✅ ADB path detection
- ✅ Comment-based help documentation
- ✅ User Guide and Quick Start documentation
- ✅ Test-APKAway.ps1 test script

---

## Enhancement Phase (In Progress)

### 🔧 UI/UX Improvements

**Priority 1: DataGridView Fixes**
- ✅ Fix column headers scrolling away (ColumnHeadersHeightSizeMode)
- ✅ Enable scrollbar arrows (ScrollBars = Both)
- ✅ Fix control Z-order (add DataGrid last)
- ⏳ Verify scrolling works properly with full dataset (534 packages)

**Priority 2: Dynamic Sizing**
- ✅ Make window size responsive (80% of screen, min 1000x600)
- ✅ Remove hard-coded 1200x800 dimensions
- ⏳ Make button positions dynamic based on form width
- ⏳ Make log panel width dynamic

**Priority 3: Safety Warnings**
- ✅ Add Select All confirmation dialog
- ✅ Add High Risk removal confirmation
- ⏳ Add separate "High Risk Warning" for high-risk packages

**Priority 4: Hard-Coded Paths**
- ⏳ Remove hard-coded paths from script
- ⏳ Make all paths relative to $PSScriptRoot or configurable
- ⏳ Update default config with relative paths

**Priority 5: Branding**
- ⏳ Create custom .ico icon file
- ⏳ Set form icon ($form.Icon)
- ⏳ Create installer with icon

**Priority 6: Visual Polish**
- ✅ Improve button styling (rounded, hover effects)
- ✅ Better color scheme (modern blues/grays)
- ⏳ Add icons to buttons (if possible in WinForms)
- ⏳ Improve spacing and padding
- ⏳ Consistent font family

**Priority 7: Distribution Structure**
- ⏳ Reorganize project for proper distribution
- ⏳ Create /bin, /src, /docs folders
- ⏳ Move APK-Away.ps1 to project bin folder
- ⏳ Move Test-APKAway.ps1 to project folder
- ⏳ Create installer/package script

---

## Known Issues

1. ⚠️ **Scrollbar visibility** - Some users report up arrow missing on scrollbar
2. ⚠️ **Dynamic control positioning** - Buttons and labels at fixed X coordinates
3. ⚠️ **No visual feedback** - Buttons don't show hover/click states clearly

---

## Testing Checklist

### Unit Tests (Functions)
- [ ] Get-InstalledPackages with device connected
- [ ] Get-InstalledPackages with no device
- [ ] Import-PackageDatabase with valid Excel
- [ ] Import-PackageDatabase with missing file
- [ ] Merge-PackageData correctly matches packages
- [ ] Backup-PackageApk creates backup file
- [ ] Remove-Package successfully uninstalls

### Integration Tests (GUI)
- [ ] Scan phone populates grid
- [ ] Color coding applies correctly
- [ ] Filter dropdown works
- [ ] Checkbox selection works
- [ ] Backup path browse works
- [ ] Remove selected processes batch
- [ ] Log updates in real-time
- [ ] Settings save/load

### Edge Cases
- [ ] 0 packages installed (unlikely but possible)
- [ ] Package with special characters in name
- [ ] Very long app names (truncation)
- [ ] Missing Excel research data (unknown packages)
- [ ] Removal fails mid-batch
- [ ] Backup folder doesn't exist (create it)

---

## Development Timeline

**Phase 1:** 2-3 hours (core functions)  
**Phase 2:** 2-3 hours (GUI layout)  
**Phase 3:** 1-2 hours (event handlers)  
**Phase 4:** 1 hour (logging)  
**Phase 5:** 1 hour (config/settings)  
**Phase 6:** 1 hour (error handling)  

**Total:** 8-12 hours of development

**Testing & Refinement:** 2-4 hours

---

## Launch Plan

### First Run Experience
1. Check for ADB (guide if missing)
2. Check for ImportExcel module (install if missing)
3. Prompt for Excel file location
4. Prompt for default backup path
5. Save settings
6. Show main window

### Quick Start
1. Connect Android device
2. Enable USB debugging
3. Launch APK-Away.ps1
4. Click "Scan Phone"
5. Select unwanted packages
6. Specify backup path (optional)
7. Click "Remove Selected"
8. Confirm
9. Done!

---

**Ready to build? Let's start with Phase 1!** 🚀
