// MARK: - Imports and Metadata

//
//  KeyboardViewController.swift
//  SmartText
//
//  Created by Dev Asheesh Chopra on 27/06/24.
//

import UIKit
import GoogleGenerativeAI
import AudioToolbox

// MARK: - Class Declaration

class KeyboardViewController: UIInputViewController {
    private let generativeModelManager = GenerativeModelManager()
    private var inputTextField: UITextField!
    private var keysStackView: UIStackView!
    private var responseLabel: UILabel!
    private var responseScrollView: UIScrollView!
    private var copyButton: UIButton!
    private var regenerateButton: UIButton!
    private var isCapsLocked = false
    private var goButton: UIButton!
    private var isInputTextFieldActive = true
    private var activityIndicator: UIActivityIndicatorView!
    private var textChecker = UITextChecker()
    private var suggestionsStackView: UIStackView!
    private var suggestionsHeightConstraint: NSLayoutConstraint?
    
    private var autoCapFlag = false
    private var consecutiveSpaces = 0
    private var suggestionsCache = [String: [String]]()
    private var currentWord: String? {
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
}

// MARK: - UserDefaults Management

extension KeyboardViewController {
    private var keyClickSoundsEnabled: Bool {
        get {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            return sharedDefaults?.bool(forKey: "keyClickSoundsEnabled") ?? false
        }
        set {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            sharedDefaults?.set(newValue, forKey: "keyClickSoundsEnabled")
        }
    }
    
    private var hapticFeedbackEnabled: Bool {
        get {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            return sharedDefaults?.bool(forKey: "hapticFeedbackEnabled") ?? false
        }
        set {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            sharedDefaults?.set(newValue, forKey: "hapticFeedbackEnabled")
        }
    }
    
    private var isAutoCapsEnabled: Bool {
        get {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            return sharedDefaults?.bool(forKey: "isAutoCapsEnabled") ?? false
        }
        set {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            sharedDefaults?.set(newValue, forKey: "isAutoCapsEnabled")
        }
    }
    
    private var isDoubleSpaceForPeriodEnabled: Bool {
        get {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            return sharedDefaults?.bool(forKey: "isDoubleSpaceForPeriodEnabled") ?? false
        }
        set {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            sharedDefaults?.set(newValue, forKey: "isDoubleSpaceForPeriodEnabled")
        }
    }
    
    private var isAutocorrectEnabled: Bool {
        get {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            return sharedDefaults?.bool(forKey: "isAutocorrectEnabled") ?? false
        }
        set {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            sharedDefaults?.set(newValue, forKey: "isAutocorrectEnabled")
        }
    }

}

// MARK: - Lifecycle

extension KeyboardViewController {
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

// MARK: - UI Configuration

extension KeyboardViewController {
    private func setupViews() {
        
        let red = CGFloat(210) / 255.0
        let green = CGFloat(212) / 255.0
        let blue = CGFloat(217) / 255.0
        view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)

        suggestionsStackView = UIStackView()
        suggestionsStackView.axis = .horizontal
        suggestionsStackView.distribution = .fillEqually
        suggestionsStackView.alignment = .fill
        suggestionsStackView.spacing = 10
        suggestionsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(suggestionsStackView)
        suggestionsHeightConstraint = suggestionsStackView.heightAnchor.constraint(equalToConstant: 30)
        suggestionsHeightConstraint?.isActive = true
        
        
        inputTextField = UITextField()
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.placeholder = "Search"
        inputTextField.borderStyle = .none
        inputTextField.backgroundColor = .white
        inputTextField.layer.cornerRadius = 10
        inputTextField.layer.shadowColor = UIColor.black.cgColor
        inputTextField.layer.shadowOffset = CGSize(width: 0, height: 1)
        inputTextField.layer.shadowOpacity = 0.2
        inputTextField.layer.shadowRadius = 1
        inputTextField.delegate = self  // Set the delegate
        inputTextField.clearButtonMode = .whileEditing
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: inputTextField.frame.height))
        inputTextField.leftView = paddingView
        inputTextField.leftViewMode = .always
        
        view.addSubview(inputTextField)
        inputTextField.delegate = self
        
        activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.hidesWhenStopped = true // Hide when not animating
            view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        
        keysStackView = createKeysStackView()
        // During the setup of your keysStackView or similar interactive elements
        view.addSubview(keysStackView)

        responseScrollView = UIScrollView()
        responseScrollView.translatesAutoresizingMaskIntoConstraints = false
        responseScrollView.isHidden = true
        view.addSubview(responseScrollView)

        responseLabel = UILabel()
        responseLabel.translatesAutoresizingMaskIntoConstraints = false
        responseLabel.numberOfLines = 0
        responseLabel.lineBreakMode = .byWordWrapping
        responseLabel.isHidden = true
        responseScrollView.addSubview(responseLabel)

        copyButton = UIButton(type: .system)
        copyButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.addTarget(self, action: #selector(copyText), for: .touchUpInside)
        copyButton.isHidden = true
        view.addSubview(copyButton)

        regenerateButton = UIButton(type: .system)
        regenerateButton.setImage(UIImage(systemName: "gobackward"), for: .normal)
        regenerateButton.translatesAutoresizingMaskIntoConstraints = false
        regenerateButton.addTarget(self, action: #selector(regeneratePrompt), for: .touchUpInside)
        regenerateButton.isHidden = true
        view.addSubview(regenerateButton)
        
        
        isCapsLocked = false  // Initialize with Caps Lock off
        updateCapsLockButtonStyle()
        updateKeyCapitals()
    }



    private func createKeysStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12  // Tighten spacing to match iOS
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Rows for different sets of keys
        stackView.addArrangedSubview(createRow(keys: "QWERTYUIOP", isFunctionRow: false))
        stackView.addArrangedSubview(createRow(keys: "ASDFGHJKL", isFunctionRow: false, indent: true))
        stackView.addArrangedSubview(createRow(keys: "ZXCVBNM", isFunctionRow: true))
        stackView.addArrangedSubview(createFunctionRow())

        return stackView
    }

    private func createRow(keys: String, isFunctionRow: Bool, indent: Bool = false) -> UIStackView {
        let row = UIStackView()
        row.spacing = 6
        row.translatesAutoresizingMaskIntoConstraints = false
        row.distribution = isFunctionRow ? .fill : .fillEqually  // Use fill to manage widths manually
        
        if indent {
            row.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            row.isLayoutMarginsRelativeArrangement = true
        }
        
        // Prepare buttons for alphabetic keys
        let alphabeticStack = UIStackView()
        alphabeticStack.distribution = .fillEqually
        alphabeticStack.spacing = 5
        alphabeticStack.translatesAutoresizingMaskIntoConstraints = false
        
        for char in keys {
            let button = UIButton(type: .system)
            button.setTitle(String(char), for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
            configureButtonAppearance(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 42).isActive = true
            button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
            alphabeticStack.addArrangedSubview(button)
        }
        
        if isFunctionRow {
            let shiftButton = createSpecialKey(title: "⇧", action: #selector(toggleCapsLock), height: 42, isSymbol: true)
            configureButtonAppearance(shiftButton, specialKey: true)
            
            
            let backspaceButton = createSpecialKey(title: "⌫", action: #selector(backspaceReleased), height: 42, isSymbol: true)
            configureButtonAppearance(backspaceButton, specialKey: true)
            configureBackspaceButton(backspaceButton)
            
            
            shiftButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
            shiftButton.setTitleColor(.black, for: .normal)
            
            backspaceButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
            backspaceButton.setTitleColor(.black, for: .normal)


            // Add shift button
            row.insertArrangedSubview(shiftButton, at: 0)
            
            // Spacer after shift button
            let leftSpacer = UIView()
            leftSpacer.translatesAutoresizingMaskIntoConstraints = false
            leftSpacer.widthAnchor.constraint(equalToConstant: 4).isActive = true
            row.insertArrangedSubview(leftSpacer, at: 1)
            
            // Add alphabetic keys encapsulated in their own stack view
            row.addArrangedSubview(alphabeticStack)
            
            // Spacer before the backspace button
            let rightSpacer = UIView()
            rightSpacer.translatesAutoresizingMaskIntoConstraints = false
            rightSpacer.widthAnchor.constraint(equalToConstant: 4).isActive = true
            row.addArrangedSubview(rightSpacer)

            // Add backspace button
            row.addArrangedSubview(backspaceButton)
        } else {
            // For non-function rows, simply add the buttons
            alphabeticStack.arrangedSubviews.forEach { row.addArrangedSubview($0) }
        }

        return row
    }
    
    private func createNumericKeysStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12  // Consistent with your other stack views
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // First row - numbers
        stackView.addArrangedSubview(createRow(keys: "1234567890", isFunctionRow: false))

        // Second row - symbols
        stackView.addArrangedSubview(createRow(keys: "-/:;()₹&@“", isFunctionRow: false))

        // Third row - more symbols
        stackView.addArrangedSubview(createRow(keys: "#+=.,?!’", isFunctionRow: false))

        // Function row for numeric layout
        stackView.addArrangedSubview(createNumericFunctionRow())

        return stackView
    }

    
    private func createNumericFunctionRow() -> UIStackView {
        let row = UIStackView()
        row.distribution = .fillProportionally
        row.spacing = 5

        let abcButton = createSpecialKey(title: "ABC", action: #selector(toggleLetters), height: 42)
        abcButton.backgroundColor = UIColor(red: CGFloat(172)/255.0, green:  CGFloat(177)/255.0, blue:  CGFloat(185)/255.0, alpha: 1)
        configureButtonAppearance(abcButton, specialKey: true)
        let spaceButton = createSpecialKey(title: "space", action: #selector(spacePressed), height: 42)
        let deleteButton = createSpecialKey(title: "⌫", action: #selector(backspacePressed), height: 42, isSymbol: true)
        configureButtonAppearance(deleteButton, specialKey: true)
        configureBackspaceButton(deleteButton)

        // Space button is more flexible
        spaceButton.setContentHuggingPriority(.defaultLow, for: .horizontal)

        row.addArrangedSubview(abcButton)
        row.addArrangedSubview(spaceButton)
        row.addArrangedSubview(deleteButton)

        return row
    }

    
    private func configureButtonAppearance(_ button: UIButton, specialKey: Bool = false) {
        
        if !specialKey {
            button.backgroundColor = UIColor.white
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: CGFloat(244)/255.0, green:  CGFloat(244)/255.0, blue:  CGFloat(245)/255.0, alpha: 1).cgColor

            
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 1) // Adjust the shadow position
            button.layer.shadowRadius = 1.5 // Adjust the blur radius
            button.layer.shadowOpacity = 0.35 // Adjust the transparency of the shadow

        }
        else {
            button.backgroundColor = UIColor(red: CGFloat(172)/255.0, green:  CGFloat(177)/255.0, blue:  CGFloat(185)/255.0, alpha: 1)
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: CGFloat(172)/255.0, green:  CGFloat(177)/255.0, blue:  CGFloat(185)/255.0, alpha: 1).cgColor

            
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 1) // Adjust the shadow position
            button.layer.shadowRadius = 1.5 // Adjust the blur radius
            button.layer.shadowOpacity = 0.35 // Adjust the transparency of the shadow

        }
        

        // Important for performance: rasterize the layer with shadows
        
        button.layer.shouldRasterize = true
        button.layer.rasterizationScale = UIScreen.main.scale
    }
    
    
    private func createFunctionRow() -> UIStackView {
        let row = UIStackView()
        row.distribution = .fillProportionally
        row.spacing = 5

        let leftButton = createSpecialKey(title: "123", action: #selector(toggleNumbers), height: 42)
        leftButton.backgroundColor = UIColor(red: CGFloat(172)/255.0, green:  CGFloat(177)/255.0, blue:  CGFloat(185)/255.0, alpha: 1)
        
        configureButtonAppearance(leftButton, specialKey: true)

        let spaceButton = createSpecialKey(title: "space", action: #selector(spacePressed), height: 42)
                
        goButton = createSpecialKey(title: "go", action: #selector(submitPrompt), height: 42)
        updateGoButtonAppearance()

        
        // Space button needs to be more flexible
        spaceButton.setContentHuggingPriority(.defaultLow, for: .horizontal)

        row.addArrangedSubview(leftButton)
        row.addArrangedSubview(spaceButton)
        row.addArrangedSubview(goButton)

        return row
    }

    // Helper to create buttons with specific actions
    private func createSpecialKey(title: String, action: Selector, height: CGFloat, isSymbol: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        
        if !isSymbol {
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
        }
        else{
            if title == "⇧" {
                button.setImage(UIImage(systemName: "shift"), for: .normal)
            }
            else{
                button.setImage(UIImage(systemName: "delete.left"), for: .normal)
            }
            button.tintColor = UIColor.black
        }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        configureButtonAppearance(button)
        button.addTarget(self, action: action, for: .touchUpInside)
        if title == "⇧" {
                button.tag = 999  // Unique identifier for the Caps Lock key
            }
        
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        return button
    }


    private func updateCapsLockButtonStyle() {
        let capsLockButton = view.viewWithTag(999) as? UIButton  // Assuming you assign tag 999 to the Caps Lock button
        let backgroundColor = isCapsLocked ? UIColor.white : UIColor(red: CGFloat(172)/255.0, green:  CGFloat(177)/255.0, blue:  CGFloat(185)/255.0, alpha: 1)

        let titleImage = isCapsLocked ? "shift.fill" : "shift"
        
        capsLockButton?.backgroundColor = backgroundColor
        capsLockButton?.setImage(UIImage(systemName: titleImage), for: .normal)
    }


    private func updateKeyCapitals() {
        for view in keysStackView.arrangedSubviews {
            guard let row = view as? UIStackView else { continue }
            
            // Check each subview, which could be either a button directly or another stack view with buttons
            for subview in row.arrangedSubviews {
                if let button = subview as? UIButton {
                    // Update only if the button is not a 'space' or 'go'
                    if let buttonText = button.title(for: .normal), buttonText.lowercased() != "space" && buttonText.lowercased() != "go" {
                        button.setTitle(isCapsLocked ? buttonText.uppercased() : buttonText.lowercased(), for: .normal)
                    }
                } else if let innerStack = subview as? UIStackView {
                    // Iterate through inner stack which contains alphabet keys
                    for case let button as UIButton in innerStack.arrangedSubviews {
                        if let buttonText = button.title(for: .normal), buttonText.lowercased() != "space" && buttonText.lowercased() != "go" {
                            button.setTitle(isCapsLocked ? buttonText.uppercased() : buttonText.lowercased(), for: .normal)
                        }
                    }
                }
            }
        }
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            
                        
            inputTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            inputTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            inputTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            inputTextField.heightAnchor.constraint(equalToConstant: 40),
            
            suggestionsStackView.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 5),
            suggestionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            suggestionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
//            suggestionsStackView.heightAnchor.constraint(equalToConstant: 30),
            

            keysStackView.topAnchor.constraint(equalTo: suggestionsStackView.bottomAnchor, constant: 5),
            keysStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            keysStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            keysStackView.bottomAnchor.constraint(equalTo: regenerateButton.bottomAnchor, constant: -5),  // Gives more space for the keyboard

            responseScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            responseScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            responseScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            responseScrollView.bottomAnchor.constraint(equalTo: regenerateButton.topAnchor, constant: -5),

                  // Add constraints for the label inside the scroll view
            responseLabel.topAnchor.constraint(equalTo: responseScrollView.contentLayoutGuide.topAnchor, constant: 5),
            responseLabel.leadingAnchor.constraint(equalTo: responseScrollView.contentLayoutGuide.leadingAnchor, constant: 5),
            responseLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            responseLabel.bottomAnchor.constraint(equalTo: responseScrollView.contentLayoutGuide.bottomAnchor, constant: -7),

            copyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            copyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            copyButton.widthAnchor.constraint(equalToConstant: 100),

            regenerateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            regenerateButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            regenerateButton.widthAnchor.constraint(equalToConstant: 100),


            ])
        responseScrollView.contentSize = CGSize(width: view.frame.width, height: 1000)

    }
}

// MARK: - UITextFieldDelegate

extension KeyboardViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        DispatchQueue.main.async {
            self.updateGoButtonAppearance()
            
            guard let currentWord = self.currentWord, self.isAutocorrectEnabled else { return }
            
            let range = NSRange(location: 0, length: currentWord.utf16.count)
            let guesses = self.textChecker.guesses(forWordRange: range, in: currentWord, language: "en_US") ?? []
            
            let topThreeGuesses = Array(guesses.prefix(5))
            
            self.updateSuggestionsBar(with: topThreeGuesses)
        }
        
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
                let currentText = textField.text ?? ""
                let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
                
            updateSuggestions(for: newText)
            return true
    }
}

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

// MARK: - Actions

extension KeyboardViewController {
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        // Handle the tap event, which could potentially switch to the default keyboard
        let location = recognizer.location(in: view)
        if location.y < inputTextField.frame.minY {
            switchToDefaultKeyboard() // Function to switch to the default keyboard
        }
    }
    
    @objc func keyPressed(_ sender: UIButton) {
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
    
    @objc func toggleCapsLock() {
            playKeyClickSound()
            triggerHapticFeedback()
            isCapsLocked.toggle()
            updateCapsLockButtonStyle()
            updateKeyCapitals()
    }
    
    
    private func configureBackspaceButton(_ button: UIButton) {
        // Handling the touch down event to change the appearance
        button.addTarget(self, action: #selector(backspacePressed(_:)), for: .touchDown)
        
        // Handling the touch up inside event to revert the appearance
        button.addTarget(self, action: #selector(backspaceReleased(_:)), for: [.touchUpInside, .touchUpOutside])
    }
    
    @objc func backspacePressed(_ sender: UIButton) {
//        inputTextField.deleteBackward()
        playKeyClickSound()
        triggerHapticFeedback()
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
        
//        sender.adjustsImageWhenHighlighted = false
        sender.backgroundColor = .white
        sender.tintColor = .black
        
        let image = UIImage(systemName: "delete.left.fill")?.withRenderingMode(.alwaysTemplate)
        sender.setImage(image, for: .normal)
        sender.setImage(image, for: .highlighted) // Ensure image is consistent even when the button is pressed
        sender.alpha = 1.0 // Ensure full opacity
    }

    @objc func backspaceReleased(_ sender: UIButton) {
        sender.backgroundColor = UIColor(red: 172/255.0, green: 177/255.0, blue: 185/255.0, alpha: 1)
        sender.tintColor = .black
        let image = UIImage(systemName: "delete.left")?.withRenderingMode(.alwaysTemplate)
        sender.setImage(image, for: .normal)
        sender.setImage(image, for: .highlighted) // Consistent for different states
        sender.alpha = 1.0 // Ensure full opacity
//        sender.adjustsImageWhenHighlighted = false
    }
    
    @objc func spacePressed() {
        playKeyClickSound()
        triggerHapticFeedback()
        guard let currentText = inputTextField.text else { return }
        
        let words = currentText.components(separatedBy: .whitespacesAndNewlines)
        guard let lastWord = words.last, !lastWord.isEmpty else {
            if isDoubleSpaceForPeriodEnabled && consecutiveSpaces == 0 {
                inputTextField.deleteBackward()

                inputTextField.insertText(". ")
                checkAutoCapsAfterPeriod()// Insert period and space
            } else {
                inputTextField.insertText(" ")
            }
            consecutiveSpaces = (consecutiveSpaces+1) % 2 // Reset or increment counter
            return
        }

        consecutiveSpaces = 0 // Reset counter since the last character is not a space

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

        inputTextField.insertText(" ") // Add space after correcting the word
        checkAutoCapsAfterPeriod()
    }
    
    @objc func copyText() {
        UIPasteboard.general.string = responseLabel.text
    }

    @objc func regeneratePrompt() {
        toggleInputVisibility(show: true)
        clearInput()
    }

    @objc func toggleNumbers() {
        playKeyClickSound()
        triggerHapticFeedback()
        if keysStackView.arrangedSubviews.last != createNumericKeysStackView() {
            keysStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            createNumericKeysStackView().arrangedSubviews.forEach { keysStackView.addArrangedSubview($0) }
        }
    }

    @objc func toggleLetters() {
        playKeyClickSound()
        triggerHapticFeedback()
        if keysStackView.arrangedSubviews.last != createKeysStackView() {
            keysStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            createKeysStackView().arrangedSubviews.forEach { keysStackView.addArrangedSubview($0) }
        }
        isCapsLocked = false
        updateCapsLockButtonStyle()
        updateKeyCapitals()
    }
    
    private func updateGoButtonAppearance() {
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

// MARK: - Utilities

extension KeyboardViewController {
    func playKeyClickSound() {
        if keyClickSoundsEnabled {
            AudioServicesPlaySystemSound(1104)  // Standard keyboard click sound ID
        }
    }
    
    func triggerHapticFeedback() {
        if hapticFeedbackEnabled {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.impactOccurred()
        }
    }
    
    func switchToDefaultKeyboard() {
        self.advanceToNextInputMode() // Method provided by UIInputViewController to switch to the next keyboard
    }

    @objc func submitPrompt() {
        guard let prompt = inputTextField.text, !prompt.isEmpty else { return }
        let finalPrompt = "Do Not Use 'Markdown Language' in your response. Do Not include beginning sentenecs like 'Here is your response:' in your response. Taking the previous instructions into consideration, respond to the following prompt: "+prompt
        activityIndicator.startAnimating()
        
        generativeModelManager.generateContent(from: finalPrompt) { [weak self] response in
                DispatchQueue.main.async {
                    self?.updateUIWithResponse(response)
                    self?.activityIndicator.stopAnimating()  // Stop the activity indicator once the response is ready
                }
            }
        hideInputComponents()
    }
    
    private func hideInputComponents() {
        inputTextField.isHidden = true
        goButton.isHidden = true
        keysStackView.isHidden = true
    }
    
    func updateUIWithResponse(_ response: String) {
        responseScrollView.isHidden = false
        responseLabel.isHidden = false
        responseLabel.text = response
        copyButton.isHidden = false
        regenerateButton.isHidden = false
    }

    
    private func toggleInputVisibility(show: Bool) {
        inputTextField.isHidden = !show
        goButton.isHidden = !show
        keysStackView.isHidden = !show
    }
    
    private func clearInput() {
        inputTextField.text = ""
        responseLabel.isHidden = true
        responseScrollView.isHidden = true
        copyButton.isHidden = true
        regenerateButton.isHidden = true
    }
    
    func checkAutoCapsAfterPeriod() {
        if isAutoCapsEnabled && inputTextField.text?.hasSuffix(". ") == true {
            // Enable caps lock
            if !isCapsLocked{
                autoCapFlag = true
                isCapsLocked = true
                updateCapsLockButtonStyle()
                updateKeyCapitals()  // Your function to visually update the keyboard for caps lock
            }
        }
    }
    
    @objc func suggestionSelected(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        
        // This logic replaces the last word typed with the selected suggestion
        if let text = inputTextField.text, let lastWordRange = text.range(of: "\\S+$", options: .regularExpression, range: text.startIndex..<text.endIndex) {
            inputTextField.text = text.replacingCharacters(in: lastWordRange, with: title)
        }
        inputTextField.insertText(" ")  // Adds a space after the inserted word
    }
    
    func updateSuggestions(for word: String) {
        let textChecker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)

        let misspelledRange = textChecker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en_US")
        if misspelledRange.location != NSNotFound {
            let guesses = textChecker.guesses(forWordRange: misspelledRange, in: word, language: "en_US") ?? []
            print("Misspelled Word Found: Updating suggestions with guesses: \(guesses)")
            updateSuggestionsBar(with: Array(guesses.prefix(3)))
//            updateSuggestionsBar(with: guesses)

        } else {
            print("No misspellings found.")
            DispatchQueue.main.async { [weak self] in
                self?.suggestionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            }
        }
    }

    func updateSuggestionsBar(with suggestions: [String]) {
        suggestionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for suggestion in suggestions {
            let button = UIButton(type: .system)
            button.setTitle(suggestion, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            button.addTarget(self, action: #selector(suggestionSelected(_:)), for: .touchUpInside)
            suggestionsStackView.addArrangedSubview(button)
        }
    }
    
    func updateSuggestionsVisibility() {
        if isAutocorrectEnabled {
            suggestionsStackView.isHidden = false
            suggestionsHeightConstraint?.constant = 30  // Or whatever the default height should be
        } else {
            suggestionsStackView.isHidden = true
            suggestionsHeightConstraint?.constant = 0  // Collapse the view
        }
        view.layoutIfNeeded()  // Force the layout to update
    }
}

// MARK: - String Extension

extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}
