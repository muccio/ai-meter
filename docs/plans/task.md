| Task | Status | Notes |
| --- | --- | --- |
| Esplorazione contesto progetto e verifica API quote | Completato | Individuato endpoint Language Server Antigravity (`/exa.language_server_pb.LanguageServerService/GetUserStatus`) e meccanismo di discovery `daemon/hub_*.json` |
| Domande di chiarimento requisiti utente | Completato | Scelta Swift/SwiftUI nativa, finestra compatta fluttuante + Menu Bar + Dock |
| Proposta di 2-3 approcci con pro/contro | Completato | Approvato Approccio 1 (Swift/SwiftUI nativo) con mandato a procedere autonomamente fino a build, commit, push e release |
| Scrittura documento di design | Completato | Documento `docs/plans/2026-11-19-ai-meter-design.md` creato |
| Scrittura piano di implementazione | Completato | Piano `docs/plans/2026-11-19-ai-meter-implementation-plan.md` creato |
| Task 1: Scaffolding SPM e `.gitignore` | In corso | Configurazione `Package.swift` e `.gitignore` |
| Task 2: Data Models & Deserializzazione JSON | In attesa | Modelli `DaemonConfig`, `ModelQuotaItem`, `UserStatusResponse` con test |
| Task 3: Discovery Daemon & Service Network RPC | In attesa | Scansione `hub_*.json` e client HTTPS Connect-RPC con SSL locale |
| Task 4: ViewModel reattivo e Timer 15s | In attesa | `QuotaViewModel` con countdown, intervallo reimpostabile e gestione stato |
| Task 5: Interfaccia SwiftUI compatta | In attesa | Header badge Pro, barre progressive colorate, pulsante Always on Top, impostazioni |
| Task 6: App Entry, Window Manager e Barra Menu | In attesa | Integrazione AppKit `NSPanel` (.floating level) e `NSStatusItem` |
| Task 7: Build bundle `.app` standalone | In attesa | Script `build_app.sh`, generazione `AIMeter.app` con icona e plist |
| Task 8: Git Repo, Push e Release GitHub | In attesa | Creazione repo GitHub `ai-meter`, push `main`, tag `v1.0.0` e release asset |
