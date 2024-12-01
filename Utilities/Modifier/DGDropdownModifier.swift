//
//  DGDropdownModifier.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct DGDropdownModifier: ViewModifier {
    @Binding var itemList: [DGDropdownItemModel]
    @Binding var isExpanded: Bool
    @Binding var choosenItem: DGDropdownItemModel
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
                    DGDropdown(
                        itemList: $itemList,
                        choosenItem: $choosenItem,
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
    func dgDropdownModifier(
        itemList: Binding<[DGDropdownItemModel]>,
        isExpanded: Binding<Bool>,
        choosenItem: Binding<DGDropdownItemModel>,
        buttonAction: (() -> Void)? = nil
    ) -> some View {
        modifier(DGDropdownModifier(
            itemList: itemList,
            isExpanded: isExpanded,
            choosenItem: choosenItem
        ))
    }
}
