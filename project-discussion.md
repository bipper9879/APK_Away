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
