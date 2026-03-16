using System;
using System.Drawing;
using System.Windows.Forms;
using System.Linq;
using APKAway.Models;
using APKAway.Services;

namespace APKAway
{
    public partial class MainForm : Form
    {
        private BindingSource bindingSource;

        public MainForm()
        {
            InitializeComponent();
            
            // Adapt window size to screen resolution
            var screen = Screen.FromControl(this);
            int width = (int)(screen.WorkingArea.Width * 0.80);
            int height = (int)(screen.WorkingArea.Height * 0.80);
            this.ClientSize = new Size(width, height);
            this.MinimumSize = new Size(800, 600);
            
            InitializeData();
        }

        private void InitializeData()
        {
            // Load demo data
            var packages = DemoDataService.GetMockPackages();
            
            // Create binding source
            bindingSource = new BindingSource();
            bindingSource.DataSource = packages;
            
            // Bind to DataGridView
            dataGridView1.DataSource = bindingSource;
            
            // Set column display names
            dataGridView1.Columns["Selected"].HeaderText = "Backup First";
            dataGridView1.Columns["BackupFirst"].HeaderText = "Remove";
            
            // Reorder columns - checkboxes first
            dataGridView1.Columns["Selected"].DisplayIndex = 0;
            dataGridView1.Columns["BackupFirst"].DisplayIndex = 1;
            
            // Set checkbox column widths
            dataGridView1.Columns["Selected"].Width = 65;
            dataGridView1.Columns["Selected"].AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
            dataGridView1.Columns["BackupFirst"].Width = 65;
            dataGridView1.Columns["BackupFirst"].AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
            
            // Make other columns fill remaining space
            foreach (DataGridViewColumn col in dataGridView1.Columns)
            {
                if (col.DataPropertyName != "Selected" && col.DataPropertyName != "BackupFirst")
                {
                    col.AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill;
                }
            }
            
            // Make Selected and BackupFirst columns editable
            foreach (DataGridViewColumn col in dataGridView1.Columns)
            {
                col.ReadOnly = (col.DataPropertyName != "Selected" && col.DataPropertyName != "BackupFirst");
            }
            
            // Apply color coding
            ApplyColorCoding();
            
            // Update title
            this.Text = string.Format("APK Away - C# Proof of Concept ({0} packages)", packages.Count);
            
            // Log startup
            txtLog.AppendText(string.Format("[{0}] Application started in DEMO mode\\r\\n", DateTime.Now.ToString("HH:mm:ss")));
            txtLog.AppendText(string.Format("[{0}] Loaded {1} mock packages\\r\\n", DateTime.Now.ToString("HH:mm:ss"), packages.Count));
        }

        private void ApplyColorCoding()
        {
            foreach (DataGridViewRow row in dataGridView1.Rows)
            {
                PackageInfo package = row.DataBoundItem as PackageInfo;
                if (package != null)
                {
                    switch (package.RiskLevel)
                    {
                        case "High":
                            row.DefaultCellStyle.BackColor = Color.FromArgb(255, 224, 224); // Light red
                            break;
                        case "Medium":
                            row.DefaultCellStyle.BackColor = Color.FromArgb(255, 249, 224); // Light yellow
                            break;
                        case "Low":
                            row.DefaultCellStyle.BackColor = Color.FromArgb(224, 255, 230); // Light green
                            break;
                        case "User":
                            row.DefaultCellStyle.BackColor = Color.White;
                            break;
                    }
                }
            }
        }

        private void btnScan_Click(object sender, EventArgs e)
        {
            txtLog.AppendText(string.Format("[{0}] Scan initiated (Demo mode)\\r\\n", DateTime.Now.ToString("HH:mm:ss")));
            txtLog.AppendText(string.Format("[{0}] Found {1} packages\\r\\n", DateTime.Now.ToString("HH:mm:ss"), dataGridView1.Rows.Count));
            MessageBox.Show(string.Format("Demo Mode: Showing {0} mock packages", dataGridView1.Rows.Count), 
                "APK Away", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnSelectAllBackup_Click(object sender, EventArgs e)
        {
            foreach (DataGridViewRow row in dataGridView1.Rows)
            {
                if (row.DataBoundItem is PackageInfo pkg)
                {
                    pkg.Selected = true;
                }
            }
            dataGridView1.Refresh();
            txtLog.AppendText(string.Format("[{0}] Selected all packages for backup\\r\\n", 
                DateTime.Now.ToString("HH:mm:ss")));
        }

        private void btnClearAll_Click(object sender, EventArgs e)
        {
            foreach (DataGridViewRow row in dataGridView1.Rows)
            {
                if (row.DataBoundItem is PackageInfo pkg)
                {
                    pkg.Selected = false;
                    pkg.BackupFirst = false;
                }
            }
            dataGridView1.Refresh();
            txtLog.AppendText(string.Format("[{0}] Cleared all selections\\r\\n", 
                DateTime.Now.ToString("HH:mm:ss")));
        }

        private void btnExecute_Click(object sender, EventArgs e)
        {
            // Get packages marked for backup and/or removal
            var backupPackages = dataGridView1.Rows
                .Cast<DataGridViewRow>()
                .Where(r => r.DataBoundItem is PackageInfo pkg && pkg.Selected)
                .Select(r => r.DataBoundItem as PackageInfo)
                .ToList();

            var removePackages = dataGridView1.Rows
                .Cast<DataGridViewRow>()
                .Where(r => r.DataBoundItem is PackageInfo pkg && pkg.BackupFirst)
                .Select(r => r.DataBoundItem as PackageInfo)
                .ToList();

            if (backupPackages.Count == 0 && removePackages.Count == 0)
            {
                MessageBox.Show("No packages selected.\n\nCheck the 'Backup First' or 'Remove' columns to select packages.", 
                    "APK Away", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            // Build confirmation message
            string confirmMsg = "";
            
            if (backupPackages.Count > 0)
                confirmMsg += string.Format("✓ Backup {0} package(s)\n", backupPackages.Count);
            
            if (removePackages.Count > 0)
            {
                int highRisk = removePackages.Count(p => p.RiskLevel == "High");
                int mediumRisk = removePackages.Count(p => p.RiskLevel == "Medium");
                int withBackup = removePackages.Count(p => p.Selected);
                int noBackup = removePackages.Count - withBackup;

                confirmMsg += string.Format("✗ Remove {0} package(s)\n", removePackages.Count);
                
                if (highRisk > 0)
                    confirmMsg += string.Format("  ⚠ WARNING: {0} HIGH RISK!\n", highRisk);
                if (mediumRisk > 0)
                    confirmMsg += string.Format("  ⚠ {0} MEDIUM RISK\n", mediumRisk);
                
                if (noBackup > 0)
                    confirmMsg += string.Format("  ✗ {0} WITHOUT backup!\n", noBackup);
                if (withBackup > 0)
                    confirmMsg += string.Format("  ✓ {0} with backup\n", withBackup);
            }
            
            confirmMsg += "\n[DEMO MODE] No actual operations will occur.\n\nProceed?";

            if (MessageBox.Show(confirmMsg, "Confirm Actions", 
                MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes)
                return;

            // Execute operations
            int totalOps = backupPackages.Count + removePackages.Count;
            progressBar.Maximum = totalOps;
            progressBar.Value = 0;
            
            txtLog.AppendText(string.Format("[{0}] Starting operations...\r\n", 
                DateTime.Now.ToString("HH:mm:ss")));

            // Phase 1: Backups
            if (backupPackages.Count > 0)
            {
                txtLog.AppendText(string.Format("[{0}] === Backup Phase ({1} packages) ===\r\n", 
                    DateTime.Now.ToString("HH:mm:ss"), backupPackages.Count));
                
                foreach (var pkg in backupPackages)
                {
                    txtLog.AppendText(string.Format("[DEMO] Backing up: {0}\r\n", pkg.PackageName));
                    progressBar.Value++;
                }
            }

            // Phase 2: Removals
            if (removePackages.Count > 0)
            {
                txtLog.AppendText(string.Format("[{0}] === Removal Phase ({1} packages) ===\r\n", 
                    DateTime.Now.ToString("HH:mm:ss"), removePackages.Count));
                
                foreach (var pkg in removePackages)
                {
                    string backupStatus = pkg.Selected ? "with backup" : "NO BACKUP";
                    txtLog.AppendText(string.Format("[DEMO] Removing: {0} ({1}, {2})\r\n", 
                        pkg.PackageName, pkg.RiskLevel, backupStatus));
                    progressBar.Value++;
                }
            }

            txtLog.AppendText(string.Format("[{0}] Complete. {1} operations processed.\r\n", 
                DateTime.Now.ToString("HH:mm:ss"), totalOps));
        }

        private void dataGridView1_CellMouseClick(object sender, DataGridViewCellMouseEventArgs e)
        {
            if (e.Button == MouseButtons.Right && e.RowIndex >= 0 && e.ColumnIndex >= 0)
            {
                string columnName = dataGridView1.Columns[e.ColumnIndex].DataPropertyName;
                if (columnName == "PackageName" || columnName == "Label" || columnName == "Path")
                {
                    dataGridView1.CurrentCell = dataGridView1[e.ColumnIndex, e.RowIndex];
                    contextMenu.Show(dataGridView1, dataGridView1.PointToClient(Cursor.Position));
                }
            }
        }

        private void copyMenuItem_Click(object sender, EventArgs e)
        {
            if (dataGridView1.CurrentCell != null && dataGridView1.CurrentCell.Value != null)
            {
                Clipboard.SetText(dataGridView1.CurrentCell.Value.ToString());
            }
        }

        private void searchMenuItem_Click(object sender, EventArgs e)
        {
            if (dataGridView1.CurrentCell != null && dataGridView1.CurrentCell.Value != null)
            {
                string searchText = dataGridView1.CurrentCell.Value.ToString();
                string url = string.Format("https://www.google.com/search?q={0}", Uri.EscapeDataString(searchText));
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                {
                    FileName = url,
                    UseShellExecute = true
                });
            }
        }
    }
}
