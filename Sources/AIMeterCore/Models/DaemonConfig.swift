import Foundation

public struct DaemonConfig: Codable, Sendable, Equatable {
    public let pid: Int
    public let httpsPort: Int
    public let httpPort: Int
    public let lsVersion: String
    public let csrfToken: String

    public init(pid: Int, httpsPort: Int, httpPort: Int, lsVersion: String, csrfToken: String) {
        self.pid = pid
        self.httpsPort = httpsPort
        self.httpPort = httpPort
        self.lsVersion = lsVersion
        self.csrfToken = csrfToken
    }
}
