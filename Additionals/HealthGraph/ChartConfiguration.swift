//
//  ChartConfiguration.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import Charts

struct ChartConfiguration {
    let chartType: HealthChartType
    let title: String
    let color: Color
    let yAxisLabel: String
    let valueExtractor: ([HealthData]) -> [(x: Date, y: Double)]?
}
