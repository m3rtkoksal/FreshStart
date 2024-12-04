//
//  WeightPickerView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct WeightPickerView: View {
    @StateObject private var viewModel = DetailsAboutMeVM()
    @Binding var weightOptions: [FSDropdownItemModel]
    @Binding var selectedUnit: WeightUnit
    @Binding var selectedItem: FSDropdownItemModel
    @Binding var isExpanded: Bool
    
    let units: [WeightUnit] = [.kg, .lbs]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: {
                    // Done action
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image("done-filled")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading, 40)
                }
                .padding()
            }
            // Unit Buttons
            HStack {
                ForEach(units, id: \.self) { unit in
                    Button(action: {
                        selectedUnit = unit
                        viewModel.loadWeightItems(for: unit)
                        // Safely select the first item in lengthOptions if available
                        if !weightOptions.isEmpty {
                            selectedItem = weightOptions[0]
                        }
                        isExpanded = true
                    }) {
                        Text(unit.rawValue)
                            .padding()
                            .frame(width: 80)
                            .background(selectedUnit == unit ? Color.mkOrange : Color.white)
                            .foregroundColor(selectedUnit == unit ? Color.black : Color.progressBarPassive)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedUnit == unit ? Color.black : Color.progressBarPassive, lineWidth: 1)
                            )
                    }
                }
            }
            
            // Picker for selecting height
            if isExpanded {
                VStack {
                    Picker("", selection: $selectedItem) {
                        ForEach(weightOptions, id: \.self) { item in
                            Text(item.text).tag(item)
                                .font(.montserrat(.medium, size: 17))
                                .foregroundColor(.black)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 200)
                    .transition(.opacity)
                    .animation(.easeInOut, value: isExpanded)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
