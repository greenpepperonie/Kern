import Foundation
import SwiftData

/// Exportiert alle Nutzerdaten als JSON-Datei
/// Konvertiert alle SwiftData-Models in ein serialisierbares Format
enum DatenExport {

    /// Alle exportierbaren Daten als Dictionary
    struct ExportDaten: Codable {
        let exportDatum: Date
        let appVersion: String
        let aufgaben: [AufgabeExport]
        let notizen: [NotizExport]
        let flashcards: [FlashcardExport]
        let lernsets: [LernsetExport]
        let gesundheit: [GesundheitsEintragExport]
        let kontakte: [KontaktExport]
        let einkaufsartikel: [EinkaufsArtikelExport]
    }

    // MARK: - Export-Strukturen (Codable-Versionen der Models)

    struct AufgabeExport: Codable {
        let titel: String
        let erledigt: Bool
        let faelligkeitsdatum: Date?
        let kategorie: String
        let istWiederkehrend: Bool
        let wiederholungsintervall: String?
        let wichtig: Bool
        let dringend: Bool
        let erstelltAm: Date
    }

    struct NotizExport: Codable {
        let titel: String
        let inhalt: String
        let kategorie: String
        let istVerschluesselt: Bool
        let hatAufnahme: Bool
        let erstelltAm: Date
        let geaendertAm: Date
    }

    struct FlashcardExport: Codable {
        let frage: String
        let antwort: String
        let deck: String
        let naechsteWiederholung: Date
        let intervall: Int
        let wiederholungen: Int
        let easeFactor: Double
    }

    struct LernsetExport: Codable {
        let name: String
        let beschreibung: String
        let erstelltAm: Date
    }

    struct GesundheitsEintragExport: Codable {
        let datum: Date
        let schlafStunden: Double?
        let energieLevel: Int?
        let symptome: [String]
        let notiz: String?
    }

    struct KontaktExport: Codable {
        let name: String
        let geburtstag: Date?
        let letzterKontakt: Date?
        let notiz: String?
        let erinnerungsintervallTage: Int?
    }

    struct EinkaufsArtikelExport: Codable {
        let name: String
        let kategorie: String
        let liste: String
        let erledigt: Bool
        let erstelltAm: Date
    }

    // MARK: - Export-Funktion

    /// Exportiert alle Daten aus dem ModelContext als JSON-Datei
    /// - Parameter context: Der aktuelle SwiftData ModelContext
    /// - Returns: URL zur exportierten JSON-Datei
    static func exportieren(context: ModelContext) throws -> URL {
        // Alle Daten aus SwiftData laden
        let aufgaben = (try? context.fetch(FetchDescriptor<Aufgabe>())) ?? []
        let notizen = (try? context.fetch(FetchDescriptor<Notiz>())) ?? []
        let flashcards = (try? context.fetch(FetchDescriptor<Flashcard>())) ?? []
        let lernsets = (try? context.fetch(FetchDescriptor<Lernset>())) ?? []
        let gesundheit = (try? context.fetch(FetchDescriptor<GesundheitsEintrag>())) ?? []
        let kontakte = (try? context.fetch(FetchDescriptor<Kontakt>())) ?? []
        let einkaufsartikel = (try? context.fetch(FetchDescriptor<EinkaufsArtikel>())) ?? []

        // In Export-Format konvertieren
        let exportDaten = ExportDaten(
            exportDatum: .now,
            appVersion: "1.0",
            aufgaben: aufgaben.map { a in
                AufgabeExport(
                    titel: a.titel, erledigt: a.erledigt,
                    faelligkeitsdatum: a.faelligkeitsdatum, kategorie: a.kategorie,
                    istWiederkehrend: a.istWiederkehrend, wiederholungsintervall: a.wiederholungsintervall,
                    wichtig: a.wichtig, dringend: a.dringend, erstelltAm: a.erstelltAm
                )
            },
            notizen: notizen.map { n in
                NotizExport(
                    titel: n.titel, inhalt: n.inhalt, kategorie: n.kategorie,
                    istVerschluesselt: n.istVerschluesselt, hatAufnahme: n.hatAufnahme,
                    erstelltAm: n.erstelltAm, geaendertAm: n.geaendertAm
                )
            },
            flashcards: flashcards.map { f in
                FlashcardExport(
                    frage: f.frage, antwort: f.antwort, deck: f.deck,
                    naechsteWiederholung: f.naechsteWiederholung, intervall: f.intervall,
                    wiederholungen: f.wiederholungen, easeFactor: f.easeFactor
                )
            },
            lernsets: lernsets.map { l in
                LernsetExport(name: l.name, beschreibung: l.beschreibung, erstelltAm: l.erstelltAm)
            },
            gesundheit: gesundheit.map { g in
                GesundheitsEintragExport(
                    datum: g.datum, schlafStunden: g.schlafStunden,
                    energieLevel: g.energieLevel, symptome: g.symptome, notiz: g.notiz
                )
            },
            kontakte: kontakte.map { k in
                KontaktExport(
                    name: k.name, geburtstag: k.geburtstag,
                    letzterKontakt: k.letzterKontakt, notiz: k.notiz,
                    erinnerungsintervallTage: k.erinnerungsintervallTage
                )
            },
            einkaufsartikel: einkaufsartikel.map { e in
                EinkaufsArtikelExport(
                    name: e.name, kategorie: e.kategorie, liste: e.liste,
                    erledigt: e.erledigt, erstelltAm: e.erstelltAm
                )
            }
        )

        // Als JSON kodieren
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let jsonDaten = try encoder.encode(exportDaten)

        // In temporäre Datei schreiben
        let dateiname = "kern_export_\(Date.now.formatted(.dateTime.year().month().day())).json"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(dateiname)
        try jsonDaten.write(to: tempURL)

        return tempURL
    }
}
