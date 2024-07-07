//
//  Actions.swift
//  SmartText
//
//  Created by Dev Asheesh Chopra on 08/07/24. (Refactoring)
//

import Foundation
import UIKit

// MARK: - Actions

extension KeyboardViewController {
    @objc internal func handleTap(_ recognizer: UITapGestureRecognizer) {
        // Handle the tap event, which could potentially switch to the default keyboard
        let location = recognizer.location(in: view)
        if location.y < inputTextField.frame.minY {
            switchToDefaultKeyboard() // Function to switch to the default keyboard
        }
    }
    
    @objc internal func specialContentKeyPressed() {
        // Lazy initialization and setup of the blur effect
        typeOfContentString = ""
        if specialContentFlag {
            specialContentFlag.toggle()
        }
        
        updateSpecialContentKeyStyle()
        
        if blurEffectView == nil {
            setupBlurEffect()
            self.view.addSubview(blurEffectView!)  // Add it just once and at the lowest level
        }
        
        // Display the blur effect
        blurEffectView?.isHidden = false

        // Lazy initialization of the popup view
        if popupView == nil {
            setupPopup()
            self.view.addSubview(popupView!)  // Add the popup above the blur
        }
        
        // Show the popup
        popupView?.isHidden = false
    }
    
    // Hide the popup
    @objc internal func hidePopup() {
        typeOfContentString = ""
        popupView?.isHidden = true
//        self.view.sendSubviewToBack(blurEffectView!)
        blurEffectView?.isHidden = true
    }

    // Handle the "Reply" button tap
    @objc internal func handleReply() {
        typeOfContentString = ""
        typeOfContentString += "reply-"
        showOptionsPopup()
//        specialContentFlag = true
    }

    @objc internal func handleComment() {
        typeOfContentString = ""
        typeOfContentString += "comment-"
        showOptionsPopup()
//        specialContentFlag = true
    }

    internal func showOptionsPopup() {
        if optionsPopupView == nil {
            setupOptionsPopup()
        }
        popupView?.isHidden = true  // Hide the first popup
        optionsPopupView?.isHidden = false  // Show the options popup
    }

    @objc internal func handleOptionSelection(_ sender: UIButton) {
        
        if let title = sender.title(for: .normal)?.lowercased() {
            typeOfContentString += title
        }
        specialContentFlag = true
        updateSpecialContentKeyStyle()
        hideAllPopups()
    }

    @objc internal func hideAllPopups() {
        popupView?.isHidden = true
        optionsPopupView?.isHidden = true
        blurEffectView?.isHidden = true  // Also hide the blur when closing all
        if !specialContentFlag{
            typeOfContentString = ""
        }
    }

    @objc internal func hideCurrentPopup() {
        optionsPopupView?.isHidden = true
        popupView?.isHidden = false  // Show the first popup again
    }
    
    @objc internal func keyPressed(_ sender: UIButton) {
        playKeyClickSound()
        triggerHapticFeedback()
        let keyTitle = sender.title(for: .normal) ?? ""
        let text = isCapsLocked ? keyTitle.uppercased() : keyTitle.lowercased()
        inputTextField.insertText(text)

        // Disable caps lock after typing the first letter if it was auto-enabled
        if autoCapFlag {
            autoCapFlag = false
            isCapsLocked = false
            updateCapsLockButtonStyle()
            updateKeyCapitals()  // Update the visual state of the keys
        }
    }
    
    @objc internal func dotPressed() {
        inputTextField.insertText(".")
    }
    
    @objc internal func toggleCapsLock() {
            playKeyClickSound()
            triggerHapticFeedback()
            isCapsLocked.toggle()
            updateCapsLockButtonStyle()
            updateKeyCapitals()
    }
    
    
    internal func configureBackspaceButton(_ button: UIButton) {
        // Handling the touch down event to change the appearance
        button.addTarget(self, action: #selector(backspacePressed(_:)), for: .touchDown)
        
        // Handling the touch up inside event to revert the appearance
        button.addTarget(self, action: #selector(backspaceReleased(_:)), for: [.touchUpInside, .touchUpOutside])
    }
    
    @objc internal func backspacePressed(_ sender: UIButton) {
        playKeyClickSound()
        triggerHapticFeedback()

        deleteCharacter()  // Initial delete for immediate feedback

        // Start repeating timer to delete continuously while button is held down
        backspaceTimer?.invalidate()  // Invalidate any existing timer
        backspaceTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(deleteCharacter), userInfo: nil, repeats: true)

        sender.backgroundColor = .white
        sender.tintColor = .black
        
        let image = UIImage(systemName: "delete.left.fill")?.withRenderingMode(.alwaysTemplate)
        sender.setImage(image, for: .normal)
        sender.setImage(image, for: .highlighted)
        sender.alpha = 1.0
    }

    @objc internal func backspaceReleased(_ sender: UIButton) {
        // Stop the timer when button is released
        backspaceTimer?.invalidate()
        backspaceTimer = nil

        sender.backgroundColor = UIColor(red: 172/255.0, green: 177/255.0, blue: 185/255.0, alpha: 1)
        sender.tintColor = .black
        let image = UIImage(systemName: "delete.left")?.withRenderingMode(.alwaysTemplate)
        sender.setImage(image, for: .normal)
        sender.setImage(image, for: .highlighted)
        sender.alpha = 1.0
    }

    @objc internal func deleteCharacter() {
        if isInputTextFieldActive {
            inputTextField.deleteBackward()
        } else {
            textDocumentProxy.deleteBackward()
        }
        if autoCapFlag {
            autoCapFlag = false
            isCapsLocked = false
            updateCapsLockButtonStyle()
            updateKeyCapitals()  // Update the visual state of the keys
        }
        checkAutoCapsAfterPeriod()
    }
    
    
    @objc internal func handleSpaceKeyLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let button = gesture.view else { return }
        
        let location = gesture.location(in: button)  // Get the location of the gesture within the button

        switch gesture.state {
        case .began:
            initialTouchLocation = location.x  // Store the initial touch location when the gesture begins
        case .changed:
            if let initialLocation = initialTouchLocation {
                let currentLocation = location.x
                let distanceMoved = currentLocation - initialLocation
                if abs(distanceMoved) > 1 {  // Add a threshold to avoid minor movements affecting the cursor
                    moveCursor(horizontalDistance: distanceMoved)
                    initialTouchLocation = currentLocation  // Update initial location for continuous tracking
                }
            }
        case .ended, .cancelled:
            initialTouchLocation = nil  // Reset the initial location on gesture end or cancel
            consecutiveSpaces = 0
        default:
            break
        }
    }

    internal func moveCursor(horizontalDistance: CGFloat) {
        guard let textField = inputTextField, let selectedRange = textField.selectedTextRange else { return }

        let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)

        // Calculate new cursor position based on the direction of the movement
        let moveRight = horizontalDistance > 0
        var newCursorPosition = cursorPosition + (moveRight ? 1 : -1)
        newCursorPosition = max(min(newCursorPosition, textField.text?.count ?? 0), 0)  // Constrain within bounds

        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: newCursorPosition) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }

    @objc internal func spacePressed() {
        playKeyClickSound()
        triggerHapticFeedback()
        guard let currentText = inputTextField.text else { return }
        
        let words = currentText.components(separatedBy: .whitespacesAndNewlines)
        guard let lastWord = words.last, !lastWord.isEmpty else {
            if isDoubleSpaceForPeriodEnabled && consecutiveSpaces == 0 {
                inputTextField.deleteBackward()

                inputTextField.insertText(". ")
                checkAutoCapsAfterPeriod()
            } else {
                inputTextField.insertText(" ")
            }
            consecutiveSpaces = (consecutiveSpaces+1) % 2
            return
        }

        consecutiveSpaces = 0
        if isAutocorrectEnabled {
            let textChecker = UITextChecker()
            let nsRange = currentText.nsRange(from: currentText.range(of: lastWord)!)
            
            // Check for misspelled words
            let misspelledRange = textChecker.rangeOfMisspelledWord(in: currentText, range: nsRange, startingAt: 0, wrap: false, language: "en_US")
            if misspelledRange.location != NSNotFound {
                let corrections = textChecker.guesses(forWordRange: misspelledRange, in: currentText, language: "en_US") ?? []
                if let topCorrection = corrections.first {
                    // Replace last word with top correction
                    let correctedText = (currentText as NSString).replacingCharacters(in: nsRange, with: topCorrection)
                    inputTextField.text = correctedText
                }
            }
        }
        inputTextField.insertText(" ") // Add space after correcting the word
        checkAutoCapsAfterPeriod()
    }
    
    @objc internal func copyText() {
        UIPasteboard.general.string = responseLabel.text
    }

    @objc internal func regeneratePrompt() {
        toggleInputVisibility(show: true)
        clearInput()
    }

    @objc internal func toggleNumbers() {
        playKeyClickSound()
        triggerHapticFeedback()
        if keysStackView.arrangedSubviews.last != createNumericKeysStackView() {
            keysStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            createNumericKeysStackView().arrangedSubviews.forEach { keysStackView.addArrangedSubview($0) }
        }
        
    }

    @objc internal func toggleLetters() {
        playKeyClickSound()
        triggerHapticFeedback()
        if keysStackView.arrangedSubviews.last != createKeysStackView() {
            keysStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            createKeysStackView().arrangedSubviews.forEach { keysStackView.addArrangedSubview($0) }
        }
        isCapsLocked = false
        updateCapsLockButtonStyle()
        updateKeyCapitals()
        
        updateSpecialContentKeyStyle()
    }
    
    internal func updateGoButtonAppearance() {
        guard let text = inputTextField.text else {
            print("Text field is nil")
            return
        }

        let isNotEmpty = !text.isEmpty
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if isNotEmpty {
                if self.goButton.backgroundColor != UIColor(red: 52/255.0, green: 120/255.0, blue: 246/255.0, alpha: 1) {
                    print("Updating goButton to active state")
                    self.goButton.backgroundColor = UIColor(red: 52/255.0, green: 120/255.0, blue: 246/255.0, alpha: 1)
                    self.goButton.setTitleColor(.white, for: .normal)
                    self.goButton.layer.borderColor = UIColor(red: 79/255.0, green: 143/255.0, blue: 238/255.0, alpha: 1).cgColor

                }
            } else {
                if self.goButton.backgroundColor != UIColor(red: 172/255.0, green: 177/255.0, blue: 185/255.0, alpha: 1) {
                    print("Updating goButton to inactive state")
                    self.goButton.backgroundColor = UIColor(red: 172/255.0, green: 177/255.0, blue: 185/255.0, alpha: 1)
                    self.goButton.setTitleColor(UIColor(red: 119/255.0, green: 123/255.0, blue: 128/255.0, alpha: 1), for: .normal)
                    self.goButton.layer.borderColor = UIColor(red: 172/255.0, green: 177/255.0, blue: 185/255.0, alpha: 1).cgColor
                }
            }
        }
    }

}
