//
//  DGDivider.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct FreshStartDivider: View {
    @State var title: String
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 0)
                .frame(height:1)
                .frame(width: UIScreen.screenWidth / 3.5)
                .foregroundColor(.black)
            Text(title)
                .font(.montserrat(.medium, size: 12))
                .foregroundColor(.black)
                .frame(width: UIScreen.screenWidth / 4)
            RoundedRectangle(cornerRadius: 0)
                .frame(height:1)
                .frame(width: UIScreen.screenWidth / 3.5)
                .foregroundColor(.black)
               
        }
    }
}

#Preview {
    FreshStartDivider(title: "Or Login with")
}
