//
//  OpenAIRequestHelper.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation

class OpenAIRequestHelper {
    static func prepareOpenAIRequest(prompt: String) -> URLRequest? {
        let openAIURL = URL(string: "https://api.openai.com/v1/chat/completions")
        let apiKey = KeychainManager.shared.getStringFromKeychain(forKey: .openAIKey)
        guard let url = openAIURL else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let httpBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 4096,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: httpBody, options: .prettyPrinted)
        } catch {
            print("Error serializing JSON: \(error)")
            return nil
        }
        
        return request
    }
}
