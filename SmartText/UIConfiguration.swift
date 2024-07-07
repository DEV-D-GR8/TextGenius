//
//  UIConfiguration.swift
//  SmartText
//
//  Created by Dev Asheesh Chopra on 08/07/24. (Refactoring)
//

import UIKit
import Foundation

extension KeyboardViewController {
    internal func setupViews() {
        
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
        inputTextField.placeholder = "Prompt goes here..."
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
        
        responseLabel = UITextView()
        responseLabel.translatesAutoresizingMaskIntoConstraints = false
        responseLabel.isEditable = false  // Make text view non-editable
        responseLabel.isSelectable = true  // Enable text selection
        responseLabel.dataDetectorTypes = .all  // Optionally detect data like links, dates, etc.
        responseLabel.font = UIFont.systemFont(ofSize: 16)
        responseLabel.isHidden = true
        responseLabel.backgroundColor = .clear
        responseLabel.delegate = self
        responseLabel.isScrollEnabled = false
        
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



    internal func createKeysStackView() -> UIStackView {
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
    
    internal func createNumericKeysStackView() -> UIStackView {
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

    
    internal func createNumericFunctionRow() -> UIStackView {
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

    
    internal func configureButtonAppearance(_ button: UIButton, specialKey: Bool = false) {
        
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
    
    
    internal func createFunctionRow() -> UIStackView {
        let row = UIStackView()
        row.distribution = .fillProportionally
        row.spacing = 5

        let leftButton = createSpecialKey(title: "123", action: #selector(toggleNumbers), height: 42)
        leftButton.backgroundColor = UIColor(red: CGFloat(172)/255.0, green:  CGFloat(177)/255.0, blue:  CGFloat(185)/255.0, alpha: 1)
        configureButtonAppearance(leftButton, specialKey: true)
        leftButton.widthAnchor.constraint(equalToConstant: 55).isActive = true
        
        
        let spaceButton = createSpecialKey(title: "space", action: #selector(spacePressed), height: 42)
        
        if longSpacePressCursorMovementEnabled {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleSpaceKeyLongPress(_:)))
            spaceButton.addGestureRecognizer(longPress)
        }
        
        let specialContentKey = createSpecialKey(title: "specialContentKey", action: #selector(specialContentKeyPressed), height: 42, isSymbol: true)
        configureButtonAppearance(specialContentKey, specialKey: true)
        specialContentKey.widthAnchor.constraint(equalToConstant: 45).isActive = true

        let dotKey = createSpecialKey(title: ".", action: #selector(dotPressed), height: 42)
        configureButtonAppearance(dotKey)
        dotKey.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
        goButton = createSpecialKey(title: "go", action: #selector(submitPrompt), height: 42)
        updateGoButtonAppearance()
        goButton.widthAnchor.constraint(equalToConstant: 55).isActive = true


        
        // Space button needs to be more flexible
        spaceButton.setContentHuggingPriority(.defaultLow, for: .horizontal)

        row.addArrangedSubview(leftButton)
        row.addArrangedSubview(dotKey)
        row.addArrangedSubview(spaceButton)
        row.addArrangedSubview(specialContentKey)
        row.addArrangedSubview(goButton)

        return row
    }

    // Helper to create buttons with specific actions
    internal func createSpecialKey(title: String, action: Selector, height: CGFloat, isSymbol: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        
        if !isSymbol {
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
        }
        else{
            if title == "⇧" {
                button.setImage(UIImage(systemName: "shift"), for: .normal)
            }
            else if title == "specialContentKey" {
                button.setImage(UIImage(systemName: "pencil.and.scribble"), for: .normal)
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
        if title == "specialContentKey" {
                button.tag = 111  // Unique identifier for the Caps Lock key
            }
        
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        return button
    }

    internal func updateSpecialContentKeyStyle() {
        let specialButton = view.viewWithTag(111) as? UIButton  // Assuming you assign tag 999 to the Caps Lock button
        let backgroundColor = specialContentFlag ? UIColor.white : UIColor(red: CGFloat(172)/255.0, green:  CGFloat(177)/255.0, blue:  CGFloat(185)/255.0, alpha: 1)
        
        specialButton?.backgroundColor = backgroundColor
    }


    internal func updateCapsLockButtonStyle() {
        let capsLockButton = view.viewWithTag(999) as? UIButton  // Assuming you assign tag 999 to the Caps Lock button
        let backgroundColor = isCapsLocked ? UIColor.white : UIColor(red: CGFloat(172)/255.0, green:  CGFloat(177)/255.0, blue:  CGFloat(185)/255.0, alpha: 1)

        let titleImage = isCapsLocked ? "shift.fill" : "shift"
        
        capsLockButton?.backgroundColor = backgroundColor
        capsLockButton?.setImage(UIImage(systemName: titleImage), for: .normal)
    }


    internal func updateKeyCapitals() {
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

    internal func setupPopup() {
        // Define the background color for the popup and buttons
        let backgroundColor = UIColor(red: 209/255, green: 213/255, blue: 219/255, alpha: 1)

        let view = UIView()
        view.frame = CGRect(x: 20, y: 50, width: self.view.frame.width - 40, height: 180) // Keep height for overall popup
        view.backgroundColor = backgroundColor
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
        view.clipsToBounds = true
        
        // Vertical stack view for arranging buttons
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8  // Minimal spacing for a fine line effect
        stackView.frame = CGRect(x: 20, y: 50, width: view.frame.width - 40, height: 80) // Adjusted stack view height to make buttons smaller

        // Create the "Reply" button
        let replyButton = UIButton(type: .system)
        replyButton.setTitle("Reply", for: .normal)
        replyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        replyButton.backgroundColor = backgroundColor
        replyButton.setTitleColor(.black, for: .normal)
        replyButton.layer.borderColor = UIColor.black.cgColor
        replyButton.layer.borderWidth = 0.5
        replyButton.layer.cornerRadius = 10
        replyButton.addTarget(self, action: #selector(handleReply), for: .touchUpInside)

        // Create the "Comment" button
        let commentButton = UIButton(type: .system)
        commentButton.setTitle("Comment", for: .normal)
        commentButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        commentButton.backgroundColor = backgroundColor
        commentButton.setTitleColor(.black, for: .normal)
        commentButton.layer.borderColor = UIColor.black.cgColor
        commentButton.layer.borderWidth = 0.5
        commentButton.layer.cornerRadius = 10
        commentButton.addTarget(self, action: #selector(handleComment), for: .touchUpInside)

        // Create the close (cross) button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .red
        closeButton.frame = CGRect(x: view.frame.width - 50, y: 10, width: 30, height: 30)
        closeButton.addTarget(self, action: #selector(hidePopup), for: .touchUpInside)

        // Add buttons to the stack view
        stackView.addArrangedSubview(replyButton)
        stackView.addArrangedSubview(commentButton)
        
        // Add stack view and close button to the popup view
        view.addSubview(stackView)
        view.addSubview(closeButton)
        
        // Keep the popup view reference and add it to the keyboard's view
        popupView = view
        self.view.addSubview(view)
        
        // Initially hide the popup
        view.isHidden = true
    }

    
    
    internal func setupBlurEffect() {
        let blurEffect = UIBlurEffect(style: .regular)  // Consider using .regular for more pronounced effect
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = self.view.bounds  // Ensuring it covers the entire view
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Add the blur effect view beneath all other subviews
        self.view.insertSubview(effectView, at: 0)
        blurEffectView = effectView
        effectView.isHidden = true
    }
    
    internal func setupOptionsPopup() {
        // RGB values for grayish background; adjust these as per your specific need
        let backgroundColor = UIColor(red: 209/255, green: 213/255, blue: 219/255, alpha: 1)

        let view = UIView()
        view.frame = CGRect(x: 20, y: 50, width: self.view.frame.width - 40, height: 200)
        view.backgroundColor = backgroundColor
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
        view.clipsToBounds = true

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 7  // This creates a fine line between buttons
        stackView.frame = CGRect(x: 20, y: 50, width: view.frame.width - 40, height: 100)

        // Button Titles and Styling
        let buttonTitles = ["Professional", "Sarcastic/Humorous", "Casual"]
        for title in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.backgroundColor = backgroundColor  // Same as the popup for a seamless look
            button.setTitleColor(.black, for: .normal)
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 0.5  // Fine line effect via border
            button.layer.cornerRadius = 10  // Optional: remove for square buttons as in some keyboard styles

            stackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(handleOptionSelection(_:)), for: .touchUpInside)
        }

        // Close button with a cross symbol
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .red
        closeButton.frame = CGRect(x: view.frame.width - 40, y: 10, width: 30, height: 30)
        closeButton.addTarget(self, action: #selector(hideAllPopups), for: .touchUpInside)

        // Back button with a left chevron
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .darkGray
        backButton.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        backButton.addTarget(self, action: #selector(hideCurrentPopup), for: .touchUpInside)

        view.addSubview(stackView)
        view.addSubview(closeButton)
        view.addSubview(backButton)

        optionsPopupView = view
        self.view.addSubview(view)
        view.isHidden = true  // Initially hidden
    }

    internal func configureConstraints() {
        NSLayoutConstraint.activate([
                        
            inputTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            inputTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            inputTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            inputTextField.heightAnchor.constraint(equalToConstant: 40),
            
            suggestionsStackView.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 5),
            suggestionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            suggestionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

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
