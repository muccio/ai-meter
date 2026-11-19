| Task | Status | Notes |
| --- | --- | --- |
| Esplorazione contesto progetto e verifica API quote | Completato | Individuato endpoint Language Server Antigravity (`/exa.language_server_pb.LanguageServerService/GetUserStatus`) e meccanismo di discovery `daemon/hub_*.json` |
| Domande di chiarimento requisiti utente | Completato | Scelta Swift/SwiftUI nativa, finestra compatta fluttuante + Menu Bar + Dock |
| Proposta di 2-3 approcci con pro/contro | Completato | Approvato Approccio 1 (Swift/SwiftUI nativo) con mandato a procedere autonomamente fino a build, commit, push e release |
| Scrittura documento di design | Completato | Documento `docs/plans/2026-11-19-ai-meter-design.md` creato |
| Scrittura piano di implementazione | Completato | Piano `docs/plans/2026-11-19-ai-meter-implementation-plan.md` creato |
| Task 1: Scaffolding SPM e `.gitignore` | Completato | Struttura pacchetto configurata e verificata con `swift test` |
| Task 2: Data Models & Deserializzazione JSON | Completato | Modelli `DaemonConfig`, `ModelQuotaItem`, `UserStatusResponse` con test unitari passati |
| Task 3: Discovery Daemon & Service Network RPC | Completato | Scansione `hub_*.json` e client HTTPS Connect-RPC verificati live con successo in 37ms |
| Task 4: ViewModel reattivo e Timer 15s | Completato | `QuotaViewModel` implementato con timer personalizzabile e test unitari passati |
| Task 5: Interfaccia SwiftUI compatta | Completato | ContentView, HeaderView, ModelQuotaRowView e SettingsView implementati e compilati con successo |
| Task 6: App Entry, Window Manager e Barra Menu | Completato | AppDelegate, NSStatusItem e controllo livello `.floating` implementati |
| Task 7: Build bundle `.app` standalone | Completato | Script `build_app.sh`, generazione `AIMeter.app` con icona e plist verificata |
| Task 8: Git Repo, Push e Release GitHub | Completato | Repository creato `https://github.com/muccio/ai-meter`, push `main`, tag `v1.0.0` e release asset `AIMeter-macOS-v1.0.0.zip` pubblicati |
