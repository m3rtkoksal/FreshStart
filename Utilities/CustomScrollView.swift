//
//  CustomScrollView.swift
//  FreshStart
//
//  Created by Mert Köksal on 16.12.2024.
//

import SwiftUI

struct CustomScrollView<Content: View>: View {
    @Binding var secondCircleFilled: Bool
    @State private var scrollOffset: CGFloat = 0 // Tracks current scroll position
    @State private var dragStartOffset: CGFloat = 0 // Tracks offset at drag start
    let content: Content
    let contentWidth: CGFloat
    let visibleWidth: CGFloat
    
    init(
        secondCircleFilled: Binding<Bool>,
        contentWidth: CGFloat,
        visibleWidth: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self._secondCircleFilled = secondCircleFilled
        self.content = content()
        self.contentWidth = contentWidth
        self.visibleWidth = visibleWidth
    }
    
    var body: some View {
        HStack {
            content
                .offset(x: adjustedScrollOffset()) // Apply adjusted scroll offset
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Update position while dragging
                            let newOffset = dragStartOffset + value.translation.width
                            scrollOffset = limitOffset(newOffset)
                        }
                        .onEnded { value in
                            // Save position after drag ends
                            dragStartOffset = scrollOffset
                            
                            // Detect swipe direction and update second circle state
                            if value.translation.width > 50 {
                                secondCircleFilled = false // Right swipe
                                print("Right swipe detected: second circle unfilled")
                            } else if value.translation.width < -50 {
                                secondCircleFilled = true // Left swipe
                                print("Left swipe detected: second circle filled")
                            }
                        }
                )
        }
        .frame(width: visibleWidth, alignment: .leading) // Visible area
        .clipped() // Ensures content outside the bounds is not visible
    }
    
    // Limit scrolling bounds to prevent over-scrolling
    private func limitOffset(_ offset: CGFloat) -> CGFloat {
        let maxOffset = 0.0 // Adjust for padding within the rounded rectangle
        let minOffset = -(contentWidth - visibleWidth) - 20 // Ensure full scroll visibility
        return min(max(offset, minOffset), maxOffset)
    }
    
    // Adjust the initial scroll offset to center content if it's smaller than visibleWidth
    private func adjustedScrollOffset() -> CGFloat {
        if contentWidth < visibleWidth {
            return (visibleWidth - contentWidth) / 2
        } else {
            return scrollOffset
        }
    }
}
