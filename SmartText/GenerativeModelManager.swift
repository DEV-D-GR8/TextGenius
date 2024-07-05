//
//  GenerativeModelManager.swift
//  SmartText
//
//  Created by Dev Asheesh Chopra on 28/06/24.
//

import Foundation
import GoogleGenerativeAI

class GenerativeModelManager {
    private let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)

    
    enum APIKey {
        static var `default`: String {
            guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: filePath),
                  let value = plist.object(forKey: "GOOGLE_API_KEY") as? String, !value.starts(with: "_") else {
                fatalError("Invalid API Key configuration.")
            }
            return value
        }
    }
    
    
    func generateContent(from prompt: String, completion: @escaping (String) -> Void) {
        Task {
            do {
                let response = try await model.generateContent(prompt)
                if let text = response.text {
                    DispatchQueue.main.async {
                        completion(text)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion("Gemini API is not responding.")
                }
            }
        }
    }
}
