//
//  FSDropdownElement.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct FSDropdownElement: View {
    var item: FSDropdownItemModel
    var isChosen: Bool
    
    var body: some View {
        HStack {
            Text(item.text)
                .font(.montserrat(.regular, size: 12))
                .foregroundColor(isChosen ? .black : .gray)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.solidWhite)
        .cornerRadius(8) // Optionally add rounded corners for better UI
    }
}

struct DGDropdownElement_Previews: PreviewProvider {
    static var previews: some View {
        FSDropdownElement(item: FSDropdownItemModel(icon: "", text: "Lorem Ipsum"), isChosen: false)
    }
}
