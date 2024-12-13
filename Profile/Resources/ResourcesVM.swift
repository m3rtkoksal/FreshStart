//
//  ResourcesVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import FirebaseAuth
import SwiftUI
import FirebaseFirestore

class ResourcesVM: BaseViewModel {
    @Published var text: AttributedString = AttributedString("")
    @Published var language: String = Locale.current.languageCode ?? "en" // Default to device language (English or Turkish)
    
    func fetchResources() {
        showIndicator = true
        let db = Firestore.firestore()
        
        db.collection("contracts").document("disclaimer").getDocument { snapshot, error in
            self.showIndicator = false
            if let data = snapshot?.data() {
                // Fetch the correct language version (either "en" or "tr")
                let rawText = data[self.language] as? String ?? "Content not available."
                
                let replacedText = self.applyTextReplacements(to: rawText)
                self.text = self.applyBoldFormatting(to: replacedText)
            }
        }
    }
    
    private func applyTextReplacements(to text: String) -> String {
        var modifiedText = text
        
        // Replacing headings with localized text
        modifiedText = modifiedText.replacingOccurrences(of: "Disclaimer & Data Privacy".localized(), with: "\n\n\( "Disclaimer & Data Privacy".localized())\n", options: .literal)
        modifiedText = modifiedText.replacingOccurrences(of: "Our Promise to You".localized(), with: "\n\n\( "Our Promise to You".localized())\n", options: .literal)
        modifiedText = modifiedText.replacingOccurrences(of: "Sources and Information Accuracy".localized(), with: "\n\n\( "Sources and Information Accuracy".localized())\n", options: .literal)
        modifiedText = modifiedText.replacingOccurrences(of: "How We Use Your Health Data".localized(), with: "\n\n\( "How We Use Your Health Data".localized())\n", options: .literal)
        modifiedText = modifiedText.replacingOccurrences(of: "Our Commitment to Privacy and Security".localized(), with: "\n\n\( "Our Commitment to Privacy and Security".localized())\n", options: .literal)
        modifiedText = modifiedText.replacingOccurrences(of: "Questions?".localized(), with: "\n\n\( "Questions?".localized())\n", options: .literal)
        
        modifiedText = modifiedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return modifiedText
    }
    
    private func applyBoldFormatting(to text: String) -> AttributedString {
        var attributedText = AttributedString(text)
        
        // Localized bold headings
        let boldHeadings = [
            "Disclaimer & Data Privacy",
            "Our Promise to You",
            "Sources and Information Accuracy",
            "How We Use Your Health Data",
            "Our Commitment to Privacy and Security",
            "Questions?"
        ]
        
        // Iterate through each heading and apply bold formatting
        for heading in boldHeadings {
            let localizedHeading = heading.localized() // Fetch the localized string for the heading
            if let range = attributedText.range(of: localizedHeading) {
                attributedText[range].font = .boldSystemFont(ofSize: 16)
            }
        }
        
        return attributedText
    }
    
    // Function to change the language and refetch the resources
    func changeLanguage(to newLanguage: String) {
        self.language = newLanguage
        fetchResources()
    }
}
