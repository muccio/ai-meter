# AI Meter Implementation Plan

> **For Antigravity:** REQUIRED WORKFLOW: Use `.agent/workflows/execute-plan.md` to execute this plan in single-flow mode.

**Goal:** Build a native macOS standalone application to monitor Google AI Pro model quotas in real-time with configurable refresh (default 15s), auto-discovery of models, compact window, and Always on Top toggle.

**Architecture:** A native Swift 6 / SwiftUI application using SPM. `AIMeterCore` handles daemon discovery (`hub_*.json`), HTTPS Connect-RPC requests to the local Antigravity Language Server, JSON parsing into dynamic model quotas, and reactive state management. `AIMeter` provides AppKit/SwiftUI window management (`.floating` panel level), Menu Bar item, and compact UI. `build_app.sh` bundles the binary into a standalone `AIMeter.app` macOS application.

**Tech Stack:** Swift 6.4, SwiftUI, AppKit, Combine, Foundation, Swift Package Manager, Git, GitHub CLI (`gh`).

---

### Task 1: Project Scaffolding & Git Ignore

**Files:**
- Create: `Package.swift`
- Create: `.gitignore`

**Step 1: Create `.gitignore`**
Include `.build/`, `*.xcodeproj/`, `.DS_Store`, `AIMeter.app`, `release/`.

**Step 2: Create `Package.swift`**
Configure macOS v14+ target with `AIMeterCore` (library), `AIMeter` (executable), and `AIMeterTests` (test target).

**Step 3: Verify with `swift package describe`**
Expected: Target graph resolved successfully.

**Step 4: Commit**
```bash
git add .gitignore Package.swift
git commit -m "chore: setup SPM package structure"
```

---

### Task 2: Data Models & JSON Deserialization

**Files:**
- Create: `Sources/AIMeterCore/Models/DaemonConfig.swift`
- Create: `Sources/AIMeterCore/Models/ModelQuotaItem.swift`
- Create: `Sources/AIMeterCore/Models/UserStatusResponse.swift`
- Create: `Tests/AIMeterTests/QuotaParsingTests.swift`

**Step 1: Write test for parsing Daemon JSON & UserStatus RPC JSON**
Test parsing `hub_*.json` (pid, httpsPort, csrfToken) and sample `GetUserStatus` JSON response into `UserPlanStatus` and `ModelQuotaItem`.

**Step 2: Run test to verify it fails**
Run: `swift test --filter QuotaParsingTests`
Expected: Compilation fail (types not defined).

**Step 3: Implement Models**
- `DaemonConfig`: `pid`, `httpsPort`, `csrfToken`.
- `ModelQuotaItem`: `modelId`, `label`, `remainingFraction`, `resetTime`, helper methods for percentage and relative time string.
- `UserStatusResponse`: full Decodable mapping to `userStatus.planStatus` and `cascadeModelConfigData.clientModelConfigs`.

**Step 4: Run test to verify it passes**
Run: `swift test --filter QuotaParsingTests`
Expected: PASS.

**Step 5: Commit**
```bash
git add Sources/AIMeterCore/Models Tests/AIMeterTests
git commit -m "feat(core): add data models and JSON deserialization"
```

---

### Task 3: Daemon Discovery & RPC Network Service

**Files:**
- Create: `Sources/AIMeterCore/Services/DaemonDiscoveryService.swift`
- Create: `Sources/AIMeterCore/Services/QuotaMonitorService.swift`
- Create: `Tests/AIMeterTests/DaemonDiscoveryTests.swift`

**Step 1: Write test for discovery service**
Verify finding the active daemon file in `~/.gemini/antigravity/daemon/`.

**Step 2: Implement `DaemonDiscoveryService` & `QuotaMonitorService`**
- `DaemonDiscoveryService`: scans `~/.gemini/antigravity/daemon/`, parses `hub_*.json`, validates process existence via `kill(pid, 0)`.
- `QuotaMonitorService`: custom `URLSession` with `URLSessionDelegate` accepting local self-signed certificates, sends POST to `https://127.0.0.1:<httpsPort>/exa.language_server_pb.LanguageServerService/GetUserStatus`, headers `Connect-Protocol-Version: 1` and `x-codeium-csrf-token`.

**Step 3: Run tests**
Run: `swift test`
Expected: PASS.

**Step 4: Commit**
```bash
git add Sources/AIMeterCore/Services Tests/AIMeterTests
git commit -m "feat(core): implement daemon discovery and quota network service"
```

---

### Task 4: ViewModel with Reactive Timer & Configurable Refresh

**Files:**
- Create: `Sources/AIMeterCore/ViewModels/QuotaViewModel.swift`

**Step 1: Implement `QuotaViewModel`**
- Published properties: `models: [ModelQuotaItem]`, `planName: String`, `promptCredits: Int`, `flowCredits: Int`, `isLoading: Bool`, `errorMessage: String?`, `lastUpdated: Date?`, `nextRefreshSeconds: Int`, `refreshInterval: Int` (default: 15).
- Timer logic: ticks every second to decrement `nextRefreshSeconds`; triggers `fetchQuota()` when reaching 0.
- `setRefreshInterval(Int)` updates the interval and resets timer.
- `isAlwaysOnTop: Bool` state publisher.

**Step 2: Verify compiling core**
Run: `swift build --target AIMeterCore`
Expected: PASS.

**Step 3: Commit**
```bash
git add Sources/AIMeterCore/ViewModels
git commit -m "feat(core): implement QuotaViewModel with configurable timer"
```

---

### Task 5: SwiftUI Views (Compact HUD, Progress Bars, Controls)

**Files:**
- Create: `Sources/AIMeter/Views/HeaderView.swift`
- Create: `Sources/AIMeter/Views/ModelQuotaRowView.swift`
- Create: `Sources/AIMeter/Views/SettingsView.swift`
- Create: `Sources/AIMeter/Views/ContentView.swift`

**Step 1: Implement UI components**
- `HeaderView`: Plan badge ("Google AI Pro"), Credits pills, Pin button (Always on Top toggle with visual highlight), Settings gear button.
- `ModelQuotaRowView`: Model name, custom progress bar with smooth gradient and color status (Green >50%, Orange 20-50%, Red <20%), percentage label, and countdown badge (e.g. `resets 18:59`).
- `SettingsView`: Interval stepper/picker (5s, 10s, 15s, 30s, 60s, 120s), manual refresh trigger.
- `ContentView`: Header, scrollable list of models with dynamic layout, footer with countdown and last updated time.

**Step 2: Verify compilation**
Run: `swift build --target AIMeter`
Expected: PASS.

**Step 3: Commit**
```bash
git add Sources/AIMeter/Views
git commit -m "feat(ui): implement compact SwiftUI interface with quota meters"
```

---

### Task 6: App Entry, Window Management & Menu Bar Item

**Files:**
- Create: `Sources/AIMeter/App/AppDelegate.swift`
- Create: `Sources/AIMeter/App/AIMeterApp.swift`

**Step 1: Implement `AppDelegate` & Window Controller**
- Custom `NSWindow` / `NSPanel` setup with `.floating` level support when `isAlwaysOnTop` is enabled.
- `NSStatusItem` in the system menu bar displaying a meter icon and a menu: "Mostra Finestra", "Aggiorna Ora", "Always on Top", "Intervallo", "Esci".

**Step 2: Run the app for verification**
Run: `swift run AIMeter` (or background test) to confirm live data fetching from Antigravity daemon.

**Step 3: Commit**
```bash
git add Sources/AIMeter/App
git commit -m "feat(app): add AppDelegate, window floating level and menu bar item"
```

---

### Task 7: App Bundling Script (`AIMeter.app`) & Standalone Packaging

**Files:**
- Create: `scripts/build_app.sh`
- Create: `Resources/Info.plist`
- Create: `Resources/AIMeterIcon.png` (or generated app icon)

**Step 1: Create `build_app.sh`**
Compiles the binary with optimizations (`swift build -c release`), creates `AIMeter.app/Contents/MacOS/AIMeter`, copies `Info.plist`, PkgInfo, and generates icon.

**Step 2: Run `build_app.sh`**
Run: `chmod +x scripts/build_app.sh && ./scripts/build_app.sh`
Expected: `build/AIMeter.app` created and verified.

**Step 3: Test launching `AIMeter.app`**
Confirm code signature (ad-hoc) and standalone launch.

**Step 4: Commit**
```bash
git add scripts Resources
git commit -m "chore(packaging): add build script for standalone macOS .app bundle"
```

---

### Task 8: Git Remote, Push, Tag & GitHub Release

**Step 1: Check/Create GitHub repository via `gh`**
Command: `gh repo create ai-meter --public --source=. --description="Standalone macOS utility to monitor Google AI Pro model quotas in real-time" --remote=origin`

**Step 2: Push code to `main`**
Command: `git push -u origin main`

**Step 3: Package release zip and create GitHub Release v1.0.0**
Command:
```bash
zip -r AIMeter-macOS-v1.0.0.zip build/AIMeter.app
gh release create v1.0.0 AIMeter-macOS-v1.0.0.zip --title "AI Meter v1.0.0" --notes "First release: Standalone macOS utility for Google AI Pro model quota monitoring."
```

**Step 4: Verify release URL and report completion**
Confirm GitHub release exists and output details to the user.
