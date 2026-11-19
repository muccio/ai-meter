import Foundation

public struct QuotaDataResult: Sendable {
    public let planName: String
    public let promptCredits: Int
    public let flowCredits: Int
    public let models: [ModelQuotaItem]
    public let quotaGroups: [QuotaGroupItem]
    public let fetchedAt: Date

    public init(
        planName: String,
        promptCredits: Int,
        flowCredits: Int,
        models: [ModelQuotaItem],
        quotaGroups: [QuotaGroupItem] = [],
        fetchedAt: Date = Date()
    ) {
        self.planName = planName
        self.promptCredits = promptCredits
        self.flowCredits = flowCredits
        self.models = models
        self.quotaGroups = quotaGroups
        self.fetchedAt = fetchedAt
    }
}

public final class LocalhostSessionDelegate: NSObject, URLSessionDelegate, Sendable {
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Specifically accept local self-signed certificate for 127.0.0.1 / localhost
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust,
           let host = challenge.protectionSpace.host as String?,
           (host == "127.0.0.1" || host == "localhost") {
            completionHandler(.useCredential, URLCredential(trust: trust))
            return
        }
        completionHandler(.performDefaultHandling, nil)
    }
}

public protocol QuotaMonitoring: Sendable {
    func fetchQuotas() async throws -> QuotaDataResult
}

public final class QuotaMonitorService: QuotaMonitoring, Sendable {
    private let discoveryService: DaemonDiscovering
    private let session: URLSession

    public init(discoveryService: DaemonDiscovering = DaemonDiscoveryService()) {
        self.discoveryService = discoveryService
        let delegate = LocalhostSessionDelegate()
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 8
        config.timeoutIntervalForResource = 12
        self.session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
    }

    public func fetchQuotas() async throws -> QuotaDataResult {
        let daemon = try discoveryService.discoverDaemon()
        
        guard let statusUrl = URL(string: "https://127.0.0.1:\(daemon.httpsPort)/exa.language_server_pb.LanguageServerService/GetUserStatus"),
              let summaryUrl = URL(string: "https://127.0.0.1:\(daemon.httpsPort)/exa.language_server_pb.LanguageServerService/RetrieveUserQuotaSummary") else {
            throw URLError(.badURL)
        }

        func makeRequest(url: URL) -> URLRequest {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("1", forHTTPHeaderField: "Connect-Protocol-Version")
            req.setValue(daemon.csrfToken, forHTTPHeaderField: "x-codeium-csrf-token")
            req.httpBody = Data("{}".utf8)
            return req
        }

        let statusReq = makeRequest(url: statusUrl)
        let summaryReq = makeRequest(url: summaryUrl)

        // Perform both requests in parallel
        async let statusTask = session.data(for: statusReq)
        async let summaryTask = session.data(for: summaryReq)

        let (statusData, statusResp) = try await statusTask

        guard let httpResponse = statusResp as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let userStatus = try JSONDecoder().decode(UserStatusResponse.self, from: statusData)
        let models = userStatus.extractModelQuotas()
        let planName = userStatus.userStatus.planStatus?.planInfo?.planName ?? "Google AI Pro"
        let promptCredits = userStatus.userStatus.planStatus?.availablePromptCredits ?? 0
        let flowCredits = userStatus.userStatus.planStatus?.availableFlowCredits ?? 0

        // Parse summary groups (5h + weekly) if available
        var quotaGroups: [QuotaGroupItem] = []
        if let (summaryData, summaryResp) = try? await summaryTask,
           let httpSummary = summaryResp as? HTTPURLResponse, httpSummary.statusCode == 200 {
            if let summaryResponse = try? JSONDecoder().decode(UserQuotaSummaryResponse.self, from: summaryData) {
                quotaGroups = summaryResponse.extractQuotaGroups()
            }
        }

        return QuotaDataResult(
            planName: planName,
            promptCredits: promptCredits,
            flowCredits: flowCredits,
            models: models,
            quotaGroups: quotaGroups,
            fetchedAt: Date()
        )
    }
}
