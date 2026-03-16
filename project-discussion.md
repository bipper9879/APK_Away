# APK_Away Project Discussion

## Date: March 15, 2026

---

### User:
i want to bulild an app to uninstall APKs via a command line so I can use --user 0 which can help with hiding or disabling some system files

---

### Assistant:
I see what you're looking for! You want to build an app that can uninstall/disable packages using `pm` commands with the `--user 0` flag.

Before I start, let me clarify the architecture since this affects the design:

**Option 1: Android App (runs ON the device)**
- Needs root or `WRITE_SECURE_SETTINGS` permission
- Can execute `pm disable-user --user 0` commands directly
- GUI app that lists installed packages and lets you disable/uninstall them
- No need for ADB connection

**Option 2: PC Tool (improved Remove-Apks.ps1)**
- Runs on your Windows PC
- Uses `adb shell pm` commands (like your current script)
- Could be a better GUI PowerShell app or keep it command-line based
- Works over ADB like you're already doing

**Option 3: Hybrid**
- PC-side app that deploys a helper APK to the device
- Uses ADB to communicate

**Which direction do you want to go?**

Also, I noticed from your history you already have `Remove-Apks.ps1` that does this from PC. Are you looking to:
- Replace it with a native Android app that runs on the phone?
- Improve the PC-side tool with a better interface?
- Both?

Let me know and I'll get started on the right architecture!

---

### User:
option 3 and I want remove-apks to be more robust and intuitive. my thought is install the app it would have selection to run a report that would list all apps on the android it would list the app name, the likely hood of it affecting system functionality what type of file system app, system service, framework, carrier app, user app, oem app, (any other type you can think of) and the package name. you should be ale to select individual files or all. there should be a choice to backup an APK before removing (to eb able to safely add it back in) and chose teh path for backing up the APKs.  there is more I am sure and there will be changes but is that enough for you to build a basic app? I would prefer to not use java and have it be a C++ app if that is possible. the language may change to one of teh other popular languaes but we can cross that later. before executing please consider I am a novice and I may be missing some very simple or needed aspects to create a project so lets discuss that before executing

---

### Assistant:
Great! Let's discuss the architecture before building anything. You've identified some important aspects, but there are a few technical constraints we need to work through:

## Key Technical Constraints

### 1. **Permission Problem with Pure Android App**
- Reading package info: ✅ Any app can do this
- Executing `pm disable-user --user 0` or `pm uninstall --user 0`: ⚠️ Requires **root** or **ADB shell access**
- A normal Android app (even system app) can't execute these commands without root
- **This is why you're using ADB from your PC right now**

### 2. **Language Choice**
For Android, here are your realistic options:
- **Kotlin** (modern standard, easiest) - NOT Java but similar
- **Java** (older standard, still widely used)
- **C++ with JNI hybrid** (C++ for logic + Java/Kotlin for UI) - complex, not recommended for beginners
- **Pure C++ (NDK Native Activity)** - extremely rare, very limited, no standard UI toolkit

For PC-side (where the ADB commands run):
- **PowerShell** (what you have now) - easy to enhance
- **C# with WPF/WinForms** (native Windows GUI) - great for desktop apps
- **C++ with Qt** (cross-platform GUI) - I see Qt mentioned in your workspace
- **Python with tkinter/PyQt** - simple but requires Python runtime

---

## Framework Migration Decision

**Date:** March 15, 2026

### User Goal: Best-in-Class Resource Efficiency
**VERY IMPORTANT:** Minimize the big 3:
1. CPU usage
2. Memory usage
3. Disk usage

### Framework Analysis

| Framework | Memory | CPU | Disk | Startup | Scrollbar Fix |
|-----------|--------|-----|------|---------|---------------|
| PowerShell WinForms (current) | 10-20MB | Minimal | 628 lines | <1s | ❌ Bug |
| **C# Windows Forms** (SELECTED) | 15-30MB | Minimal | ~50KB | <1s | ✅ Fixed |
| WPF | 30-50MB | Moderate | ~10MB | 1-2s | ✅ |
| PyQt5/PySide6 | 50-100MB | High | ~100MB | 2-3s | ✅ |

### Decision: C# Windows Forms ✅

**Reasons:**
1. Nearly identical resource footprint to PowerShell (15-30MB vs 10-20MB)
2. Fixes DataGridView scrollbar rendering bug
3. Same Windows Forms API (minimal migration)
4. Compiled to native code (faster than interpreted PowerShell)
5. No external dependencies (uses built-in .NET Framework)
6. Small executable size (~50KB)

**Why not WPF or PyQt5:**
- WPF: 2-3x more memory, DirectX rendering engine overhead (not needed)
- PyQt5: 5x more memory, 100MB disk footprint, Python runtime overhead

### Migration Plan
See: [MIGRATION_PLAN.md](MIGRATION_PLAN.md)

**Next Step:** Build proof-of-concept C# Windows Forms app

## My Recommended Architectures

### Option A: **Enhanced PC Tool** (Simplest, Most Practical)
```
┌─────────────────────────────────┐
│   Windows PC Application        │
│  (C#/PowerShell/C++ with GUI)   │
│                                 │
│  - Lists all packages via ADB   │
│  - Categorizes/scores them      │
│  - Interactive selection        │
│  - Backup to custom folder      │
│  - Execute pm commands          │
└─────────────────────────────────┘
           │
           │ ADB over USB
           ▼
┌─────────────────────────────────┐
│   Android Device                │
│   (no app installation needed)  │
└─────────────────────────────────┘
```
**Pros:**
- No Android app to install/maintain
- Works exactly like your current workflow
- Can use C++ (Qt), C# (WPF), or PowerShell
- Full ADB power with `--user 0`

**Cons:**
- Must use PC, not portable

### Option B: **Hybrid with Android UI**
```
┌─────────────────────────────────┐
│   Android App (Kotlin/Java)     │
│                                 │
│  - Scans packages locally       │
│  - Beautiful native UI          │
│  - User selects packages        │
│  - Sends commands to PC helper  │
└─────────────────────────────────┘
           │
           │ Network/USB
           ▼
┌─────────────────────────────────┐
│   PC Helper Tool                │
│   (PowerShell/C#/C++)           │
│                                 │
│  - Receives package list        │
│  - Executes ADB commands        │
└─────────────────────────────────┘
```
**Pros:**
- Nice Android UI on device
- Can review packages on-device

**Cons:**
- Still needs PC connected
- Two codebases to maintain
- More complex communication

## What's Missing from Your Design (Important!)

1. **Categorization Logic**: How do we determine "likelihood of affecting system"?
   - Flag checks: `FLAG_SYSTEM`, `FLAG_UPDATED_SYSTEM_APP`
   - Package name patterns: `com.android.*`, `com.google.*`, `com.samsung.*`
   - Known safe/unsafe lists (we'd need to build this database)

2. **APK Backup**: 
   - Get APK path: `pm path <package>`
   - Copy via `adb pull <path> <destination>`
   - Some system APKs are in `/system` and can't be backed up traditionally

3. **Safety Features**:
   - Whitelist of "never touch" packages (system UI, settings, etc.)
   - Confirmation dialog showing consequences
   - Dry-run mode (`-WhatIf` like your current script)

4. **Restore Functionality**:
   - `adb install -r <backed-up-apk>` for user apps
   - System apps are trickier - need `pm enable` to restore disabled ones

## Questions Before We Proceed

1. **Which architecture do you prefer?** Option A (PC-only) or Option B (hybrid)?

2. **Which language for PC side?**
   - PowerShell with GUI (Windows Forms) - enhance your current script
   - C# with WPF - professional Windows app
   - C++ with Qt - cross-platform, matches Organic Maps style

3. **Categorization priority**: Should I implement a scoring algorithm, or start with basic categories first?

4. **Project name**: What should we call it? Suggestions:
   - `AdbPackageManager`
   - `SystemAppCleaner`
   - `PackageDebloater`
   - Your choice?

5. **Scope for v1**: Start with just the core (list, categorize, backup, uninstall) or add extras like restore, batch operations, profiles?

Let me know your preferences and I'll create the project structure tailored to your needs!

---

### User:
store every word of this conversation starting with "i want to bulild an app to uninstall APKs via a command line so I can use --user 0 which can help with hiding or disabling some system files" to the root of C:\Users\Dad\Workspace\Projects\APK_Away as a docx so I can review before we continue.

---

## Notes

**Conversation saved as Markdown (.md) file**

I've saved this conversation as a Markdown file instead of .docx because:
- .docx files require special XML/ZIP formatting that isn't supported by basic file creation tools
- Markdown (.md) is easily readable in VS Code, text editors, and can be converted to .docx

**To convert to .docx:**
1. Open this file in VS Code or any text editor
2. Use Pandoc: `pandoc project-discussion.md -o project-discussion.docx`
3. Or copy/paste into Microsoft Word and save as .docx

The file location: `C:\Users\Dad\Workspace\Projects\APK_Away\project-discussion.md`

---

## C# Migration Session - March 16, 2026

### Session Overview
**Goal:** Complete C# Windows Forms proof-of-concept (Phase 1)  
**Primary Objective:** Fix DataGridView scrollbar bug that exists in PowerShell version  
**Status:** ✅ COMPLETE

### Key Accomplishments

1. **Scrollbar Bug Fix** ✅
   - User confirmed: "the scroll bar is visible" after testing C# version
   - PRIMARY MIGRATION GOAL ACHIEVED
   - Root cause: PowerShell Windows Forms rendering limitation

2. **UI Enhancements**
   - Fixed column header visual bug (turning blue on cell click)
     - Solution: `EnableHeadersVisualStyles = false`
   - Added two checkbox columns: "Backup First" and "Remove"
   - Configured column widths (65px for checkboxes)
   - Column ordering: Checkboxes first, then text columns
   - Column headers centered

3. **Context Menu Implementation**
   - Right-click on PackageName, Label, or Path columns
   - Options: Copy, Search on Internet
   - Opens default browser with Google search

4. **Bottom Panel Restoration**
   - Progress bar with real-time updates
   - Log output with timestamp format: `[HH:mm:ss]`
   - Panel height: 180px (expanded from 50px)
   - Console font: Consolas 8pt

5. **Button Consolidation**
   - Removed separate Remove/Backup buttons from top panel
   - Added single **Execute** button in bottom panel
   - Execute processes both backup and removal in phases:
     - Phase 1: Backup all packages marked "Backup First"
     - Phase 2: Remove all packages marked "Remove"

6. **Smart Confirmation Dialogs**
   - Backup confirmation: Shows count
   - Remove confirmation: 
     - Package count
     - Risk level warnings (⚠ HIGH RISK / MEDIUM RISK)
     - Backup status (✓ with backup / ✗ WITHOUT backup)
     - Mixed status if some have backup, some don't

7. **Bulk Selection Features**
   - **Select All Backup** button - Checks all "Backup First" checkboxes
   - **Clear All** button - Unchecks both columns for all packages

8. **Icon and Branding**
   - Custom application icon (AppIcon.ico)
   - Logo display in top panel center (App Away.png)
   - Attempted full-app translucent watermark (reverted - didn't work as expected)

### Technical Details

**Memory Usage:** 33.8MB (target was <30MB, but acceptable)  
**Executable Size:** 17.5KB (excellent)  
**Startup Time:** <1 second  
**Framework:** .NET 8.0 Windows Desktop (net8.0-windows)

**Project Structure:**
```
src/APKAway/
├── APKAway.csproj
├── Program.cs
├── MainForm.cs
├── MainForm.Designer.cs
├── Models/
│   └── PackageInfo.cs (Selected, BackupFirst, PackageName, Label, RiskLevel, Category, Description, Path)
├── Services/
│   └── DemoDataService.cs (25 mock packages)
└── AppIcon.ico
```

### Bug Fixes Applied

1. **Column Header Blue Highlight**
   - Issue: Headers turning blue when cell selected
   - Fix: Set `EnableHeadersVisualStyles = false` + explicit `SelectionBackColor`

2. **Checkbox Not Editable**
   - Issue: Checkboxes were read-only
   - Fix: Changed `dataGridView1.ReadOnly = false`, set per-column ReadOnly

3. **Context Menu on Wrong Columns**
   - Issue: Menu appeared on all cells
   - Fix: Added `CellMouseClick` event handler filtering by `DataPropertyName`

4. **Column Width Auto-Sizing Conflict**
   - Issue: App wouldn't start after setting widths
   - Fix: Changed Designer `AutoSizeColumnsMode` from Fill to None

5. **Icon Loading Crash**
   - Issue: Malformed ICO file caused unhandled exception
   - Fix: Added try/catch around icon loading (optional feature)

### User Feedback Pattern Observed
**Principle:** "Ask what is the simplest possible change first"  
- User prefers minimal diffs over architectural changes
- Incremental fixes tested after each change
- This approach successfully debugged multiple issues

### Next Steps (Phase 2)
- ADB integration for real device scanning
- Excel import (FE_APP_LIST.xlsx - 534 packages)
- Real backup functionality (`adb pull`)
- Real removal functionality (`adb shell pm uninstall --user 0`)
- Configuration persistence (JSON)

**Phase 1 Completion Time:** ~1 session with iterative refinements  
**User Satisfaction:** High - scrollbar fix validated, UI matching PowerShell version

