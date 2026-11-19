import Testing
import Foundation
@testable import AIMeterCore

@Suite("Daemon Discovery & Network Service Tests")
struct DaemonDiscoveryTests {

    @Test func testDiscoveryWithCustomFolder() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let hubFile = tempDir.appendingPathComponent("hub_49659.json")
        let json = """
        {
          "pid": \(ProcessInfo.processInfo.processIdentifier),
          "httpsPort": 49658,
          "httpPort": 49659,
          "lsVersion": "2.33.0",
          "csrfToken": "test-token"
        }
        """.data(using: .utf8)!
        try json.write(to: hubFile)

        let service = DaemonDiscoveryService(customDirectoryURL: tempDir)
        let config = try service.discoverDaemon()
        #expect(config.httpsPort == 49658)
        #expect(config.csrfToken == "test-token")
    }

    @Test func testLiveDaemonFetchIfAvailable() async throws {
        // Test against live daemon currently running on developer machine
        let discovery = DaemonDiscoveryService()
        do {
            let config = try discovery.discoverDaemon()
            #expect(config.httpsPort > 0)
            
            let monitor = QuotaMonitorService(discoveryService: discovery)
            let result = try await monitor.fetchQuotas()
            #expect(!result.planName.isEmpty)
            #expect(!result.models.isEmpty)
        } catch {
            // If running in an environment without active daemon, ignore live test
            print("Live daemon not running or unavailable: \(error)")
        }
    }
}
