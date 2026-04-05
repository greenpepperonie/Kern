import Foundation
import SwiftData

/// Eine Notiz mit Markdown-Inhalt, optionaler Verschlüsselung und Sprachaufnahme
@Model
class Notiz {
    var titel: String
    var inhalt: String                 // Markdown-Text
    var kategorie: String              // "Schnell", "Idee", "Brain Dump"
    var istVerschluesselt: Bool
    var hatAufnahme: Bool              // Sprach-Notiz vorhanden?
    var aufnahmePfad: String?          // Dateipfad zur Aufnahme
    var erstelltAm: Date
    var geaendertAm: Date

    init(
        titel: String,
        inhalt: String = "",
        kategorie: String = "Schnell",
        istVerschluesselt: Bool = false,
        hatAufnahme: Bool = false,
        aufnahmePfad: String? = nil,
        erstelltAm: Date = .now,
        geaendertAm: Date = .now
    ) {
        self.titel = titel
        self.inhalt = inhalt
        self.kategorie = kategorie
        self.istVerschluesselt = istVerschluesselt
        self.hatAufnahme = hatAufnahme
        self.aufnahmePfad = aufnahmePfad
        self.erstelltAm = erstelltAm
        self.geaendertAm = geaendertAm
    }
}
