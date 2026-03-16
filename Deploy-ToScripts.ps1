<#
.SYNOPSIS
    Deploy APK-Away to Scripts folder

.DESCRIPTION
    Combines all modules and deploys APK-Away.ps1 to C:\Users\Dad\Workspace\Scripts\
    
    This script:
    1. Validates all source files exist
    2. Combines Core + GUI into a single deployable script
    3. Copies to Scripts folder with backup of existing version

.PARAMETER Force
    Skip confirmation prompts

.EXAMPLE
    .\Deploy-ToScripts.ps1
    Deploy with confirmation

.EXAMPLE  
    .\Deploy-ToScripts.ps1 -Force
    Deploy without confirmation
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Paths
$ProjectRoot = $PSScriptRoot
$SrcPath = Join-Path $ProjectRoot "src"
$BinPath = Join-Path $ProjectRoot "bin"
$DeployPath = "C:\Users\Dad\Workspace\Scripts"

$CoreModule = Join-Path $SrcPath "APK-Away-Core.ps1"
$GUIModule = Join-Path $SrcPath "APK-Away-GUI.ps1"
$MainScript = Join-Path $BinPath "APK-Away.ps1"

Write-Host "`n=== APK-Away Deployment Script ===" -ForegroundColor Cyan
Write-Host ""

# Validate source files
Write-Host "Validating source files..." -ForegroundColor Yellow
$missingFiles = @()

if (-not (Test-Path $CoreModule)) { $missingFiles += "Core module: $CoreModule" }
if (-not (Test-Path $GUIModule)) { $missingFiles += "GUI module: $GUIModule" }
if (-not (Test-Path $MainScript)) { $missingFiles += "Main script: $MainScript" }

if ($missingFiles.Count -gt 0) {
    Write-Host "`n❌ Missing required files:" -ForegroundColor Red
    $missingFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "✓ All source files found" -ForegroundColor Green

# Read source files
Write-Host "`nReading modules..." -ForegroundColor Yellow
$coreContent = Get-Content $CoreModule -Raw
$guiContent = Get-Content $GUIModule -Raw

# Read only the header and config from main script (first 50 lines)
$mainLines = Get-Content $MainScript
$headerLines = $mainLines[0..49]

# Find the main entry point (everything after "#region Main Entry Point")
$mainEntryStart = ($mainLines | Select-String "#region Main Entry Point" -SimpleMatch).LineNumber
$mainEntryLines = $mainLines[($mainEntryStart - 1)..($mainLines.Count - 1)]

Write-Host "✓ Core module: $((Get-Content $CoreModule).Count) lines" -ForegroundColor Green
Write-Host "✓ GUI module: $((Get-Content $GUIModule).Count) lines" -ForegroundColor Green

# Build combined script
Write-Host "`nBuilding combined script..." -ForegroundColor Yellow
$combinedScript = @"
$($headerLines -join "`r`n")

$coreContent

$guiContent

$($mainEntryLines -join "`r`n")
"@

$outputFile = Join-Path $DeployPath "APK-Away.ps1"

# Show deployment info
Write-Host "`nDeployment target:" -ForegroundColor Cyan
Write-Host "  From: $ProjectRoot" -ForegroundColor Gray
Write-Host "  To:   $outputFile" -ForegroundColor Gray
Write-Host "  Size: $([Math]::Round($combinedScript.Length / 1KB, 1)) KB" -ForegroundColor Gray

# Check if target exists
$backupCreated = $false
if (Test-Path $outputFile) {
    Write-Host "`n⚠ Existing file found at target location" -ForegroundColor Yellow
    
    if (-not $Force) {
        Write-Host "Create backup and overwrite? (Y/N): " -NoNewline -ForegroundColor Yellow
        $response = Read-Host
        if ($response -ne 'Y' -and $response -ne 'y') {
            Write-Host "`nDeployment cancelled by user" -ForegroundColor Yellow
            exit 0
        }
    }
    
    # Create backup
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backupFile = Join-Path $DeployPath "APK-Away_backup_$timestamp.ps1"
    Copy-Item $outputFile $backupFile -Force
    Write-Host "✓ Backup created: APK-Away_backup_$timestamp.ps1" -ForegroundColor Green
    $backupCreated = $true
}

# Deploy
Write-Host "`nDeploying..." -ForegroundColor Yellow
$combinedScript | Set-Content $outputFile -Encoding UTF8 -NoNewline

Write-Host "✓ Deployed successfully!" -ForegroundColor Green

# Summary
Write-Host "`n=== Deployment Summary ===" -ForegroundColor Cyan
Write-Host "✓ Combined script deployed to: $outputFile" -ForegroundColor Green
if ($backupCreated) {
    Write-Host "✓ Previous version backed up" -ForegroundColor Green
}
Write-Host "`nYou can now run:" -ForegroundColor Cyan
Write-Host "  $outputFile" -ForegroundColor White
Write-Host "  $outputFile -DemoMode" -ForegroundColor White
Write-Host ""
