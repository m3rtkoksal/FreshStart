//
//  FreshStartAlert.swift
//  FreshStart
//
//  Created by Mert Köksal on 3.12.2024.
//

import SwiftUI

struct FreshStartAlertView: View {
    let title: String
    let message: String
    let confirmButtonText: String
    let cancelButtonText: String?
    let confirmAction: () -> Void
    let cancelAction: (() -> Void)?

    var body: some View {
        ZStack {
            BackgroundBlurView(style: .dark)
                .edgesIgnoringSafeArea(.all)
            
            // Alert content
            VStack(spacing: 20) {
                Text(title)
                    .font(.montserrat(.bold, size: 18))
                    .foregroundColor(.white)
                    .padding(.top)
                
                Text(message)
                    .font(.montserrat(.medium, size: 13))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    if let cancelButtonText = cancelButtonText, let cancelAction = cancelAction {
                        Button(action: cancelAction) {
                            Text(cancelButtonText)
                                .foregroundColor(.black)
                                .font(.montserrat(.bold, size: 18))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.mkPurple.opacity(0.5))
                                .cornerRadius(38)
                        }
                    }
                    Button(action: confirmAction) {
                        Text(confirmButtonText)
                            .font(.montserrat(.bold, size: 18))
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.mkOrange)
                            .cornerRadius(38)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding()
            .background(Color.black)
            .cornerRadius(20)
            .shadow(radius: 10)
            .frame(width: UIScreen.main.bounds.width * 0.85)
        }
    }
}

#Preview {
    FreshStartAlertView(title: "Confirm Diet Plan Change", message: "Are you sure you want to change your default diet plan?", confirmButtonText: "Change", cancelButtonText: "Cancel", confirmAction: {}, cancelAction: {})
}
