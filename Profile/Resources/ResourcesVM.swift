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
    
    func fetchResources() {
        showIndicator = true
        let db = Firestore.firestore()
        
        db.collection("contracts").document("disclaimer").getDocument { snapshot, error in
            self.showIndicator = false
            if let data = snapshot?.data() {
                let rawText = data["text"] as? String ?? "Content not available."
                
                let replacedText = self.applyTextReplacements(to: rawText)
               
                self.text = self.applyBoldFormatting(to: replacedText)
            }
        }
    }
    
    private func applyTextReplacements(to text: String) -> String {
        var modifiedText = text
        
        modifiedText = modifiedText.replacingOccurrences(of: "Disclaimer & Data Privacy", with: "\n\nDisclaimer & Data Privacy\n", options: .literal)
        
        modifiedText = modifiedText.replacingOccurrences(of: "Our Promise to You", with: "\n\nOur Promise to You\n", options: .literal)
        
        modifiedText = modifiedText.replacingOccurrences(of: "Sources and Information Accuracy", with: "\n\nSources and Information Accuracy\n", options: .literal)
        
        modifiedText = modifiedText.replacingOccurrences(of: "How We Use Your Health Data", with: "\n\nHow We Use Your Health Data\n", options: .literal)
        
        modifiedText = modifiedText.replacingOccurrences(of: "Our Commitment to Privacy and Security", with: "\n\nOur Commitment to Privacy and Security\n", options: .literal)
        
        modifiedText = modifiedText.replacingOccurrences(of: "Questions?", with: "\n\nQuestions?\n", options: .literal)
        
        modifiedText = modifiedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return modifiedText
    }
    
    private func applyBoldFormatting(to text: String) -> AttributedString {
        var attributedText = AttributedString(text)
        
        if let range = attributedText.range(of: "Disclaimer & Data Privacy") {
            attributedText[range].font = .boldSystemFont(ofSize: 16)
        }
        
        if let range = attributedText.range(of: "Our Promise to You") {
            attributedText[range].font = .boldSystemFont(ofSize: 16)
        }
        
        if let range = attributedText.range(of: "Sources and Information Accuracy") {
            attributedText[range].font = .boldSystemFont(ofSize: 16)
        }
        
        if let range = attributedText.range(of: "How We Use Your Health Data") {
            attributedText[range].font = .boldSystemFont(ofSize: 16)
        }
        
        if let range = attributedText.range(of: "Our Commitment to Privacy and Security") {
            attributedText[range].font = .boldSystemFont(ofSize: 16)
        }
        
        if let range = attributedText.range(of: "Questions?") {
            attributedText[range].font = .boldSystemFont(ofSize: 16)
        }
        
        return attributedText
    }
}
