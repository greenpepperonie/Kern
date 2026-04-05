import SwiftUI
import SwiftData

/// KI-Lernassistent: Generiert Flashcards basierend auf Thema und Schwierigkeitsgrad
struct KILernassistentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var thema = ""
    @State private var schwierigkeitsgrad = "Schüler"
    @State private var anzahlKarten = 10
    @State private var deckName = ""
    @State private var laedtGerade = false
    @State private var fehler: String?
    @State private var generierteKarten: [(frage: String, antwort: String)] = []
    @State private var fertig = false

    /// Verfügbare Schwierigkeitsgrade
    private let schwierigkeitsgrade = [
        "8 Jahre alt",
        "Schüler (Mittelstufe)",
        "Schüler (Oberstufe)",
        "Student",
        "Experte"
    ]

    private let anzahlOptionen = [5, 10, 15, 20]

    var body: some View {
        NavigationStack {
            if fertig {
                // Erfolgsmeldung
                VStack(spacing: 24) {
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)
                    Text("\(generierteKarten.count) Karten erstellt!")
                        .font(.title.bold())
                    Text("Deck: \(deckName)")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Fertig") { dismiss() }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom, 32)
                }
            } else {
                Form {
                    // MARK: - Thema
                    Section("Was möchtest du lernen?") {
                        TextField("Thema (z.B. Photosynthese)", text: $thema)

                        TextField("Deck-Name", text: $deckName)
                            .onChange(of: thema) { _, neu in
                                // Auto-fill Deck-Name
                                if deckName.isEmpty || deckName == thema {
                                    deckName = neu
                                }
                            }
                    }

                    // MARK: - Schwierigkeitsgrad
                    Section("Schwierigkeitsgrad") {
                        Picker("Level", selection: $schwierigkeitsgrad) {
                            ForEach(schwierigkeitsgrade, id: \.self) { grad in
                                Text(grad).tag(grad)
                            }
                        }
                        .pickerStyle(.inline)
                        .labelsHidden()
                    }

                    // MARK: - Anzahl
                    Section("Anzahl Karten") {
                        Picker("Karten", selection: $anzahlKarten) {
                            ForEach(anzahlOptionen, id: \.self) { n in
                                Text("\(n) Karten").tag(n)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // MARK: - API-Status
                    if !ClaudeAPIService.shared.istKonfiguriert {
                        Section {
                            Label("API-Key fehlt — bitte in Einstellungen hinterlegen",
                                  systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                        }
                    }

                    // Fehlermeldung
                    if let fehler {
                        Section {
                            Text(fehler)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .navigationTitle("KI-Lernassistent")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if laedtGerade {
                            ProgressView()
                        } else {
                            Button("Generieren") {
                                generieren()
                            }
                            .disabled(
                                thema.trimmingCharacters(in: .whitespaces).isEmpty ||
                                !ClaudeAPIService.shared.istKonfiguriert
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - KI-Generierung

    private func generieren() {
        fehler = nil
        laedtGerade = true

        Task {
            do {
                let karten = try await ClaudeAPIService.shared.flashcardsGenerieren(
                    thema: thema,
                    schwierigkeitsgrad: schwierigkeitsgrad,
                    anzahl: anzahlKarten
                )

                // Flashcards in SwiftData speichern
                let deck = deckName.trimmingCharacters(in: .whitespaces)
                for karte in karten {
                    let flashcard = Flashcard(
                        frage: karte.frage,
                        antwort: karte.antwort,
                        deck: deck.isEmpty ? thema : deck
                    )
                    context.insert(flashcard)
                }

                // Lernset erstellen falls nicht vorhanden
                let lernsetName = deck.isEmpty ? thema : deck
                let lernset = Lernset(
                    name: lernsetName,
                    beschreibung: "KI-generiert: \(thema) (\(schwierigkeitsgrad))"
                )
                context.insert(lernset)

                generierteKarten = karten
                fertig = true

                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } catch {
                fehler = error.localizedDescription
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }

            laedtGerade = false
        }
    }
}

#Preview {
    KILernassistentView()
        .modelContainer(for: [Flashcard.self, Lernset.self], inMemory: true)
}
