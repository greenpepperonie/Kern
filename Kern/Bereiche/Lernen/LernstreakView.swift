import SwiftUI
import SwiftData

/// Lernstreak-Ansicht mit Gamification-Elementen
/// Zeigt Streak, Gesamtstatistik und motivierende Meldungen
struct LernstreakView: View {
    @Query private var flashcards: [Flashcard]

    /// Gesamtzahl gelernter Karten (mindestens 1 Wiederholung)
    private var gelerntGesamt: Int {
        flashcards.filter { $0.wiederholungen > 0 }.count
    }

    /// Karten die heute fällig sind
    private var heuteFaellig: Int {
        flashcards.filter { $0.naechsteWiederholung <= .now }.count
    }

    /// Durchschnittlicher Ease Factor
    private var durchschnittEF: Double {
        guard !flashcards.isEmpty else { return 2.5 }
        let summe = flashcards.reduce(0.0) { $0 + $1.easeFactor }
        return summe / Double(flashcards.count)
    }

    /// Berechnet den aktuellen Streak (aufeinanderfolgende Tage mit Lernaktivität)
    /// Basiert auf Karten deren naechsteWiederholung in der Zukunft liegt
    private var aktuellerStreak: Int {
        // Vereinfachte Streak-Berechnung basierend auf gelernten Karten
        let kalender = Calendar.current
        var streak = 0
        var pruefDatum = kalender.startOfDay(for: .now)

        // Prüfe für jeden Tag rückwärts ob Karten gelernt wurden
        while true {
            let hatGelernt = flashcards.contains { karte in
                karte.wiederholungen > 0 &&
                kalender.isDate(karte.naechsteWiederholung, inSameDayAs: pruefDatum) == false &&
                karte.naechsteWiederholung > pruefDatum
            }

            if hatGelernt || kalender.isDateInToday(pruefDatum) && heuteFaellig == 0 && gelerntGesamt > 0 {
                streak += 1
                guard let vortag = kalender.date(byAdding: .day, value: -1, to: pruefDatum) else { break }
                pruefDatum = vortag
            } else {
                break
            }
        }

        return streak
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Streak-Anzeige
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)

                    Text("\(aktuellerStreak)")
                        .font(.system(size: 56, weight: .bold))

                    Text(aktuellerStreak == 1 ? "Tag Streak" : "Tage Streak")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 32)

                // Motivierende Meldung
                Text(motivierenderText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // MARK: - Statistik-Karten
                HStack(spacing: 16) {
                    StatistikKarteKlein(
                        titel: "Gesamt",
                        wert: "\(flashcards.count)",
                        symbol: "rectangle.on.rectangle.fill",
                        farbe: .blue
                    )
                    StatistikKarteKlein(
                        titel: "Gelernt",
                        wert: "\(gelerntGesamt)",
                        symbol: "checkmark.circle.fill",
                        farbe: .green
                    )
                    StatistikKarteKlein(
                        titel: "Heute fällig",
                        wert: "\(heuteFaellig)",
                        symbol: "clock.fill",
                        farbe: heuteFaellig > 0 ? .orange : .secondary
                    )
                }
                .padding(.horizontal)

                // Durchschnittliche Schwierigkeit
                VStack(alignment: .leading, spacing: 8) {
                    Text("Durchschnittliche Schwierigkeit")
                        .font(.headline)

                    HStack {
                        ProgressView(value: (durchschnittEF - 1.3) / (3.7)) // Normalisiert auf 0–1
                            .tint(durchschnittEF > 2.5 ? .green : .orange)

                        Text(String(format: "%.1f", durchschnittEF))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text("Je höher der Wert, desto leichter fallen dir die Karten")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
        .navigationTitle("Lernstreak")
    }

    /// Motivierender Text basierend auf Streak
    private var motivierenderText: String {
        switch aktuellerStreak {
        case 0: return "Starte heute deinen Lernstreak!"
        case 1...2: return "Guter Start! Bleib dran!"
        case 3...6: return "Du bist auf einem guten Weg!"
        case 7...13: return "Eine ganze Woche! Starke Leistung!"
        case 14...29: return "Zwei Wochen am Stück — beeindruckend!"
        default: return "Über einen Monat! Du bist unaufhaltbar!"
        }
    }
}

/// Kompakte Statistik-Karte
struct StatistikKarteKlein: View {
    let titel: String
    let wert: String
    let symbol: String
    let farbe: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .foregroundStyle(farbe)
            Text(wert)
                .font(.title2.bold())
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
