//
//  ChangeLanguageView.swift
//  FreshStart
//
//  Created by Mert Köksal on 13.12.2024.
//

import SwiftUI
import FlagKit

struct ChangeLanguageView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChangeLanguageVM()
    @State private var selectedLanguage: LanguageType?
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
                           background: .solidWhite,
                           showIndicator: $viewModel.showIndicator) {
            VStack {
                FSTitle(
                    title: "profile.change_language".localized(),
                    subtitle: "")
                
                ScrollView {
                    ForEach(LanguageType.allCases, id: \.self) { language in
                        LanguageElement(language: language,
                                        isSelected: language == selectedLanguage)
                        .padding(.top)
                        .onTapGesture {
                            selectedLanguage = language
                        }
                    }
                }
                
                FreshStartButton(text: "save".localized(), backgroundColor: .mkOrange) {
                    if let selectedLanguage = selectedLanguage {
                        LanguageHelper.shared.setLanguage(selectedLanguage)
                        self.dismiss()
                    }
                }
            }
        }
                           .navigationBarTitle("")
                           .navigationBarBackButtonHidden()
                           .navigationBarItems(
                            leading: FreshStartBackButton()
                           )
                           .onAppear {
                               // Check if a selected language exists in UserDefaults
                               if let savedLanguageRawValue = UserDefaults.standard.string(forKey: "selectedLanguage"),
                                  let savedLanguage = LanguageType(rawValue: savedLanguageRawValue) {
                                   // If there's a saved language, use it
                                   selectedLanguage = savedLanguage
                                   print("Using saved language: \(savedLanguage.rawValue)")
                               } else {
                                   // Get the first language code from the device's preferred languages
                                   if let deviceLanguageCode = Locale.preferredLanguages.first?.prefix(2).description {
                                       // Try to map the language code to the LanguageType enum
                                       switch deviceLanguageCode.lowercased() {
                                       case "tr":
                                           selectedLanguage = .TR
                                       case "en":
                                           selectedLanguage = .EN
                                       case "uk":
                                           selectedLanguage = .UK
                                       default:
                                           // Fallback to a default language (English) if no match
                                           selectedLanguage = .EN
                                       }
                                       print("Using device language: \(String(describing: selectedLanguage?.rawValue))")
                                   }
                               }
                           }
    }
}
