//
//  DietPreferenceElement.swift
//  FreshStart
//
//  Created by Mert Köksal on 18.11.2024.
//


import SwiftUI

struct DietPreferenceElement: View {
    var dietPreference: DietPreferenceItem
    var isSelected: Bool
    @State private var showInfoView = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(isSelected ? Color.mkPurple.opacity(0.5) : Color.white)
                .frame(width: UIScreen.screenWidth + 3, height: 80)
            Rectangle()
                .strokeBorder(Color.black, lineWidth: 1)
                .frame(width: UIScreen.screenWidth + 3, height: 80)
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(dietPreference.title.unsafelyUnwrapped)
                            .foregroundStyle(.black)
                            .font(.montserrat(.semiBold, size: 20))
                        HStack {
                            Text(dietPreference.description.unsafelyUnwrapped)
                                .foregroundStyle(Color.otherGray)
                                .font(.montserrat(.medium, size: 10))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                            Spacer()
                        }
                    }
                    .padding(.leading, 40)
                    Spacer()
                    Button(action: {
                        showInfoView.toggle()
                    }) {
                        Image("info.icon")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .padding(.trailing, 40)
                }
                .frame(width: UIScreen.screenWidth)
            }
            .sheet(isPresented: $showInfoView) {
                DietPreferenceInfoView(dietPreference: dietPreference)
                    .presentationDetents([.fraction(0.6)])
            }
        }
    }
}
