# AI Meter 🚀

**AI Meter** è un'applicazione nativa standalone per macOS (Swift 6 / SwiftUI) progettata per monitorare in tempo reale le quote di tutti i modelli inclusi nel piano **Google AI Pro** (Gemini 4 Neon, Argon, Hydrogen, Gemini 3.8 Flash, Claude Opus 5.5, Claude Sonnet 5.5, GPT-OSS 120B e modelli futuri).

![macOS Version](https://img.shields.io/badge/macOS-14.0%2B-blue?logo=apple)
![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange?logo=swift)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ✨ Caratteristiche Principali

- ⚡ **Auto-Discovery dei Modelli**: Rileva in automatico tutti i modelli inclusi nel piano dell'account tramite l'endpoint Connect-RPC locale di Antigravity Language Server (`hub_*.json`). Quando Google aggiunge o modifica modelli, la lista si aggiorna da sola.
- ⏱️ **Intervallo di Refresh Personalizzabile**: Refresh automatico impostato a **15 secondi** di default, reimpostabile in qualunque momento (5s, 10s, 15s, 30s, 60s, 120s) dall'interfaccia.
- 📌 **Always on Top (Sempre in primo piano)**: Finestra compatta con pulsante rapido per mantenere l'utility sempre visibile sopra gli altri programmi durante il coding o l'interazione con l'AI.
- 📊 **Metriche e Percentuali Intuitive**:
  - Barre di avanzamento dinamiche a colori (Verde >50%, Arancione 20-50%, Rosso <20%).
  - Orario o conto alla rovescia di reset per ogni quota (es. *in 3h 14m*).
  - Conteggio crediti Prompt e Flow.
- 🔍 **Filtro Rapido**: Barra di ricerca istantanea per filtrare i modelli per nome o identificatore.
- 🖥️ **Presenza Ibrida Dock + Barra dei Menu**: Icona comoda nella Barra di Stato per mostrare/nascondere la finestra con un singolo clic.
- 🪶 **Consumo Risorse Ultra-Leggero**: < 20 MB di RAM, 0% CPU tra i cicli di refresh.

---

## 🛠️ Requisiti di Sistema

- macOS 14.0 (Sonoma) o versioni successive (Apple Silicon o Intel).
- Antigravity IDE attivo in background (da cui legge localmente le quote del piano).

---

## 📦 Installazione ed Esecuzione

### Download Release
Scarica l'archivio precompilato dalla sezione [Releases](https://github.com/muccio/ai-meter/releases):
1. Estrai `AIMeter-macOS-v1.0.0.zip`.
2. Trascina `AIMeter.app` nella cartella `/Applications` (o aprila direttamente).

### Compilazione dai sorgenti
```bash
git clone https://github.com/muccio/ai-meter.git
cd ai-meter
./scripts/build_app.sh
```
L'applicazione pronta all'uso si troverà in `build/AIMeter.app`.

---

## 🏗️ Architettura del Codice

```
Sources/
├── AIMeterCore/             # Libreria core indipendente
│   ├── Models/              # DaemonConfig, ModelQuotaItem, UserStatusResponse
│   ├── Services/            # DaemonDiscoveryService, QuotaMonitorService (Connect-RPC HTTPS)
│   └── ViewModels/          # QuotaViewModel con Timer reattivo e Combine
└── AIMeter/                 # Applicazione macOS
    ├── App/                 # AppDelegate (Window level .floating, NSStatusItem)
    ├── Views/               # ContentView, HeaderView, ModelQuotaRowView, SettingsView
    └── main.swift           # Entry point NSApplication
```

---

## 📄 Licenza

Rilasciato sotto licenza MIT.
