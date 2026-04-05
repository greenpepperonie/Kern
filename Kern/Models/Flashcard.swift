import Foundation
import SwiftData

/// Eine Lernkarte mit SM-2 Spaced-Repetition-Parametern
@Model
class Flashcard {
    var frage: String
    var antwort: String
    var deck: String                       // Name des Decks/Lernsets
    var naechsteWiederholung: Date         // Wann die Karte erneut gezeigt werden soll
    var intervall: Int                     // SM-2: Tage bis zur nächsten Wiederholung
    var wiederholungen: Int                // Anzahl erfolgreicher Wiederholungen
    var easeFactor: Double                 // SM-2: Schwierigkeitsfaktor (startet bei 2.5)

    init(
        frage: String,
        antwort: String,
        deck: String = "",
        naechsteWiederholung: Date = .now,
        intervall: Int = 0,
        wiederholungen: Int = 0,
        easeFactor: Double = 2.5
    ) {
        self.frage = frage
        self.antwort = antwort
        self.deck = deck
        self.naechsteWiederholung = naechsteWiederholung
        self.intervall = intervall
        self.wiederholungen = wiederholungen
        self.easeFactor = easeFactor
    }
}
