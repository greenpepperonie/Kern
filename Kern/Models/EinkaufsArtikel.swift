import Foundation
import SwiftData

/// Ein einzelner Artikel in einer Einkaufsliste
/// Eigenes Model, komplett unabhängig von Aufgabe
@Model
class EinkaufsArtikel {
    var name: String
    var kategorie: String              // z.B. "Obst & Gemüse", "Milchprodukte"
    var liste: String                  // Name der Liste (z.B. "Rewe", "Aldi")
    var erledigt: Bool
    var erstelltAm: Date

    init(
        name: String,
        kategorie: String = "Sonstiges",
        liste: String = "Einkaufsliste",
        erledigt: Bool = false,
        erstelltAm: Date = .now
    ) {
        self.name = name
        self.kategorie = kategorie
        self.liste = liste
        self.erledigt = erledigt
        self.erstelltAm = erstelltAm
    }
}

/// Speichert gelernte Kategorie-Zuordnungen für Einkaufsitems
/// Wird von der KI beim ersten Mal befüllt, danach lokal verwendet
@Model
class KategorieMapping {
    var artikelName: String            // Normalisierter Name (lowercase)
    var kategorie: String              // Zugeordnete Kategorie

    init(artikelName: String, kategorie: String) {
        self.artikelName = artikelName.lowercased().trimmingCharacters(in: .whitespaces)
        self.kategorie = kategorie
    }
}
