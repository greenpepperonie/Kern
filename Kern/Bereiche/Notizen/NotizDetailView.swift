import SwiftUI

/// Detailansicht einer Notiz mit Markdown-Rendering
struct NotizDetailView: View {
    let notiz: Notiz
    @State private var zeigBearbeiten = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Metadaten
                HStack {
                    // Kategorie-Badge
                    Text(notiz.kategorie)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(farbeFuerKategorie(notiz.kategorie).opacity(0.15))
                        .foregroundStyle(farbeFuerKategorie(notiz.kategorie))
                        .clipShape(Capsule())

                    Spacer()

                    // Änderungsdatum
                    Text(notiz.geaendertAm.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Verschlüsselungs-Hinweis
                if notiz.istVerschluesselt {
                    Label("Verschlüsselt", systemImage: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                Divider()

                // MARK: - Inhalt als Markdown
                if notiz.inhalt.isEmpty {
                    Text("Kein Inhalt")
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    Text(LocalizedStringKey(notiz.inhalt))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationTitle(notiz.titel)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    zeigBearbeiten = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $zeigBearbeiten) {
            NotizEditorView(notiz: notiz)
        }
    }

    /// Gibt eine passende Farbe für die Kategorie zurück
    private func farbeFuerKategorie(_ kategorie: String) -> Color {
        switch kategorie {
        case "Schnell": return .blue
        case "Idee": return .purple
        case "Brain Dump": return .orange
        default: return .secondary
        }
    }
}
