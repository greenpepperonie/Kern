import SwiftUI
import SwiftData

/// Hauptansicht für den Aufgaben-Tab
/// Zeigt alle Aufgaben gruppiert nach offen/erledigt mit Such- und Filterfunktion
struct AufgabenView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Aufgabe.erstelltAm, order: .reverse) private var aufgaben: [Aufgabe]
    @State private var viewModel = AufgabenViewModel()
    @State private var suchtext = ""
    @State private var zeigTimer = false

    /// Gefilterte Aufgaben basierend auf Suchtext
    private var gefilterteAufgaben: [Aufgabe] {
        if suchtext.isEmpty {
            return aufgaben
        }
        return aufgaben.filter {
            $0.titel.localizedCaseInsensitiveContains(suchtext) ||
            $0.kategorie.localizedCaseInsensitiveContains(suchtext)
        }
    }

    /// Offene Aufgaben (nicht erledigt)
    private var offeneAufgaben: [Aufgabe] {
        gefilterteAufgaben.filter { !$0.erledigt }
    }

    /// Erledigte Aufgaben
    private var erledigteAufgaben: [Aufgabe] {
        gefilterteAufgaben.filter { $0.erledigt }
    }

    var body: some View {
        List {
            // MARK: - Schnellzugriffe
            Section {
                NavigationLink {
                    EinkaufslisteView()
                } label: {
                    Label("Einkaufsliste", systemImage: "cart.fill")
                }

                NavigationLink {
                    EisenhowerView()
                } label: {
                    Label("Eisenhower-Matrix", systemImage: "square.grid.2x2.fill")
                }

                NavigationLink {
                    FokusModusView()
                } label: {
                    Label("Fokus-Modus", systemImage: "scope")
                }

                NavigationLink {
                    WochenreviewView()
                } label: {
                    Label("Wochenreview", systemImage: "chart.bar.fill")
                }
            }

            if aufgaben.isEmpty {
                // Platzhalter wenn noch keine Aufgaben vorhanden
                ContentUnavailableView(
                    "Keine Aufgaben",
                    systemImage: "checkmark.circle",
                    description: Text("Tippe auf + um deine erste Aufgabe zu erstellen")
                )
            } else {
                // MARK: - Offene Aufgaben
                if !offeneAufgaben.isEmpty {
                    Section("Offen (\(offeneAufgaben.count))") {
                        ForEach(offeneAufgaben) { aufgabe in
                            AufgabeZeileView(aufgabe: aufgabe) {
                                viewModel.aufgabeToggle(aufgabe)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.aufgabeLoeschen(aufgabe, context: context)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    viewModel.bearbeitenStarten(aufgabe)
                                } label: {
                                    Label("Bearbeiten", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }

                // MARK: - Erledigte Aufgaben (einklappbar)
                if !erledigteAufgaben.isEmpty {
                    Section("Erledigt (\(erledigteAufgaben.count))") {
                        ForEach(erledigteAufgaben) { aufgabe in
                            AufgabeZeileView(aufgabe: aufgabe) {
                                viewModel.aufgabeToggle(aufgabe)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.aufgabeLoeschen(aufgabe, context: context)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $suchtext, prompt: "Aufgaben durchsuchen")
        .navigationTitle("Aufgaben")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    EinstellungenView()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 16) {
                    // Timer öffnen
                    NavigationLink {
                        TimerView()
                    } label: {
                        Image(systemName: "timer")
                    }

                    // Neue Aufgabe erstellen
                    Button {
                        viewModel.zeigNeueAufgabeSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        // Sheet: Neue Aufgabe erstellen
        .sheet(isPresented: $viewModel.zeigNeueAufgabeSheet) {
            AufgabeFormularView()
        }
        // Sheet: Aufgabe bearbeiten
        .sheet(isPresented: $viewModel.zeigBearbeitenSheet) {
            if let aufgabe = viewModel.ausgewaehlteAufgabe {
                AufgabeFormularView(aufgabe: aufgabe)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AufgabenView()
    }
    .modelContainer(for: Aufgabe.self, inMemory: true)
}
