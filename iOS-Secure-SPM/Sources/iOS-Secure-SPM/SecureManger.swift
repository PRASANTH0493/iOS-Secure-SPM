//
//  File.swift
//  iOS-Secure-SPM
//
//  Created by PrasanthPodalakur on 03/08/25.
//

import Foundation
import UIKit
public class SecureManager: NSObject {
    @MainActor public static let shared = SecureManager()
    var secureManagerDelegates: SecureManagerprotocol?
    var antiFraudManager: AntiFraudManagerProtocol?
    var screenshotNotificationObserver: NSObjectProtocol?
    var screenRecordingNotificationObserver: NSObjectProtocol?
    
    public func configure(secureManagerDelegates: SecureManagerprotocol,
                          antiFraudManager: AntiFraudManagerProtocol) {
        self.secureManagerDelegates = secureManagerDelegates
        self.antiFraudManager = antiFraudManager
    }
    
}

public protocol SecureManagerprotocol {
    var secureFeatureToggles: SecureFeatureProtocol { get }
}

public protocol AntiFraudManagerProtocol {
    func getApplicationWindow() -> UIWindow?
    func getMakingView() -> UIView?
    func showAlert(title: String, message: String)
    
}
public protocol SecureFeatureProtocol {
    var isScreenshotDetectionEnabled: Bool { get }
    var isScreenRecordingDetectionEnabled: Bool { get }
    var isScreenshotMaskingEnabled: Bool { get }
    var isVPNDetectionEnabled: Bool { get }
}
