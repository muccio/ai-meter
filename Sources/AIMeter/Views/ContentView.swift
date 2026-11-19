import SwiftUI
import AIMeterCore

public struct ContentView: View {
    @ObservedObject var viewModel: QuotaViewModel
    @State private var showSettings: Bool = false

    public init(viewModel: QuotaViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top Header
                HeaderView(viewModel: viewModel, showSettings: $showSettings)

                Divider()

                // View Mode Picker (Limiti 5h/Settimanali vs Tutti i Modelli)
                Picker("", selection: $viewModel.viewMode) {
                    Text("Insieme").tag(QuotaViewMode.all)
                    Text("5h & Settimana").tag(QuotaViewMode.summary)
                    Text("Modelli (\(viewModel.models.count))").tag(QuotaViewMode.models)
                }
                .pickerStyle(.segmented)
                .controlSize(.small)
                .padding(.horizontal, 10)
                .padding(.top, 6)
                .padding(.bottom, 4)

                // Compact Search bar (if in all or models view)
                if viewModel.viewMode != .summary {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)

                        TextField("Filtra modelli...", text: $viewModel.searchQuery)
                            .textFieldStyle(.plain)
                            .font(.system(size: 11))

                        if !viewModel.searchQuery.isEmpty {
                            Button {
                                viewModel.searchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(.horizontal, 10)
                    .padding(.bottom, 4)
                }

                // Error banner if any
                if let error = viewModel.errorMessage {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 11))
                        Text(error)
                            .font(.system(size: 10))
                            .lineLimit(2)
                            .foregroundColor(.primary)
                        Spacer()
                        Button("Riprova") {
                            Task { await viewModel.refresh() }
                        }
                        .font(.system(size: 10, weight: .semibold))
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                }

                // Main Scrollable Content
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Section 1: Quota Groups with 5h & Weekly limits
                        if viewModel.viewMode == .all || viewModel.viewMode == .summary {
                            if !viewModel.quotaGroups.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("LIMITI A 5H E SETTIMANALI")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 2)

                                    ForEach(viewModel.quotaGroups) { group in
                                        QuotaGroupCardView(group: group)
                                    }
                                }
                            }
                        }

                        // Section 2: Detailed Models List
                        if viewModel.viewMode == .all || viewModel.viewMode == .models {
                            VStack(alignment: .leading, spacing: 6) {
                                if viewModel.viewMode == .all && !viewModel.quotaGroups.isEmpty {
                                    HStack {
                                        Text("DETTAGLIO MODELLI")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 2)
                                    .padding(.top, 4)
                                }

                                if viewModel.models.isEmpty && viewModel.isLoading {
                                    VStack(spacing: 10) {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Caricamento quote in corso...")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 120)
                                } else if viewModel.filteredModels.isEmpty {
                                    VStack(spacing: 8) {
                                        Image(systemName: "tray")
                                            .font(.system(size: 20))
                                            .foregroundColor(.secondary)
                                        Text(viewModel.searchQuery.isEmpty ? "Nessun modello trovato" : "Nessun modello corrispondente")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 80)
                                } else {
                                    ForEach(viewModel.filteredModels) { item in
                                        ModelQuotaRowView(item: item)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                }

                Divider()

                // Footer
                HStack(alignment: .center) {
                    if let updated = viewModel.lastUpdated {
                        Text("Aggiornato: \(formattedTime(updated))")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                    } else {
                        Text("In attesa dati...")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Countdown to next refresh
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                        Text("tra \(viewModel.nextRefreshSeconds)s")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.secondary.opacity(0.04))
            }

            // Settings overlay if active
            if showSettings {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showSettings = false
                    }

                SettingsView(viewModel: viewModel, isPresented: $showSettings)
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
        }
        .frame(minWidth: 340, idealWidth: 380, maxWidth: 440, minHeight: 400, idealHeight: 560, maxHeight: 850)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}
