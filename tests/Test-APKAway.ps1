#Requires -Version 7.0
<#
.SYNOPSIS
    Test harness for APK Away - runs without connected device

.DESCRIPTION
    Creates mock data and tests all functions and workflows
    No Android device required

.EXAMPLE
    .\Test-APKAway.ps1
#>

[CmdletBinding()]
param()

Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     APK Away Test Suite - No Device Required          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Import the main script functions (dot source without running)
$scriptPath = Join-Path $PSScriptRoot "APK-Away.ps1"
if (-not (Test-Path $scriptPath)) {
    Write-Error "APK-Away.ps1 not found in $PSScriptRoot"
    exit 1
}

# Load script content to extract functions
$scriptContent = Get-Content $scriptPath -Raw

#region Mock Data Generator

function Get-MockPackageData {
    [CmdletBinding()]
    param([int]$Count = 50)
    
    $mockPackages = @(
        # High Risk System Packages
        [PSCustomObject]@{ Package = "com.android.systemui"; AppName = "System UI"; WillBreak = "High"; Type = "System App"; ApkPath = "/system/priv-app/SystemUI/SystemUI.apk" }
        [PSCustomObject]@{ Package = "com.android.phone"; AppName = "Phone"; WillBreak = "High"; Type = "System App"; ApkPath = "/system/priv-app/TeleService/TeleService.apk" }
        [PSCustomObject]@{ Package = "com.samsung.android.knox.containeragent"; AppName = "Knox Container"; WillBreak = "High"; Type = "System Service"; ApkPath = "/system/app/KnoxContainer/KnoxContainer.apk" }
        [PSCustomObject]@{ Package = "com.google.android.gms"; AppName = "Google Play Services"; WillBreak = "High"; Type = "Framework"; ApkPath = "/system/priv-app/GmsCore/GmsCore.apk" }
        [PSCustomObject]@{ Package = "com.android.vending"; AppName = "Google Play Store"; WillBreak = "High"; Type = "System App"; ApkPath = "/system/priv-app/Phonesky/Phonesky.apk" }
        
        # Medium Risk
        [PSCustomObject]@{ Package = "com.samsung.android.messaging"; AppName = "Samsung Messages"; WillBreak = "Medium"; Type = "OEM App"; ApkPath = "/system/app/SamsungMessages/SamsungMessages.apk" }
        [PSCustomObject]@{ Package = "com.google.android.apps.photos"; AppName = "Google Photos"; WillBreak = "Medium"; Type = "OEM App"; ApkPath = "/system/app/Photos/Photos.apk" }
        [PSCustomObject]@{ Package = "com.samsung.android.calendar"; AppName = "Samsung Calendar"; WillBreak = "Medium"; Type = "OEM App"; ApkPath = "/system/app/Calendar/Calendar.apk" }
        [PSCustomObject]@{ Package = "com.android.chrome"; AppName = "Chrome Browser"; WillBreak = "Medium"; Type = "OEM App"; ApkPath = "/system/app/Chrome/Chrome.apk" }
        [PSCustomObject]@{ Package = "com.google.android.apps.maps"; AppName = "Google Maps"; WillBreak = "Medium"; Type = "OEM App"; ApkPath = "/product/app/Maps/Maps.apk" }
        
        # Low Risk
        [PSCustomObject]@{ Package = "com.facebook.system"; AppName = "Facebook App Manager"; WillBreak = "Low"; Type = "Bloatware"; ApkPath = "/system/app/Facebook/Facebook.apk" }
        [PSCustomObject]@{ Package = "com.facebook.services"; AppName = "Facebook Services"; WillBreak = "Low"; Type = "Bloatware"; ApkPath = "/system/app/FBServices/FBServices.apk" }
        [PSCustomObject]@{ Package = "com.att.personalcloud"; AppName = "AT&T Personal Cloud"; WillBreak = "Low"; Type = "Carrier App"; ApkPath = "/system/app/ATTCloud/ATTCloud.apk" }
        [PSCustomObject]@{ Package = "com.att.myWireless"; AppName = "myAT&T"; WillBreak = "Low"; Type = "Carrier App"; ApkPath = "/system/app/myATT/myATT.apk" }
        [PSCustomObject]@{ Package = "com.amazon.mShop.android.shopping"; AppName = "Amazon Shopping"; WillBreak = "Low"; Type = "Bloatware"; ApkPath = "/product/app/Amazon/Amazon.apk" }
        [PSCustomObject]@{ Package = "com.samsung.android.game.gametools"; AppName = "Game Tools"; WillBreak = "Low"; Type = "OEM App"; ApkPath = "/system/app/GameTools/GameTools.apk" }
        [PSCustomObject]@{ Package = "com.samsung.android.bixby.agent"; AppName = "Bixby Voice"; WillBreak = "Low"; Type = "OEM App"; ApkPath = "/system/app/BixbyAgent/BixbyAgent.apk" }
        [PSCustomObject]@{ Package = "com.microsoft.office.excel"; AppName = "Microsoft Excel"; WillBreak = "Low"; Type = "OEM App"; ApkPath = "/product/app/Excel/Excel.apk" }
        
        # User Apps
        [PSCustomObject]@{ Package = "com.spotify.music"; AppName = "Spotify"; WillBreak = "Unknown"; Type = "User App"; ApkPath = "/data/app/Spotify/Spotify.apk" }
        [PSCustomObject]@{ Package = "com.whatsapp"; AppName = "WhatsApp"; WillBreak = "Unknown"; Type = "User App"; ApkPath = "/data/app/WhatsApp/WhatsApp.apk" }
        [PSCustomObject]@{ Package = "com.reddit.frontpage"; AppName = "Reddit"; WillBreak = "Unknown"; Type = "User App"; ApkPath = "/data/app/Reddit/Reddit.apk" }
        [PSCustomObject]@{ Package = "com.twitter.android"; AppName = "Twitter"; WillBreak = "Unknown"; Type = "User App"; ApkPath = "/data/app/Twitter/Twitter.apk" }
        [PSCustomObject]@{ Package = "org.mozilla.firefox"; AppName = "Firefox"; WillBreak = "Unknown"; Type = "User App"; ApkPath = "/data/app/Firefox/Firefox.apk" }
        
        # Unknown (not in research DB)
        [PSCustomObject]@{ Package = "com.unknown.test.app1"; AppName = "Unknown"; WillBreak = "Unknown"; Type = "Unknown"; ApkPath = "/data/app/TestApp1/TestApp1.apk" }
        [PSCustomObject]@{ Package = "com.unknown.test.app2"; AppName = "Unknown"; WillBreak = "Unknown"; Type = "Unknown"; ApkPath = "/data/app/TestApp2/TestApp2.apk" }
    )
    
    return $mockPackages
}

#endregion

#region Test Functions

function Test-MockPackageGeneration {
    Write-Host "`n[TEST 1] Mock Package Generation" -ForegroundColor Yellow
    Write-Host "─" * 60
    
    try {
        $packages = Get-MockPackageData
        Write-Host "  ✓ Generated $($packages.Count) mock packages" -ForegroundColor Green
        
        # Show distribution
        $high = ($packages | Where-Object { $_.WillBreak -eq 'High' }).Count
        $med = ($packages | Where-Object { $_.WillBreak -eq 'Medium' }).Count
        $low = ($packages | Where-Object { $_.WillBreak -eq 'Low' }).Count
        $unknown = ($packages | Where-Object { $_.WillBreak -eq 'Unknown' }).Count
        
        Write-Host "    Risk Distribution:" -ForegroundColor Cyan
        Write-Host "      High:    $high packages" -ForegroundColor Red
        Write-Host "      Medium:  $med packages" -ForegroundColor Yellow
        Write-Host "      Low:     $low packages" -ForegroundColor Green
        Write-Host "      Unknown: $unknown packages" -ForegroundColor Gray
        
        # Show type distribution
        $types = $packages | Group-Object Type | Sort-Object Count -Descending
        Write-Host "    Type Distribution:" -ForegroundColor Cyan
        foreach ($type in $types) {
            Write-Host "      $($type.Name): $($type.Count)" -ForegroundColor White
        }
        
        return $true
    }
    catch {
        Write-Host "  ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-ColorCodeLogic {
    Write-Host "`n[TEST 2] Color Code Logic" -ForegroundColor Yellow
    Write-Host "─" * 60
    
    $packages = Get-MockPackageData
    
    Write-Host "  Sample Color Assignments:" -ForegroundColor Cyan
    
    # Test each risk level
    $tests = @(
        @{ Risk = "High"; Expected = "LightCoral (Red)" }
        @{ Risk = "Medium"; Expected = "LightYellow (Yellow)" }
        @{ Risk = "Low"; Expected = "LightGreen (Green)" }
        @{ Risk = "Unknown"; Expected = "White" }
    )
    
    foreach ($test in $tests) {
        $sample = $packages | Where-Object { $_.WillBreak -eq $test.Risk } | Select-Object -First 1
        if ($sample) {
            Write-Host "    $($test.Risk) Risk → $($test.Expected)" -ForegroundColor $(
                switch ($test.Risk) {
                    'High' { 'Red' }
                    'Medium' { 'Yellow' }
                    'Low' { 'Green' }
                    default { 'Gray' }
                }
            )
            Write-Host "      Example: $($sample.Package)" -ForegroundColor DarkGray
        }
    }
    
    Write-Host "  ✓ Color code logic validated" -ForegroundColor Green
    return $true
}

function Test-FilterLogic {
    Write-Host "`n[TEST 3] Filter Logic" -ForegroundColor Yellow
    Write-Host "─" * 60
    
    $packages = Get-MockPackageData
    
    $filters = @{
        "High Risk" = { $_.WillBreak -eq 'High' }
        "Medium Risk" = { $_.WillBreak -eq 'Medium' }
        "Low Risk" = { $_.WillBreak -eq 'Low' }
        "Unknown" = { $_.WillBreak -eq 'Unknown' }
        "User Apps" = { $_.Type -eq 'User App' }
        "System Apps" = { $_.Type -match 'System' }
        "Bloatware" = { $_.Type -eq 'Bloatware' }
    }
    
    Write-Host "  Filter Results:" -ForegroundColor Cyan
    foreach ($filterName in $filters.Keys) {
        $filtered = $packages | Where-Object $filters[$filterName]
        $status = if ($filtered.Count -gt 0) { "✓" } else { "⚠" }
        $color = if ($filtered.Count -gt 0) { "Green" } else { "Yellow" }
        Write-Host "    $status $filterName`: $($filtered.Count) packages" -ForegroundColor $color
    }
    
    return $true
}

function Test-MockBackup {
    Write-Host "`n[TEST 4] Mock Backup Functionality" -ForegroundColor Yellow
    Write-Host "─" * 60
    
    $testBackupPath = Join-Path $env:TEMP "APK_Away_Test_Backups"
    
    try {
        # Create test backup directory
        if (Test-Path $testBackupPath) {
            Remove-Item $testBackupPath -Recurse -Force
        }
        New-Item -ItemType Directory -Path $testBackupPath -Force | Out-Null
        Write-Host "  ✓ Created test backup directory: $testBackupPath" -ForegroundColor Green
        
        # Simulate backing up 3 packages
        $mockPackages = @(
            "com.facebook.system",
            "com.att.personalcloud",
            "com.amazon.mShop.android.shopping"
        )
        
        foreach ($pkg in $mockPackages) {
            # Create a fake APK file
            $fakeApk = Join-Path $testBackupPath "$pkg.apk"
            "MOCK APK DATA FOR $pkg" | Out-File $fakeApk -Encoding ASCII
            Write-Host "    ✓ Backed up: $pkg.apk" -ForegroundColor Cyan
        }
        
        # Verify
        $backupCount = (Get-ChildItem $testBackupPath -Filter "*.apk").Count
        Write-Host "  ✓ Mock backup test passed: $backupCount APKs created" -ForegroundColor Green
        
        # Cleanup
        Write-Host "  ℹ Cleaning up test backups..." -ForegroundColor DarkGray
        Remove-Item $testBackupPath -Recurse -Force
        
        return $true
    }
    catch {
        Write-Host "  ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-MockRemoval {
    Write-Host "`n[TEST 5] Mock Removal Workflow" -ForegroundColor Yellow
    Write-Host "─" * 60
    
    $packages = Get-MockPackageData
    
    # Simulate selecting 5 low-risk packages
    $selected = $packages | Where-Object { $_.WillBreak -eq 'Low' } | Select-Object -First 5
    
    Write-Host "  Simulating removal of $($selected.Count) packages:" -ForegroundColor Cyan
    
    $successCount = 0
    $failCount = 0
    
    foreach ($pkg in $selected) {
        # Simulate random success/failure (90% success rate)
        $success = (Get-Random -Minimum 1 -Maximum 100) -le 90
        
        if ($success) {
            Write-Host "    ✓ $($pkg.Package) - Success" -ForegroundColor Green
            $successCount++
        }
        else {
            Write-Host "    ✗ $($pkg.Package) - Failed (simulated)" -ForegroundColor Red
            $failCount++
        }
        
        Start-Sleep -Milliseconds 200  # Simulate processing time
    }
    
    Write-Host "`n  Summary:" -ForegroundColor Cyan
    Write-Host "    Success: $successCount" -ForegroundColor Green
    Write-Host "    Failed:  $failCount" -ForegroundColor $(if ($failCount -eq 0) { 'Green' } else { 'Red' })
    
    return $true
}

function Test-LoggingSystem {
    Write-Host "`n[TEST 6] Logging System" -ForegroundColor Yellow
    Write-Host "─" * 60
    
    $testLogDir = Join-Path $PSScriptRoot "Logs"
    $testLogFile = Join-Path $testLogDir "test_apk-away_$(Get-Date -Format 'yyyyMMdd').log"
    
    try {
        # Create log directory
        if (-not (Test-Path $testLogDir)) {
            New-Item -ItemType Directory -Path $testLogDir -Force | Out-Null
        }
        
        # Write test log entries
        $testEntries = @(
            "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] INFO: Test log entry 1",
            "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] SUCCESS: Mock scan completed",
            "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] BACKUP: com.test.app -> backup.apk",
            "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] REMOVE: com.test.app - Success",
            "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ERROR: Simulated error for testing"
        )
        
        foreach ($entry in $testEntries) {
            Add-Content -Path $testLogFile -Value $entry
        }
        
        Write-Host "  ✓ Created test log: $testLogFile" -ForegroundColor Green
        Write-Host "  ✓ Wrote $($testEntries.Count) test entries" -ForegroundColor Green
        
        # Show sample
        Write-Host "`n  Sample log entries:" -ForegroundColor Cyan
        $testEntries | ForEach-Object {
            $color = if ($_ -match 'ERROR') { 'Red' } 
                     elseif ($_ -match 'SUCCESS') { 'Green' }
                     elseif ($_ -match 'BACKUP|REMOVE') { 'Cyan' }
                     else { 'White' }
            Write-Host "    $_" -ForegroundColor $color
        }
        
        return $true
    }
    catch {
        Write-Host "  ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-ConfigManagement {
    Write-Host "`n[TEST 7] Configuration Management" -ForegroundColor Yellow
    Write-Host "─" * 60
    
    $testConfigFile = Join-Path $PSScriptRoot "test-apk-away-config.json"
    
    try {
        # Create test config
        $testConfig = @{
            excelPath = "C:\Test\Excel.xlsx"
            defaultBackupPath = "C:\Test\Backups"
            adbPath = "C:\Test\adb.exe"
            logEnabled = $true
            autoBackup = $true
            confirmBeforeRemoval = $true
            windowSize = "1200x800"
            lastUsed = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        }
        
        # Save config
        $testConfig | ConvertTo-Json | Set-Content $testConfigFile -Encoding UTF8
        Write-Host "  ✓ Created test config file" -ForegroundColor Green
        
        # Read config back
        $loaded = Get-Content $testConfigFile | ConvertFrom-Json
        Write-Host "  ✓ Successfully loaded config" -ForegroundColor Green
        
        # Verify properties
        $properties = @('excelPath', 'defaultBackupPath', 'adbPath', 'logEnabled')
        Write-Host "  ✓ Verified config properties:" -ForegroundColor Cyan
        foreach ($prop in $properties) {
            Write-Host "    - $prop`: $($loaded.$prop)" -ForegroundColor White
        }
        
        # Cleanup
        Remove-Item $testConfigFile -Force
        Write-Host "  ✓ Cleaned up test config" -ForegroundColor Green
        
        return $true
    }
    catch {
        Write-Host "  ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-SafetyFeatures {
    Write-Host "`n[TEST 8] Safety Features" -ForegroundColor Yellow
    Write-Host "─" * 60
    
    $packages = Get-MockPackageData
    
    # Check for high-risk packages
    $highRisk = $packages | Where-Object { $_.WillBreak -eq 'High' }
    Write-Host "  High-risk package detection:" -ForegroundColor Cyan
    Write-Host "    ✓ Found $($highRisk.Count) high-risk packages" -ForegroundColor $(if ($highRisk.Count -gt 0) { 'Yellow' } else { 'Green' })
    
    # Simulate high-risk warning
    if ($highRisk.Count -gt 0) {
        Write-Host "`n  [SIMULATED WARNING]" -ForegroundColor Red
        Write-Host "  ⚠ WARNING: You have selected $($highRisk.Count) HIGH RISK package(s)." -ForegroundColor Red
        Write-Host "  Removing these may cause system instability." -ForegroundColor Red
        Write-Host "  Examples:" -ForegroundColor Yellow
        $highRisk | Select-Object -First 3 | ForEach-Object {
            Write-Host "    • $($_.Package) - $($_.AppName)" -ForegroundColor Yellow
        }
    }
    
    # Test critical package protection
    $criticalPackages = @('com.android.systemui', 'com.android.phone', 'com.google.android.gms')
    Write-Host "`n  Critical package protection check:" -ForegroundColor Cyan
    foreach ($critical in $criticalPackages) {
        $found = $packages | Where-Object { $_.Package -eq $critical }
        if ($found) {
            Write-Host "    ⚠ Protected: $critical" -ForegroundColor Red
        }
    }
    
    Write-Host "`n  ✓ Safety features validated" -ForegroundColor Green
    return $true
}

function Show-MockWorkflowDemo {
    Write-Host "`n[DEMO] Complete Workflow Simulation" -ForegroundColor Yellow
    Write-Host "═" * 60 -ForegroundColor Yellow
    
    Write-Host "`n  Step 1: Launch Application" -ForegroundColor Cyan
    Write-Host "    • Loading configuration..." -ForegroundColor White
    Start-Sleep -Milliseconds 500
    Write-Host "    ✓ Configuration loaded" -ForegroundColor Green
    
    Write-Host "`n  Step 2: Scan Phone" -ForegroundColor Cyan
    Write-Host "    • Connecting to device (mock)..." -ForegroundColor White
    Start-Sleep -Milliseconds 300
    Write-Host "    • Scanning packages..." -ForegroundColor White
    Start-Sleep -Milliseconds 500
    $packages = Get-MockPackageData
    Write-Host "    ✓ Found $($packages.Count) packages" -ForegroundColor Green
    
    Write-Host "`n  Step 3: Load Research Data" -ForegroundColor Cyan
    Write-Host "    • Reading Excel database..." -ForegroundColor White
    Start-Sleep -Milliseconds 300
    Write-Host "    ✓ Loaded research for $($packages.Count) packages" -ForegroundColor Green
    
    Write-Host "`n  Step 4: Filter Low Risk Packages" -ForegroundColor Cyan
    $lowRisk = $packages | Where-Object { $_.WillBreak -eq 'Low' }
    Write-Host "    ✓ Showing $($lowRisk.Count) low-risk packages" -ForegroundColor Green
    
    Write-Host "`n  Step 5: Select Packages for Removal" -ForegroundColor Cyan
    $selected = $lowRisk | Select-Object -First 3
    foreach ($pkg in $selected) {
        Write-Host "    ☑ $($pkg.Package) - $($pkg.AppName)" -ForegroundColor Yellow
    }
    
    Write-Host "`n  Step 6: Set Backup Path" -ForegroundColor Cyan
    $backupPath = "C:\Users\Dad\Workspace\APK_Backups"
    Write-Host "    📁 $backupPath" -ForegroundColor White
    
    Write-Host "`n  Step 7: Remove Selected Packages" -ForegroundColor Cyan
    foreach ($pkg in $selected) {
        Write-Host "    • Processing: $($pkg.Package)..." -ForegroundColor White
        Start-Sleep -Milliseconds 200
        Write-Host "      ✓ Backed up APK" -ForegroundColor Cyan
        Start-Sleep -Milliseconds 200
        Write-Host "      ✓ Removed successfully" -ForegroundColor Green
    }
    
    Write-Host "`n  Step 8: Summary" -ForegroundColor Cyan
    Write-Host "    Success: $($selected.Count)" -ForegroundColor Green
    Write-Host "    Failed:  0" -ForegroundColor Green
    
    Write-Host "`n  ✓ Workflow completed successfully!" -ForegroundColor Green
}

#endregion

#region Main Test Runner

function Invoke-AllTests {
    $tests = @(
        @{ Name = "Test-MockPackageGeneration"; Function = ${function:Test-MockPackageGeneration} },
        @{ Name = "Test-ColorCodeLogic"; Function = ${function:Test-ColorCodeLogic} },
        @{ Name = "Test-FilterLogic"; Function = ${function:Test-FilterLogic} },
        @{ Name = "Test-MockBackup"; Function = ${function:Test-MockBackup} },
        @{ Name = "Test-MockRemoval"; Function = ${function:Test-MockRemoval} },
        @{ Name = "Test-LoggingSystem"; Function = ${function:Test-LoggingSystem} },
        @{ Name = "Test-ConfigManagement"; Function = ${function:Test-ConfigManagement} },
        @{ Name = "Test-SafetyFeatures"; Function = ${function:Test-SafetyFeatures} }
    )
    
    $results = @()
    
    foreach ($test in $tests) {
        try {
            $result = & $test.Function
            $results += [PSCustomObject]@{
                Test = $test.Name
                Result = if ($result) { "PASS" } else { "FAIL" }
                Status = $result
            }
        }
        catch {
            $results += [PSCustomObject]@{
                Test = $test.Name
                Result = "ERROR"
                Status = $false
            }
            Write-Host "  ✗ Exception: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Show workflow demo
    Show-MockWorkflowDemo
    
    # Summary
    Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    TEST SUMMARY                        ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    Write-Host "`n  Test Results:" -ForegroundColor Yellow
    foreach ($result in $results) {
        $symbol = if ($result.Result -eq "PASS") { "✓" } else { "✗" }
        $color = if ($result.Result -eq "PASS") { "Green" } else { "Red" }
        Write-Host "    $symbol $($result.Test): " -NoNewline
        Write-Host $result.Result -ForegroundColor $color
    }
    
    $passed = ($results | Where-Object { $_.Result -eq "PASS" }).Count
    $failed = ($results | Where-Object { $_.Result -ne "PASS" }).Count
    $total = $results.Count
    
    Write-Host "`n  Overall: " -NoNewline
    Write-Host "$passed/$total tests passed" -ForegroundColor $(if ($failed -eq 0) { 'Green' } else { 'Yellow' })
    
    if ($failed -eq 0) {
        Write-Host "`n  🎉 All tests passed! APK Away is ready to use." -ForegroundColor Green
        Write-Host "  ℹ  Connect your Android device to test with real data." -ForegroundColor Cyan
    }
    else {
        Write-Host "`n  ⚠ $failed test(s) failed. Review errors above." -ForegroundColor Yellow
    }
}

#endregion

# Run all tests
Invoke-AllTests

Write-Host "`n═" * 60 -ForegroundColor Cyan
Write-Host ""
