//
//  DGTitle.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct DGTitle: View {
    
    var title: String
    var subtitle: String
    var bottomPadding: CGFloat?
    var color: Color = .black

    var body: some View {
       VStack(spacing: 0){
            HStack {
                Text(title)
                    .foregroundColor(color)
                    .font(.montserrat(.bold, size: 24))
                Spacer()
            }
            .padding(.top, 12)
            .padding(.trailing,33)
            HStack {
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .foregroundColor(color)
                        .font(.montserrat(.medium, size: 14))
                        .multilineTextAlignment(.leading)
                        .padding(.top,10)
                    Spacer()
                }
            }
            .padding(.bottom, bottomPadding ?? 40)
            .padding(.trailing, 28)
        }
        .padding(.leading, 20)
    }
}
