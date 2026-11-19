import SwiftUI
import AIMeterCore

public struct HeaderView: View {
    @ObservedObject var viewModel: QuotaViewModel
    @Binding var showSettings: Bool

    public var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                // Title and Plan Badge
                HStack(spacing: 6) {
                    Image(systemName: "gauge.with.needle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    Text("AI Meter")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    
                    Text("PRO")
                        .font(.system(size: 9, weight: .heavy))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(
                            LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }

                Spacer()

                // Actions: Always-on-top, Refresh, Settings
                HStack(spacing: 4) {
                    // Always-on-top toggle
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.toggleAlwaysOnTop()
                        }
                    } label: {
                        Image(systemName: viewModel.isAlwaysOnTop ? "pin.fill" : "pin")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(viewModel.isAlwaysOnTop ? Color.yellow : Color.secondary)
                            .frame(width: 26, height: 26)
                            .background(viewModel.isAlwaysOnTop ? Color.yellow.opacity(0.18) : Color.clear)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .help(viewModel.isAlwaysOnTop ? "Sempre in primo piano (Attivo)" : "Sempre in primo piano (Disattivato)")

                    // Manual refresh button
                    Button {
                        Task {
                            await viewModel.refresh()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12, weight: .semibold))
                            .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                            .animation(viewModel.isLoading ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isLoading)
                            .foregroundStyle(Color.secondary)
                            .frame(width: 26, height: 26)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isLoading)
                    .help("Aggiorna adesso")

                    // Settings toggle
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(showSettings ? Color.blue : Color.secondary)
                            .frame(width: 26, height: 26)
                            .background(showSettings ? Color.blue.opacity(0.18) : Color.clear)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .help("Impostazioni intervallo")
                }
            }

            // Credits pill bar if available
            if viewModel.promptCredits > 0 || viewModel.flowCredits > 0 {
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Text("Prompt:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("\(viewModel.promptCredits)")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                    HStack(spacing: 4) {
                        Text("Flow:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("\(viewModel.flowCredits)")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                    Spacer()
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }
}
