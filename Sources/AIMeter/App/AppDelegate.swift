import AppKit
import SwiftUI
import Combine
import AIMeterCore

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var window: NSWindow?
    private var statusItem: NSStatusItem?
    public let viewModel = QuotaViewModel()
    private var cancellables = Set<AnyCancellable>()

    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)

        setupWindow()
        setupStatusItem()
        setupBindings()

        Task {
            await viewModel.refresh()
        }
    }

    private func setupWindow() {
        let contentView = ContentView(viewModel: viewModel)
        let hostingController = NSHostingController(rootView: contentView)

        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 380, height: 560),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.setFrameAutosaveName("AIMeterMainWindow")
        window.contentViewController = hostingController
        window.title = "AI Meter"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.minSize = NSSize(width: 330, height: 400)
        
        // Prevent window deallocation on close, delegate to hide instead
        window.isReleasedWhenClosed = false
        window.delegate = self

        // Set initial always-on-top level
        window.level = viewModel.isAlwaysOnTop ? .floating : .normal

        window.makeKeyAndOrderFront(nil)
        self.window = window
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            if let image = NSImage(systemSymbolName: "gauge.with.needle.fill", accessibilityDescription: "AI Meter") {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = "AI"
            }
            button.action = #selector(statusItemClicked)
            button.target = self
        }
    }

    private func setupBindings() {
        // Watch for Always on Top changes
        viewModel.$isAlwaysOnTop
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alwaysOnTop in
                guard let self = self, let window = self.window else { return }
                window.level = alwaysOnTop ? .floating : .normal
            }
            .store(in: &cancellables)
    }

    @objc private func statusItemClicked() {
        guard let window = self.window else { return }
        if window.isVisible && NSApp.isActive {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // Intercept window close button (red X) to hide rather than destroy window
    public func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }

    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        return true
    }

    public func applicationWillTerminate(_ notification: Notification) {
        cancellables.removeAll()
    }
}
