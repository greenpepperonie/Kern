import Foundation
import SwiftData

/// Ein täglicher Gesundheitseintrag mit Schlaf, Energie und Symptomen
@Model
class GesundheitsEintrag {
    var datum: Date
    var schlafStunden: Double?             // Stunden geschlafen
    var energieLevel: Int?                 // 1–5 Skala
    var symptome: [String]                 // Liste von Symptomen
    var notiz: String?                     // Optionaler Freitext

    init(
        datum: Date = .now,
        schlafStunden: Double? = nil,
        energieLevel: Int? = nil,
        symptome: [String] = [],
        notiz: String? = nil
    ) {
        self.datum = datum
        self.schlafStunden = schlafStunden
        self.energieLevel = energieLevel
        self.symptome = symptome
        self.notiz = notiz
    }
}
