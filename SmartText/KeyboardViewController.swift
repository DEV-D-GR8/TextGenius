
//
//  KeyboardViewController.swift
//  SmartText
//
//  Created by Dev Asheesh Chopra on 27/06/24.
//

import UIKit
import GoogleGenerativeAI

// MARK: - Class Declaration

class KeyboardViewController: UIInputViewController, UITextViewDelegate {
    
    // MARK: - Variables
    
        internal let generativeModelManager = GenerativeModelManager()
        internal var inputTextField: UITextField!
        internal var keysStackView: UIStackView!
        internal var responseLabel: UITextView!
        internal var responseScrollView: UIScrollView!
        internal var copyButton: UIButton!
        internal var regenerateButton: UIButton!
        internal var isCapsLocked = false
        internal var goButton: UIButton!
        internal var isInputTextFieldActive = true
        internal var activityIndicator: UIActivityIndicatorView!
        internal var textChecker = UITextChecker()
        internal var suggestionsStackView: UIStackView!
        internal var suggestionsHeightConstraint: NSLayoutConstraint?
        internal var popupView: UIView?
        internal var blurEffectView: UIVisualEffectView?
        internal var optionsPopupView: UIView?
        internal var backspaceTimer: Timer?
        internal var initialTouchLocation: CGFloat?

        internal var autoCapFlag = false
        internal var specialContentFlag = false
        internal var typeOfContentString = ""
        internal var inputFieldLastText = ""
        internal var consecutiveSpaces = 0
        internal var suggestionsCache = [String: [String]]()
        internal var currentWord: String? {
            if let textRange = inputTextField.selectedTextRange, let text = inputTextField.text {
                let beginning = inputTextField.beginningOfDocument
                let start = textRange.start
                let cursorOffset = inputTextField.offset(from: beginning, to: start)
                let textBeforeCursor = String(text.prefix(cursorOffset))
                let components = textBeforeCursor.components(separatedBy: CharacterSet.alphanumerics.inverted)
                return components.last
            }
            return nil
        }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureConstraints()
        updateSuggestionsVisibility()
        setupGestureRecognizer()
    }
    
    private func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }
}
