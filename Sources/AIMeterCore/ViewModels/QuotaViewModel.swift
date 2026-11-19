import Foundation
import Combine
import SwiftUI

public enum QuotaViewMode: String, CaseIterable, Identifiable, Sendable {
    case all = "Tutti"
    case summary = "Limiti 5h & Settimana"
    case models = "Modelli"
    public var id: String { rawValue }
}

@MainActor
public final class QuotaViewModel: ObservableObject {
    @Published public var models: [ModelQuotaItem] = []
    @Published public var quotaGroups: [QuotaGroupItem] = []
    @Published public var planName: String = "Google AI Pro"
    @Published public var promptCredits: Int = 0
    @Published public var flowCredits: Int = 0
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var lastUpdated: Date? = nil
    @Published public var viewMode: QuotaViewMode = .all
    @Published public var refreshInterval: Int {
        didSet {
            UserDefaults.standard.set(refreshInterval, forKey: "AIMeter_refreshInterval")
            nextRefreshSeconds = refreshInterval
        }
    }
    @Published public var nextRefreshSeconds: Int = 15
    @Published public var isAlwaysOnTop: Bool {
        didSet {
            UserDefaults.standard.set(isAlwaysOnTop, forKey: "AIMeter_isAlwaysOnTop")
        }
    }
    @Published public var searchQuery: String = ""

    private let monitorService: QuotaMonitoring
    private var timerCancellable: AnyCancellable?

    public init(monitorService: QuotaMonitoring = QuotaMonitorService()) {
        self.monitorService = monitorService
        
        let savedInterval = UserDefaults.standard.integer(forKey: "AIMeter_refreshInterval")
        let initialInterval = savedInterval > 0 ? savedInterval : 15
        self.refreshInterval = initialInterval
        self.nextRefreshSeconds = initialInterval

        if UserDefaults.standard.object(forKey: "AIMeter_isAlwaysOnTop") != nil {
            self.isAlwaysOnTop = UserDefaults.standard.bool(forKey: "AIMeter_isAlwaysOnTop")
        } else {
            self.isAlwaysOnTop = true // Default always on top as requested
        }

        startTimer()
    }

    public var filteredModels: [ModelQuotaItem] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return models
        }
        return models.filter {
            $0.label.localizedCaseInsensitiveContains(query) ||
            $0.modelId.localizedCaseInsensitiveContains(query)
        }
    }

    public func startTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.nextRefreshSeconds > 1 {
                    self.nextRefreshSeconds -= 1
                } else {
                    self.nextRefreshSeconds = self.refreshInterval
                    Task {
                        await self.refresh()
                    }
                }
            }
    }

    public func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let result = try await monitorService.fetchQuotas()
            self.planName = result.planName == "Pro" ? "Google AI Pro" : result.planName
            self.promptCredits = result.promptCredits
            self.flowCredits = result.flowCredits
            self.models = result.models
            self.quotaGroups = result.quotaGroups
            self.lastUpdated = result.fetchedAt
            self.isLoading = false
            self.nextRefreshSeconds = self.refreshInterval
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    public func setRefreshInterval(_ seconds: Int) {
        let clamped = max(5, min(300, seconds))
        self.refreshInterval = clamped
    }

    public func toggleAlwaysOnTop() {
        self.isAlwaysOnTop.toggle()
    }
}
