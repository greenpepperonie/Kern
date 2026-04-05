import SwiftUI
import SwiftData

/// Detailansicht eines Lernsets — zeigt alle Flashcards im Deck
struct LernsetDetailView: View {
    @Environment(\.modelContext) private var context
    let deckName: String

    @Query(sort: \Flashcard.naechsteWiederholung) private var alleFlashcards: [Flashcard]
    @State private var zeigNeueKarte = false

    /// Karten in diesem Deck
    private var karten: [Flashcard] {
        alleFlashcards.filter { $0.deck == deckName }
    }

    /// Karten die heute fällig sind
    private var faelligeKarten: [Flashcard] {
        karten.filter { $0.naechsteWiederholung <= .now }
    }

    var body: some View {
        List {
            // MARK: - Lern-Button
            if !faelligeKarten.isEmpty {
                Section {
                    NavigationLink {
                        FlashcardLernView(deckName: deckName)
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundStyle(Color.accentColor)
                            Text("\(faelligeKarten.count) Karten lernen")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }

            // MARK: - Alle Karten
            Section("Karten (\(karten.count))") {
                if karten.isEmpty {
                    ContentUnavailableView(
                        "Keine Karten",
                        systemImage: "rectangle.on.rectangle",
                        description: Text("Füge deine erste Lernkarte hinzu")
                    )
                } else {
                    ForEach(karten) { karte in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(karte.frage)
                                .font(.headline)
                            Text(karte.antwort)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)

                            HStack {
                                // Nächste Wiederholung
                                Label(
                                    karte.naechsteWiederholung.formatted(date: .abbreviated, time: .omitted),
                                    systemImage: "calendar"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)

                                Spacer()

                                // Ease Factor als Schwierigkeit
                                Text("EF: \(karte.easeFactor, specifier: "%.1f")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                context.delete(karte)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(deckName)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    zeigNeueKarte = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $zeigNeueKarte) {
            FlashcardFormularView(deckName: deckName)
        }
    }
}
