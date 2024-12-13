//
//  ChangeLanguageVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 13.12.2024.
//

import Foundation

class ChangeLanguageVM: BaseViewModel {
    @Published var language: String = Locale.current.language.languageCode?.identifier ?? "en"
    @Published var selectedLanguage = LanguageType.EN
}
