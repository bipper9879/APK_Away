# APK Away - Quick Reference

## Launch Command
```powershell
C:\Users\Dad\Workspace\Scripts\APK-Away.ps1
```

## File Locations
- **Script:** `C:\Users\Dad\Workspace\Scripts\APK-Away.ps1`
- **Config:** `C:\Users\Dad\Workspace\Scripts\apk-away-config.json`
- **Logs:** `C:\Users\Dad\Workspace\Scripts\Logs\`
- **Backups:** `C:\Users\Dad\Workspace\APK_Backups\`
- **Excel Data:** `C:\Users\Dad\OneDrive\ADP\FE_APP_LIST.xlsx`

## First Time Setup
1. Connect Android device (USB debugging enabled)
2. Run script - it will initialize configuration
3. Click "Scan Phone"
4. Start with "Low Risk" or "Bloatware" filter
5. Select packages, set backup path, remove

## Safety Tips
- ✅ Always backup before first removal
- ✅ Start with Low Risk packages
- ✅ Remove in small batches (5-10 at a time)
- ✅ Test device between batches
- ❌ Never remove High Risk without research
- ❌ Never remove `.systemui`, `.framework`, `.core` packages

## Color Codes
- 🔴 Red = High Risk (can break system)
- 🟡 Yellow = Medium Risk (may affect features)
- 🟢 Green = Low Risk (safe to remove)
- ⚪ White = Unknown (not in research database)

## Quick Filters
- **Bloatware** - Facebook, Amazon, carrier apps (safe)
- **Low Risk** - Non-critical apps
- **User Apps** - Apps you installed
- **Carrier Apps** - AT&T bloatware

## Troubleshooting
**No device found:** Check USB debugging, try different cable/port  
**Excel not found:** Tool works without it (packages show as Unknown)  
**Removal fails:** Package may already be removed or system-protected  

## Documentation
**Full Guide:** `C:\Users\Dad\Workspace\Projects\APK_Away\USER_GUIDE.md`

## Restore Package
```powershell
# From backup
adb install C:\Path\To\Backup\com.package.name.apk

# Re-enable system package
adb shell pm install-existing com.package.name
```

## Version
v1.0 - March 15, 2026
