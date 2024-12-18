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
                Text("body_fat_percentage".localized())
                    .font(.montserrat(.medium, size: 12))
            }
            .padding(.top, 20)
            Chart(viewModel.healthDataEntries) { entry in
                if let bodyFat = entry.bodyFatPercentage {
                    LineMark(
                        x: .value("date".localized(), entry.createdAt?.toDDMMDateFormat() ?? Date().toDDMMDateFormat()),
                        y: .value("body_fat_percentage".localized(), bodyFat * 100)
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
            .chartYAxisLabel("body_fat_percentage".localized(), position: .top)
            .foregroundColor(.mkPurple)
            .chartXAxisLabel("date".localized(), position: .bottomTrailing)
            .foregroundColor(.mkPurple)
        }
    }

    func LeanBodyMassChart() -> some View {
        VStack {
            HStack {
                Circle()
                    .fill(Color.mkPurple)
                    .frame(width: 10, height:  10)
                Text("lean_body_mass".localized())
                    .font(.montserrat(.medium, size: 12))
            }
            .padding(.top, 20)
            Chart(viewModel.healthDataEntries) { entry in
                if let leanBodyMass = entry.leanBodyMass {
                    LineMark(
                        x: .value("date".localized(), entry.createdAt?.toDDMMDateFormat() ?? Date().toDDMMDateFormat()),
                        y: .value("lean_body_mass".localized(), leanBodyMass)
                    )
                    .foregroundStyle(Color.mkPurple)
                }
            }
            .chartYAxisLabel("lean_body_mass".localized())
            .chartXAxisLabel("date".localized(), position: .bottomTrailing)
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
                Text("active_energy".localized())
                    .font(.montserrat(.medium, size: 12))
            } .padding(.top, 20)
            Chart(viewModel.healthDataEntries) { entry in
                if let activeEnergy = entry.activeEnergy {
                    LineMark(
                        x: .value("date".localized(), entry.createdAt?.toDDMMDateFormat() ?? Date().toDDMMDateFormat()),
                        y: .value("active_energy".localized(), activeEnergy)
                    )
                    .foregroundStyle(Color.mkOrange)
                }
            }
            .chartYAxisLabel("active_energy".localized())
            .chartXAxisLabel("date".localized(), position: .bottomTrailing)
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
                Text("weight".localized())
                    .font(.montserrat(.medium, size: 12))
            } .padding(.top, 20)
            Chart(viewModel.healthDataEntries) { entry in
                if let weight = entry.weight {
                    LineMark(
                        x: .value("date".localized(), entry.createdAt?.toDDMMDateFormat() ?? Date().toDDMMDateFormat()),
                        y: .value("weight".localized(), weight)
                    )
                    .foregroundStyle(Color.mkPurple)
                }
            }
            .chartYAxisLabel("weight".localized())
            .chartXAxisLabel("date".localized(), position: .bottomTrailing)
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
