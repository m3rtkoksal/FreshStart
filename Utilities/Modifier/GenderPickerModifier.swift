//
//  GenderPickerModifier.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct GenderPickerModifier: ViewModifier {
    @Binding var isExpanded: Bool
    @Binding var genderOptions: [FSDropdownItemModel]
    @Binding var selectedItem: FSDropdownItemModel
    var buttonAction: (() -> Void)?
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isExpanded)
            
            if isExpanded {
                BackgroundBlurView(style: .dark)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isExpanded = false
                        }
                    }
            }
            
            if isExpanded {
                VStack {
                    Spacer()
                    GenderPickerView(
                        genderOptions: $genderOptions,
                        selectedItem: $selectedItem,
                        isExpanded: $isExpanded)
                    .frame(width: UIScreen.main.bounds.width)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .transition(.move(edge: .bottom))
                    .offset(y: 30)
                }
                .ignoresSafeArea()
            }
        }
    }
}

extension View {
    func genderPickerModifier(
        genderOptions: Binding<[FSDropdownItemModel]>,
        isExpanded: Binding<Bool>,
        selectedItem: Binding<FSDropdownItemModel>,
        buttonAction: (() -> Void)? = nil
    ) -> some View {
        modifier(GenderPickerModifier(
            isExpanded: isExpanded,
            genderOptions: genderOptions,
            selectedItem: selectedItem,
            buttonAction: buttonAction
        ))
    }
}
