//
//  DietPreferenceInfoView.swift
//  FreshStart
//
//  Created by Mert Köksal on 24.11.2024.
//

import SwiftUI

struct DietPreferenceInfoView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    var dietPreference: DietPreferenceItem
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.mkPurple)
                .opacity(0.4)
                .frame(width: 80, height: 5)
                .padding(.top, 20)
            VStack(alignment: .leading, spacing: 30) {
                HStack {
                    Text(dietPreference.title.unsafelyUnwrapped)
                        .font(.montserrat(.bold, size: 20))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Image(dietPreference.icon.unsafelyUnwrapped)
                        .resizable()
                        .frame(width: 46, height: 46)
                }
                Text(dietPreference.infoDescription.unsafelyUnwrapped)
                    .font(.montserrat(.medium, size: 14))
                    .fixedSize(horizontal: false, vertical: true)
                Text("You can eat")
                    .foregroundColor(.mkPurple)
                    .underline(true, color: .mkPurple)
                    .font(.montserrat(.bold, size: 20))
                Text(dietPreference.infoCanEat.unsafelyUnwrapped)
                    .font(.montserrat(.medium, size: 14))
                    .fixedSize(horizontal: false, vertical: true)
                Text("You can NOT eat")
                    .foregroundColor(.mkOrange)
                    .underline(true, color: .mkOrange)
                    .font(.montserrat(.bold, size: 20))
                Text(dietPreference.infoCantEat.unsafelyUnwrapped)
                    .font(.montserrat(.medium, size: 14))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
        }
        .padding(.horizontal,20)
    }
}
