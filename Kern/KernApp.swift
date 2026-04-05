import SwiftUI
import SwiftData

/// Einstiegspunkt der Kern-App
/// Konfiguriert den SwiftData-Container und zeigt die Hauptnavigation
@main
struct KernApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // SwiftData-Container mit allen Models konfigurieren
        .modelContainer(for: [
            Aufgabe.self,
            Notiz.self,
            Flashcard.self,
            Lernset.self,
            GesundheitsEintrag.self,
            Kontakt.self,
            EinkaufsArtikel.self,
            KategorieMapping.self,
            Habit.self,
            HabitEintrag.self
        ])
    }
}
