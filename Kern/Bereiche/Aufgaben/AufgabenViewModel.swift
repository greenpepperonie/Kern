import SwiftUI
import SwiftData

/// ViewModel für die Aufgabenverwaltung
/// Enthält die gesamte Logik zum Erstellen, Bearbeiten und Löschen von Aufgaben
@Observable
class AufgabenViewModel {
    var zeigNeueAufgabeSheet = false
    var zeigBearbeitenSheet = false
    var ausgewaehlteAufgabe: Aufgabe?

    // MARK: - Aufgabe erstellen

    /// Erstellt eine neue Aufgabe und speichert sie im ModelContext
    func aufgabeErstellen(
        titel: String,
        kategorie: String,
        faelligkeitsdatum: Date?,
        wichtig: Bool,
        dringend: Bool,
        context: ModelContext
    ) {
        let aufgabe = Aufgabe(
            titel: titel,
            faelligkeitsdatum: faelligkeitsdatum,
            kategorie: kategorie,
            wichtig: wichtig,
            dringend: dringend
        )
        context.insert(aufgabe)
    }

    // MARK: - Aufgabe erledigen/unerledigen

    /// Toggled den Erledigt-Status einer Aufgabe mit haptischem Feedback
    func aufgabeToggle(_ aufgabe: Aufgabe) {
        aufgabe.erledigt.toggle()
        // Haptisches Feedback bei Statusänderung
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    // MARK: - Aufgabe löschen

    /// Löscht eine Aufgabe aus dem ModelContext
    func aufgabeLoeschen(_ aufgabe: Aufgabe, context: ModelContext) {
        context.delete(aufgabe)
        // Haptisches Feedback bei Löschung
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    // MARK: - Bearbeiten starten

    /// Öffnet das Bearbeiten-Sheet für eine bestimmte Aufgabe
    func bearbeitenStarten(_ aufgabe: Aufgabe) {
        ausgewaehlteAufgabe = aufgabe
        zeigBearbeitenSheet = true
    }
}
