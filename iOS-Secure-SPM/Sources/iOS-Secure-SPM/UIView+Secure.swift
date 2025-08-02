//
//  File.swift
//  iOS-Secure-SPM
//
//  Created by PrasanthPodalakur on 03/08/25.
//

import Foundation
import UIKit

extension UIView {
    func makeSecureApp() {
        let maskingView = SecureManager.shared.antiFraudManager?.getMakingView() ?? UIView()
        maskingView.frame = self.bounds
        self.addSubview(maskingView)
        /// Secure field to trigger screenshot protection
        let secureField = UITextField(frame: self.bounds)
        secureField.isSecureTextEntry = true
        secureField.isUserInteractionEnabled = false
        secureField.backgroundColor = .clear
        secureField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(secureField)
        self.layer.superlayer?.addSublayer(maskingView.layer)
        self.layer.superlayer?.addSublayer(secureField.layer)
        secureField.layer.sublayers?.last?.addSublayer(self.layer)
    }
}
