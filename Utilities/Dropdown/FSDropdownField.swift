//
//  FSDropdownField.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct FSDropdownField: View {
    var title: String
    @Binding var isExpanded: Bool
    @Binding var chosenItem: FSDropdownItemModel
    var isHiddenChangeText: Bool = false
    
    var body: some View {
        HStack {
            Button {
                isExpanded.toggle()
            } label: {
                VStack(alignment: .leading) {
                    Divider()
                        .frame(width: UIScreen.screenWidth, height: 1)
                        .background(Color.black)
                    Spacer()
                    if chosenItem.text.isEmpty {
                        Text(title)
                            .font(.montserrat(.medium, size: 14))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                    }
                    Text(chosenItem.text.isEmpty ? "" : chosenItem.text)
                        .font(.montserrat(.medium, size: 14))
                        .foregroundColor(chosenItem.text.isEmpty ? .gray : .black)
                        .padding(.horizontal, 20)
                    Spacer()
                }
                Spacer()
            }
            .frame(height: 46)
            .background(Color.white)
        }
    }
}

struct DGDropdownField_Previews: PreviewProvider {
    static var previews: some View {
        FSDropdownField(
            title: "Title",
            isExpanded: .constant(false),
            chosenItem: .constant(FSDropdownItemModel(icon: "", text: ""))
        )
    }
}
