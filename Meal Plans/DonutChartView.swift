//
//  DonutChartView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct DonutChartView: View {
    var totalNutrients: TotalNutrients
    @State private var animatedProgress: CGFloat = 0
    
    var body: some View {
        let nutrients: [(String, Int, Color)] = [
            ("Protein", totalNutrients.protein, Color.black),
            ("Carbohydrate", totalNutrients.carbohydrate, Color.mkOrange),
            ("Fat", totalNutrients.fat, Color.mkPurple)
        ]
        
        let totalValue = nutrients.map { $0.1 }.reduce(0, +)
        let sliceAngles = computeSliceAngles(nutrients: nutrients, totalValue: totalValue)
        GeometryReader { geometry in
            let size = min(geometry.size.width * 1.1, geometry.size.height * 1.1)
            let center = CGPoint(x: size / 2, y: size / 2)
            let outerRadius = size * 0.45
            let innerRadius = outerRadius * 0.6
            
            VStack {
                HStack(spacing: 2) {
                    Text("\(totalNutrients.kcal) kcal")
                        .font(.montserrat(.bold, size: 14))
                        .foregroundColor(.mkOrange)
                    Text("per day")
                        .font(.montserrat(.semiBold, size: 14))
                        .foregroundColor(.black)
                }
                .padding(.top, 4)
                
                ZStack {
                    // Draw slices
                    ForEach(0..<nutrients.count, id: \.self) { index in
                        let slice = sliceAngles[index]
                        
                        Path { path in
                            // Outer arc
                            path.addArc(center: center,
                                        radius: outerRadius,
                                        startAngle: slice.startAngle,
                                        endAngle: slice.endAngle,
                                        clockwise: false)
                            
                            // Line to inner arc
                            let innerEndX = center.x + innerRadius * cos(slice.endAngle.radians)
                            let innerEndY = center.y + innerRadius * sin(slice.endAngle.radians)
                            path.addLine(to: CGPoint(x: innerEndX, y: innerEndY))
                            
                            // Inner arc
                            path.addArc(center: center,
                                        radius: innerRadius,
                                        startAngle: slice.endAngle,
                                        endAngle: slice.startAngle,
                                        clockwise: true)
                            
                            path.addLine(to: CGPoint(x: center.x + innerRadius * cos(slice.startAngle.radians),
                                                     y: center.y + innerRadius * sin(slice.startAngle.radians)))
                        }
                        .fill(nutrients[index].2)
                        .animation(.easeOut(duration: 1.5), value: animatedProgress)
                        let labelAngle = (slice.startAngle.radians + slice.endAngle.radians) / 2
                        let labelRadius = (outerRadius + innerRadius) / 2
                        let labelPosition = CGPoint(x: center.x + labelRadius * cos(labelAngle),
                                                    y: center.y + labelRadius * sin(labelAngle))
                        if animatedProgress >= 1.0 {
                            Text("\(nutrients[index].1) gr")
                                .font(.system(size: size * 0.04, weight: .bold))
                                .foregroundColor(.white)
                                .position(labelPosition)
                        }
                    }
                    
                    // Add centered text
                    Text("Nutrients")
                        .font(.system(size: size * 0.06, weight: .bold))
                        .foregroundColor(.black)
                        .underline()
                        .position(x: center.x, y: center.y)
                }
                .frame(width: size, height: size)
                .padding(.top, -10)
                .onAppear {
                    withAnimation {
                        animatedProgress = 1.0
                    }
                }
            }
            .offset(y: -geometry.size.height * 0.06)
            
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(width: UIScreen.screenWidth / 2.5)
    }
    
    // Helper method to precompute angles
    private func computeSliceAngles(nutrients: [(String, Int, Color)], totalValue: Int) -> [SliceAngle] {
        var startAngle = Angle(degrees: -90)
        return nutrients.map { nutrient in
            let proportion = Double(nutrient.1) / Double(totalValue)
            let endAngle = startAngle + Angle(degrees: proportion * 360.0)
            let slice = SliceAngle(startAngle: startAngle, endAngle: endAngle)
            startAngle = endAngle
            return slice
        }
    }
    
    struct SliceAngle {
        let startAngle: Angle
        let endAngle: Angle
    }
}

struct NutrientChartText: View {
    var color: Color
    var text: String
    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .frame(width: 10, height: 10)
                .foregroundColor(color)
            Text(text)
                .font(.montserrat(.medium, size: 8))
                .foregroundColor(.black)
        }
    }
}
