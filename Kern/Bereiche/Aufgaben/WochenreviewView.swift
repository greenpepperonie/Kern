import SwiftUI
import SwiftData

/// Wochenreview: Zusammenfassung der vergangenen Woche
/// Zeigt erledigte Aufgaben, Statistiken und Produktivitätstrend
struct WochenreviewView: View {
    @Query private var alleAufgaben: [Aufgabe]

    /// Start der aktuellen Woche (Montag)
    private var wochenstart: Date {
        let kalender = Calendar.current
        let heute = kalender.startOfDay(for: .now)
        // Woche beginnt am Montag
        let wochentag = kalender.component(.weekday, from: heute)
        // weekday: 1=So, 2=Mo, ... 7=Sa
        let tageZurueck = (wochentag + 5) % 7
        return kalender.date(byAdding: .day, value: -tageZurueck, to: heute) ?? heute
    }

    /// Start der vorherigen Woche
    private var vorherigerWochenstart: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: wochenstart) ?? wochenstart
    }

    /// Aufgaben die diese Woche erledigt wurden
    private var dieseWocheErledigt: [Aufgabe] {
        alleAufgaben.filter { aufgabe in
            aufgabe.erledigt && aufgabe.erstelltAm >= wochenstart
        }
    }

    /// Aufgaben die letzte Woche erledigt wurden
    private var letzteWocheErledigt: [Aufgabe] {
        alleAufgaben.filter { aufgabe in
            aufgabe.erledigt &&
            aufgabe.erstelltAm >= vorherigerWochenstart &&
            aufgabe.erstelltAm < wochenstart
        }
    }

    /// Diese Woche erstellte Aufgaben
    private var dieseWocheErstellt: [Aufgabe] {
        alleAufgaben.filter { $0.erstelltAm >= wochenstart }
    }

    /// Noch offene Aufgaben
    private var offeneAufgaben: [Aufgabe] {
        alleAufgaben.filter { !$0.erledigt }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Übersicht-Karten
                HStack(spacing: 16) {
                    StatistikKarte(
                        titel: "Erledigt",
                        wert: "\(dieseWocheErledigt.count)",
                        symbol: "checkmark.circle.fill",
                        farbe: .green
                    )
                    StatistikKarte(
                        titel: "Erstellt",
                        wert: "\(dieseWocheErstellt.count)",
                        symbol: "plus.circle.fill",
                        farbe: .blue
                    )
                    StatistikKarte(
                        titel: "Offen",
                        wert: "\(offeneAufgaben.count)",
                        symbol: "circle",
                        farbe: .orange
                    )
                }
                .padding(.horizontal)

                // MARK: - Trend
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trend")
                        .font(.headline)

                    let differenz = dieseWocheErledigt.count - letzteWocheErledigt.count
                    HStack {
                        Image(systemName: differenz >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .foregroundStyle(differenz >= 0 ? .green : .red)
                        if differenz > 0 {
                            Text("\(differenz) mehr als letzte Woche")
                        } else if differenz < 0 {
                            Text("\(abs(differenz)) weniger als letzte Woche")
                        } else {
                            Text("Gleich viel wie letzte Woche")
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                // MARK: - Kategorien-Aufschlüsselung
                if !dieseWocheErledigt.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nach Kategorie")
                            .font(.headline)

                        let nachKategorie = Dictionary(grouping: dieseWocheErledigt) {
                            $0.kategorie.isEmpty ? "Ohne Kategorie" : $0.kategorie
                        }
                        ForEach(nachKategorie.sorted(by: { $0.value.count > $1.value.count }), id: \.key) { kategorie, aufgaben in
                            HStack {
                                Text(kategorie)
                                Spacer()
                                Text("\(aufgaben.count)")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding()
                    .background(.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                // MARK: - Erledigte Aufgaben dieser Woche
                VStack(alignment: .leading, spacing: 12) {
                    Text("Diese Woche erledigt")
                        .font(.headline)

                    if dieseWocheErledigt.isEmpty {
                        Text("Noch keine Aufgaben erledigt diese Woche.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(dieseWocheErledigt) { aufgabe in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.caption)
                                Text(aufgabe.titel)
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Wochenreview")
    }
}

/// Kompakte Statistik-Karte für die Übersicht
struct StatistikKarte: View {
    let titel: String
    let wert: String
    let symbol: String
    let farbe: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(farbe)
            Text(wert)
                .font(.title.bold())
            Text(titel)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        WochenreviewView()
    }
    .modelContainer(for: Aufgabe.self, inMemory: true)
}
