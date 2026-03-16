# APK_Away - Android Package Manager

PowerShell and C# GUI tools for managing and removing Android bloatware safely.

## 🚀 C# Version (Recommended)

**Status:** Phase 1 Complete ✅ | Phase 2 In Progress ⏳

The C# Windows Forms version fixes the DataGridView scrollbar bug and provides identical functionality with better resource efficiency.

**Location:** `src\APKAway\`  
**Run:** `dotnet run` (from `src\APKAway` directory)

### Features (C# v0.1 - Proof of Concept)
- ✅ Scrollbar fix validated (primary goal achieved)
- ✅ Two checkbox columns: "Backup First" and "Remove"
- ✅ Execute button with smart confirmation dialogs
- ✅ Right-click context menu (Copy, Search on Internet)
- ✅ Progress bar and timestamped log output
- ✅ Select All Backup / Clear All buttons
- ✅ Custom icon and logo display
- ✅ Demo mode with 25 mock packages
- ⏳ ADB integration (Phase 2)
- ⏳ Excel import (Phase 2)
- ⏳ Real backup/removal (Phase 2)

### Quick Start (C#)
```powershell
cd C:\Users\Dad\Workspace\Projects\APK_Away\csharp\APKAway
dotnet run
```

**Memory:** 33.8MB | **Exe Size:** 17.5KB | **Startup:** <1s

---

## PowerShell Version (v1.0 - Complete)

**Status:** ✅ Fully functional, feature-complete

**Location:** `bin\APK-Away.ps1` (development) or `C:\Users\Dad\Workspace\Scripts\APK-Away.ps1` (deployed)

## Project Structure

```
APK_Away/
├── src/                      # C# Windows Forms version (ACTIVE)
│   └── APKAway/
│       ├── Program.cs
│       ├── MainForm.cs       # GUI and event handlers
│       ├── MainForm.Designer.cs
│       ├── Models/
│       │   └── PackageInfo.cs
│       ├── Services/
│       │   └── DemoDataService.cs
│       ├── APKAway.csproj
│       └── AppIcon.ico
├── bin/                      # PowerShell executable scripts
│   └── APK-Away.ps1         # Main entry point (loads modules)
├── src/                      # PowerShell source modules
│   ├── APK-Away-Core.ps1    # Core functions (scan, backup, remove)
│   └── APK-Away-GUI.ps1     # Windows Forms GUI
├── tests/                    # Test scripts
│   └── Test-APKAway.ps1     # Automated testing
├── docs/                     # Documentation
│   ├── USER_GUIDE.md        # Comprehensive user guide
│   ├── QUICK_START.md       # Quick reference
│   └── BUILD_PLAN.md        # Development roadmap
├── Deploy-ToScripts.ps1     # Deployment script
├── MIGRATION_PLAN.md        # C# migration roadmap
├── SESSION_STATE.md         # Current session status
├── README.md                # This file
└── *.md                      # Planning documents
```

## Development Workflow

### C# Development (Current Focus)
```powershell
# Work in src/APKAway folder
cd C:\Users\Dad\Workspace\Projects\APK_Away\src\APKAway

# Run with hot reload
dotnet run

# Build release
dotnet build -c Release
```

### PowerShell Development (Maintenance Mode)
Edit source files in `src/`:
- `src/APK-Away-Core.ps1` - Core functionality
- `src/APK-Away-GUI.ps1` - GUI layout and controls

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
