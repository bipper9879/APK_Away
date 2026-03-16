using System.Collections.Generic;
using APKAway.Models;

namespace APKAway.Services
{
    public static class DemoDataService
    {
        public static List<PackageInfo> GetMockPackages()
        {
            var packages = new List<PackageInfo>();

            // HIGH RISK (5 packages) - System critical components
            packages.Add(new PackageInfo(
                "com.samsung.android.knox.containercore",
                "Knox Container Core",
                "High",
                "System",
                "Knox security framework - removal may break Samsung security features",
                "/system/app/KnoxCore/KnoxCore.apk"
            ));

            packages.Add(new PackageInfo(
                "com.android.systemui",
                "System UI",
                "High",
                "Framework",
                "Core Android system interface - DO NOT REMOVE",
                "/system/priv-app/SystemUI/SystemUI.apk"
            ));

            packages.Add(new PackageInfo(
                "com.google.android.gms",
                "Google Play Services",
                "High",
                "System",
                "Core Google services - required for most apps",
                "/system/priv-app/GmsCore/GmsCore.apk"
            ));

            packages.Add(new PackageInfo(
                "com.android.vending",
                "Google Play Store",
                "High",
                "System",
                "App marketplace - removal prevents installing apps",
                "/system/priv-app/Phonesky/Phonesky.apk"
            ));

            packages.Add(new PackageInfo(
                "com.samsung.android.knox.attestation",
                "Knox Attestation",
                "High",
                "System",
                "Security attestation service - may break Samsung Pay",
                "/system/app/KnoxAttestation/KnoxAttestation.apk"
            ));

            // MEDIUM RISK (5 packages) - Important but replaceable
            packages.Add(new PackageInfo(
                "com.samsung.android.messaging",
                "Samsung Messages",
                "Medium",
                "OEM",
                "Default SMS app - can be replaced with alternatives",
                "/system/app/SamsungMessages/SamsungMessages.apk"
            ));

            packages.Add(new PackageInfo(
                "com.google.android.apps.photos",
                "Google Photos",
                "Medium",
                "System",
                "Photo backup and gallery - data will be preserved",
                "/system/app/Photos/Photos.apk"
            ));

            packages.Add(new PackageInfo(
                "com.samsung.android.calendar",
                "Samsung Calendar",
                "Medium",
                "OEM",
                "Calendar app - alternatives available",
                "/system/app/SamsungCalendar/SamsungCalendar.apk"
            ));

            packages.Add(new PackageInfo(
                "com.android.chrome",
                "Chrome Browser",
                "Medium",
                "System",
                "Web browser - alternatives available (Firefox, Edge)",
                "/system/app/Chrome/Chrome.apk"
            ));

            packages.Add(new PackageInfo(
                "com.samsung.android.email.provider",
                "Samsung Email",
                "Medium",
                "OEM",
                "Email client - can use Gmail or Outlook instead",
                "/system/app/SecEmail/SecEmail.apk"
            ));

            // LOW RISK (10 packages) - Bloatware safe to remove
            packages.Add(new PackageInfo(
                "com.samsung.android.game.gamehome",
                "Game Launcher",
                "Low",
                "Bloatware",
                "Samsung game hub - safe to remove if not gaming",
                "/system/app/GameHome/GameHome.apk"
            ));

            packages.Add(new PackageInfo(
                "com.samsung.android.ardrawing",
                "AR Zone",
                "Low",
                "Bloatware",
                "AR camera effects - purely optional",
                "/system/app/ARZone/ARZone.apk"
            ));

            packages.Add(new PackageInfo(
                "com.samsung.android.bixby.agent",
                "Bixby Voice",
                "Low",
                "Bloatware",
                "Samsung voice assistant - Google Assistant alternative",
                "/system/app/BixbyAgent/BixbyAgent.apk"
            ));

            packages.Add(new PackageInfo(
                "com.samsung.android.visionintelligence",
                "Bixby Vision",
                "Low",
                "Bloatware",
                "Visual search feature - rarely used",
                "/system/app/BixbyVision/BixbyVision.apk"
            ));

            packages.Add(new PackageInfo(
                "com.netflix.partner.activation",
                "Netflix (carrier)",
                "Low",
                "Carrier",
                "Pre-installed Netflix stub - can install from Play Store",
                "/system/app/Netflix_activation/Netflix_activation.apk"
            ));

            packages.Add(new PackageInfo(
                "com.facebook.system",
                "Facebook App Manager",
                "Low",
                "Bloatware",
                "Facebook services - safe to remove if not using FB",
                "/system/app/FBAppManager/FBAppManager.apk"
            ));

            packages.Add(new PackageInfo(
                "com.samsung.android.app.tips",
                "Samsung Tips",
                "Low",
                "Bloatware",
                "Tips and tutorials app - not essential",
                "/system/app/Tips/Tips.apk"
            ));

            packages.Add(new PackageInfo(
                "com.microsoft.appmanager",
                "Microsoft App Manager",
                "Low",
                "Carrier",
                "Microsoft services integration - optional",
                "/system/app/MSAppManager/MSAppManager.apk"
            ));

            packages.Add(new PackageInfo(
                "com.samsung.android.smartsuggestions",
                "Smart Suggestions",
                "Low",
                "Bloatware",
                "AI suggestions feature - battery drain",
                "/system/app/SmartSuggestions/SmartSuggestions.apk"
            ));

            packages.Add(new PackageInfo(
                "com.samsung.android.samsungpass",
                "Samsung Pass",
                "Low",
                "OEM",
                "Password manager - alternatives available (LastPass, Bitwarden)",
                "/system/app/SamsungPass/SamsungPass.apk"
            ));

            // USER APPS (5 packages) - Installed by user
            packages.Add(new PackageInfo(
                "com.whatsapp",
                "WhatsApp",
                "User",
                "User",
                "Messaging app - user installed",
                "/data/app/~~abc123/com.whatsapp/base.apk"
            ));

            packages.Add(new PackageInfo(
                "com.instagram.android",
                "Instagram",
                "User",
                "User",
                "Social media app - user installed",
                "/data/app/~~def456/com.instagram.android/base.apk"
            ));

            packages.Add(new PackageInfo(
                "com.spotify.music",
                "Spotify",
                "User",
                "User",
                "Music streaming - user installed",
                "/data/app/~~ghi789/com.spotify.music/base.apk"
            ));

            packages.Add(new PackageInfo(
                "com.netflix.mediaclient",
                "Netflix",
                "User",
                "User",
                "Video streaming - user installed",
                "/data/app/~~jkl012/com.netflix.mediaclient/base.apk"
            ));

            packages.Add(new PackageInfo(
                "com.zhiliaoapp.musically",
                "TikTok",
                "User",
                "User",
                "Social media app - user installed",
                "/data/app/~~mno345/com.zhiliaoapp.musically/base.apk"
            ));

            return packages;
        }
    }
}
