import SwiftUI
import SwiftData

/// Einkaufsliste mit smarter Kategorie-Sortierung und schnellem Hinzufügen
/// Gegenstände werden als Aufgaben mit Kategorie "Einkauf" gespeichert
struct EinkaufslisteView: View {
    @Environment(\.modelContext) private var context
    @Query(
        filter: #Predicate<Aufgabe> { $0.kategorie == "Einkauf" },
        sort: \Aufgabe.erstelltAm,
        order: .reverse
    ) private var alleArtikel: [Aufgabe]

    @State private var neuerArtikel = ""
    @State private var ausgewaehlteKategorie = "Sonstiges"
    @FocusState private var eingabeFokussiert: Bool

    /// Vordefinierte Einkaufskategorien mit passenden Symbolen
    private static let kategorieSymbole: [(name: String, symbol: String)] = [
        ("Obst & Gemüse", "leaf.fill"),
        ("Milchprodukte", "cup.and.saucer.fill"),
        ("Fleisch & Fisch", "fork.knife"),
        ("Backwaren", "birthday.cake.fill"),
        ("Getränke", "waterbottle.fill"),
        ("Haushalt", "house.fill"),
        ("Tiefkühl", "snowflake"),
        ("Snacks", "popcorn.fill"),
        ("Sonstiges", "bag.fill"),
    ]

    /// Artikel gruppiert nach Unterkategorie und sortiert
    private var gruppiertNachKategorie: [(String, [Aufgabe])] {
        let gruppen = Dictionary(grouping: nichtErledigteArtikel) { artikel -> String in
            // Unterkategorie aus dem Titel extrahieren (gespeichert als "Kategorie|Titel")
            let teile = artikel.titel.split(separator: "|", maxSplits: 1)
            return teile.count > 1 ? String(teile[0]) : "Sonstiges"
        }
        // Sortierung nach der Reihenfolge der vordefinierten Kategorien
        let reihenfolge = Self.kategorieSymbole.map(\.name)
        return gruppen.sorted { a, b in
            let indexA = reihenfolge.firstIndex(of: a.key) ?? reihenfolge.count
            let indexB = reihenfolge.firstIndex(of: b.key) ?? reihenfolge.count
            return indexA < indexB
        }
    }

    private var nichtErledigteArtikel: [Aufgabe] {
        alleArtikel.filter { !$0.erledigt }
    }

    private var erledigteArtikel: [Aufgabe] {
        alleArtikel.filter { $0.erledigt }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Schnelles Hinzufügen
            HStack(spacing: 12) {
                // Kategorie-Auswahl (kompakt)
                Menu {
                    ForEach(Self.kategorieSymbole, id: \.name) { kat in
                        Button {
                            ausgewaehlteKategorie = kat.name
                        } label: {
                            Label(kat.name, systemImage: kat.symbol)
                        }
                    }
                } label: {
                    Image(systemName: symbolFuerKategorie(ausgewaehlteKategorie))
                        .frame(width: 32, height: 32)
                        .background(.quaternary)
                        .clipShape(Circle())
                }

                // Textfeld für neuen Artikel
                TextField("Artikel hinzufügen…", text: $neuerArtikel)
                    .focused($eingabeFokussiert)
                    .onSubmit {
                        artikelHinzufuegen()
                    }
                    .submitLabel(.done)

                // Hinzufügen-Button
                Button {
                    artikelHinzufuegen()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .disabled(neuerArtikel.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .background(.bar)

            // MARK: - Artikelliste
            List {
                if alleArtikel.isEmpty {
                    ContentUnavailableView(
                        "Einkaufsliste leer",
                        systemImage: "cart",
                        description: Text("Füge oben deinen ersten Artikel hinzu")
                    )
                } else {
                    // Nicht erledigte Artikel nach Kategorie gruppiert
                    ForEach(gruppiertNachKategorie, id: \.0) { kategorie, artikel in
                        Section {
                            ForEach(artikel) { item in
                                artikelZeile(item)
                            }
                        } header: {
                            Label(kategorie, systemImage: symbolFuerKategorie(kategorie))
                        }
                    }

                    // Erledigte Artikel
                    if !erledigteArtikel.isEmpty {
                        Section("Im Wagen (\(erledigteArtikel.count))") {
                            ForEach(erledigteArtikel) { item in
                                artikelZeile(item)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Einkaufsliste")
        .toolbar {
            // Erledigte Artikel löschen
            if !erledigteArtikel.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button("Aufräumen") {
                        erledigteLoeschen()
                    }
                }
            }
        }
    }

    // MARK: - Artikel-Zeile

    /// Zeigt einen einzelnen Artikel mit Checkbox
    @ViewBuilder
    private func artikelZeile(_ artikel: Aufgabe) -> some View {
        HStack(spacing: 12) {
            Button {
                artikel.erledigt.toggle()
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            } label: {
                Image(systemName: artikel.erledigt ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(artikel.erledigt ? .green : .secondary)
            }
            .buttonStyle(.plain)

            // Anzeigename (ohne Kategorie-Prefix)
            Text(anzeigeName(artikel))
                .strikethrough(artikel.erledigt)
                .foregroundStyle(artikel.erledigt ? .secondary : .primary)

            Spacer()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                context.delete(artikel)
            } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
    }

    // MARK: - Hilfsfunktionen

    /// Fügt einen neuen Artikel zur Einkaufsliste hinzu
    private func artikelHinzufuegen() {
        let name = neuerArtikel.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        // Speichere als "Kategorie|Artikelname"
        let artikel = Aufgabe(
            titel: "\(ausgewaehlteKategorie)|\(name)",
            kategorie: "Einkauf"
        )
        context.insert(artikel)
        neuerArtikel = ""

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Extrahiert den Anzeigenamen aus dem Titel (entfernt Kategorie-Prefix)
    private func anzeigeName(_ artikel: Aufgabe) -> String {
        let teile = artikel.titel.split(separator: "|", maxSplits: 1)
        return teile.count > 1 ? String(teile[1]) : artikel.titel
    }

    /// Gibt das SF Symbol für eine Einkaufskategorie zurück
    private func symbolFuerKategorie(_ kategorie: String) -> String {
        Self.kategorieSymbole.first { $0.name == kategorie }?.symbol ?? "bag.fill"
    }

    /// Löscht alle erledigten Artikel
    private func erledigteLoeschen() {
        for artikel in erledigteArtikel {
            context.delete(artikel)
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    NavigationStack {
        EinkaufslisteView()
    }
    .modelContainer(for: Aufgabe.self, inMemory: true)
}
