import SwiftUI

struct ProgressCard: View {
    let title: String
    let value: Double
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(alignment: .bottom, spacing: 2) {
                    Text(formatValue())
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Constants.UI.paddingMedium)
        .background(Color(.systemGray6))
        .cornerRadius(Constants.UI.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.UI.cornerRadiusMedium)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func formatValue() -> String {
        if unit == "lbs" {
            if value >= Constants.Formatting.millionThreshold {
                return String(format: "%.1fM", value / Constants.Formatting.millionThreshold)
            } else if value >= Constants.Formatting.thousandThreshold {
                return String(format: "%.1fK", value / Constants.Formatting.thousandThreshold)
            } else {
                return String(format: "%.0f", value)
            }
        } else if unit == "days" {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ProgressCard(
            title: "Daily Target",
            value: 68493.15,
            unit: "lbs",
            color: .blue,
            icon: "calendar.badge.clock"
        )
        
        ProgressCard(
            title: "Your Average",
            value: 69833.09,
            unit: "lbs",
            color: .green,
            icon: "chart.line.uptrend.xyaxis"
        )
        
        ProgressCard(
            title: "Days Left",
            value: 130,
            unit: "days",
            color: .purple,
            icon: "clock.arrow.circlepath"
        )
        
        ProgressCard(
            title: "Projected",
            value: 25489077.85,
            unit: "lbs",
            color: .green,
            icon: "chart.bar.fill"
        )
    }
    .padding()
}
