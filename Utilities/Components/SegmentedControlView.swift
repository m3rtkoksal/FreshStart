//
//  SegmentedControlView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct SegmentTitle {
    let title: String
}

struct SegmentedControlView: View {
    @Binding var selectedIndex: Int
    var segmentNames: [SegmentTitle]
    @State private var fontSize: CGFloat = 14
    private var segmentWidth: CGFloat {
        UIScreen.screenWidth * 0.85 / CGFloat(segmentNames.count)
    }
    
    private var totalWidth: CGFloat {
        segmentWidth * CGFloat(segmentNames.count)
    }
    private func adjustFontSize() -> CGFloat {
        let longestText = segmentNames.max { $0.title.count < $1.title.count }
        let textWidth = longestText?.title.width(using: .montserrat(.semiBold, size: fontSize)) ?? 0
        
        if textWidth > segmentWidth {
            return 10
        } else {
            return fontSize
        }
    }
    
    var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.mkPurple.opacity(0.5))
                    .frame(width: totalWidth, height: 40)
                HStack(spacing: 0) {
                    ForEach(0..<segmentNames.count, id: \.self) { index in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedIndex = index
                            }
                        }) {
                            Text(segmentNames[index].title)
                                .font(.montserrat(.semiBold, size: adjustFontSize()))
                                .lineLimit(1)
                                .frame(width: segmentWidth, height: 40)
                                .foregroundColor(.white)
                                .background(selectedIndex == index ? Color.mkPurple : Color.clear)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: selectedIndex == index ? 30 : 0,
                                        style: .continuous
                                    )
                                )
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
    }
}

struct SegmentedControlView_Previews: PreviewProvider {
    @State static var selectedIndex = 0
    
    static var previews: some View {
        SegmentedControlView(
            selectedIndex: $selectedIndex,
            segmentNames: [
                SegmentTitle(title: "Male"),
                SegmentTitle(title: "Female")
            ]
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
