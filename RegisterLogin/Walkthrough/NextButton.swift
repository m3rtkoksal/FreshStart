//
//  NextButton.swift
//  FreshStart
//
//  Created by Mert Köksal on 13.11.2024.
//

import SwiftUI

struct NextButton: View {
    // MARK: - PROPERTIES
    let action: () -> Void
    let isLastCard: Bool
    // MARK: - BODY
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black.opacity(1), lineWidth: 2)
                    .shadow(radius: 10)
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                Text(isLastCard ? "walkthrough.lets_go".localized() : "walkthrough.next".localized())

                    .font(.montserrat(.semiBold, size: 14))
                    .foregroundColor(.black)
            }
            .frame(width: 110, height: 35)
        }
    }
}
