//
//  GestureRecognizerDelegate.swift
//  SmartText
//
//  Created by Dev Asheesh Chopra on 08/07/24. (Refactoring)
//

import Foundation
import UIKit

// MARK: - UIGestureRecognizerDelegate

extension KeyboardViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: view)
                if inputTextField.frame.contains(location) {
            return false // Do not recognize the gesture; let the inputTextField handle the touch
        } else if keysStackView.frame.contains(location) {
            return false // Do not recognize the gesture; let the keysStackView handle the touch
        }
        return true // Recognize the gesture if it's outside these areas
    }
}
