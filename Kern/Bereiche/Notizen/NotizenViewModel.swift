import SwiftUI
import SwiftData

/// ViewModel für die Notizverwaltung
@Observable
class NotizenViewModel {
    var zeigNeueNotizSheet = false
    var zeigBearbeitenSheet = false
    var ausgewaehlteNotiz: Notiz?
    var ausgewaehlteKategorie: String? = nil

    /// Alle verfügbaren Kategorien
    static let kategorien = ["Schnell", "Idee", "Brain Dump"]

    // MARK: - Notiz erstellen

    /// Erstellt eine neue Schnell-Notiz mit minimalem Aufwand
    func schnellNotizErstellen(titel: String, kategorie: String, context: ModelContext) {
        let notiz = Notiz(titel: titel, kategorie: kategorie)
        context.insert(notiz)
    }

    // MARK: - Notiz löschen

    func notizLoeschen(_ notiz: Notiz, context: ModelContext) {
        context.delete(notiz)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    // MARK: - Bearbeiten

    func bearbeitenStarten(_ notiz: Notiz) {
        ausgewaehlteNotiz = notiz
        zeigBearbeitenSheet = true
    }
}
