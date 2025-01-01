import SwiftUI
import DGCharts

struct BarChartWrapper: UIViewRepresentable {
    var totalLifted: Double
    var daysIntoYear: Int
    
    func makeUIView(context: Context) -> BarChartView {
        let barChart = BarChartView()
        barChart.data = generateChartData()
        barChart.animate(yAxisDuration: 1.5)
        barChart.rightAxis.enabled = false // Disable the right axis
        barChart.leftAxis.axisMinimum = 0 // Start y-axis at 0
        barChart.leftAxis.axisMaximum = 100 // Cap y-axis at 100%
        barChart.xAxis.drawLabelsEnabled = true // Enable x-axis labels
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Total Lifted", "Days Into Year"])
        barChart.xAxis.granularity = 1
        barChart.legend.enabled = false // Disable the legend
        barChart.drawValueAboveBarEnabled = true // Show values above bars
        return barChart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        uiView.data = generateChartData()
    }
    
    private func generateChartData() -> BarChartData {
        // Calculate percentages
        let totalLiftedPercentage = Double(round((totalLifted / 15000000.0) * 10000) / 100)
        let daysIntoYearPercentage = Double(round((Double(daysIntoYear) / 365.0) * 10000) / 100)
        
        // Bar chart entries
        let entries = [
            BarChartDataEntry(x: 0, y: totalLiftedPercentage),
            BarChartDataEntry(x: 1, y: daysIntoYearPercentage)
        ]
        
        // Bar chart dataset
        let dataSet = BarChartDataSet(entries: entries, label: "")
        dataSet.colors = [UIColor.yellow, UIColor.red]
        dataSet.valueTextColor = .black
        dataSet.valueFont = .systemFont(ofSize: 12, weight: .bold)
        dataSet.drawValuesEnabled = true
        
        // Create custom formatter
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        dataSet.valueFormatter = DefaultValueFormatter(formatter: formatter)
        
        return BarChartData(dataSet: dataSet)
    }
}
