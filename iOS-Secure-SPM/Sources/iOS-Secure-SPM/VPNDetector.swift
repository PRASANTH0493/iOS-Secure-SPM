import Foundation
import Network
import NetworkExtension
import UIKit

// Notification name for VPN status change
extension Notification.Name {
    static let vpnStatusDidChange = Notification.Name("vpnStatusDidChange")
}

// Singleton VPNDetector that checks VPN status using multiple methods
@MainActor
public class VPNDetector {
    public static let shared = VPNDetector()
    private init() {}

    private(set) var isVPNActive = false {
        didSet {
            if oldValue != isVPNActive {
                NotificationCenter.default.post(name: .vpnStatusDidChange,
                                                object: nil,
                                                userInfo: ["isVPNActive": isVPNActive])
            }
        }
    }

    // Public method to check all VPN methods asynchronously and update notification
    public func checkVPNStatus() async {
        let wasActive = isVPNActive
        let nowActive = await isVPNActiveAsync()
        if nowActive != wasActive {
            isVPNActive = nowActive
        }
    }

    // Internal combined VPN detection logic
    private func isVPNActiveAsync() async -> Bool {
        if isVPNConnectedCFNetwork() {
            return true
        }
        if await isVPNConnectedNetworkFramework() {
            return true
        }
        return await isNEVPNManagerConnected()
    }

    // Check VPN via CFNetwork proxy settings (synchronous)
    private func isVPNConnectedCFNetwork() -> Bool {
        guard let cfDict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as NSDictionary?,
              let scoped = cfDict["__SCOPED__"] as? NSDictionary else {
            return false
        }
        let vpnKeys = ["tap", "tun", "ppp", "ipsec", "ipsec0", "utun", "utun0", "utun1", "utun2"]
        for key in scoped.allKeys {
            if let keyString = key as? String {
                if vpnKeys.contains(where: keyString.contains) {
                    return true
                }
            }
        }
        return false
    }

    // Check VPN via NWPathMonitor asynchronously (iOS 17+)
    private func isVPNConnectedNetworkFramework() async -> Bool {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "VPNMonitor")
        monitor.start(queue: queue)

        for await path in monitor {
            monitor.cancel()
            if path.status == .satisfied,
               path.availableInterfaces.contains(where: { $0.type == .other }) {
                return true
            }
            return false
        }
        return false
    }

    // Check VPN status using NEVPNManager async
    private func isNEVPNManagerConnected() async -> Bool {
        await withCheckedContinuation { continuation in
            let manager = NEVPNManager.shared()
            manager.loadFromPreferences { error in
                if let error = error {
                    print("Failed to load VPN preferences: \(error.localizedDescription)")
                    continuation.resume(returning: false)
                    return
                }
                let status = manager.connection.status
                continuation.resume(returning: status == .connected)
            }
        }
    }
}

// Utility to show VPN alert from anywhere by finding top view controller
@MainActor
public class VPNNotifier {
    public static let shared = VPNNotifier()
    private init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleVPNChange(_:)),
                                               name: .vpnStatusDidChange,
                                               object: nil)
    }

    @objc private func handleVPNChange(_ notification: Notification) {
        guard let isActive = notification.userInfo?["isVPNActive"] as? Bool,
              isActive == true else { return }
        showVPNConnectedAlert()
    }

    private func showVPNConnectedAlert() {
        DispatchQueue.main.async {
            guard let topVC = UIApplication.topMostViewController() else {
                print("Failed to find top view controller")
                return
            }
            // Prevent multiple alerts stacking
            if topVC.presentedViewController is UIAlertController { return }

            let alert = UIAlertController(title: "VPN Connected",
                                          message: "Your device is connected to a VPN.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            topVC.present(alert, animated: true)
        }
    }
}

// UIApplication extension to find top-most view controller
extension UIApplication {
    static func topMostViewController(base: UIViewController? = {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first?.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }()) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}
