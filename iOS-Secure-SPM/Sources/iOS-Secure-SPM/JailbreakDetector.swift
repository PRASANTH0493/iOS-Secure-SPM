import UIKit

@MainActor
public class JailbreakDetector {
    // Singleton instance
    public static let shared = JailbreakDetector()

    // List of known jailbreak-related paths
    private let jailbreakPaths = [
        "/Applications/Cydia.app",
        "/Applications/RockApp.app",
        "/Applications/Icy.app",
        "/Applications/WinterBoard.app",
        "/Applications/SBSettings.app",
        "/Applications/MxTube.app",
        "/Applications/IntelliScreen.app",
        "/Applications/FakeCarrier.app",
        "/Applications/blackra1n.app",
        "/Applications/FakeCarrier.app",
        
        "/private/var/lib/apt/",
        "/private/var/lib/cydia",
        "/private/var/log/syslog",
        "/private/var/tmp/cydia.log",
        "/private/var/mobile/Library/SBSettings/Themes",
        "/private/var/stash",
        "/private/var/cache/apt/",
        
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/Library/MobileSubstrate/CydiaSubstrate.dylib",
        "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
        "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
        
        "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
        "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
        
        "/var/cache/apt",
        "/var/lib/apt",
        "/var/lib/cydia",
        
        "/bin/bash",
        "/bin/sh",
        "/usr/sbin/sshd",
        "/usr/libexec/ssh-keysign",
        "/usr/bin/sshd",
        "/usr/libexec/sftp-server",
        
        "/etc/ssh/sshd_config",
        "/etc/apt",
        
        "/usr/sbin/frida-server",
        "/etc/apt/sources.list.d/electra.list",
        "/etc/apt/sources.list.d/sileo.sources",
        
        "/.bootstrapped_electra",
        "/.cydia_no_stash",
        "/.installed_unc0ver",
        
        "/var/log/apt",
        
        "/jb/lzma",
        "/jb/offsets.plist",
        "/usr/share/jailbreak/injectme.plist",
        "/etc/apt/undecimus/undecimus.list",
        "/var/lib/dpkg/info/mobilesubstrate.md5sums",
        
        "/jb/jailbreakd.plist",
        "/jb/amfid_payload.dylib",
        "/jb/libjailbreak.dylib",
        
        "/usr/libexec/cydia/firmware.sh"
    ]

    // List of suspicious URL schemes related to jailbreak
    private let suspiciousURLSchemes = [
        "cydia://package/com.example.package",
        "cydia://",
        "undecimus://",
        "sileo://",
        "zebra://",
        "dopamine://"
    ]

    // Public method to check if device is jailbroken
    func isJailbroken() -> Bool {
        return canWriteOutsideSandbox() ||
               checkJailbreakPathsExist() ||
               canOpenSuspiciousSchemes()
    }
    
    // MARK: - Private Checks
    
    // Check if app can write outside of its sandbox (typical jailbreak indicator)
    private func canWriteOutsideSandbox() -> Bool {
        let testPath = "/private/jailbreak_test.txt"
        do {
            try "Jailbreak Test".write(toFile: testPath, atomically: true, encoding: .utf8)
            // Cleanup test file
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
    }
    
    // Check if any jailbreak files exist in the known paths
    private func checkJailbreakPathsExist() -> Bool {
        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    // Check if suspicious jailbreak URLs can be opened
    private func canOpenSuspiciousSchemes() -> Bool {
        for scheme in suspiciousURLSchemes {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        return false
    }
}
