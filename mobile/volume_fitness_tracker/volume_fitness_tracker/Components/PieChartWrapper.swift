import SwiftUI
import DGCharts

struct PieChartWrapper: UIViewRepresentable {
    var data: [ExerciseData]
    @Binding var selectedExercise: String?

    class Coordinator: NSObject, ChartViewDelegate {
        var parent: PieChartWrapper

        init(parent: PieChartWrapper) {
            self.parent = parent
        }

        func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
            if let pieEntry = entry as? PieChartDataEntry {
                parent.selectedExercise = "\(pieEntry.label ?? ""): \(Int(pieEntry.value)) lbs"
            }
        }

        func chartValueNothingSelected(_ chartView: ChartViewBase) {
            parent.selectedExercise = nil
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> PieChartView {
        let pieChart = PieChartView()
        pieChart.data = generateChartData()
        pieChart.holeRadiusPercent = Constants.Chart.pieChartHoleRadius
        pieChart.animate(xAxisDuration: Constants.Chart.pieChartAnimationDuration)
        pieChart.delegate = context.coordinator
        pieChart.drawEntryLabelsEnabled = false
        pieChart.legend.enabled = false
        pieChart.legend.textColor = UIColor.clear
        pieChart.legend.form = .none
        pieChart.backgroundColor = UIColor.clear
        pieChart.isOpaque = false
        
        // Set hole color to match system appearance (dark mode support)
        if #available(iOS 13.0, *) {
            pieChart.holeColor = UIColor.systemBackground
            pieChart.transparentCircleColor = UIColor.systemBackground
        } else {
            pieChart.holeColor = UIColor.white
            pieChart.transparentCircleColor = UIColor.white
        }
        
        return pieChart
    }

    func updateUIView(_ uiView: PieChartView, context: Context) {
        uiView.data = generateChartData()
    }

    private func generateChartData() -> PieChartData {
        let entries = data.map {
            PieChartDataEntry(
                value: Double($0.value),
                label: $0.exercise.capitalized
            )
        }
        let dataSet = PieChartDataSet(entries: entries, label: "")
        
        // Modern fitness color scheme matching React app
        dataSet.colors = [
            UIColor(red: 0.42, green: 0.49, blue: 0.92, alpha: 1.0), // #667eea - Primary blue
            UIColor(red: 0.46, green: 0.29, blue: 0.64, alpha: 1.0), // #764ba2 - Purple
            UIColor(red: 0.94, green: 0.58, blue: 0.98, alpha: 1.0), // #f093fb - Pink
            UIColor(red: 0.96, green: 0.34, blue: 0.42, alpha: 1.0), // #f5576c - Red
            UIColor(red: 0.31, green: 0.67, blue: 1.0, alpha: 1.0),  // #4facfe - Light blue
            UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0),   // #00f2fe - Cyan
            UIColor(red: 0.0, green: 0.83, blue: 0.67, alpha: 1.0),  // #00d4aa - Teal
            UIColor(red: 1.0, green: 0.65, blue: 0.15, alpha: 1.0),  // #ffa726 - Orange
            UIColor(red: 0.91, green: 0.34, blue: 0.38, alpha: 1.0), // #e94560 - Highlight red
            UIColor(red: 0.22, green: 0.33, blue: 0.38, alpha: 1.0), // #0f3460 - Dark blue
        ]
        
        dataSet.drawValuesEnabled = false
        dataSet.selectionShift = Constants.Chart.pieChartSelectionShift // Increase hover effect
        dataSet.highlightEnabled = true
        dataSet.drawIconsEnabled = false
        
        return PieChartData(dataSet: dataSet)
    }
}
