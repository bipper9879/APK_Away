using System.Drawing;
using System.Windows.Forms;

namespace APKAway
{
    partial class MainForm
    {
        private System.ComponentModel.IContainer components = null;
        private DataGridView dataGridView1;
        private Panel panelTop;
        private Panel panelBottom;
        private Button btnScan;
        private Button btnClose;
        private Button btnSelectAllBackup;
        private Button btnClearAll;
        private Button btnExecute;
        private PictureBox pictureBoxLogo;
        private Label lblStatus;
        private ProgressBar progressBar;
        private TextBox txtLog;
        private ContextMenuStrip contextMenu;
        private ToolStripMenuItem copyMenuItem;
        private ToolStripMenuItem searchMenuItem;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.dataGridView1 = new DataGridView();
            this.contextMenu = new ContextMenuStrip(this.components);
            this.copyMenuItem = new ToolStripMenuItem();
            this.searchMenuItem = new ToolStripMenuItem();
            this.panelTop = new Panel();
            this.btnScan = new Button();
            this.btnClose = new Button();
            this.btnSelectAllBackup = new Button();
            this.btnClearAll = new Button();
            this.btnExecute = new Button();
            this.pictureBoxLogo = new PictureBox();
            this.panelBottom = new Panel();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxLogo)).BeginInit();
            this.lblStatus = new Label();
            this.progressBar = new ProgressBar();
            this.txtLog = new TextBox();
            
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.contextMenu.SuspendLayout();
            this.panelTop.SuspendLayout();
            this.panelBottom.SuspendLayout();
            this.SuspendLayout();
            
            // 
            // dataGridView1
            // 
            this.dataGridView1.AllowUserToAddRows = false;
            this.dataGridView1.AllowUserToDeleteRows = false;
            this.dataGridView1.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None;
            this.dataGridView1.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Dock = DockStyle.Fill;
            this.dataGridView1.Location = new Point(0, 60);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.ReadOnly = false;
            this.dataGridView1.RowHeadersWidth = 25;
            this.dataGridView1.RowTemplate.Height = 29;
            this.dataGridView1.SelectionMode = DataGridViewSelectionMode.CellSelect;
            this.dataGridView1.Size = new Size(1200, 640);
            this.dataGridView1.TabIndex = 0;
            // CRITICAL: Enable scrollbars
            this.dataGridView1.ScrollBars = ScrollBars.Both;
            this.dataGridView1.AutoSizeRowsMode = DataGridViewAutoSizeRowsMode.None;
            this.dataGridView1.RowTemplate.Height = 28;
            
            // Fix column headers turning blue when cells are selected
            this.dataGridView1.EnableHeadersVisualStyles = false;
            this.dataGridView1.ColumnHeadersDefaultCellStyle.BackColor = Color.LightGray;
            this.dataGridView1.ColumnHeadersDefaultCellStyle.ForeColor = Color.Black;
            this.dataGridView1.ColumnHeadersDefaultCellStyle.SelectionBackColor = Color.LightGray;
            this.dataGridView1.ColumnHeadersDefaultCellStyle.SelectionForeColor = Color.Black;
            this.dataGridView1.ColumnHeadersDefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            this.dataGridView1.CellMouseClick += new DataGridViewCellMouseEventHandler(this.dataGridView1_CellMouseClick);
            
            // 
            // contextMenu
            // 
            this.contextMenu.Items.AddRange(new ToolStripItem[] {
                this.copyMenuItem,
                this.searchMenuItem});
            this.contextMenu.Name = "contextMenu";
            this.contextMenu.Size = new Size(180, 48);
            
            // 
            // copyMenuItem
            // 
            this.copyMenuItem.Name = "copyMenuItem";
            this.copyMenuItem.Size = new Size(179, 22);
            this.copyMenuItem.Text = "Copy";
            this.copyMenuItem.Click += new System.EventHandler(this.copyMenuItem_Click);
            
            // 
            // searchMenuItem
            // 
            this.searchMenuItem.Name = "searchMenuItem";
            this.searchMenuItem.Size = new Size(179, 22);
            this.searchMenuItem.Text = "Search on Internet";
            this.searchMenuItem.Click += new System.EventHandler(this.searchMenuItem_Click);
            
            // 
            // panelTop
            // 
            this.panelTop.AutoScroll = true;
            this.panelTop.Controls.Add(this.pictureBoxLogo);
            this.panelTop.Controls.Add(this.btnClearAll);
            this.panelTop.Controls.Add(this.btnSelectAllBackup);
            this.panelTop.Controls.Add(this.btnClose);
            this.panelTop.Controls.Add(this.btnScan);
            this.panelTop.Dock = DockStyle.Top;
            this.panelTop.Location = new Point(0, 0);
            this.panelTop.Name = "panelTop";
            this.panelTop.Size = new Size(1200, 80);
            this.panelTop.TabIndex = 1;
            
            // 
            // btnScan
            // 
            this.btnScan.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
            this.btnScan.Location = new Point(12, 12);
            this.btnScan.Name = "btnScan";
            this.btnScan.Size = new Size(120, 36);
            this.btnScan.TabIndex = 0;
            this.btnScan.Text = "Scan (Demo)";
            this.btnScan.UseVisualStyleBackColor = true;
            this.btnScan.Click += new System.EventHandler(this.btnScan_Click);
            
            // 
            // btnClose
            // 
            this.btnClose.Location = new Point(390, 12);
            this.btnClose.Name = "btnClose";
            this.btnClose.Size = new Size(100, 36);
            this.btnClose.TabIndex = 1;
            this.btnClose.Text = "Close";
            this.btnClose.UseVisualStyleBackColor = true;
            this.btnClose.Click += new System.EventHandler(this.btnClose_Click);
            
            // 
            // btnSelectAllBackup
            // 
            this.btnSelectAllBackup.Location = new Point(140, 12);
            this.btnSelectAllBackup.Name = "btnSelectAllBackup";
            this.btnSelectAllBackup.Size = new Size(120, 36);
            this.btnSelectAllBackup.TabIndex = 2;
            this.btnSelectAllBackup.Text = "Select All Backup";
            this.btnSelectAllBackup.UseVisualStyleBackColor = true;
            this.btnSelectAllBackup.Click += new System.EventHandler(this.btnSelectAllBackup_Click);
            
            // 
            // btnClearAll
            // 
            this.btnClearAll.Location = new Point(268, 12);
            this.btnClearAll.Name = "btnClearAll";
            this.btnClearAll.Size = new Size(115, 36);
            this.btnClearAll.TabIndex = 3;
            this.btnClearAll.Text = "Clear All";
            this.btnClearAll.UseVisualStyleBackColor = true;
            this.btnClearAll.Click += new System.EventHandler(this.btnClearAll_Click);
            
            // 
            // pictureBoxLogo
            // 
            this.pictureBoxLogo.Location = new Point(530, 5);
            this.pictureBoxLogo.Name = "pictureBoxLogo";
            this.pictureBoxLogo.Size = new Size(140, 70);
            this.pictureBoxLogo.SizeMode = PictureBoxSizeMode.Zoom;
            this.pictureBoxLogo.TabIndex = 4;
            this.pictureBoxLogo.TabStop = false;
            try
            {
                string logoPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "..", "..", "..", "..", "..", "App Away.png");
                if (File.Exists(logoPath))
                {
                    this.pictureBoxLogo.Image = Image.FromFile(logoPath);
                }
            }
            catch { /* Logo is optional */ }
            
            // 
            // panelBottom
            // 
            this.panelBottom.AutoScroll = true;
            this.panelBottom.BackColor = Color.FromArgb(245, 245, 245);
            this.panelBottom.Controls.Add(this.btnExecute);
            this.panelBottom.Controls.Add(this.txtLog);
            this.panelBottom.Controls.Add(this.progressBar);
            this.panelBottom.Controls.Add(this.lblStatus);
            this.panelBottom.Dock = DockStyle.Bottom;
            this.panelBottom.Location = new Point(0, 570);
            this.panelBottom.Name = "panelBottom";
            this.panelBottom.Size = new Size(1200, 180);
            this.panelBottom.TabIndex = 2;
            
            // 
            // btnExecute
            // 
            this.btnExecute.BackColor = Color.FromArgb(50, 120, 200);
            this.btnExecute.FlatStyle = FlatStyle.Flat;
            this.btnExecute.Font = new Font("Segoe UI", 10F, FontStyle.Bold);
            this.btnExecute.ForeColor = Color.White;
            this.btnExecute.Location = new Point(10, 10);
            this.btnExecute.Name = "btnExecute";
            this.btnExecute.Size = new Size(150, 40);
            this.btnExecute.TabIndex = 0;
            this.btnExecute.Text = "Execute";
            this.btnExecute.UseVisualStyleBackColor = false;
            this.btnExecute.Click += new System.EventHandler(this.btnExecute_Click);
            
            // 
            // lblStatus
            // 
            this.lblStatus.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
            this.lblStatus.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
            this.lblStatus.Location = new Point(170, 10);
            this.lblStatus.Name = "lblStatus";
            this.lblStatus.Size = new Size(740, 40);
            this.lblStatus.TabIndex = 1;
            this.lblStatus.Text = "Ready - Demo Mode (25 mock packages)";
            this.lblStatus.TextAlign = ContentAlignment.MiddleLeft;
            
            // 
            // progressBar
            // 
            this.progressBar.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            this.progressBar.Location = new Point(920, 15);
            this.progressBar.Name = "progressBar";
            this.progressBar.Size = new Size(260, 30);
            this.progressBar.TabIndex = 2;
            
            // 
            // txtLog
            // 
            this.txtLog.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right | AnchorStyles.Bottom;
            this.txtLog.BackColor = Color.FromArgb(250, 250, 250);
            this.txtLog.Font = new Font("Consolas", 8F);
            this.txtLog.Location = new Point(10, 55);
            this.txtLog.Multiline = true;
            this.txtLog.Name = "txtLog";
            this.txtLog.ReadOnly = true;
            this.txtLog.ScrollBars = ScrollBars.Vertical;
            this.txtLog.Size = new Size(1170, 115);
            this.txtLog.TabIndex = 3;
            
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new SizeF(8F, 20F);
            this.AutoScaleMode = AutoScaleMode.Font;
            this.ClientSize = new Size(1200, 750);
            this.MinimumSize = new Size(800, 600);
            this.Controls.Add(this.dataGridView1);
            this.Controls.Add(this.panelBottom);
            this.Controls.Add(this.panelTop);
            try
            {
                if (File.Exists("AppIcon.ico"))
                {
                    this.Icon = new Icon("AppIcon.ico");
                }
            }
            catch { /* Icon loading is optional */ }
            this.Name = "MainForm";
            this.StartPosition = FormStartPosition.CenterScreen;
            this.Text = "APK Away - C# Proof of Concept";
            
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxLogo)).EndInit();
            this.contextMenu.ResumeLayout(false);
            this.panelTop.ResumeLayout(false);
            this.panelBottom.ResumeLayout(false);
            this.panelBottom.PerformLayout();
            this.ResumeLayout(false);
        }
    }
}
