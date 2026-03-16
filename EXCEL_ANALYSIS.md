# Excel File Analysis - FE_APP_LIST.xlsx

**File Location:** `C:\Users\Dad\OneDrive\ADP\FE_APP_LIST.xlsx`  
**Analysis Date:** March 15, 2026  
**Total Packages:** 534

---

## Sheet 1: FE_APP_LIST

### Column Schema

| Column | Data Type | Nullable | Unique Values | Description |
|--------|-----------|----------|---------------|-------------|
| Package | String | No | 534 | Full Android package identifier |
| App Name | String | No | ~534 | Human-readable application name |
| Will Break | String | Yes (70 NaN) | 4 | Risk assessment: High/Medium/Low/NaN |
| Type | String | No | 7 | Application category |

### Will Break - Risk Distribution

| Risk Level | Count | Percentage | Description |
|------------|-------|------------|-------------|
| High | 123 | 23.0% | Critical system components - removal will break phone |
| Medium | 149 | 27.9% | Moderate risk - some features may fail |
| Low | 192 | 36.0% | Safe to remove - minimal impact |
| NaN | 70 | 13.1% | User apps - no system impact |

**Risk Criteria (inferred from data patterns):**

**High Risk:**
- Core system services: IMS, Knox, telephony
- Framework components: Android core, Google core services
- Critical UI: SystemUI, Settings, Launcher
- Examples: `com.android.systemui`, `com.samsung.android.knox.*`, `com.google.android.gms`

**Medium Risk:**
- Optional system features: Smart View, Samsung features
- Carrier services: Enhanced features, analytics
- OEM services: Samsung Cloud, DeX
- Examples: `com.samsung.android.smartmirroring`, `com.att.*`

**Low Risk:**
- Pre-installed apps: Gallery, Calendar, browser
- Optional features: AR Emoji, themes, game tools
- Bloatware: Facebook, Amazon
- Examples: `com.samsung.android.calendar`, `com.facebook.*`

**NaN (No Data):**
- User-installed apps
- Games, banking apps, social media
- No system integration

### Type - Category Distribution

| Type | Count | % | Description |
|------|-------|---|-------------|
| System Service | 221 | 41.4% | Background services, daemons |
| System App | 99 | 18.5% | Built-in apps with system privileges |
| Framework | 74 | 13.9% | Android/Google/Samsung core frameworks |
| User App | 69 | 12.9% | User-installed applications |
| OEM App | 51 | 9.6% | Pre-installed by Samsung/Google |
| Carrier App | 15 | 2.8% | AT&T specific applications |
| Bloatware | 5 | 0.9% | Unwanted pre-installed apps |

**Category Definitions:**

**System Service (221):**
- Background processes, no UI
- Examples: Location providers, IMS logger, Knox agents
- Characteristics: `*.service`, `*agent`, `*provider` in package name
- Removal impact: Often breaks related features

**System App (99):**
- Core apps with system permissions
- Examples: Settings, Phone, Messages, Gallery
- Characteristics: In `/system/app` or `/system/priv-app`
- Removal impact: Lost functionality, UI components

**Framework (74):**
- Core system libraries and overlays
- Examples: Android framework overlays, Google modules
- Characteristics: `android.*`, `com.google.android.ext.*`
- Removal impact: System instability, crashes

**User App (69):**
- Installed by user from Play Store or APK
- Examples: Banking apps, games, messaging
- Characteristics: Non-system install location
- Removal impact: None to system

**OEM App (51):**
- Pre-installed by manufacturer (Samsung/Google)
- Examples: Samsung Health, Google Photos, Chrome
- Characteristics: Branded but optional
- Removal impact: Lost features, often replaceable

**Carrier App (15):**
- AT&T specific applications
- Examples: AT&T Smart Wi-Fi, Call Protect, MyATT
- Characteristics: `com.att.*` package names
- Removal impact: Carrier features only

**Bloatware (5):**
- Explicitly unwanted pre-installed apps
- Examples: Facebook, Amazon App Store
- Characteristics: Known bloatware list
- Removal impact: None (desired)

---

## Sheet 2: what_goes

### Purpose
Working sheet for user to mark packages for batch removal operations.

### Additional Columns

| Column | Type | Description |
|--------|------|-------------|
| go y/n | String | `y` = uninstall this package, NaN = skip |
| backup to folder | String | Whether to backup APK before removal |

Plus all columns from FE_APP_LIST sheet (Package, App Name, Will Break, Type).

### Usage Pattern
1. User reviews FE_APP_LIST
2. Copies rows to what_goes sheet
3. Marks `go y/n` = `y` for packages to remove
4. Marks `backup to folder` for packages to backup first
5. Tool processes marked rows in batch

### Current State
- Multiple rows marked with `y` in `go y/n` column
- Represents user's intended removal list
- Mix of bloatware, carrier apps, and optional features

---

## Package Name Patterns

### Samsung Packages
```
com.samsung.android.*     - Samsung Android apps/services
com.sec.android.*         - Samsung Security/Enterprise
com.sec.*                 - Samsung (short prefix)
```

### Google Packages
```
com.google.android.gms    - Google Play Services (CRITICAL)
com.google.android.apps.* - Google apps
com.android.*             - Android core system
android.*                 - Android framework
```

### Carrier Packages
```
com.att.*                 - AT&T applications
com.tmobile.*             - T-Mobile (if present)
com.vzw.*                 - Verizon (if present)
```

### Known Bloatware
```
com.facebook.*            - Facebook
com.amazon.*              - Amazon
com.netflix.*             - Netflix (pre-installed)
```

---

## Research Methodology (Previous Session)

User reported the previous Claude session:
1. Pulled package list from phone via ADB
2. Researched each package using:
   - **Industry standards** - Android Developer docs, Google guidelines
   - **Best practices** - XDA forums, Android Police articles
   - **User forums** - Reddit r/AndroidQuestions, XDA Developers forums
3. Categorized by Type based on package location and function
4. Scored "Will Break" based on:
   - Critical system dependencies
   - User reports of removal consequences
   - Function analysis (what does this package do?)

### Likely Sources Consulted
- **XDA Developers Forums** - De-bloat guides, safe removal lists
- **Reddit r/AndroidQuestions** - Community removal experiences
- **Android Developer Docs** - Official package documentation
- **GitHub debloat lists** - Community-maintained safe removal lists
- **Stack Overflow** - Developer discussions on package functions

---

## Data Quality Notes

### Complete Information
- All 534 packages have Package and App Name
- All have Type classification
- 464 have Will Break scores (87%)

### Missing Data
- 70 packages have NaN for Will Break (all User Apps - expected)
- Most are user-installed apps with no system impact

### Consistency
- Type categories are consistent and well-defined
- Risk scores align with package criticality
- App Names are descriptive and researched (not just package names)

---

## Usage in APK_Away Tool

### Primary Use Case
**Reference Database** - Don't re-research packages, use existing data

### Tool Logic
1. Scan phone: Get current installed packages
2. Load Excel: Read FE_APP_LIST.xlsx
3. Match: Join phone packages with Excel data on package name
4. Display: Show combined info in GUI
5. Flag: Highlight new packages not in Excel (need research)

### Data Flow
```
Phone (ADB) → List of installed packages
                ↓
Excel (FE_APP_LIST.xlsx) → Risk scores + Categories
                ↓
            JOIN on Package name
                ↓
GUI Table → Color-coded by risk, filterable by type
                ↓
User selects packages
                ↓
Backup (optional) → Pull APK via ADB
                ↓
Uninstall → adb shell pm uninstall --user 0 <package>
```

### New Package Handling
When tool detects package NOT in Excel:
1. Mark as "Unknown" risk
2. Display package name + basic info from ADB
3. Recommend user research before removal
4. Optionally: Add to Excel for future reference

---

## Statistics Summary

- **Total Packages Analyzed**: 534
- **Critical (High Risk)**: 123 (don't touch without backup/research)
- **Moderate (Medium Risk)**: 149 (research first)
- **Safe (Low Risk)**: 192 (good candidates for removal)
- **User Apps (NaN)**: 70 (safe to remove if unwanted)

**Recommended Removal Targets:**
- Bloatware: 5 (Facebook, Amazon)
- Carrier Apps: 15 (AT&T specific)
- Low Risk System Apps: Select from 192
- **Total Safe Removal Candidates: ~20-50 packages**

---

## File Maintenance

### When to Update Excel
- New packages appear on phone (OS update, new app install)
- User researches unknown package - add findings
- Risk assessment changes (user experience proves score wrong)
- New Type category needed

### Backup Strategy
- Keep Excel in OneDrive (already done)
- Version control: Save dated copies after major changes
- Export to CSV for git tracking (optional)

---

**This research is GOLD** - 534 packages already analyzed. Build tool to leverage it! 🏆
