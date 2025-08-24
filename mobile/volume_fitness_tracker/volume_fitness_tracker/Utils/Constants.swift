import SwiftUI

struct Constants {
    // Fitness Goals
    static let yearlyGoalLbs: Int = 25_000_000
    static let daysInYear: Int = 365
    
    // UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let cornerRadiusSmall: CGFloat = 8
        static let cornerRadiusMedium: CGFloat = 10
        static let padding: CGFloat = 16
        static let paddingSmall: CGFloat = 8
        static let paddingMedium: CGFloat = 12
    }
    
    // Chart Constants
    struct Chart {
        static let pieChartHoleRadius: Double = 0.6
        static let pieChartAnimationDuration: Double = 1.5
        static let pieChartSelectionShift: Double = 15
    }
    
    // Number Formatting
    struct Formatting {
        static let millionThreshold: Double = 1_000_000
        static let thousandThreshold: Double = 1_000
    }
}

// MARK: - View Modifiers for DRY Code
struct StandardCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Constants.UI.padding)
            .background(Color(.systemGray6))
            .cornerRadius(Constants.UI.cornerRadius)
    }
}

struct StandardButtonStyle: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(Constants.UI.padding)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(Constants.UI.cornerRadiusMedium)
            .padding(.horizontal)
    }
}

extension View {
    func standardCard() -> some View {
        modifier(StandardCardStyle())
    }
    
    func standardButton(color: Color = .blue) -> some View {
        modifier(StandardButtonStyle(color: color))
    }
}
