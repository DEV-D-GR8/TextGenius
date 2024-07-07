// MARK: - UITextFieldDelegate

//
//  TextFieldDelegate.swift
//  SmartText
//
//  Created by Dev Asheesh Chopra on 08/07/24. (Refactoring)
//

import UIKit
import Foundation

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
