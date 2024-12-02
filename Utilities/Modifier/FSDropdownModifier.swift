//
//  FSDropdownModifier.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct FSDropdownModifier: ViewModifier {
    @Binding var itemList: [FSDropdownItemModel]
    @Binding var isExpanded: Bool
    @Binding var choosenItem: FSDropdownItemModel
    var buttonAction: (() -> Void)?
    var selectedLengthUnit: LengthUnit = .cm
    var selectedWeightUnit: WeightUnit = .kg
    
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
                    FSDropdown(
                        itemList: $itemList,
                        chosenItem: $choosenItem,
                        isExpanded: $isExpanded
                    )
                }
                .ignoresSafeArea()
                .transition(.move(edge: .bottom))
            }
        }
    }
}

extension View {
    func fsDropdownModifier(
        itemList: Binding<[FSDropdownItemModel]>,
        isExpanded: Binding<Bool>,
        choosenItem: Binding<FSDropdownItemModel>,
        buttonAction: (() -> Void)? = nil
    ) -> some View {
        modifier(FSDropdownModifier(
            itemList: itemList,
            isExpanded: isExpanded,
            choosenItem: choosenItem
        ))
    }
}
