import SwiftUI
import AIMeterCore

public struct SettingsView: View {
    @ObservedObject var viewModel: QuotaViewModel
    @Binding var isPresented: Bool

    private let intervals = [5, 10, 15, 30, 60, 120]

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Impostazioni")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
            }

            Divider()

            // Refresh interval section
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Intervallo di aggiornamento:")
                        .font(.system(size: 11, weight: .medium))
                    Spacer()
                    Text("\(viewModel.refreshInterval)s")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                }

                HStack(spacing: 4) {
                    ForEach(intervals, id: \.self) { seconds in
                        Button {
                            viewModel.setRefreshInterval(seconds)
                        } label: {
                            Text("\(seconds)s")
                                .font(.system(size: 10, weight: .medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .frame(maxWidth: .infinity)
                                .background(viewModel.refreshInterval == seconds ? Color.blue : Color.secondary.opacity(0.12))
                                .foregroundColor(viewModel.refreshInterval == seconds ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Always on top toggle
            Toggle(isOn: Binding(
                get: { viewModel.isAlwaysOnTop },
                set: { _ in viewModel.toggleAlwaysOnTop() }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Finestra Always on Top")
                        .font(.system(size: 11, weight: .medium))
                    Text("Mantiene la finestra sopra le altre applicazioni")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
            .toggleStyle(.switch)

            Divider()

            // Info text
            HStack {
                Text("Modelli rilevati automaticamente da Google AI Pro")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(12)
        .background(Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
        .shadow(radius: 6)
        .padding(10)
    }
}
