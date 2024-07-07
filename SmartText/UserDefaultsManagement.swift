//
//  UserDefaultsManagement.swift
//  SmartText
//
//  Created by Dev Asheesh Chopra on 08/07/24. (Refactoring)
//

// MARK: - UserDefaults Management

import Foundation

extension KeyboardViewController {
    internal var resetSpecialKeyAfterSubmissionEnabled: Bool {
        get {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            return sharedDefaults?.bool(forKey: "resetSpecialKeyAfterSubmissionEnabled") ?? false
        }
        set {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            sharedDefaults?.set(newValue, forKey: "resetSpecialKeyAfterSubmissionEnabled")
        }
    }
    
    internal var longSpacePressCursorMovementEnabled: Bool {
        get {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            return sharedDefaults?.bool(forKey: "longSpacePressCursorMovementEnabled") ?? false
        }
        set {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            sharedDefaults?.set(newValue, forKey: "longSpacePressCursorMovementEnabled")
        }
    }
    
    internal var promptClearEnabled: Bool {
        get {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            return sharedDefaults?.bool(forKey: "promptClearEnabled") ?? false
        }
        set {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            sharedDefaults?.set(newValue, forKey: "promptClearEnabled")
        }
    }
    
    internal var keyClickSoundsEnabled: Bool {
        get {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            return sharedDefaults?.bool(forKey: "keyClickSoundsEnabled") ?? false
        }
        set {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            sharedDefaults?.set(newValue, forKey: "keyClickSoundsEnabled")
        }
    }
    
    internal var hapticFeedbackEnabled: Bool {
        get {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            return sharedDefaults?.bool(forKey: "hapticFeedbackEnabled") ?? false
        }
        set {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            sharedDefaults?.set(newValue, forKey: "hapticFeedbackEnabled")
        }
    }
    
    internal var isAutoCapsEnabled: Bool {
        get {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            return sharedDefaults?.bool(forKey: "isAutoCapsEnabled") ?? false
        }
        set {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            sharedDefaults?.set(newValue, forKey: "isAutoCapsEnabled")
        }
    }
    
    internal var isDoubleSpaceForPeriodEnabled: Bool {
        get {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            return sharedDefaults?.bool(forKey: "isDoubleSpaceForPeriodEnabled") ?? false
        }
        set {
            let sharedDefaults = UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")
            sharedDefaults?.set(newValue, forKey: "isDoubleSpaceForPeriodEnabled")
        }
    }
    
    internal var isAutocorrectEnabled: Bool {
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
