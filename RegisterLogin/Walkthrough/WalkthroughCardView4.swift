//
//  WalkthroughCardView3 2.swift
//  FreshStart
//
//  Created by Mert Köksal on 22.11.2024.
//


import SwiftUI

struct WalkthroughCardView4: View {
    // MARK: - PROPERTIES
    let walkthrough: Walkthrough
    let onNext: () -> Void
    let isLastCard: Bool
    let walkthrough4ListData: [Walkthrough4Item] = [
        Walkthrough4Item(text: "We use AI and science to help you see real results.", image: "AI"),
        Walkthrough4Item(text: "You will get perfectly personalized Diet Plan tailored to your unique preferences, dietary restrictions and lifestyle goals.", image: "Notebook"),
        Walkthrough4Item(text: "To accurately set your goals, we’d like to know a bit more about you.", image: "VectorHuman")
    ]
    
    // MARK: - BODY
    var body: some View {
        VStack(alignment: .leading) {
            Text(walkthrough.title)
                .foregroundColor(Color.white)
                .font(.montserrat(.medium, size: 40))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(.leading, 20)
                .lineSpacing(10)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                VStack(alignment: .leading, spacing: 30) {
                    ForEach(walkthrough4ListData.indices, id: \.self) { index in
                        Walkthrough4ListElement(text: walkthrough4ListData[index].text, icon: walkthrough4ListData[index].image)
                    }
                }
                .frame(maxWidth: UIScreen.screenWidth * 0.9, alignment: .leading)
                Spacer()
            }
            .padding(.top,40)
            DGButton(text: "Let's go", backgroundColor: .mkOrange, textColor: .black) {
                onNext()
            }
            .padding(.top,50)
            .padding(.leading, 46)
            Spacer()
        }
    }
}

struct Walkthrough4Item {
    let text: String
    let image: String
}

struct Walkthrough4ListElement: View {
    var text: String
    var icon: String
    
    var body: some View {
        HStack {
           Image(icon)
                .resizable()
                .frame(width: 80, height: 100)
            Text(text)
                .font(.montserrat(.medium, size: 20))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 20)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
