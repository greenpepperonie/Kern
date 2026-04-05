import Foundation
import SwiftData

/// Eine Aufgabe mit optionalem Fälligkeitsdatum, Kategorie und Eisenhower-Einordnung
@Model
class Aufgabe {
    var titel: String
    var erledigt: Bool
    var faelligkeitsdatum: Date?
    var kategorie: String              // z.B. "Einkauf", "Arbeit"
    var istWiederkehrend: Bool
    var wiederholungsintervall: String? // "täglich", "wöchentlich"
    var wichtig: Bool                  // für Eisenhower-Matrix
    var dringend: Bool                 // für Eisenhower-Matrix
    var erstelltAm: Date

    init(
        titel: String,
        erledigt: Bool = false,
        faelligkeitsdatum: Date? = nil,
        kategorie: String = "",
        istWiederkehrend: Bool = false,
        wiederholungsintervall: String? = nil,
        wichtig: Bool = false,
        dringend: Bool = false,
        erstelltAm: Date = .now
    ) {
        self.titel = titel
        self.erledigt = erledigt
        self.faelligkeitsdatum = faelligkeitsdatum
        self.kategorie = kategorie
        self.istWiederkehrend = istWiederkehrend
        self.wiederholungsintervall = wiederholungsintervall
        self.wichtig = wichtig
        self.dringend = dringend
        self.erstelltAm = erstelltAm
    }
}
