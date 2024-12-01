//
//  DGProfileElement.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct DGProfileElement: View {
    let title: String
    let description: String
    let buttonIcon: String?
    let isLastElement: Bool
    let buttonAction: () -> Void

    init(
        title: String,
        description: String,
        buttonIcon: String? = nil,
        isLastElement: Bool = false,
        buttonAction: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.buttonIcon = buttonIcon
        self.isLastElement = isLastElement
        self.buttonAction = buttonAction
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: buttonAction) {
                HStack {
                    Text(title)
                        .font(.montserrat(.regular, size: 14))
                        .foregroundColor(.black)
                    Spacer()
                    
                    Text(description)
                        .font(.montserrat(.medium, size: 14))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    if let icon = buttonIcon {
                        Image(systemName: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                            .foregroundColor(.mkPurple.opacity(0.5))
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
            }
            if !isLastElement {
                Divider()
                    .padding(.top, 8)
            }
        }
    }
}

struct DGProfileElement_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DGProfileElement(
                title: "Müşteri ID",
                description: "The White House The White House",
                buttonIcon: "pasteGoIcon",
                buttonAction: { }
            )
            
            DGProfileElement(
                title: "Müşteri ID",
                description: "The White House",
                buttonIcon: "pasteGoIcon",
                buttonAction: { }
            )
            
            DGProfileElement(
                title: "Müşteri ID",
                description: "The White House",
                buttonIcon: nil,
                buttonAction: { }
            )
        }
    }
}
