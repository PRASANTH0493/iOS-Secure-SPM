//
//  File.swift
//  iOS-Secure-SPM
//
//  Created by PrasanthPodalakur on 03/08/25.
//

import Foundation
import UIKit
public extension SecureManager {
    @MainActor func addScreenshotPreventNotification(viewController: UIViewController? = nil) {
        if secureManagerDelegates?.secureFeatureToggles.isScreenshotDetectionEnabled ?? false {
            screenshotNotificationObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.userDidTakeScreenshotNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.antiFraudManager?.showAlert(title: "Screenshot Detected", message: "Screenshot Detected")
                }
            }
        }
        if secureManagerDelegates?.secureFeatureToggles.isScreenshotMaskingEnabled ?? false {
            antiFraudManager?.getApplicationWindow()?.makeSecureApp()
        }
        if secureManagerDelegates?.secureFeatureToggles.isScreenRecordingDetectionEnabled ?? false {
            screenRecordingNotificationObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.userDidTakeScreenshotNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.antiFraudManager?.showAlert(title: "Screen Record Detected", message: "Screen Record Detected")
                }
            }
        }
    }
}

