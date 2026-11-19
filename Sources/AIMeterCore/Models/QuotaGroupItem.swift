import Foundation

public struct QuotaBucketItem: Identifiable, Hashable, Sendable, Codable {
    public var id: String { bucketId }
    public let bucketId: String
    public let displayName: String
    public let description: String?
    public let window: String // "5h", "weekly", etc.
    public let remainingFraction: Double
    public let resetTimeString: String?
    public let resetTime: Date?

    public init(
        bucketId: String,
        displayName: String,
        description: String? = nil,
        window: String,
        remainingFraction: Double,
        resetTimeString: String?
    ) {
        self.bucketId = bucketId
        self.displayName = displayName
        self.description = description
        self.window = window
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

    public var isFiveHour: Bool {
        return window.lowercased() == "5h" || displayName.localizedCaseInsensitiveContains("five hour")
    }

    public var isWeekly: Bool {
        return window.lowercased() == "weekly" || displayName.localizedCaseInsensitiveContains("weekly")
    }

    public func formattedResetTime(relativeTo now: Date = Date()) -> String {
        guard let reset = resetTime else { return "N/D" }
        let diff = reset.timeIntervalSince(now)
        if diff <= 0 {
            return "Adesso"
        }
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        if hours >= 24 {
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

public struct QuotaGroupItem: Identifiable, Hashable, Sendable, Codable {
    public var id: String { displayName }
    public let displayName: String
    public let description: String?
    public let buckets: [QuotaBucketItem]

    public init(displayName: String, description: String? = nil, buckets: [QuotaBucketItem]) {
        self.displayName = displayName
        self.description = description
        self.buckets = buckets
    }

    public var fiveHourBucket: QuotaBucketItem? {
        buckets.first(where: { $0.isFiveHour })
    }

    public var weeklyBucket: QuotaBucketItem? {
        buckets.first(where: { $0.isWeekly })
    }
}

// Server Response DTO for RetrieveUserQuotaSummary
public struct UserQuotaSummaryResponse: Codable, Sendable {
    public let response: QuotaSummaryPayload?

    public struct QuotaSummaryPayload: Codable, Sendable {
        public let groups: [QuotaGroupPayload]?
        public let description: String?
    }

    public struct QuotaGroupPayload: Codable, Sendable {
        public let displayName: String?
        public let description: String?
        public let buckets: [QuotaBucketPayload]?
    }

    public struct QuotaBucketPayload: Codable, Sendable {
        public let bucketId: String?
        public let displayName: String?
        public let description: String?
        public let window: String?
        public let remainingFraction: Double?
        public let resetTime: String?
    }

    public func extractQuotaGroups() -> [QuotaGroupItem] {
        guard let groupPayloads = response?.groups else { return [] }
        return groupPayloads.compactMap { g in
            guard let name = g.displayName else { return nil }
            let bucketItems: [QuotaBucketItem] = (g.buckets ?? []).compactMap { b in
                guard let bId = b.bucketId,
                      let bName = b.displayName,
                      let window = b.window,
                      let fraction = b.remainingFraction,
                      !fraction.isNaN else {
                    return nil
                }
                return QuotaBucketItem(
                    bucketId: bId,
                    displayName: bName,
                    description: b.description,
                    window: window,
                    remainingFraction: fraction,
                    resetTimeString: b.resetTime
                )
            }
            return QuotaGroupItem(
                displayName: name,
                description: g.description,
                buckets: bucketItems
            )
        }
    }
}
