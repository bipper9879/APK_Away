# APK_Away - Android Package Manager

PowerShell GUI tool for managing and removing Android bloatware safely.

## Project Structure

```
APK_Away/
├── bin/                      # Executable scripts
│   └── APK-Away.ps1         # Main entry point (loads modules)
├── src/                      # Source modules
│   ├── APK-Away-Core.ps1    # Core functions (scan, backup, remove)
│   └── APK-Away-GUI.ps1     # Windows Forms GUI
├── tests/                    # Test scripts
│   └── Test-APKAway.ps1     # Automated testing
├── docs/                     # Documentation
│   ├── USER_GUIDE.md        # Comprehensive user guide
│   ├── QUICK_START.md       # Quick reference
│   └── BUILD_PLAN.md        # Development roadmap
├── Deploy-ToScripts.ps1     # Deployment script
├── README.md                # This file
└── *.md                      # Planning documents
```

## Development Workflow

### 1. Work in Project Folder
Edit source files in `src/`:
- `src/APK-Away-Core.ps1` - Core functionality
- `src/APK-Away-GUI.ps1` - GUI layout and controls

### 2. Test from bin/
Run directly from project:
```powershell
cd C:\Users\Dad\Workspace\Projects\APK_Away
.\bin\APK-Away.ps1 -DemoMode
```

### 3. Deploy to Scripts Folder
When ready to deploy:
```powershell
.\Deploy-ToScripts.ps1
```

This combines all modules into a single script and copies to:
`C:\Users\Dad\Workspace\Scripts\APK-Away.ps1`

## Quick Start

**Demo Mode (no device required):**
```powershell
.\bin\APK-Away.ps1 -DemoMode
```

**With Android Device:**
```powershell
.\bin\APK-Away.ps1
```

## Features

- ✅ Scan Android packages via ADB
- ✅ Load research data from Excel (534 packages analyzed)
- ✅ Color-coded risk levels (High/Medium/Low)
- ✅ Backup APKs before removal
- ✅ Demo mode for testing
- ✅ Logging and configuration
- ✅ Safety warnings for high-risk packages

## Requirements

- PowerShell 7+
- ImportExcel module (`Install-Module ImportExcel`)
- Android SDK Platform Tools (ADB)
- USB debugging enabled on Android device

## Version

**v1.0** (March 15, 2026)
- Modular architecture
- Windows Forms GUI
- Full backup and removal workflow
- Demo mode for testing

## Documentation

See `docs/` folder:
- **USER_GUIDE.md** - Complete usage instructions
- **QUICK_START.md** - Quick reference
- **BUILD_PLAN.md** - Development progress

## Author

Dad - 2026
