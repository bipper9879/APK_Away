#region GUI Application

<#
.SYNOPSIS
    Launches the main GUI application

.DESCRIPTION
    Creates Windows Forms GUI with DataGridView for package management
#>
function Show-ApkAwayGUI {
    [CmdletBinding()]
    param()
    
    # Load Windows Forms
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    # Create main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = if ($Script:DemoMode) { "APK Away - Android Package Manager [DEMO MODE]" } else { "APK Away - Android Package Manager" }
    
    # Dynamic sizing based on screen resolution (80% of screen)
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    $formWidth = [Math]::Min(1400, [Math]::Floor($screen.Width * 0.8))
    $formHeight = [Math]::Min(900, [Math]::Floor($screen.Height * 0.8))
    $form.Size = New-Object System.Drawing.Size($formWidth, $formHeight)
    $form.StartPosition = "CenterScreen"
    $form.MinimumSize = New-Object System.Drawing.Size(1000, 600)
    
    # Suspend layout during control creation to prevent flicker and layout issues
    $form.SuspendLayout()
    
    #region Top Control Panel
    
    $panelTop = New-Object System.Windows.Forms.Panel
    $panelTop.Dock = [System.Windows.Forms.DockStyle]::Top
    $panelTop.Height = 100
    $panelTop.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
    $panelTop.Padding = New-Object System.Windows.Forms.Padding(5)
    
    # Scan Phone Button
    $btnScan = New-Object System.Windows.Forms.Button
    $btnScan.Location = New-Object System.Drawing.Point(10, 15)
    $btnScan.Size = New-Object System.Drawing.Size(120, 35)
    $btnScan.Text = if ($Script:DemoMode) { "Scan (Demo)" } else { "Scan Phone" }
    $btnScan.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
    $btnScan.ForeColor = [System.Drawing.Color]::White
    $btnScan.FlatStyle = "Flat"
    $btnScan.FlatAppearance.BorderSize = 0
    $btnScan.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btnScan.Cursor = [System.Windows.Forms.Cursors]::Hand
    $panelTop.Controls.Add($btnScan)
    
    # Backup Path Label
    $lblBackup = New-Object System.Windows.Forms.Label
    $lblBackup.Location = New-Object System.Drawing.Point(140, 20)
    $lblBackup.Size = New-Object System.Drawing.Size(80, 25)
    $lblBackup.Text = "Backup to:"
    $lblBackup.TextAlign = "MiddleRight"
    $panelTop.Controls.Add($lblBackup)
    
    # Backup Path TextBox
    $txtBackupPath = New-Object System.Windows.Forms.TextBox
    $txtBackupPath.Location = New-Object System.Drawing.Point(225, 20)
    $txtBackupPath.Size = New-Object System.Drawing.Size(400, 25)
    $txtBackupPath.Text = $Script:Config.DefaultBackupPath
    $panelTop.Controls.Add($txtBackupPath)
    
    # Browse Button
    $btnBrowse = New-Object System.Windows.Forms.Button
    $btnBrowse.Location = New-Object System.Drawing.Point(630, 19)
    $btnBrowse.Size = New-Object System.Drawing.Size(80, 27)
    $btnBrowse.Text = "Browse..."
    $btnBrowse.FlatStyle = "Flat"
    $btnBrowse.Cursor = [System.Windows.Forms.Cursors]::Hand
    $panelTop.Controls.Add($btnBrowse)
    
    # Filter Label
    $lblFilter = New-Object System.Windows.Forms.Label
    $lblFilter.Location = New-Object System.Drawing.Point(720, 20)
    $lblFilter.Size = New-Object System.Drawing.Size(50, 25)
    $lblFilter.Text = "Filter:"
    $lblFilter.TextAlign = "MiddleRight"
    $panelTop.Controls.Add($lblFilter)
    
    # Filter Dropdown
    $cmbFilter = New-Object System.Windows.Forms.ComboBox
    $cmbFilter.Location = New-Object System.Drawing.Point(775, 20)
    $cmbFilter.Size = New-Object System.Drawing.Size(150, 25)
    $cmbFilter.DropDownStyle = "DropDownList"
    $cmbFilter.Items.AddRange(@("All Packages", "High Risk", "Medium Risk", "Low Risk", "Unknown", "User Apps", "System Apps"))
    $cmbFilter.SelectedIndex = 0
    $panelTop.Controls.Add($cmbFilter)
    
    # Remove Selected Button
    $btnRemove = New-Object System.Windows.Forms.Button
    $btnRemove.Location = New-Object System.Drawing.Point(935, 15)
    $btnRemove.Size = New-Object System.Drawing.Size(140, 35)
    $btnRemove.Text = "Remove Selected"
    $btnRemove.BackColor = [System.Drawing.Color]::FromArgb(215, 50, 50)
    $btnRemove.ForeColor = [System.Drawing.Color]::White
    $btnRemove.FlatStyle = "Flat"
    $btnRemove.FlatAppearance.BorderSize = 0
    $btnRemove.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btnRemove.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnRemove.Enabled = $false
    $panelTop.Controls.Add($btnRemove)
    
    # Demo Mode Indicator (if in demo mode)
    if ($Script:DemoMode) {
        $lblDemoMode = New-Object System.Windows.Forms.Label
        $lblDemoMode.Location = New-Object System.Drawing.Point(1080, 20)
        $lblDemoMode.Size = New-Object System.Drawing.Size(100, 25)
        $lblDemoMode.Text = "🎮 DEMO"
        $lblDemoMode.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $lblDemoMode.ForeColor = [System.Drawing.Color]::Magenta
        $lblDemoMode.TextAlign = "MiddleCenter"
        $panelTop.Controls.Add($lblDemoMode)
    }
    
    # Select All Checkbox
    $chkSelectAll = New-Object System.Windows.Forms.CheckBox
    $chkSelectAll.Location = New-Object System.Drawing.Point(10, 60)
    $chkSelectAll.Size = New-Object System.Drawing.Size(100, 25)
    $chkSelectAll.Text = "Select All"
    $panelTop.Controls.Add($chkSelectAll)
    
    # Package Count Label
    $lblPackageCount = New-Object System.Windows.Forms.Label
    $lblPackageCount.Location = New-Object System.Drawing.Point(120, 60)
    $lblPackageCount.Size = New-Object System.Drawing.Size(500, 25)
    $lblPackageCount.Text = "No packages loaded. Click 'Scan Phone' to begin."
    $lblPackageCount.ForeColor = [System.Drawing.Color]::Gray
    $panelTop.Controls.Add($lblPackageCount)
    
    #endregion
    
    #region DataGridView for Packages
    
    $dataGrid = New-Object System.Windows.Forms.DataGridView
    # Manual positioning instead of Dock.Fill
    $dataGrid.Location = New-Object System.Drawing.Point(0, 100)  # Right below top panel
    $dataGrid.Size = New-Object System.Drawing.Size($formWidth, 400)  # Fixed height to force scrolling with 25 rows
    $dataGrid.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $dataGrid.MinimumSize = New-Object System.Drawing.Size($formWidth, 400)
    
    $dataGrid.AllowUserToAddRows = $false
    $dataGrid.AllowUserToDeleteRows = $false
    $dataGrid.AllowUserToResizeRows = $false
    $dataGrid.ReadOnly = $false
    $dataGrid.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
    $dataGrid.MultiSelect = $true
    $dataGrid.RowHeadersVisible = $false
    $dataGrid.BackgroundColor = [System.Drawing.Color]::White
    $dataGrid.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
    $dataGrid.EnableHeadersVisualStyles = $false
    $dataGrid.AllowUserToOrderColumns = $false
    
    # Column Header Settings - CRITICAL for visibility
    $dataGrid.ColumnHeadersVisible = $true
    $dataGrid.ColumnHeadersHeightSizeMode = [System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode]::DisableResizing
    $dataGrid.ColumnHeadersHeight = 35
    $dataGrid.ColumnHeadersBorderStyle = [System.Windows.Forms.DataGridViewHeaderBorderStyle]::Single
    $dataGrid.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(70, 70, 70)
    $dataGrid.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::White
    $dataGrid.ColumnHeadersDefaultCellStyle.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $dataGrid.ColumnHeadersDefaultCellStyle.Alignment = [System.Drawing.ContentAlignment]::MiddleLeft
    $dataGrid.ColumnHeadersDefaultCellStyle.WrapMode = [System.Windows.Forms.DataGridViewTriState]::False
    
    # Row Settings
    $dataGrid.RowTemplate.Height = 28
    $dataGrid.AutoSizeRowsMode = [System.Windows.Forms.DataGridViewAutoSizeRowsMode]::None
    $dataGrid.DefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::FromArgb(51, 153, 255)
    $dataGrid.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::White
    $dataGrid.DefaultCellStyle.WrapMode = [System.Windows.Forms.DataGridViewTriState]::False
    
    # Scrollbar Settings - Force vertical scrollbar to always show
    $dataGrid.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $dataGrid.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
    
    # Performance and layout settings
    $dataGrid.VirtualMode = $false
    
    # Add columns
    $colSelect = New-Object System.Windows.Forms.DataGridViewCheckBoxColumn
    $colSelect.Name = "Select"
    $colSelect.HeaderText = ""
    $colSelect.Width = 40
    $colSelect.ReadOnly = $false
    $dataGrid.Columns.Add($colSelect) | Out-Null
    
    $colPackage = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $colPackage.Name = "Package"
    $colPackage.HeaderText = "Package Name"
    $colPackage.ReadOnly = $true
    $colPackage.AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::Fill
    $colPackage.FillWeight = 40
    $dataGrid.Columns.Add($colPackage) | Out-Null
    
    $colAppName = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $colAppName.Name = "AppName"
    $colAppName.HeaderText = "App Name"
    $colAppName.ReadOnly = $true
    $colAppName.AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::Fill
    $colAppName.FillWeight = 30
    $dataGrid.Columns.Add($colAppName) | Out-Null
    
    $colRisk = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $colRisk.Name = "Risk"
    $colRisk.HeaderText = "Risk Level"
    $colRisk.ReadOnly = $true
    $colRisk.Width = 100
    $dataGrid.Columns.Add($colRisk) | Out-Null
    
    $colType = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $colType.Name = "Type"
    $colType.HeaderText = "Type"
    $colType.ReadOnly = $true
    $colType.AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::Fill
    $colType.FillWeight = 20
    $dataGrid.Columns.Add($colType) | Out-Null
    
    $colApkPath = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $colApkPath.Name = "ApkPath"
    $colApkPath.HeaderText = "APK Path"
    $colApkPath.ReadOnly = $true
    $colApkPath.Visible = $false
    $dataGrid.Columns.Add($colApkPath) | Out-Null
    
    #endregion
    
    #region Bottom Status Panel
    
    $panelBottom = New-Object System.Windows.Forms.Panel
    $panelBottom.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $panelBottom.Height = 180
    $panelBottom.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
    $panelBottom.Padding = New-Object System.Windows.Forms.Padding(5)
    
    # Status Label
    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Location = New-Object System.Drawing.Point(10, 10)
    $lblStatus.Size = New-Object System.Drawing.Size(900, 25)
    $lblStatus.Text = "Ready"
    $lblStatus.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $panelBottom.Controls.Add($lblStatus)
    
    # Progress Bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(920, 10)
    $progressBar.Size = New-Object System.Drawing.Size(260, 25)
    $progressBar.Style = "Continuous"
    $panelBottom.Controls.Add($progressBar)
    
    # Log TextBox
    $txtLog = New-Object System.Windows.Forms.TextBox
    $txtLog.Location = New-Object System.Drawing.Point(10, 45)
    $txtLog.Size = New-Object System.Drawing.Size(1170, 125)
    $txtLog.Multiline = $true
    $txtLog.ScrollBars = "Vertical"
    $txtLog.ReadOnly = $true
    $txtLog.Font = New-Object System.Drawing.Font("Consolas", 8)
    $txtLog.BackColor = [System.Drawing.Color]::FromArgb(250, 250, 250)
    $panelBottom.Controls.Add($txtLog)
    
    #endregion
    
    # Add controls to form - order doesn't matter with manual positioning
    $form.Controls.Add($panelTop)
    $form.Controls.Add($dataGrid)
    $form.Controls.Add($panelBottom)
    
    #region Helper Functions
    
    function Update-Status {
        param([string]$Message, [string]$Color = "Black")
        $lblStatus.Text = $Message
        $lblStatus.ForeColor = [System.Drawing.Color]::$Color
        $form.Refresh()
    }
    
    function Add-LogEntry {
        param([string]$Message)
        $timestamp = Get-Date -Format 'HH:mm:ss'
        $txtLog.AppendText("[$timestamp] $Message`r`n")
        $txtLog.SelectionStart = $txtLog.TextLength
        $txtLog.ScrollToCaret()
    }
    
    function Apply-ColorCoding {
        foreach ($row in $dataGrid.Rows) {
            $risk = $row.Cells['Risk'].Value
            
            switch ($risk) {
                'High'   { 
                    $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(255, 200, 200)
                    $row.DefaultCellStyle.ForeColor = [System.Drawing.Color]::DarkRed
                }
                'Medium' { 
                    $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 200)
                    $row.DefaultCellStyle.ForeColor = [System.Drawing.Color]::DarkGoldenrod
                }
                'Low'    { 
                    $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(200, 255, 200)
                    $row.DefaultCellStyle.ForeColor = [System.Drawing.Color]::DarkGreen
                }
                default  { 
                    $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::White
                    $row.DefaultCellStyle.ForeColor = [System.Drawing.Color]::Black
                }
            }
        }
    }
    
    function Get-SelectedPackages {
        $selected = @()
        foreach ($row in $dataGrid.Rows) {
            if ($row.Cells['Select'].Value -eq $true) {
                $selected += [PSCustomObject]@{
                    Package = $row.Cells['Package'].Value
                    AppName = $row.Cells['AppName'].Value
                    Risk = $row.Cells['Risk'].Value
                    Type = $row.Cells['Type'].Value
                    ApkPath = $row.Cells['ApkPath'].Value
                }
            }
        }
        return $selected
    }
    
    #endregion
    
    #region Event Handlers (Phase 3)
    
    # Scan Phone Button Click
    $btnScan.Add_Click({
        try {
            # Skip validation in demo mode
            if (-not $Script:DemoMode) {
                # Validate ADB connection first
                $adbTest = Test-AdbConnection
                if (-not $adbTest.Success) {
                    Show-ErrorDialog -Title "Connection Error" -Message $adbTest.Message -Details $adbTest.Suggestion
                    Add-LogEntry "ERROR: $($adbTest.Message)"
                    return
                }
            }
            else {
                Add-LogEntry "DEMO MODE: Using mock data"
            }
            
            Update-Status "Scanning device..." "Blue"
            Add-LogEntry "Starting device scan..."
            $dataGrid.Rows.Clear()
            
            # Scan packages
            $packages = Get-InstalledPackages
            Add-LogEntry "Found $($packages.Count) packages on device"
            
            # Load research data (non-critical)
            Update-Status "Loading research database..." "Blue"
            $research = $null
            try {
                $research = Import-PackageDatabase
                Add-LogEntry "Loaded research data for $($research.Count) packages"
            }
            catch {
                Add-LogEntry "WARNING: Could not load research database - packages will show as Unknown"
                $research = @()
            }
            
            # Merge data
            Update-Status "Merging data..." "Blue"
            $Script:MergedData = Merge-PackageData -PhonePackages $packages -ExcelData $research
            
            # Populate grid
            foreach ($pkg in $Script:MergedData) {
                $dataGrid.Rows.Add(
                    $false,
                    $pkg.Package,
                    $pkg.AppName,
                    $pkg.WillBreak,
                    $pkg.Type,
                    $pkg.ApkPath
                ) | Out-Null
            }
            
            # Apply color coding
            Apply-ColorCoding
            
            # Force DataGrid to recalculate layout after population
            $dataGrid.Refresh()
            $dataGrid.PerformLayout()
            
            # Update counts
            $highRisk = ($Script:MergedData | Where-Object { $_.WillBreak -eq 'High' }).Count
            $medRisk = ($Script:MergedData | Where-Object { $_.WillBreak -eq 'Medium' }).Count
            $lowRisk = ($Script:MergedData | Where-Object { $_.WillBreak -eq 'Low' }).Count
            $unknown = ($Script:MergedData | Where-Object { $_.WillBreak -eq 'Unknown' }).Count
            
            $lblPackageCount.Text = "Total: $($Script:MergedData.Count) | High: $highRisk | Medium: $medRisk | Low: $lowRisk | Unknown: $unknown"
            $lblPackageCount.ForeColor = [System.Drawing.Color]::Black
            
            Update-Status "Scan complete - $($Script:MergedData.Count) packages loaded" "Green"
            Add-LogEntry "Scan completed successfully"
            $btnRemove.Enabled = $true
        }
        catch {
            Update-Status "Error: $($_.Exception.Message)" "Red"
            Add-LogEntry "ERROR: $($_.Exception.Message)"
            Show-ErrorDialog -Title "Scan Error" -Message "Failed to scan device" -Details $_.Exception.Message
        }
    })
    
    # Browse Button Click
    $btnBrowse.Add_Click({
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Select backup folder for APK files"
        $folderBrowser.SelectedPath = $txtBackupPath.Text
        
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $txtBackupPath.Text = $folderBrowser.SelectedPath
            Add-LogEntry "Backup path changed to: $($folderBrowser.SelectedPath)"
        }
    })
    
    # Select All Checkbox Click
    $chkSelectAll.Add_Click({
        if ($chkSelectAll.Checked) {
            # Show warning when selecting all
            $result = [System.Windows.Forms.MessageBox]::Show(
                "You are about to select ALL $($dataGrid.Rows.Count) packages.`n`nThis includes system packages that may be critical for device operation.`n`nAre you sure you want to select everything?",
                "Select All Warning",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            
            if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
                $chkSelectAll.Checked = $false
                Add-LogEntry "Select All cancelled by user"
                return
            }
            
            Add-LogEntry "Select All: Selecting all $($dataGrid.Rows.Count) packages"
        }
        
        foreach ($row in $dataGrid.Rows) {
            $row.Cells['Select'].Value = $chkSelectAll.Checked
        }
    })
    
    # Filter Dropdown Change
    $cmbFilter.Add_SelectedIndexChanged({
        if (-not $Script:MergedData) { return }
        
        $dataGrid.Rows.Clear()
        
        $filtered = switch ($cmbFilter.SelectedItem) {
            "High Risk"    { $Script:MergedData | Where-Object { $_.WillBreak -eq 'High' } }
            "Medium Risk"  { $Script:MergedData | Where-Object { $_.WillBreak -eq 'Medium' } }
            "Low Risk"     { $Script:MergedData | Where-Object { $_.WillBreak -eq 'Low' } }
            "Unknown"      { $Script:MergedData | Where-Object { $_.WillBreak -eq 'Unknown' } }
            "User Apps"    { $Script:MergedData | Where-Object { $_.Type -eq 'User App' } }
            "System Apps"  { $Script:MergedData | Where-Object { $_.Type -match 'System' } }
            default        { $Script:MergedData }
        }
        
        foreach ($pkg in $filtered) {
            $dataGrid.Rows.Add(
                $false,
                $pkg.Package,
                $pkg.AppName,
                $pkg.WillBreak,
                $pkg.Type,
                $pkg.ApkPath
            ) | Out-Null
        }
        
        Apply-ColorCoding
        $dataGrid.Refresh()
        $dataGrid.PerformLayout()
        Add-LogEntry "Filter applied: $($cmbFilter.SelectedItem) - $($filtered.Count) packages shown"
    })
    
    # Remove Selected Button Click
    $btnRemove.Add_Click({
        $selected = Get-SelectedPackages
        
        if ($selected.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show(
                "No packages selected. Please check the boxes next to packages you want to remove.",
                "No Selection",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
            return
        }
        
        # Show warning for high-risk packages
        $highRiskSelected = ($selected | Where-Object { $_.Risk -eq 'High' }).Count
        if ($highRiskSelected -gt 0) {
            $warnResult = [System.Windows.Forms.MessageBox]::Show(
                "WARNING: You have selected $highRiskSelected HIGH RISK package(s).`n`nRemoving these may cause system instability or break functionality.`n`nAre you sure you want to continue?",
                "High Risk Warning",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            
            if ($warnResult -ne [System.Windows.Forms.DialogResult]::Yes) {
                Add-LogEntry "Removal cancelled by user (high risk warning)"
                return
            }
        }
        
        # Final confirmation
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Remove $($selected.Count) package(s)?`n`nBackup location: $($txtBackupPath.Text)`n`nThis action will uninstall the packages for user 0.",
            "Confirm Removal",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
        
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            # Disable controls during operation
            $btnScan.Enabled = $false
            $btnRemove.Enabled = $false
            $dataGrid.Enabled = $false
            
            # Setup progress bar
            $progressBar.Value = 0
            $progressBar.Maximum = $selected.Count
            
            $successCount = 0
            $failCount = 0
            $backupPath = $txtBackupPath.Text
            
            foreach ($pkg in $selected) {
                Update-Status "Processing: $($pkg.Package)" "Blue"
                Add-LogEntry "Processing: $($pkg.Package)"
                
                # Backup if path specified
                $backupPerformed = $false
                if ($backupPath) {
                    try {
                        $backupResult = Backup-PackageApk -PackageName $pkg.Package -BackupPath $backupPath
                        if ($backupResult.Success) {
                            Add-LogEntry "  ✓ Backed up to: $($backupResult.BackupFile)"
                            $backupPerformed = $true
                        }
                        else {
                            Add-LogEntry "  ⚠ Backup failed: $($backupResult.Message)"
                        }
                    }
                    catch {
                        Add-LogEntry "  ⚠ Backup error: $($_.Exception.Message)"
                    }
                }
                
                # Remove package
                try {
                    $removeResult = Remove-Package -PackageName $pkg.Package
                    if ($removeResult.Success) {
                        Add-LogEntry "  ✓ Removed successfully"
                        $successCount++
                        Write-OperationLog -Level "REMOVE" -Message "$($pkg.Package) - Success"
                    }
                    else {
                        Add-LogEntry "  ✗ Removal failed: $($removeResult.Message)"
                        $failCount++
                        Write-OperationLog -Level "ERROR" -Message "$($pkg.Package) - Failed: $($removeResult.Message)"
                    }
                }
                catch {
                    Add-LogEntry "  ✗ Removal error: $($_.Exception.Message)"
                    $failCount++
                    Write-OperationLog -Level "ERROR" -Message "$($pkg.Package) - Error: $($_.Exception.Message)"
                }
                
                $progressBar.Value++
            }
            
            # Re-enable controls
            $btnScan.Enabled = $true
            $btnRemove.Enabled = $true
            $dataGrid.Enabled = $true
            
            # Show summary
            $summaryMsg = "Operation Complete`n`nSuccess: $successCount`nFailed: $failCount"
            Update-Status $summaryMsg "$(if ($failCount -eq 0) { 'Green' } else { 'DarkOrange' })"
            Add-LogEntry "════════════════════════════════════════"
            Add-LogEntry "Operation Summary: $successCount succeeded, $failCount failed"
            Add-LogEntry "════════════════════════════════════════"
            
            [System.Windows.Forms.MessageBox]::Show(
                $summaryMsg,
                "Removal Complete",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
            
            # Rescan device
            $btnScan.PerformClick()
        }
        else {
            Add-LogEntry "Removal cancelled by user"
        }
    })
    
    # Form Closing Event - Save settings
    $form.Add_FormClosing({
        param($sender, $e)
        
        # Update settings with current backup path
        $Script:AppSettings.DefaultBackupPath = $txtBackupPath.Text
        
        # Save configuration
        Save-AppSettings -Settings $Script:AppSettings | Out-Null
        
        Add-LogEntry "Application closing - settings saved"
    })
    
    #endregion
    
    # Show the form
    if ($Script:DemoMode) {
        Add-LogEntry "⚠ APK Away started in DEMO MODE - All operations are simulated"
        Add-LogEntry "Click 'Scan Phone' to load mock package data"
    }
    else {
        Add-LogEntry "APK Away started - Ready to scan device"
    }
    
    # Resume layout and perform final layout calculation
    $form.ResumeLayout($true)
    $form.PerformLayout()
    
    $form.ShowDialog() | Out-Null
}

#endregion
