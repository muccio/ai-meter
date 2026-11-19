import SwiftUI
import AIMeterCore

public struct ModelQuotaRowView: View {
    public let item: ModelQuotaItem

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(item.label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(.primary)

                Spacer()

                HStack(spacing: 5) {
                    // Reset time badge
                    HStack(spacing: 2) {
                        Image(systemName: "clock")
                            .font(.system(size: 8))
                        Text(item.formattedResetTime())
                            .font(.system(size: 9, weight: .regular, design: .monospaced))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1.5)
                    .background(Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 3))

                    // Percentage value
                    Text("\(item.percentage)%")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(statusTextColor)
                        .frame(width: 38, alignment: .trailing)
                }
            }

            // Compact modern progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.12))
                        .frame(height: 5)

                    Capsule()
                        .fill(statusGradient)
                        .frame(width: max(3, geo.size.width * CGFloat(max(0.0, min(1.0, item.remainingFraction)))), height: 5)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: item.remainingFraction)
                }
            }
            .frame(height: 5)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.primary.opacity(0.04), lineWidth: 1)
        )
    }

    private var statusGradient: LinearGradient {
        switch item.quotaStatus {
        case .good:
            return LinearGradient(
                colors: [Color.green, Color.teal],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .warning:
            return LinearGradient(
                colors: [Color.orange, Color.yellow],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .critical:
            return LinearGradient(
                colors: [Color.red, Color.orange],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    private var statusTextColor: Color {
        switch item.quotaStatus {
        case .good:
            return .green
        case .warning:
            return .orange
        case .critical:
            return .red
        }
    }
}
