import Foundation

public enum QuotaStatus: String, Sendable, Codable {
    case good      // > 50%
    case warning   // 20% - 50%
    case critical  // < 20%
}

public struct ModelQuotaItem: Identifiable, Hashable, Sendable, Codable {
    public var id: String { modelId }
    public let modelId: String
    public let label: String
    public let remainingFraction: Double
    public let resetTimeString: String?
    public let resetTime: Date?

    public init(
        modelId: String,
        label: String,
        remainingFraction: Double,
        resetTimeString: String?
    ) {
        self.modelId = modelId
        self.label = label
        self.remainingFraction = remainingFraction
        self.resetTimeString = resetTimeString
        
        if let raw = resetTimeString {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: raw) {
                self.resetTime = date
            } else {
                let fallback = ISO8601DateFormatter()
                self.resetTime = fallback.date(from: raw)
            }
        } else {
            self.resetTime = nil
        }
    }

    public var percentage: Int {
        let clamped = max(0.0, min(1.0, remainingFraction))
        return Int(round(clamped * 100.0))
    }

    public var quotaStatus: QuotaStatus {
        if percentage > 50 {
            return .good
        } else if percentage >= 20 {
            return .warning
        } else {
            return .critical
        }
    }

    public func formattedResetTime(relativeTo now: Date = Date()) -> String {
        guard let reset = resetTime else { return "N/D" }
        let diff = reset.timeIntervalSince(now)
        if diff <= 0 {
            return "Adesso"
        }
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        if hours > 24 {
            let days = hours / 24
            let remHours = hours % 24
            return "\(days)g \(remHours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
