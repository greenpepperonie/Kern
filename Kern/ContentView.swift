import SwiftUI

/// Hauptnavigation der App mit 5 Tabs
/// Jeder Tab enthält einen eigenen NavigationStack
struct ContentView: View {
    var body: some View {
        TabView {
            // Tab 1: Aufgaben & Fokus
            NavigationStack {
                AufgabenView()
            }
            .tabItem {
                Label("Aufgaben", systemImage: "checkmark.circle")
            }

            // Tab 2: Notizen & Kreativität
            NavigationStack {
                NotizenView()
            }
            .tabItem {
                Label("Notizen", systemImage: "note.text")
            }

            // Tab 3: Lernen
            NavigationStack {
                LernenView()
            }
            .tabItem {
                Label("Lernen", systemImage: "brain.head.profile")
            }

            // Tab 4: Gesundheit & Wohlbefinden
            NavigationStack {
                GesundheitView()
            }
            .tabItem {
                Label("Gesundheit", systemImage: "heart.text.square")
            }

            // Tab 5: Kontext & Erinnerungen
            NavigationStack {
                KontextView()
            }
            .tabItem {
                Label("Kontext", systemImage: "location.circle")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Aufgabe.self,
            Notiz.self,
            Flashcard.self,
            Lernset.self,
            GesundheitsEintrag.self,
            Kontakt.self
        ], inMemory: true)
}
