# Design Document: AI Meter (macOS Standalone)

- **Date**: 2026-11-19
- **Author**: Antigravity Assistant
- **Status**: Approved

## 1. Vision & Requirements
AI Meter is a native macOS standalone utility designed to monitor AI model quotas in real-time for users on the Google AI Pro plan. It runs efficiently with a negligible memory footprint, updating dynamically as models and quotas change.

### Key Requirements
- **Live Quota Monitoring**: Queries the local Antigravity Language Server RPC endpoint to retrieve real-time quotas for all models enabled under the user's Pro plan (Gemini 4 Neon, Argon, Hydrogen, Flash, Claude Opus/Sonnet, GPT-OSS, etc.).
- **Automatic Model Discovery**: Automatically renders any new or altered models returned by the daemon without requiring hardcoded lists.
- **Configurable Refresh Interval**: Defaults to 15 seconds; adjustable via a quick stepper/picker and persists user preference.
- **Compact Always-on-Top Window**: Compact HUD/Panel window with a toggle button to switch between floating (`.floating`) and standard (`.normal`) window levels.
- **System Integration**: Available in the macOS Menu Bar (`NSStatusItem`) and the Dock, allowing the user to hide/show the window instantly or quit cleanly.

---

## 2. Technical Architecture

### 2.1 Daemon Discovery & Communication
The application locates the active Antigravity daemon by scanning:
`~/.gemini/antigravity/daemon/hub_*.json`

This file provides:
- `pid`: Process identifier
- `httpsPort`: Local HTTPS port (e.g., 49658)
- `csrfToken`: Secret token required for RPC authentication

### 2.2 Network & Protocol
- **Transport**: HTTPS POST to `https://127.0.0.1:<httpsPort>/exa.language_server_pb.LanguageServerService/GetUserStatus`
- **Headers**:
  - `Content-Type: application/json`
  - `Connect-Protocol-Version: 1`
  - `x-codeium-csrf-token: <csrfToken>`
- **Security**: Self-signed local certificate accepted via custom `URLSessionDelegate` pinned to `127.0.0.1`.
- **Payload**: `{}`

### 2.3 Data Models
- **`ModelQuotaItem`**:
  - `id`: Unique identifier (e.g. `gemini-4-neon-high`)
  - `label`: Human-readable name (e.g. `Gemini 4 Neon (High)`)
  - `remainingFraction`: Double value (0.0 to 1.0)
  - `resetTime`: Parsed `Date` from ISO 8601 string
  - `formattedCountdown`: Relative countdown string (e.g. `in 3h 15m`)
  - `statusColor`: Dynamic color (Green > 50%, Amber 20-50%, Red < 20%)
- **`UserPlanSummary`**:
  - `planName`: "Pro"
  - `availablePromptCredits`: Int
  - `availableFlowCredits`: Int

### 2.4 State Management
- `QuotaMonitorViewModel`:
  - Runs a background timer firing every `refreshInterval` seconds (default: 15s).
  - Handles manual refresh on demand.
  - Exposes published properties for SwiftUI views.
  - Automatically handles daemon restarts or transient network dropouts with graceful retry.

### 2.5 Window Management
- `NSWindow` / `NSPanel` with style `.titled`, `.closable`, `.miniaturizable`, `.resizable`.
- Floating window level (`.floating`) active when `isAlwaysOnTop == true`.
- Menu bar status item with a popup menu: "Mostra/Nascondi Finestra", "Aggiorna Adesso", "Intervallo...", "Esci".

---

## 3. Implementation Stack & Distribution
- **Language**: Swift 6.4 (Native Apple Silicon & Intel)
- **Frameworks**: SwiftUI, AppKit, Combine, Foundation
- **Build System**: Swift Package Manager + Shell packaging script for `.app` bundle
- **Version Control & Release**: Git, GitHub CLI (`gh`), automated release bundle `AIMeter-macOS-v1.0.0.zip` with GitHub release.
