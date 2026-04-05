import SwiftUI
import SwiftData

/// Lern-Session: Zeigt fällige Flashcards und bewertet mit SM-2
struct FlashcardLernView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Flashcard.naechsteWiederholung) private var alleFlashcards: [Flashcard]

    let deckName: String
    @State private var aktuellerIndex = 0
    @State private var zeigAntwort = false
    @State private var sessionFertig = false

    /// Fällige Karten in diesem Deck
    private var faelligeKarten: [Flashcard] {
        alleFlashcards.filter { $0.deck == deckName && $0.naechsteWiederholung <= .now }
    }

    /// Aktuelle Karte
    private var aktuelleKarte: Flashcard? {
        guard aktuellerIndex < faelligeKarten.count else { return nil }
        return faelligeKarten[aktuellerIndex]
    }

    var body: some View {
        VStack(spacing: 24) {
            if sessionFertig || faelligeKarten.isEmpty {
                // Session beendet
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)
                Text("Session fertig!")
                    .font(.title.bold())
                Text("Alle Karten für heute gelernt.")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Zurück") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 32)
            } else if let karte = aktuelleKarte {
                // Fortschritt
                HStack {
                    Text("Karte \(aktuellerIndex + 1) / \(faelligeKarten.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)

                Spacer()

                // MARK: - Flashcard
                VStack(spacing: 16) {
                    // Frage
                    Text(karte.frage)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .padding()

                    if zeigAntwort {
                        Divider()

                        // Antwort
                        Text(karte.antwort)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .onTapGesture {
                    if !zeigAntwort {
                        zeigAntwort = true
                    }
                }

                Spacer()

                // MARK: - Bewertung (nur wenn Antwort sichtbar)
                if zeigAntwort {
                    VStack(spacing: 8) {
                        Text("Wie gut wusstest du es?")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            bewertungsButton("Nochmal", farbe: .red, qualitaet: 1)
                            bewertungsButton("Schwer", farbe: .orange, qualitaet: 3)
                            bewertungsButton("Gut", farbe: .blue, qualitaet: 4)
                            bewertungsButton("Leicht", farbe: .green, qualitaet: 5)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("Tippe um die Antwort zu sehen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 32)
            }
        }
        .navigationTitle("Lernen")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Bewertungs-Button

    @ViewBuilder
    private func bewertungsButton(_ label: String, farbe: Color, qualitaet: Int) -> some View {
        Button {
            bewerten(qualitaet: qualitaet)
        } label: {
            Text(label)
                .font(.caption.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(.white)
                .background(farbe)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - SM-2 Bewertung anwenden

    private func bewerten(qualitaet: Int) {
        guard let karte = aktuelleKarte else { return }

        // SM-2 berechnen
        let ergebnis = SM2Algorithmus.berechne(
            qualitaet: qualitaet,
            wiederholungen: karte.wiederholungen,
            easeFactor: karte.easeFactor,
            intervall: karte.intervall
        )

        // Karte aktualisieren
        karte.intervall = ergebnis.intervall
        karte.wiederholungen = ergebnis.wiederholungen
        karte.easeFactor = ergebnis.easeFactor
        karte.naechsteWiederholung = ergebnis.naechsteWiederholung

        // Haptisches Feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        // Nächste Karte
        zeigAntwort = false
        if aktuellerIndex + 1 >= faelligeKarten.count {
            sessionFertig = true
        } else {
            aktuellerIndex += 1
        }
    }
}
