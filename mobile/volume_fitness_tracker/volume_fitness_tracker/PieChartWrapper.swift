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
        pieChart.holeRadiusPercent = 0.5
        pieChart.animate(xAxisDuration: 1.5)
        pieChart.delegate = context.coordinator
        pieChart.drawEntryLabelsEnabled = false
        return pieChart
    }

    func updateUIView(_ uiView: PieChartView, context: Context) {
        uiView.data = generateChartData()
    }

    private func generateChartData() -> PieChartData {
        let entries = data.map {
            PieChartDataEntry(
                value: Double($0.value),
                label: $0.exercise.capitalized // Capitalize the exercise name
            )
        }
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = ChartColorTemplates.colorful()
        dataSet.drawValuesEnabled = false
        
        return PieChartData(dataSet: dataSet)
    }
}
