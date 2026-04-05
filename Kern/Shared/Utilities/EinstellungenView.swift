import SwiftUI
import SwiftData

/// Einstellungen-View mit Export-Funktion und App-Info
/// Erreichbar über einen Zahnrad-Button in der Tab-Bar oder Navigation
struct EinstellungenView: View {
    @Environment(\.modelContext) private var context
    @State private var exportURL: URL?
    @State private var zeigShareSheet = false
    @State private var exportFehler: String?
    @State private var exportiert = false
    @State private var apiKey: String = UserDefaults.standard.string(forKey: "anthropic_api_key") ?? ""

    var body: some View {
        List {
            // MARK: - KI-Integration
            Section("Claude API (KI-Features)") {
                SecureField("API-Key", text: $apiKey)
                    .onChange(of: apiKey) { _, neuerKey in
                        UserDefaults.standard.set(neuerKey, forKey: "anthropic_api_key")
                    }

                if ClaudeAPIService.shared.istKonfiguriert {
                    Label("API-Key gespeichert", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                } else {
                    Label("Für KI-Lernassistent und smarte Einkaufsliste", systemImage: "info.circle")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }

            // MARK: - Daten
            Section("Daten") {
                Button {
                    exportieren()
                } label: {
                    Label("Alle Daten exportieren (JSON)", systemImage: "square.and.arrow.up")
                }

                if exportiert {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Export erfolgreich!")
                            .foregroundStyle(.green)
                    }
                }

                if let fehler = exportFehler {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Text(fehler)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }

            // MARK: - App-Info
            Section("Über Kern") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Plattform")
                    Spacer()
                    Text("iOS 17+")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Daten")
                    Spacer()
                    Text("Lokal auf dem Gerät")
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: - Datenschutz
            Section {
                Label("Alle Daten bleiben auf deinem Gerät", systemImage: "lock.shield.fill")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .navigationTitle("Einstellungen")
        .sheet(isPresented: $zeigShareSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }

    /// Exportiert alle Daten und öffnet das Share-Sheet
    private func exportieren() {
        exportFehler = nil
        exportiert = false

        do {
            let url = try DatenExport.exportieren(context: context)
            exportURL = url
            zeigShareSheet = true
            exportiert = true

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            exportFehler = "Export fehlgeschlagen: \(error.localizedDescription)"
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

/// UIKit Share-Sheet Wrapper für SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        EinstellungenView()
    }
    .modelContainer(for: [
        Aufgabe.self, Notiz.self, Flashcard.self,
        Lernset.self, GesundheitsEintrag.self, Kontakt.self
    ], inMemory: true)
}
