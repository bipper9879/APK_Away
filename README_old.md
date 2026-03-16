# APK_Away Project

## Status: Planning Complete, Ready to Build

**Last Updated:** March 15, 2026  
**Session:** 2026-03-15-c

---

## Quick Context for AI Assistants

**User has existing research:** `C:\Users\Dad\OneDrive\ADP\FE_APP_LIST.xlsx`
- 534 Android packages already researched with risk scores and categories
- Previous Claude session analyzed packages from user's phone
- **DO NOT regenerate this research** - use existing data

**Current Goal:** Build PowerShell GUI tool to manage package removal

**Read these files first when continuing:**
1. `project-discussion.md` - Initial architecture discussion
2. `EXCEL_ANALYSIS.md` - Detailed breakdown of existing data
3. `BUILD_PLAN.md` - What to build next

---

## Project Architecture

### Approach: Enhanced PowerShell Tool (v1)
- Start with GUI version of existing `Remove-Apks.ps1`
- Prove concept before building Android app
- Quick iteration, familiar tech stack

### Why PowerShell?
- User already has Remove-Apks.ps1 working
- Knows ADB commands
- ImportExcel module already in use
- Fast prototype, easy to enhance

### Future (v2): Hybrid
- Android app (Kotlin) for on-device UI
- PC helper maintains execution via ADB
- Build after v1 proven successful

---

## Core Features (v1 Scope)

### ✅ Must Have
1. **Scan packages** - `adb shell pm list packages -f`
2. **Load Excel data** - Read FE_APP_LIST.xlsx for risk/category info
3. **GUI table** - DataGridView with sort/filter
4. **Color coding** - Red=High, Yellow=Medium, Green=Low risk
5. **Selection** - Individual checkboxes + Select All
6. **Backup** - Get APK path, pull via ADB before removal
7. **Uninstall** - `adb shell pm uninstall --user 0 <package>`
8. **Logging** - Timestamped log files

### ⏭️ Future (v1.1+)
- Restore functionality
- Saved profiles ("Samsung bloatware preset")
- Package search/filter
- Export reports
- Scheduled scans

---

## Key Files & Locations

### Data
- **Research data**: `C:\Users\Dad\OneDrive\ADP\FE_APP_LIST.xlsx`
  - Sheet 1: `FE_APP_LIST` - Main research (534 packages)
  - Sheet 2: `what_goes` - User selection logic

### Scripts
- **Current tool**: `C:\Users\Dad\OneDrive\Workspace\Scripts\Remove-Apks.ps1`
- **New tool will be**: `C:\Users\Dad\Workspace\Scripts\APK-Away.ps1`

### Project
- **This folder**: `C:\Users\Dad\Workspace\Projects\APK_Away\`
- **History**: `C:\Users\Dad\OneDrive\Workspace\MyAIBuddy\History\2026-03-15-*.md`

---

## Excel File Structure

### FE_APP_LIST Sheet (534 rows)

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| Package | String | Full package name | `com.samsung.android.knox.containeragent` |
| App Name | String | Human-readable name | Samsung Knox Container Agent |
| Will Break | String | Risk level | High, Medium, Low, NaN |
| Type | String | Category | System Service, Framework, User App, etc. |

**Risk Distribution:**
- High: 123 (critical - system will break)
- Medium: 149 (moderate - some features may break)
- Low: 192 (safe - minimal/no impact)
- NaN: 70 (user apps - no system impact)

**Type Categories:**
- System Service: 221 (background services, daemons)
- System App: 99 (system apps with privileges)
- Framework: 74 (core Android/Samsung/Google)
- User App: 69 (user installed)
- OEM App: 51 (Samsung/Google pre-installed)
- Carrier App: 15 (AT&T bloatware)
- Bloatware: 5 (Facebook, Amazon, etc.)

### what_goes Sheet

Additional columns for user workflow:
- **go y/n**: Mark `y` to uninstall this package
- **backup to folder**: Mark if should backup before removal
- (Plus all FE_APP_LIST columns repeated)

---

## ADB Commands Reference

### List Packages
```powershell
# All packages with APK paths
adb shell pm list packages -f

# System packages only
adb shell pm list packages -s

# Third-party only
adb shell pm list packages -3

# Disabled packages
adb shell pm list packages -d
```

### Get Package Info
```powershell
# Detailed package info
adb shell dumpsys package <package_name>

# Get APK path
adb shell pm path <package_name>
# Output: package:/system/priv-app/Something/Something.apk
```

### Backup APK
```powershell
# Get path
$path = (adb shell pm path com.example.app) -replace 'package:', ''

# Pull file
adb pull $path C:\Backup\app.apk
```

### Uninstall/Disable
```powershell
# Uninstall for user 0 (hides, doesn't delete from /system)
adb shell pm uninstall --user 0 <package>

# Disable (keeps app but inactive)
adb shell pm disable-user --user 0 <package>

# Re-enable
adb shell pm enable <package>

# Full uninstall (requires root)
adb shell pm uninstall <package>
```

---

## Tech Notes

### ImportExcel Module
Already used in user's Remove-Apks.ps1:
```powershell
# Install if needed
Install-Module ImportExcel -Scope CurrentUser

# Read Excel
$data = Import-Excel -Path "path\to\file.xlsx" -WorksheetName "SheetName"

# Filter rows
$toRemove = $data | Where-Object { $_.'go y/n' -eq 'y' }
```

### Windows Forms GUI
Basic PowerShell GUI structure:
```powershell
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "APK Away"
$form.Size = New-Object System.Drawing.Size(1000, 700)

$dataGrid = New-Object System.Windows.Forms.DataGridView
# ... configure grid

$form.Controls.Add($dataGrid)
$form.ShowDialog()
```

---

## Next Steps (For AI to Execute)

When user says "continue" or "let's build":

1. **Create base script**: `APK-Away.ps1` in Scripts folder
2. **Implement core functions**:
   - `Get-InstalledPackages` - ADB package scan
   - `Import-PackageDatabase` - Load Excel data
   - `Show-PackageGUI` - Windows Forms UI
   - `Backup-Package` - Pull APK via ADB
   - `Remove-Package` - Uninstall via ADB
3. **Build GUI**: DataGridView with checkboxes, color coding
4. **Add logging**: Timestamped operation logs
5. **Test with dummy data** first
6. **Create VS Code task** for quick launch
7. **Write user documentation**

---

## User's Environment

- **OS**: Windows
- **PowerShell**: 7.x
- **Android SDK**: `C:\Users\Dad\Workspace\Tools\AndroidSDK\`
- **ADB**: `C:\Users\Dad\Workspace\Tools\AndroidSDK\platform-tools\adb.exe`
- **Phone**: Samsung (AT&T carrier), 534 packages
- **Current tool**: Remove-Apks.ps1 (text file based, no GUI)

---

## Design Notes

### Color Coding (DataGridView)
```powershell
# Row color based on risk
if ($row.Cells['Will Break'].Value -eq 'High') {
    $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::LightCoral
} elseif ($row.Cells['Will Break'].Value -eq 'Medium') {
    $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::LightYellow
} elseif ($row.Cells['Will Break'].Value -eq 'Low') {
    $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::LightGreen
}
```

### Smart Merge Logic
1. Scan phone via ADB (current state)
2. Load Excel data (research/history)
3. Match by package name
4. Show combined view:
   - Packages on phone + known data
   - Flag unknown packages (not in Excel)
   - Show disabled packages (in Excel but not on phone)

---

**Ready to build when user returns!** 🚀
