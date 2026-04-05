import SwiftUI

/// Editor zum Erstellen und Bearbeiten einer Notiz
/// Unterstützt Titel, Inhalt (Markdown), Kategorie
struct NotizEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    // Die zu bearbeitende Notiz (nil = neue Notiz)
    var notiz: Notiz?

    @State private var titel: String = ""
    @State private var inhalt: String = ""
    @State private var kategorie: String = "Schnell"
    @State private var zeigMarkdownVorschau = false

    private var istBearbeitung: Bool { notiz != nil }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Kategorie-Auswahl
                Picker("Kategorie", selection: $kategorie) {
                    ForEach(NotizenViewModel.kategorien, id: \.self) { kat in
                        Text(kat).tag(kat)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // MARK: - Titel
                TextField("Titel", text: $titel)
                    .font(.title2.bold())
                    .padding(.horizontal)

                Divider()
                    .padding(.vertical, 8)

                // MARK: - Inhalt (Editor oder Vorschau)
                if zeigMarkdownVorschau {
                    // Markdown-Vorschau
                    ScrollView {
                        VStack(alignment: .leading) {
                            if inhalt.isEmpty {
                                Text("Keine Vorschau verfügbar")
                                    .foregroundStyle(.secondary)
                            } else {
                                // iOS 15+ unterstützt Markdown in Text nativ
                                Text(LocalizedStringKey(inhalt))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                    }
                } else {
                    // Text-Editor
                    TextEditor(text: $inhalt)
                        .padding(.horizontal, 12)
                        .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(istBearbeitung ? "Notiz bearbeiten" : "Neue Notiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }

                ToolbarItem(placement: .principal) {
                    // Markdown-Vorschau Toggle
                    Button {
                        zeigMarkdownVorschau.toggle()
                    } label: {
                        Image(systemName: zeigMarkdownVorschau ? "pencil" : "eye")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") {
                        sichern()
                        dismiss()
                    }
                    .disabled(titel.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let notiz {
                    titel = notiz.titel
                    inhalt = notiz.inhalt
                    kategorie = notiz.kategorie
                }
            }
        }
    }

    // MARK: - Speichern

    private func sichern() {
        let getrimmterTitel = titel.trimmingCharacters(in: .whitespaces)
        guard !getrimmterTitel.isEmpty else { return }

        if let notiz {
            // Bestehende Notiz aktualisieren
            notiz.titel = getrimmterTitel
            notiz.inhalt = inhalt
            notiz.kategorie = kategorie
            notiz.geaendertAm = .now
        } else {
            // Neue Notiz erstellen
            let neue = Notiz(
                titel: getrimmterTitel,
                inhalt: inhalt,
                kategorie: kategorie
            )
            context.insert(neue)
        }
    }
}

#Preview("Neue Notiz") {
    NotizEditorView()
        .modelContainer(for: Notiz.self, inMemory: true)
}
