using System;

namespace APKAway.Models
{
    public class PackageInfo
    {
        public string PackageName { get; set; }
        public string Label { get; set; }
        public string RiskLevel { get; set; }  // High, Medium, Low, User
        public string Category { get; set; }   // System, User, OEM, Carrier, Framework
        public string Description { get; set; }
        public string Path { get; set; }
        public bool Selected { get; set; }
        public bool BackupFirst { get; set; }

        public PackageInfo()
        {
            PackageName = string.Empty;
            Label = string.Empty;
            RiskLevel = "Low";
            Category = "User";
            Description = string.Empty;
            Path = string.Empty;
            Selected = false;
            BackupFirst = false;
        }

        public PackageInfo(string packageName, string label, string riskLevel, string category, string description, string path = "")
        {
            PackageName = packageName;
            Label = label;
            RiskLevel = riskLevel;
            Category = category;
            Description = description;
            Path = path;
            Selected = false;
            BackupFirst = false;
        }
    }
}
