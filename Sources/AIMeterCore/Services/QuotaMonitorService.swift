import Foundation

public struct QuotaDataResult: Sendable {
    public let planName: String
    public let promptCredits: Int
    public let flowCredits: Int
    public let models: [ModelQuotaItem]
    public let fetchedAt: Date

    public init(
        planName: String,
        promptCredits: Int,
        flowCredits: Int,
        models: [ModelQuotaItem],
        fetchedAt: Date = Date()
    ) {
        self.planName = planName
        self.promptCredits = promptCredits
        self.flowCredits = flowCredits
        self.models = models
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
        guard let url = URL(string: "https://127.0.0.1:\(daemon.httpsPort)/exa.language_server_pb.LanguageServerService/GetUserStatus") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("1", forHTTPHeaderField: "Connect-Protocol-Version")
        request.setValue(daemon.csrfToken, forHTTPHeaderField: "x-codeium-csrf-token")
        request.httpBody = Data("{}".utf8)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard httpResponse.statusCode == 200 else {
            throw URLError(.init(rawValue: httpResponse.statusCode))
        }

        let userStatus = try JSONDecoder().decode(UserStatusResponse.self, from: data)
        let models = userStatus.extractModelQuotas()
        let planName = userStatus.userStatus.planStatus?.planInfo?.planName ?? "Google AI Pro"
        let promptCredits = userStatus.userStatus.planStatus?.availablePromptCredits ?? 0
        let flowCredits = userStatus.userStatus.planStatus?.availableFlowCredits ?? 0

        return QuotaDataResult(
            planName: planName,
            promptCredits: promptCredits,
            flowCredits: flowCredits,
            models: models,
            fetchedAt: Date()
        )
    }
}
