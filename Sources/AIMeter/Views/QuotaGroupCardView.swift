import SwiftUI
import AIMeterCore

public struct QuotaGroupCardView: View {
    public let group: QuotaGroupItem

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Group Header
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(iconGradient)

                Text(cleanTitle)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Spacer()

                if let desc = group.description {
                    Image(systemName: "info.circle")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .help(desc)
                }
            }

            // Both 5h and Weekly Limits together!
            VStack(spacing: 6) {
                if let fiveHour = group.fiveHourBucket {
                    bucketGaugeRow(
                        title: "Limite 5 Ore",
                        icon: "bolt.fill",
                        iconColor: .orange,
                        bucket: fiveHour
                    )
                }

                if let weekly = group.weeklyBucket {
                    bucketGaugeRow(
                        title: "Limite Settimanale",
                        icon: "calendar",
                        iconColor: .blue,
                        bucket: weekly
                    )
                }

                // Any other bucket
                ForEach(otherBuckets) { b in
                    bucketGaugeRow(
                        title: b.displayName,
                        icon: "gauge",
                        iconColor: .purple,
                        bucket: b
                    )
                }
            }
        }
        .padding(10)
        .background(Color.primary.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }

    private var otherBuckets: [QuotaBucketItem] {
        group.buckets.filter { !$0.isFiveHour && !$0.isWeekly }
    }

    @ViewBuilder
    private func bucketGaugeRow(
        title: String,
        icon: String,
        iconColor: Color,
        bucket: QuotaBucketItem
    ) -> some View {
        VStack(spacing: 3) {
            HStack(alignment: .center) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 9))
                        .foregroundColor(iconColor)
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.primary)
                }

                Spacer()

                // Reset time badge
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.system(size: 8))
                    Text(bucket.formattedResetTime())
                        .font(.system(size: 9, design: .monospaced))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
                .padding(.vertical, 1.5)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 3))

                // Percentage text
                Text("\(bucket.percentage)%")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(statusColor(bucket.quotaStatus))
                    .frame(width: 36, alignment: .trailing)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.12))
                        .frame(height: 6)

                    Capsule()
                        .fill(statusGradient(bucket.quotaStatus))
                        .frame(width: max(3, geo.size.width * CGFloat(max(0.0, min(1.0, bucket.remainingFraction)))), height: 6)
                        .animation(.spring(response: 0.4), value: bucket.remainingFraction)
                }
            }
            .frame(height: 6)
        }
        .padding(6)
        .background(Color.secondary.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var cleanTitle: String {
        if group.displayName.localizedCaseInsensitiveContains("Gemini Models") {
            return "Modelli Gemini"
        } else if group.displayName.localizedCaseInsensitiveContains("Claude") {
            return "Claude & GPT"
        } else if group.displayName.localizedCaseInsensitiveContains("Argon") {
            return "Gemini 4 Argon"
        }
        return group.displayName
    }

    private var iconName: String {
        if group.displayName.localizedCaseInsensitiveContains("Gemini Models") {
            return "sparkles"
        } else if group.displayName.localizedCaseInsensitiveContains("Claude") {
            return "brain.head.profile"
        } else if group.displayName.localizedCaseInsensitiveContains("Argon") {
            return "atom"
        }
        return "gauge"
    }

    private var iconGradient: LinearGradient {
        if group.displayName.localizedCaseInsensitiveContains("Gemini Models") {
            return LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else if group.displayName.localizedCaseInsensitiveContains("Claude") {
            return LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(colors: [.teal, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private func statusColor(_ status: QuotaStatus) -> Color {
        switch status {
        case .good: return .green
        case .warning: return .orange
        case .critical: return .red
        }
    }

    private func statusGradient(_ status: QuotaStatus) -> LinearGradient {
        switch status {
        case .good:
            return LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing)
        case .warning:
            return LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
        case .critical:
            return LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
        }
    }
}
