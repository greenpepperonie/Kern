import SwiftUI
import SwiftData

/// Hauptansicht für den Lernen-Tab
/// Zeigt Lernsets, fällige Karten und Lernstreak
struct LernenView: View {
    @Environment(\.modelContext) private var context
    @Query private var flashcards: [Flashcard]
    @Query private var lernsets: [Lernset]
    @State private var zeigNeuesLernset = false
    @State private var neuerDeckName = ""

    /// Alle einzigartigen Deck-Namen (aus Flashcards + Lernsets)
    private var deckNamen: [String] {
        let ausKarten = Set(flashcards.map(\.deck))
        let ausLernsets = Set(lernsets.map(\.name))
        return Array(ausKarten.union(ausLernsets)).sorted()
    }

    /// Gesamtzahl heute fälliger Karten
    private var heuteFaellig: Int {
        flashcards.filter { $0.naechsteWiederholung <= .now }.count
    }

    var body: some View {
        List {
            // MARK: - Übersicht
            Section {
                NavigationLink {
                    LernstreakView()
                } label: {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("Lernstreak")
                        Spacer()
                        if heuteFaellig > 0 {
                            Text("\(heuteFaellig) fällig")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.orange.opacity(0.15))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            // MARK: - Lernsets
            Section("Lernsets") {
                if deckNamen.isEmpty {
                    ContentUnavailableView(
                        "Keine Lernsets",
                        systemImage: "brain.head.profile",
                        description: Text("Erstelle dein erstes Lernset")
                    )
                } else {
                    ForEach(deckNamen, id: \.self) { name in
                        NavigationLink {
                            LernsetDetailView(deckName: name)
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.on.rectangle")
                                    .foregroundStyle(Color.accentColor)
                                VStack(alignment: .leading) {
                                    Text(name)
                                        .font(.headline)
                                    let anzahl = flashcards.filter { $0.deck == name }.count
                                    Text("\(anzahl) Karten")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                let faellig = flashcards.filter { $0.deck == name && $0.naechsteWiederholung <= .now }.count
                                if faellig > 0 {
                                    Text("\(faellig)")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.orange.opacity(0.15))
                                        .foregroundStyle(.orange)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deckLoeschen(name)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Lernen")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    zeigNeuesLernset = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Neues Lernset", isPresented: $zeigNeuesLernset) {
            TextField("Name", text: $neuerDeckName)
            Button("Erstellen") {
                let name = neuerDeckName.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { return }
                let lernset = Lernset(name: name)
                context.insert(lernset)
                neuerDeckName = ""
            }
            Button("Abbrechen", role: .cancel) {
                neuerDeckName = ""
            }
        }
    }

    /// Löscht ein Deck und alle zugehörigen Flashcards
    private func deckLoeschen(_ name: String) {
        // Flashcards des Decks löschen
        for karte in flashcards where karte.deck == name {
            context.delete(karte)
        }
        // Lernset löschen
        for lernset in lernsets where lernset.name == name {
            context.delete(lernset)
        }
    }
}

#Preview {
    NavigationStack {
        LernenView()
    }
    .modelContainer(for: [Flashcard.self, Lernset.self], inMemory: true)
}
