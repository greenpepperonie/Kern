import SwiftUI
import SwiftData

/// Übersicht aller Einkaufslisten
/// Ermöglicht das Erstellen und Verwalten mehrerer Listen (z.B. Rewe, Aldi)
struct EinkaufslistenUebersicht: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \EinkaufsArtikel.erstelltAm) private var alleArtikel: [EinkaufsArtikel]
    @State private var zeigNeueListe = false
    @State private var neuerListenName = ""

    /// Alle einzigartigen Listennamen
    private var listenNamen: [String] {
        Array(Set(alleArtikel.map(\.liste))).sorted()
    }

    var body: some View {
        List {
            // Neue Liste erstellen
            Section {
                Button {
                    zeigNeueListe = true
                } label: {
                    Label("Neue Liste erstellen", systemImage: "plus.circle")
                }
            }

            // Vorhandene Listen
            if listenNamen.isEmpty {
                ContentUnavailableView(
                    "Keine Einkaufslisten",
                    systemImage: "cart",
                    description: Text("Erstelle deine erste Einkaufsliste")
                )
            } else {
                Section("Meine Listen") {
                    ForEach(listenNamen, id: \.self) { name in
                        NavigationLink {
                            EinkaufslisteDetailView(listenName: name)
                        } label: {
                            HStack {
                                Image(systemName: "cart.fill")
                                    .foregroundStyle(Color.accentColor)
                                VStack(alignment: .leading) {
                                    Text(name)
                                        .font(.headline)
                                    let offene = alleArtikel.filter { $0.liste == name && !$0.erledigt }.count
                                    let gesamt = alleArtikel.filter { $0.liste == name }.count
                                    Text("\(offene) offen / \(gesamt) gesamt")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                let offene = alleArtikel.filter { $0.liste == name && !$0.erledigt }.count
                                if offene > 0 {
                                    Text("\(offene)")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.accentColor.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                listeLoeschen(name)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Einkaufslisten")
        .alert("Neue Einkaufsliste", isPresented: $zeigNeueListe) {
            TextField("Name (z.B. Rewe)", text: $neuerListenName)
            Button("Erstellen") {
                let name = neuerListenName.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { return }
                // Erstelle einen Platzhalter-Artikel damit die Liste existiert
                // Der wird sofort gelöscht wenn der User seinen ersten Artikel hinzufügt
                // Alternativ: Leere Liste einfach über den Namen merken
                // Wir navigieren direkt zur neuen leeren Liste
                neuerListenName = ""
            }
            Button("Abbrechen", role: .cancel) {
                neuerListenName = ""
            }
        }
    }

    private func listeLoeschen(_ name: String) {
        for artikel in alleArtikel where artikel.liste == name {
            context.delete(artikel)
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

// MARK: - Detail-Ansicht einer einzelnen Einkaufsliste

/// Zeigt eine einzelne Einkaufsliste mit Artikeln gruppiert nach Kategorie
struct EinkaufslisteDetailView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \EinkaufsArtikel.erstelltAm) private var alleArtikel: [EinkaufsArtikel]
    @Query private var kategorieMappings: [KategorieMapping]

    let listenName: String
    @State private var neuerArtikel = ""
    @FocusState private var eingabeFokussiert: Bool
    @State private var kategorisiereGerade = false

    /// Vordefinierte Einkaufskategorien mit Symbolen
    static let kategorieSymbole: [(name: String, symbol: String)] = [
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

    /// Artikel dieser Liste
    private var artikelDerListe: [EinkaufsArtikel] {
        alleArtikel.filter { $0.liste == listenName }
    }

    private var offeneArtikel: [EinkaufsArtikel] {
        artikelDerListe.filter { !$0.erledigt }
    }

    private var erledigteArtikel: [EinkaufsArtikel] {
        artikelDerListe.filter { $0.erledigt }
    }

    /// Offene Artikel gruppiert nach Kategorie
    private var gruppiertNachKategorie: [(String, [EinkaufsArtikel])] {
        let gruppen = Dictionary(grouping: offeneArtikel) { $0.kategorie }
        let reihenfolge = Self.kategorieSymbole.map(\.name)
        return gruppen.sorted { a, b in
            let indexA = reihenfolge.firstIndex(of: a.key) ?? reihenfolge.count
            let indexB = reihenfolge.firstIndex(of: b.key) ?? reihenfolge.count
            return indexA < indexB
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Schnelles Hinzufügen
            HStack(spacing: 12) {
                TextField("Artikel hinzufügen…", text: $neuerArtikel)
                    .focused($eingabeFokussiert)
                    .onSubmit { artikelHinzufuegen() }
                    .submitLabel(.done)

                if kategorisiereGerade {
                    ProgressView()
                        .frame(width: 24, height: 24)
                } else {
                    Button {
                        artikelHinzufuegen()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(neuerArtikel.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding()
            .background(.bar)

            // MARK: - Artikelliste
            List {
                if artikelDerListe.isEmpty {
                    ContentUnavailableView(
                        "Liste leer",
                        systemImage: "cart",
                        description: Text("Füge oben deinen ersten Artikel hinzu")
                    )
                } else {
                    // Offene Artikel nach Kategorie
                    ForEach(gruppiertNachKategorie, id: \.0) { kategorie, artikel in
                        Section {
                            ForEach(artikel) { item in
                                artikelZeile(item)
                            }
                        } header: {
                            Label(kategorie, systemImage: symbolFuer(kategorie))
                        }
                    }

                    // Erledigte
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
        .navigationTitle(listenName)
        .toolbar {
            if !erledigteArtikel.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button("Aufräumen") {
                        for item in erledigteArtikel {
                            context.delete(item)
                        }
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                }
            }
        }
    }

    // MARK: - Artikel-Zeile

    @ViewBuilder
    private func artikelZeile(_ artikel: EinkaufsArtikel) -> some View {
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

            Text(artikel.name)
                .strikethrough(artikel.erledigt)
                .foregroundStyle(artikel.erledigt ? .secondary : .primary)

            Spacer()

            Text(artikel.kategorie)
                .font(.caption2)
                .foregroundStyle(.secondary)
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

    /// Fügt Artikel hinzu — prüft zuerst lokalen Kategorie-Cache, dann ggf. KI
    private func artikelHinzufuegen() {
        let name = neuerArtikel.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        // Kategorie aus lokalem Cache suchen
        let normalisiert = name.lowercased()
        let kategorie: String
        if let mapping = kategorieMappings.first(where: { $0.artikelName == normalisiert }) {
            // Bereits bekanntes Item → lokal gecachte Kategorie verwenden
            kategorie = mapping.kategorie
        } else {
            // Unbekanntes Item → erst mal "Sonstiges", KI-Zuordnung kommt später
            kategorie = kategorieVermuten(name)
            // Mapping speichern für die Zukunft
            let neuesMapping = KategorieMapping(artikelName: name, kategorie: kategorie)
            context.insert(neuesMapping)
        }

        let artikel = EinkaufsArtikel(
            name: name,
            kategorie: kategorie,
            liste: listenName
        )
        context.insert(artikel)
        neuerArtikel = ""

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Einfache regelbasierte Kategorie-Vermutung als Fallback
    /// Wird durch KI-Integration ersetzt wenn API-Key vorhanden
    private func kategorieVermuten(_ name: String) -> String {
        let lower = name.lowercased()

        // Obst & Gemüse
        let obstGemuese = ["apfel", "banane", "tomate", "gurke", "salat", "karotte", "zwiebel",
                           "paprika", "kartoffel", "zitrone", "orange", "birne", "erdbeere",
                           "brokkoli", "spinat", "avocado", "knoblauch", "ingwer", "pilze",
                           "champignon", "kräuter", "basilikum", "petersilie", "trauben", "melone"]
        if obstGemuese.contains(where: { lower.contains($0) }) { return "Obst & Gemüse" }

        // Milchprodukte
        let milch = ["milch", "käse", "joghurt", "butter", "sahne", "quark", "schmand",
                     "frischkäse", "mozzarella", "parmesan", "gouda", "ei", "eier"]
        if milch.contains(where: { lower.contains($0) }) { return "Milchprodukte" }

        // Fleisch & Fisch
        let fleisch = ["fleisch", "hähnchen", "huhn", "rind", "schwein", "wurst", "schinken",
                       "fisch", "lachs", "thunfisch", "hack", "steak", "schnitzel", "salami"]
        if fleisch.contains(where: { lower.contains($0) }) { return "Fleisch & Fisch" }

        // Backwaren
        let backwaren = ["brot", "brötchen", "semmel", "toast", "kuchen", "croissant", "mehl",
                         "hefe", "brezel", "baguette"]
        if backwaren.contains(where: { lower.contains($0) }) { return "Backwaren" }

        // Getränke
        let getraenke = ["wasser", "saft", "cola", "bier", "wein", "limonade", "tee", "kaffee",
                         "sprudel", "fanta", "sprite", "energy", "smoothie"]
        if getraenke.contains(where: { lower.contains($0) }) { return "Getränke" }

        // Haushalt
        let haushalt = ["spülmittel", "waschmittel", "klopapier", "toilettenpapier", "seife",
                        "shampoo", "zahnpasta", "müllbeutel", "schwamm", "reiniger", "tücher"]
        if haushalt.contains(where: { lower.contains($0) }) { return "Haushalt" }

        // Tiefkühl
        let tiefkuehl = ["pizza", "tiefkühl", "eis", "pommes", "tk-", "gefror"]
        if tiefkuehl.contains(where: { lower.contains($0) }) { return "Tiefkühl" }

        // Snacks
        let snacks = ["chips", "schokolade", "keks", "gummibärchen", "nüsse", "riegel",
                      "popcorn", "cracker", "müsli"]
        if snacks.contains(where: { lower.contains($0) }) { return "Snacks" }

        return "Sonstiges"
    }

    private func symbolFuer(_ kategorie: String) -> String {
        Self.kategorieSymbole.first { $0.name == kategorie }?.symbol ?? "bag.fill"
    }
}

#Preview {
    NavigationStack {
        EinkaufslistenUebersicht()
    }
    .modelContainer(for: [EinkaufsArtikel.self, KategorieMapping.self], inMemory: true)
}
