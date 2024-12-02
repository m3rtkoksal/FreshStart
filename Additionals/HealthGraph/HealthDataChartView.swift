//
//  HealthDataChartView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Charts
import SwiftUI

struct HealthDataChartView: View {
    @StateObject private var viewModel = HealthDataChartVM()
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @State private var selectedChartType: HealthChartType = .bodyFat

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                VStack(spacing: 10) {
                    TabView(selection: $selectedChartType) {
                        ForEach(HealthChartType.allCases, id: \.self) { chartType in
                            VStack {
                                switch chartType {
                                case .bodyFat:
                                    BodyFatChart()
                                case .leanBodyMass:
                                    LeanBodyMassChart()
                                case .activeEnergy:
                                    ActiveEnergyChart()
                                case .weight:
                                   WeightChart()
                                }
                            }
                            .tag(chartType)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .padding(.horizontal, 33)
                }
                FSProgressBar(progressCount: HealthChartType.allCases.count, currentProgress: selectedChartType.rawValue,color: .mkPurple, dotColor: .mkPurple.opacity(0.5))
                    .frame(width: 100, height: 7)
                    .padding(.bottom, 20)
                    .padding(.top, 10)
            }
            .background(
                Group {
                    ZStack {
                        Rectangle()
                            .strokeBorder(Color.black, lineWidth: 1)
                    }
                }
                    .frame(maxWidth: UIScreen.screenWidth - 40)
            )
        }
       
        .onAppear {
            viewModel.fetchHealthDataEntries()
            viewModel.fetchChartSegments()
        }
        .navigationBarBackButtonHidden()
        .navigationBarItems(
            leading: FreshStartBackButton()
        )
    }
    
    func BodyFatChart() -> some View {
        VStack {
            HStack {
                Circle()
                    .fill(Color.mkOrange)
                    .frame(width: 10, height:  10)
                Text("Body Fat %")
                    .font(.montserrat(.medium, size: 12))
            }
            .padding(.top, 20)
            Chart(viewModel.healthDataEntries) { entry in
                if let bodyFat = entry.bodyFatPercentage {
                    LineMark(
                        x: .value("Date", entry.createdAt?.toDDMMDateFormat() ?? Date().toDDMMDateFormat()),
                        y: .value("Body Fat %", bodyFat * 100)
                    )
                    .foregroundStyle(Color.mkOrange)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom, values: .automatic)
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic)
            }
            .chartYAxisLabel("Body Fat %", position: .top)
            .foregroundColor(.mkPurple)
            .chartXAxisLabel("Date", position: .bottomTrailing)
            .foregroundColor(.mkPurple)
        }
    }

    func LeanBodyMassChart() -> some View {
        VStack {
            HStack {
                Circle()
                    .fill(Color.mkPurple)
                    .frame(width: 10, height:  10)
                Text("Lean Body Mass")
                    .font(.montserrat(.medium, size: 12))
            }
            .padding(.top, 20)
            Chart(viewModel.healthDataEntries) { entry in
                if let leanBodyMass = entry.leanBodyMass {
                    LineMark(
                        x: .value("Date", entry.createdAt?.toDDMMDateFormat() ?? Date().toDDMMDateFormat()),
                        y: .value("Lean Body Mass", leanBodyMass)
                    )
                    .foregroundStyle(Color.mkPurple)
                }
            }
            .chartYAxisLabel("Lean Body Mass")
            .chartXAxisLabel("Date", position: .bottomTrailing)
            .padding(.horizontal)
            .chartXAxis {
                AxisMarks(position: .bottom, values: .automatic)
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic)
            }
        }
    }
    
    func ActiveEnergyChart() -> some View {
        VStack {
            HStack {
                Circle()
                    .fill(Color.mkOrange)
                    .frame(width: 10, height:  10)
                Text("Active Energy")
                    .font(.montserrat(.medium, size: 12))
            } .padding(.top, 20)
            Chart(viewModel.healthDataEntries) { entry in
                if let activeEnergy = entry.activeEnergy {
                    LineMark(
                        x: .value("Date", entry.createdAt?.toDDMMDateFormat() ?? Date().toDDMMDateFormat()),
                        y: .value("Active Energy", activeEnergy)
                    )
                    .foregroundStyle(Color.mkOrange)
                }
            }
            .chartYAxisLabel("Active Energy")
            .chartXAxisLabel("Date", position: .bottomTrailing)
            .padding(.horizontal)
            .chartXAxis {
                AxisMarks(position: .bottom, values: .automatic)
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic)
            }
        }
    }
    func WeightChart() -> some View {
        VStack {
            HStack {
                Circle()
                    .fill(Color.mkPurple)
                    .frame(width: 10, height:  10)
                Text("Weight")
                    .font(.montserrat(.medium, size: 12))
            } .padding(.top, 20)
            Chart(viewModel.healthDataEntries) { entry in
                if let weight = entry.weight {
                    LineMark(
                        x: .value("Date", entry.createdAt?.toDDMMDateFormat() ?? Date().toDDMMDateFormat()),
                        y: .value("Weight", weight)
                    )
                    .foregroundStyle(Color.mkPurple)
                }
            }
            .chartYAxisLabel("Weight")
            .chartXAxisLabel("Date", position: .bottomTrailing)
            .padding(.horizontal)
            .chartXAxis {
                AxisMarks(position: .bottom, values: .automatic)
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic)
            }
        }
    }
}
