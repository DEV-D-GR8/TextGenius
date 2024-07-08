//
//  Utilities.swift
//  SmartText
//
//  Created by Dev Asheesh Chopra on 08/07/24. (Refactoring)
//

import Foundation
import UIKit
import AudioToolbox
import MarkdownKit

// MARK: - Utilities

extension KeyboardViewController {
    
    
    internal func playKeyClickSound() {
        if keyClickSoundsEnabled {
            AudioServicesPlaySystemSound(1104)  // Standard keyboard click sound ID
        }
    }
    
    internal func triggerHapticFeedback() {
        if hapticFeedbackEnabled {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.impactOccurred()
        }
    }
    
    internal func switchToDefaultKeyboard() {
        self.advanceToNextInputMode() // Method provided by UIInputViewController to switch to the next keyboard
    }

    internal func createLLMPrompt(typeOfContentString: String) -> String {
        // Split the string into components
        let components = typeOfContentString.split(separator: "-").map { String($0) }
        if components.count != 2 {
            return "Please specify your content type and style clearly."
        }
        
        let actionType = components[0]  // "reply" or "comment"
        let styleType = components[1]  // "professional", "sarcastic/humorous", "casual"

        // Creating the prompt based on action and style
        var prompt = "Generate a "
        switch styleType {
        case "professional":
            prompt += "formal and professional "
        case "sarcastic/humorous":
            prompt += "sarcastic and humorous "
        case "casual":
            prompt += "casual and friendly "
        default:
            prompt += "well-written "
        }

        prompt += "short \(actionType) to the following query. Ensure the response is plain text without any Markdown formatting or introductory phrases such as 'Here is your response'. Remember that the query you will get was dedicated to the sender of the query and not you. The query is: "

        return prompt
    }

    
    @objc internal func submitPrompt() {
        guard let prompt = inputTextField.text, !prompt.isEmpty else { return }
        var finalPrompt = ""
        if specialContentFlag {
//            specialContentFlag.toggle()
            finalPrompt = createLLMPrompt(typeOfContentString: typeOfContentString) + prompt
        }
        else {
            
            
            finalPrompt = "Do Not include beginning sentenecs like 'Here is your response:' in your response. Taking the previous instructions into consideration, respond to the following prompt: "+prompt
        }
        activityIndicator.startAnimating()
        
        generativeModelManager.generateContent(from: finalPrompt) { [weak self] response in
                DispatchQueue.main.async {
                    self?.updateUIWithResponse(response)
                    self?.activityIndicator.stopAnimating()  // Stop the activity indicator once the response is ready
                }
            }
        
        if resetSpecialKeyAfterSubmissionEnabled {
            specialContentFlag = false
            updateSpecialContentKeyStyle()
        }
        
        hideInputComponents()
    }
    
    internal func hideInputComponents() {
        inputTextField.isHidden = true
        goButton.isHidden = true
        keysStackView.isHidden = true
        if isAutocorrectEnabled {
            suggestionsStackView.isHidden = true
        }
    }
    
    internal func updateUIWithResponse(_ response: String) {
        responseScrollView.isHidden = false
        responseLabel.isHidden = false
        copyButton.isHidden = false
        regenerateButton.isHidden = false

        let markdownParser = MarkdownParser(font: UIFont.systemFont(ofSize: 16))
            
            // Customizing styles for bold and italic, slightly increasing their size to make them stand out
        markdownParser.bold.font = UIFont.boldSystemFont(ofSize: 16)  // Keeping bold the same size but bold
        markdownParser.italic.font = UIFont.italicSystemFont(ofSize: 16)  // Keeping italic the same size but italic
            
            // Customizing header font, making it larger and bold
        markdownParser.header.font = UIFont.boldSystemFont(ofSize: 18)
        responseLabel.attributedText = markdownParser.parse(response)
    }
    
    internal func toggleInputVisibility(show: Bool) {
        
        inputTextField.isHidden = !show
        goButton.isHidden = !show
        keysStackView.isHidden = !show
        if isAutocorrectEnabled {
            suggestionsStackView.isHidden = !show
        }

    }
    
    internal func clearInput() {
        if promptClearEnabled {
            inputTextField.text = ""
        }
        responseLabel.isHidden = true
        responseScrollView.isHidden = true
        copyButton.isHidden = true
        regenerateButton.isHidden = true
    }
    
    internal func checkAutoCapsAfterPeriod() {
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
    
    @objc internal func suggestionSelected(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        
        // This logic replaces the last word typed with the selected suggestion
        if let text = inputTextField.text, let lastWordRange = text.range(of: "\\S+$", options: .regularExpression, range: text.startIndex..<text.endIndex) {
            inputTextField.text = text.replacingCharacters(in: lastWordRange, with: title)
        }
        inputTextField.insertText(" ")  // Adds a space after the inserted word
    }
    
    internal func updateSuggestions(for word: String) {
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

    internal func updateSuggestionsBar(with suggestions: [String]) {
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
    
    internal func updateSuggestionsVisibility() {
        if isAutocorrectEnabled {
            suggestionsStackView.isHidden = false
            suggestionsHeightConstraint?.constant = 30  // Or whatever the default height should be
        } else {
            suggestionsStackView.isHidden = true
            suggestionsHeightConstraint?.constant = 0  // Collapse the view
        }
        view.layoutIfNeeded()  // Force the layout to update
    }
    
    internal func textViewDidChange(_ textView: UITextView) {
            let size = CGSize(width: textView.frame.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            
            textView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
            
            textView.isScrollEnabled = textView.contentSize.height > estimatedSize.height
        }
}
