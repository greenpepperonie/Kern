import Foundation
import SwiftData

/// Ein Lernset (Deck) das mehrere Flashcards gruppiert
@Model
class Lernset {
    var name: String
    var beschreibung: String
    var erstelltAm: Date

    init(
        name: String,
        beschreibung: String = "",
        erstelltAm: Date = .now
    ) {
        self.name = name
        self.beschreibung = beschreibung
        self.erstelltAm = erstelltAm
    }
}
