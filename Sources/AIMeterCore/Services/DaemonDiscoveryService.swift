import Foundation
import Darwin

public enum DaemonDiscoveryError: LocalizedError, Sendable {
    case directoryNotFound(String)
    case noDaemonFound
    case processNotRunning(pid: Int)
    case invalidConfig(String)

    public var errorDescription: String? {
        switch self {
        case .directoryNotFound(let path):
            return "Cartella daemon non trovata: \(path)"
        case .noDaemonFound:
            return "Nessun daemon Antigravity attivo trovato in ~/.gemini/antigravity/daemon"
        case .processNotRunning(let pid):
            return "Il processo daemon (PID \(pid)) non è più attivo"
        case .invalidConfig(let reason):
            return "Configurazione daemon non valida: \(reason)"
        }
    }
}

public protocol DaemonDiscovering: Sendable {
    func discoverDaemon() throws -> DaemonConfig
}

public struct DaemonDiscoveryService: DaemonDiscovering {
    public let customDirectoryURL: URL?

    public init(customDirectoryURL: URL? = nil) {
        self.customDirectoryURL = customDirectoryURL
    }

    public var daemonDirectoryURL: URL {
        if let custom = customDirectoryURL {
            return custom
        }
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".gemini/antigravity/daemon", isDirectory: true)
    }

    public func discoverDaemon() throws -> DaemonConfig {
        let dir = daemonDirectoryURL
        let fm = FileManager.default

        guard fm.fileExists(atPath: dir.path) else {
            throw DaemonDiscoveryError.directoryNotFound(dir.path)
        }

        let contents = try fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.contentModificationDateKey], options: .skipsHiddenFiles)
        
        let hubFiles = contents.filter { url in
            let name = url.lastPathComponent
            return name.hasPrefix("hub_") && name.hasSuffix(".json")
        }

        guard !hubFiles.isEmpty else {
            throw DaemonDiscoveryError.noDaemonFound
        }

        // Sort by modification date descending
        let sorted = hubFiles.sorted { u1, u2 in
            let d1 = (try? u1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            let d2 = (try? u2.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            return d1 > d2
        }

        for fileURL in sorted {
            do {
                let data = try Data(contentsOf: fileURL)
                let config = try JSONDecoder().decode(DaemonConfig.self, from: data)
                
                // If checking live process:
                if isProcessAlive(pid: config.pid) {
                    return config
                }
            } catch {
                continue
            }
        }

        // If no alive process was confirmed, try the newest valid config file as fallback
        if let first = sorted.first {
            let data = try Data(contentsOf: first)
            return try JSONDecoder().decode(DaemonConfig.self, from: data)
        }

        throw DaemonDiscoveryError.noDaemonFound
    }

    private func isProcessAlive(pid: Int) -> Bool {
        // kill(pid, 0) returns 0 if process exists and signal can be sent
        return kill(pid_t(pid), 0) == 0
    }
}
