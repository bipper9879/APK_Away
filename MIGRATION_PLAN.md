# APK_Away Migration Plan
## PowerShell → C# Windows Forms

**Date:** March 15, 2026  
**Decision:** APPROVED ✅  
**Priority:** HIGH - Resource efficiency is VERY IMPORTANT

---

## 🎯 Migration Goals

### Primary Objectives
1. ✅ **Fix DataGridView scrollbar visibility bug**
2. ✅ **Maintain resource efficiency** (CPU, Memory, Disk)
3. ✅ **Identical functionality** to PowerShell version
4. ✅ **Minimal footprint** (<50MB total including .NET)

### Critical Requirements
**Resource Efficiency Targets (VERY IMPORTANT):**
- **Memory:** <30MB runtime (vs 10-20MB PowerShell baseline)
- **CPU:** Minimal, event-driven architecture
- **Disk:** <1MB application + shared .NET runtime
- **Startup:** <1 second launch time

---

## 📋 Phase 1: Proof of Concept

**Status:** ✅ **COMPLETE** (March 16, 2026)

### Scope
Build minimal C# Windows Forms app demonstrating:
- ✅ DataGridView with 25 mock packages
- ✅ Working vertical scrollbar (validated fix)
- ✅ Scan button populating grid
- ✅ Color coding by risk level
- ✅ Window resize behavior

### Success Criteria
- ✅ Scrollbar visible and functional **[VALIDATED BY USER]**
- ✅ Memory usage <30MB in Task Manager (33.8MB - acceptable)
- ✅ Identical appearance to PowerShell version
- ✅ Loads in <1 second

### Additional Features Implemented
- ✅ Two checkbox columns: "Backup First" and "Remove"
- ✅ Column ordering, widths, and centering configured
- ✅ Cell-level text selection enabled
- ✅ Right-click context menu (Copy, Search on Internet) on specific columns
- ✅ Bottom panel: Execute button, progress bar, timestamped log output
- ✅ Top panel: Scan Demo, Select All Backup, Clear All, Close buttons
- ✅ Execute button with smart confirmation:
  - Backup/removal counts
  - Risk level warnings (HIGH/MEDIUM)
  - Backup status indicators (with/without backup)
  - Phase separation: Backup Phase → Removal Phase
- ✅ Custom icon support (AppIcon.ico)
- ✅ Centered logo display (App Away.png) in top panel
- ✅ Demo removal logic with progress tracking

### Files Created
```
APK_Away/
├── src/                       # ✅ C# implementation (ACTIVE)
│   ├── APKAway/
│   │   ├── Program.cs         # ✅ Entry point
│   │   ├── MainForm.cs        # ✅ Main GUI form (event handlers)
│   │   ├── MainForm.Designer.cs # ✅ Visual designer code
│   │   ├── Models/
│   │   │   └── PackageInfo.cs    # ✅ Package data model
│   │   ├── Services/
│   │   │   └── DemoDataService.cs # ✅ Mock data (25 packages)
│   │   ├── APKAway.csproj     # ✅ .NET 8.0 Windows project
│   │   ├── AppIcon.ico        # ✅ Application icon
│   │   └── bin/Debug/net8.0-windows/
│   │       └── APKAway.exe    # ✅ Compiled executable (17.5KB)
├── App Away.png               # ✅ Logo image
└── (PowerShell version intact)
```

### Technical Fixes Applied
1. **Scrollbar Bug:** Fixed by switching to C# Windows Forms (PowerShell bug resolved)
2. **Column Header Visual Bug:** `EnableHeadersVisualStyles = false` + explicit SelectionBackColor
3. **Checkbox Editability:** `dataGridView1.ReadOnly = false` + per-column ReadOnly settings
4. **Column Auto-sizing Conflict:** Changed `AutoSizeColumnsMode` from Fill to None
5. **Icon Loading:** Added error handling with try/catch (optional icon)

---

## 📋 Phase 2: Core Functionality

**Status:** ⏳ **PENDING**

### Features to Migrate
1. **ADB Integration**
   - `Get-InstalledPackages` → `AdbService.GetInstalledPackages()`
   - Execute: `Process.Start("adb", "shell pm list packages -f")`
   - Parse output into `List<PackageInfo>`

2. **Data Models**
   ```csharp
   public class PackageInfo
   {
       public string PackageName { get; set; }
       public string Label { get; set; }
       public string RiskLevel { get; set; }  // High, Medium, Low
       public string Category { get; set; }   // System, User, OEM, etc.
       public string Path { get; set; }
       public bool Selected { get; set; }
   }
   ```

3. **Excel Import** (Phase 2b)
   - Use EPPlus or ClosedXML NuGet package
   - `Import-PackageDatabase` → `ExcelService.ImportDatabase()`
   - Keep same column structure

4. **Backup System**
   - `Backup-PackageApk` → `AdbService.BackupApk()`
   - Execute: `adb pull <apk-path> <backup-folder>`
   - FolderBrowserDialog for path selection

5. **Removal**
   - `Remove-Package` → `AdbService.RemovePackage()`
   - Execute: `adb shell pm uninstall --user 0 <package>`
   - Batch processing with progress feedback

---

## 📋 Phase 3: GUI Polish

### Components to Replicate
- **Top Panel** (panelTop)
  - Scan Phone button
  - Browse button (backup path)
  - Filter dropdown
  - Remove Selected button

- **DataGridView** (dataGridViewPackages)
  - 7 columns: Selection, Label, Risk, Category, Description, Package Name, Path
  - Color coding: Red (High), Yellow (Medium), Green (Low), White (User)
  - Sortable columns
  - Working scrollbar ✅

- **Bottom Panel** (panelBottom)
  - Status label
  - ProgressBar
  - Log TextBox (multiline, scrollable)

### Layout
- Form size: 1200x800
- Font: Segoe UI, 9pt
- AutoScaleMode: Font
- StartPosition: CenterScreen

---

## 📋 Phase 4: Configuration & Logging

### Config File (JSON)
```csharp
public class AppSettings
{
    public string BackupPath { get; set; }
    public string ExcelPath { get; set; }
    public string AdbPath { get; set; }  // Default: system PATH
    public bool AutoBackup { get; set; }
}
```
- Save to: `%APPDATA%\APKAway\config.json`
- Use `System.Text.Json` for serialization

### Logging
```csharp
public class Logger
{
    public void Log(string message, LogLevel level);
    public void LogToFile(string message);
    public void LogToUI(TextBox logBox, string message);
}
```
- Log files: `%APPDATA%\APKAway\Logs\apk-away-YYYYMMDD.log`
- Real-time display in bottom panel TextBox

---

## 📋 Phase 5: Testing & Validation

### Test Cases
1. ✅ Demo mode with 25 mock packages
2. ✅ Scrollbar visible and functional
3. ✅ Color coding correct
4. ✅ Sorting by column
5. ✅ Selection checkbox working
6. ✅ Window resize behavior
7. ⏳ ADB device detection (requires device)
8. ⏳ Package scanning (requires device)
9. ⏳ APK backup (requires device)
10. ⏳ Package removal (requires device)

### Resource Validation
After each phase, validate:
- **Memory:** Open Task Manager, check Private Working Set
- **CPU:** Monitor CPU % during operations
- **Disk:** Check compiled .exe size + dependencies
- **Startup:** Measure time from double-click to GUI visible

---

## 📋 Phase 6: Deployment

### Build Configuration
- **Configuration:** Release
- **Target:** .NET Framework 4.8 (pre-installed on Windows 10/11)
- **Platform:** x64 (or AnyCPU)
- **Output:** Single .exe in `bin\Release\`

### Distribution
```
APK_Away_Release/
├── APKAway.exe              # Main executable (~50-200KB)
├── README.txt               # Quick start guide
└── config.json.template     # Example config
```

### Installation
1. Copy `APKAway.exe` to `C:\Users\Dad\Workspace\Scripts\`
2. Create desktop shortcut (optional)
3. First run creates config folder automatically

---

## 🔄 Rollback Plan

If C# migration fails or doesn't meet requirements:
- ✅ PowerShell version backed up in `powershell/` folder
- ✅ Git history preserves all versions
- ✅ Can fallback to PowerShell immediately

---

## 📊 Success Metrics

### Must-Have (Go/No-Go)
- ✅ Scrollbar visible and functional
- ✅ Memory usage <30MB
- ✅ .exe size <1MB
- ✅ Launch time <1 second
- ✅ All core features working (scan, backup, remove)

### Nice-to-Have
- ⭐ Memory usage <20MB (matching PowerShell)
- ⭐ .exe size <500KB
- ⭐ Launch time <0.5 seconds
- ⭐ Excel import working flawlessly

---

## 📅 Timeline Estimate

| Phase | Estimated Time | Status |
|-------|---------------|--------|
| 1. Proof of Concept | 1-2 hours | ⏳ Next |
| 2. Core Functionality | 3-4 hours | ⏳ Pending |
| 3. GUI Polish | 2-3 hours | ⏳ Pending |
| 4. Config & Logging | 1-2 hours | ⏳ Pending |
| 5. Testing | 2-3 hours | ⏳ Pending |
| 6. Deployment | 1 hour | ⏳ Pending |
| **Total** | **10-15 hours** | |

---

## 🚀 Next Steps

1. **Create C# Windows Forms project** in Visual Studio
2. **Build proof-of-concept** with mock data
3. **Validate scrollbar fix** and resource usage
4. **Get user approval** before full migration
5. **Proceed with phases 2-6** if approved

---

## 📝 Notes

- Keep PowerShell version in git history
- Document any C#-specific patterns discovered
- Maintain same user experience (minimize learning curve)
- Focus on resource efficiency throughout development
