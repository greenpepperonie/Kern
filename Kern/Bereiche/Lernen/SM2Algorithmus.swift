import Foundation

/// SM-2 Spaced-Repetition-Algorithmus
/// Berechnet das nächste Wiederholungsdatum basierend auf der Antwortqualität
///
/// Qualitätsstufen:
/// 0 = Komplett falsch
/// 1 = Falsch, aber nach Anzeige erinnert
/// 2 = Falsch, aber es kam einem bekannt vor
/// 3 = Richtig, aber mit Mühe
/// 4 = Richtig, nach kurzem Überlegen
/// 5 = Perfekt, sofort gewusst
enum SM2Algorithmus {

    /// Ergebnis einer SM-2-Berechnung
    struct Ergebnis {
        let intervall: Int              // Tage bis zur nächsten Wiederholung
        let wiederholungen: Int         // Neue Anzahl Wiederholungen
        let easeFactor: Double          // Neuer Schwierigkeitsfaktor
        let naechsteWiederholung: Date  // Konkretes Datum
    }

    /// Berechnet die nächste Wiederholung basierend auf SM-2
    /// - Parameters:
    ///   - qualitaet: Antwortqualität (0–5)
    ///   - wiederholungen: Bisherige erfolgreiche Wiederholungen
    ///   - easeFactor: Aktueller Schwierigkeitsfaktor (≥ 1.3)
    ///   - intervall: Aktuelles Intervall in Tagen
    /// - Returns: Neues SM-2-Ergebnis
    static func berechne(
        qualitaet: Int,
        wiederholungen: Int,
        easeFactor: Double,
        intervall: Int
    ) -> Ergebnis {
        let q = Double(min(max(qualitaet, 0), 5))

        var neueWiederholungen = wiederholungen
        var neuesIntervall = intervall
        var neuerEaseFactor = easeFactor

        if qualitaet >= 3 {
            // Richtige Antwort — Intervall erhöhen
            switch wiederholungen {
            case 0:
                neuesIntervall = 1
            case 1:
                neuesIntervall = 6
            default:
                neuesIntervall = Int(round(Double(intervall) * easeFactor))
            }
            neueWiederholungen = wiederholungen + 1
        } else {
            // Falsche Antwort — zurück auf Anfang
            neueWiederholungen = 0
            neuesIntervall = 1
        }

        // Ease Factor anpassen (Minimum 1.3)
        neuerEaseFactor = easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        neuerEaseFactor = max(neuerEaseFactor, 1.3)

        // Nächstes Wiederholungsdatum berechnen
        let naechstesDatum = Calendar.current.date(
            byAdding: .day,
            value: neuesIntervall,
            to: .now
        ) ?? .now

        return Ergebnis(
            intervall: neuesIntervall,
            wiederholungen: neueWiederholungen,
            easeFactor: neuerEaseFactor,
            naechsteWiederholung: naechstesDatum
        )
    }
}
