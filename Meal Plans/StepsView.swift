//
//  StepsView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import HealthKit

struct StepsView: View {
    private var healthStore = HealthKitManager()
    @State private var stepsToday: Int = 0
    @State private var dailyStepGoal: Double = 8000
    private var circleSize: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        // Adjust based on device height
        if screenHeight <= 812 { // Small screens (e.g., iPhone 13 Mini)
            return screenWidth * 0.34
        } else { // Larger screens
            return screenWidth * 0.36
        }
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 2) {
                Text("\(Int(dailyStepGoal)) steps")
                    .font(.montserrat(.bold, size: 14))
                    .foregroundColor(.mkOrange)
                Text("per day")
                    .font(.montserrat(.semiBold, size: 14))
                    .foregroundColor(.black)
            }
                .padding(.bottom, 10)
            
            ZStack {
                Track(size: circleSize)
                Label(steps: stepsToday)
                Outline(steps: stepsToday, size: circleSize)
            }
            
        }
        .padding(.leading, -10)
        .onAppear {
            healthStore.requestAuthorization { success in
                if success {
                    healthStore.calculateSteps { statisticsCollection in
                        if let statisticsCollection = statisticsCollection {
                            updateUIFromStatistics(statisticsCollection)
                            ProfileManager.shared.setUserSteps(stepsToday)
                        }
                    }
                } else {
                    print("Authorization failed")
                }
            }
        }
    }
    private func updateUIFromStatistics(_ statisticsCollection: HKStatisticsCollection) {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let now = Date()
        
        statisticsCollection.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in
            if let quantity = statistics.sumQuantity() {
                let steps = quantity.doubleValue(for: .count())
                DispatchQueue.main.async {
                    self.stepsToday = Int(steps)
                }
            }
        }
    }
}
struct Label: View {
    var steps: Int
    var body : some View {
        ZStack {
            VStack {
                Text(String(steps))
                    .font(.montserrat(.semiBold, size: 18))
                    .foregroundColor(.black)
                Text("Steps")
                    .font(.montserrat(.medium, size: 10))
                    .foregroundColor(.black)
                    .underline()
                Image("footsteps")
                    .resizable()
                    .frame(width: 19.5, height: 22.5)
            }
        }
    }
}

struct Outline: View {
    var steps: Int
    var size: CGFloat
    var percentage: CGFloat = 8000
    var colors : [Color] = [Color.mkOrange]
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.clear)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .trim(from: 0, to: CGFloat(steps) / percentage )
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .fill(AngularGradient(gradient: .init(colors: colors), center: .center, startAngle: .zero, endAngle: .init(degrees: 360)))
                        .rotationEffect(Angle(degrees: 270.0))
                )
                .animation(
                    .spring(response: 2.0, dampingFraction: 1.0, blendDuration: 1.0),
                    value: steps
                )
        }
    }
}

struct Track: View {
    var size: CGFloat
    var colors: [Color] = [Color.black]
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.clear)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 20))
                        .fill(AngularGradient(gradient: .init(colors: colors), center: .center))
                )
        }
    }
}

#Preview {
    StepsView()
}
