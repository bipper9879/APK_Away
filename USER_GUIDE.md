# APK Away - User Guide

**Version:** 1.0  
**Date:** March 15, 2026

---

## Quick Start

1. Connect your Android device via USB
2. Enable USB debugging on your device
3. Run: `C:\Users\Dad\Workspace\Scripts\APK-Away.ps1`
4. Click "Scan Phone"
5. Select packages to remove (checkboxes)
6. Specify backup location (optional)
7. Click "Remove Selected"
8. Done!

---

## Requirements

### Software
- ✅ Windows 10/11
- ✅ PowerShell 7+
- ✅ ImportExcel PowerShell module (auto-installs if missing)
- ✅ Android SDK Platform Tools (ADB)

### Hardware
- ✅ Android device with USB debugging enabled
- ✅ USB cable

### Optional
- Excel research file (`C:\Users\Dad\OneDrive\ADP\FE_APP_LIST.xlsx`) - provides risk levels and app information

---

## Enabling USB Debugging on Android

1. Open **Settings** on your Android device
2. Scroll to **About Phone**
3. Tap **Build Number** 7 times (enables Developer Mode)
4. Go back to **Settings** → **Developer Options**
5. Enable **USB Debugging**
6. Connect device to PC - authorize the connection when prompted

---

## Using APK Away

### Main Interface

```
┌─────────────────────────────────────────────────────────────┐
│ [Scan Phone]  Backup: [____________] [Browse] Filter: [All]│
│ [Remove Selected]                                           │
│ □ Select All  |  Total: 534 | High: 123 | Medium: 149     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Package List (Color-Coded by Risk)                        │
│  □ com.example.app | App Name | Risk | Type                │
│  ...                                                        │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ Status: Ready                              [Progress Bar]  │
│ ┌───────────── Log ─────────────────────────────────────┐ │
│ │ [12:00:00] Scan complete - 534 packages loaded        │ │
│ └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Controls

**Scan Phone Button**
- Connects to your Android device
- Reads all installed packages
- Loads research data from Excel file
- Displays packages in the grid with color coding

**Backup Path**
- Specify where to save APK backups before removal
- Default: `C:\Users\Dad\Workspace\APK_Backups`
- Browse button opens folder picker
- Leave blank to skip backups (not recommended)

**Filter Dropdown**
- All Packages - Show everything
- High Risk - Critical system packages (RED)
- Medium Risk - Moderate impact packages (YELLOW)
- Low Risk - Safe to remove (GREEN)
- Unknown - Not in research database (WHITE)
- User Apps - Apps you installed
- System Apps - Pre-installed system components

**Select All Checkbox**
- Quickly select/deselect all visible packages
- Works with current filter

**Remove Selected Button**
- Processes all checked packages
- Backs up APKs if path specified
- Uninstalls via `adb shell pm uninstall --user 0`
- Shows progress bar during operation
- Displays summary when complete

### Color Coding

| Color        | Risk Level | Meaning                                    |
|--------------|------------|--------------------------------------------|
| 🔴 Light Red | High       | CRITICAL - Will break system functionality |
| 🟡 Yellow    | Medium     | May affect some features                   |
| 🟢 Green     | Low        | Safe to remove                             |
| ⚪ White     | Unknown    | Not in research database                   |

### Package Information Columns

- **Package** - Full package name (e.g., `com.samsung.android.something`)
- **App Name** - Human-readable name
- **Risk** - Impact level (High/Medium/Low/Unknown)
- **Type** - Category (System Service, User App, Bloatware, etc.)

---

## Safety Features

### ⚠️ High Risk Warning
When you select High Risk packages, APK Away shows a warning:
```
WARNING: You have selected X HIGH RISK package(s).

Removing these may cause system instability or break functionality.

Are you sure you want to continue?
```

### 🔒 Confirmation Dialog
Before any removal, you get a final confirmation:
```
Remove X package(s)?

Backup location: C:\...\APK_Backups

This action will uninstall the packages for user 0.
```

### 💾 Automatic Backups
- APKs are pulled from device before removal
- Saved as: `<backup_path>\<package_name>.apk`
- Can be reinstalled manually if needed

### 📝 Operation Logging
- All actions logged with timestamps
- Log files: `C:\Users\Dad\Workspace\Scripts\Logs\apk-away_YYYYMMDD.log`
- Success/failure status for each package
- Visible in bottom panel during operation

---

## Understanding Package Types

### System Service (221 packages)
Background services and daemons. Often critical for device operation.
- Examples: `.systemui`, `.bluetooth`, `.wifi`
- Risk: Usually HIGH

### System App (99 packages)
Built-in applications with system privileges.
- Examples: Settings, Phone, Messages
- Risk: HIGH to MEDIUM

### Framework (74 packages)
Core Android/Google/Samsung frameworks.
- Examples: `.framework`, `.services`, `.core`
- Risk: HIGH (never remove)

### User App (69 packages)
Apps you installed from Play Store.
- Examples: Your downloaded apps
- Risk: NONE (safe to remove)

### OEM App (51 packages)
Pre-installed by Samsung/Google.
- Examples: Samsung Health, Google Photos
- Risk: LOW to MEDIUM

### Carrier App (15 packages)
Pre-installed by carrier (AT&T).
- Examples: AT&T apps, carrier services
- Risk: LOW (safe to remove, may affect carrier features)

### Bloatware (5 packages)
Unwanted pre-installed apps.
- Examples: Facebook, Amazon
- Risk: NONE (safe to remove)

---

## Typical Workflow

### First-Time Use
1. Launch APK-Away.ps1
2. Wait for configuration initialization
3. Click "Scan Phone" to load your device
4. Review the color-coded list
5. Start with filter: "Low Risk" or "Bloatware"
6. Select packages you recognize and want gone
7. Set backup path (recommended for first run)
8. Click "Remove Selected"
9. Check device functionality after removal

### Regular Use
1. Launch APK-Away.ps1
2. Click "Scan Phone"
3. Use filters to find unwanted packages
4. Remove in small batches
5. Test device between batches

### Maintenance
1. Weekly/monthly scans to catch new bloatware
2. Review "Unknown" packages (newly installed)
3. Keep backup directory size in check

---

## What Happens When You Remove a Package?

### Package Removal Process
1. **Backup** (if path specified):
   - Gets APK path: `adb shell pm path <package>`
   - Pulls file: `adb pull <path> <backup>`
   
2. **Uninstall**:
   - Executes: `adb shell pm uninstall --user 0 <package>`
   - Package hidden from user 0 (you)
   - Still exists in `/system` partition (not deleted)
   
3. **Result**:
   - ✅ Success: Package no longer visible or active
   - ❌ Failure: Package protected or removal failed

### Important Notes
- **User 0 Removal**: Hides the app, doesn't delete from system partition
- **Reversible**: Can be reinstalled or re-enabled
- **Root Not Required**: Works on non-rooted devices
- **No Factory Reset Needed**: Changes survive reboots

---

## Restoring Packages

### Method 1: Reinstall from Backup
```powershell
adb install C:\Backup\com.package.name.apk
```

### Method 2: Re-enable System Package
```powershell
adb shell pm install-existing com.package.name
```

### Method 3: Factory Reset
Last resort - restores everything to stock.

---

## Troubleshooting

### "No Android device connected"
**Solutions:**
1. Check USB cable
2. Enable USB debugging
3. Authorize PC on device (popup)
4. Try different USB port
5. Restart ADB: `adb kill-server && adb start-server`
6. Restart device

### "Excel file not found"
**Solutions:**
1. Update path in config: `C:\Users\Dad\Workspace\Scripts\apk-away-config.json`
2. Or accept that packages will show as "Unknown"
3. Tool still works without Excel file

### "ImportExcel module not found"
**Solutions:**
- Script auto-installs on first run
- Manual install: `Install-Module ImportExcel -Scope CurrentUser`

### "Removal failed: Failure [not installed for 0]"
**Meaning:** Package already removed or never was installed for user 0
**Action:** Ignore, or click "Scan Phone" to refresh

### "Permission denied"
**Solutions:**
1. Re-connect USB cable
2. Revoke USB debugging authorization and reconnect
3. Restart ADB server
4. Check USB debugging is still enabled

### Device Not Responding After Removal
**Solutions:**
1. DON'T PANIC - device is likely fine
2. Wait 2-3 minutes for startup
3. Check which packages you removed
4. Restore from backup: `adb install <backup>.apk`
5. Factory reset (last resort)

---

## Configuration File

Location: `C:\Users\Dad\Workspace\Scripts\apk-away-config.json`

```json
{
    "excelPath": "C:\\Users\\Dad\\OneDrive\\ADP\\FE_APP_LIST.xlsx",
    "defaultBackupPath": "C:\\Users\\Dad\\Workspace\\APK_Backups",
    "adbPath": "C:\\Users\\Dad\\Workspace\\Tools\\AndroidSDK\\platform-tools\\adb.exe",
    "logEnabled": true,
    "autoBackup": true,
    "confirmBeforeRemoval": true,
    "windowSize": "1200x800",
    "lastUsed": "2026-03-15 12:00:00"
}
```

Edit this file to change default paths.

---

## Log Files

Location: `C:\Users\Dad\Workspace\Scripts\Logs\`

Format: `apk-away_YYYYMMDD.log`

Example Log Entry:
```
[2026-03-15 14:30:22] INFO: Scanned device, found 534 packages
[2026-03-15 14:31:05] BACKUP: com.facebook.system -> C:\Backup\com.facebook.system.apk
[2026-03-15 14:31:10] REMOVE: com.facebook.system - Success
[2026-03-15 14:31:15] ERROR: com.android.systemui - Failure (cannot remove system)
```

---

## Best Practices

### ✅ Do
- Always backup before first removal session
- Remove packages in small batches (5-10 at a time)
- Test device functionality between batches
- Start with "Low Risk" and "Bloatware" filters
- Read package names carefully before selecting
- Keep Excel research file updated

### ❌ Don't
- Remove packages with "High Risk" without research
- Remove everything at once
- Remove packages you don't recognize (High Risk)
- Skip backups
- Remove packages matching: `.android.*`, `.system.*`, `.framework.*`

### 🚫 Never Remove
- `com.android.systemui` - System UI (device becomes unusable)
- `com.android.phone` - Phone dialer
- `com.samsung.android.knox.*` - Samsung security
- `com.google.android.gms` - Google Play Services
- Anything with `.framework` or `.core` in the name

---

## FAQ

**Q: Is this safe?**
A: Yes, with proper caution. The `--user 0` flag hides apps without deleting them from system partition. They can be restored.

**Q: Do I need root?**
A: No. APK Away works on non-rooted devices.

**Q: Will this void my warranty?**
A: No. This doesn't modify system partition or bootloader.

**Q: What if I remove something critical?**
A: Restore from backup or use factory reset. User 0 removal is reversible.

**Q: Can I use this on any Android device?**
A: Yes, any device with USB debugging enabled.

**Q: Why are some packages "Unknown"?**
A: They're not in your research database (Excel file). Either new apps or not yet researched.

**Q: Does this free up storage space?**
A: Minimal. Apps are hidden, not deleted from system partition. User data may be cleared.

**Q: Can I remove all bloatware safely?**
A: Yes, packages marked as "Bloatware" and "Low Risk" are generally safe.

**Q: What's the difference between High/Medium/Low risk?**
A: Based on research of system impact:
- High = Will break critical functions
- Medium = May affect some features
- Low = No system impact

---

## Support

**Log File Location:** `C:\Users\Dad\Workspace\Scripts\Logs\`  
**Config File:** `C:\Users\Dad\Workspace\Scripts\apk-away-config.json`  
**Backup Location:** `C:\Users\Dad\Workspace\APK_Backups\`  
**Research Data:** `C:\Users\Dad\OneDrive\ADP\FE_APP_LIST.xlsx`

---

## Version History

### v1.0 (2026-03-15)
- Initial release
- Core functionality: scan, backup, remove
- GUI with color-coded risk levels
- Excel research database integration
- Logging and configuration management
- Multi-package batch processing
- Safety warnings for high-risk removals

---

**Stay Safe. Remove Wisely. Keep Backups.** 🚀
