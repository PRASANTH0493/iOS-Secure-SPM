//
//  SceneDelegate.swift
//  ios-secureExample
//
//  Created by PrasanthPodalakur on 02/08/25.
//

import UIKit
import iOS_Secure_SPM
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    
        configureSecureManager()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

extension SceneDelegate {
    func configureSecureManager() {
        SecureManager.shared.configure(secureManagerDelegates: SecureManagerDelegatesMock(), antiFraudManager: AntiFraudManagerProtocolMock())
        SecureManager.shared.addScreenshotPreventNotification()
    }
}

class SecureManagerDelegatesMock: SecureManagerprotocol {
    var secureFeatureToggles: SecureFeatureProtocol {
        SecureFeatureProtocolMock()
    }
}
class SecureFeatureProtocolMock: SecureFeatureProtocol {
    var isScreenshotDetectionEnabled: Bool { true }
    var isScreenRecordingDetectionEnabled: Bool { true }
    var isScreenshotMaskingEnabled: Bool { true }
    var isVPNDetectionEnabled: Bool { true }
}
class AntiFraudManagerProtocolMock: AntiFraudManagerProtocol {
    func getApplicationWindow() -> UIWindow? {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let delegate = scene.delegate as? SceneDelegate,
           let window = delegate.window {
            return window
        }
        return nil
    }
    
    func getMakingView() -> UIView? {
        return UIStoryboard(name: "SecureLayer", bundle: nil).instantiateInitialViewController()?.view
    }
    
    func showAlert(title: String, message: String) {
        guard let topVC = getTopViewController() else {
            print("Failed to find top view controller")
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        topVC.present(alert, animated: true)
    }
    func getTopViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
            
            if let nav = base as? UINavigationController {
                return getTopViewController(base: nav.visibleViewController)
            }
            
            if let tab = base as? UITabBarController {
                if let selected = tab.selectedViewController {
                    return getTopViewController(base: selected)
                }
            }
            
            if let presented = base?.presentedViewController {
                return getTopViewController(base: presented)
            }
            
            return base
        }
    
}
