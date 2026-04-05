import SwiftUI

/// Formular zum Erstellen und Bearbeiten einer Aufgabe
/// Wird als Sheet angezeigt — sowohl für neue als auch bestehende Aufgaben
struct AufgabeFormularView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    // Die zu bearbeitende Aufgabe (nil = neue Aufgabe erstellen)
    var aufgabe: Aufgabe?

    // Formular-Felder
    @State private var titel: String = ""
    @State private var kategorie: String = ""
    @State private var hatFaelligkeit: Bool = false
    @State private var faelligkeitsdatum: Date = .now
    @State private var wichtig: Bool = false
    @State private var dringend: Bool = false
    @State private var istWiederkehrend: Bool = false
    @State private var wiederholungsintervall: String = "täglich"

    /// Vordefinierte Kategorien für schnelle Auswahl
    private let kategorien = ["Arbeit", "Privat", "Einkauf", "Gesundheit", "Lernen", "Sonstiges"]

    /// Optionen für Wiederholungsintervall
    private let intervalle = ["täglich", "wöchentlich", "monatlich"]

    /// True wenn wir eine bestehende Aufgabe bearbeiten
    private var istBearbeitung: Bool { aufgabe != nil }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Grunddaten
                Section("Aufgabe") {
                    TextField("Titel", text: $titel)

                    // Kategorie als horizontale Auswahl
                    Picker("Kategorie", selection: $kategorie) {
                        Text("Keine").tag("")
                        ForEach(kategorien, id: \.self) { kat in
                            Text(kat).tag(kat)
                        }
                    }
                }

                // MARK: - Fälligkeit
                Section("Fälligkeit") {
                    Toggle("Fälligkeitsdatum", isOn: $hatFaelligkeit)

                    if hatFaelligkeit {
                        DatePicker(
                            "Datum",
                            selection: $faelligkeitsdatum,
                            displayedComponents: [.date]
                        )
                    }
                }

                // MARK: - Wiederholung
                Section("Wiederholung") {
                    Toggle("Wiederkehrend", isOn: $istWiederkehrend)

                    if istWiederkehrend {
                        Picker("Intervall", selection: $wiederholungsintervall) {
                            ForEach(intervalle, id: \.self) { intervall in
                                Text(intervall.capitalized).tag(intervall)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                // MARK: - Priorität (Eisenhower)
                Section("Priorität") {
                    Toggle("Wichtig", isOn: $wichtig)
                    Toggle("Dringend", isOn: $dringend)
                }
            }
            .navigationTitle(istBearbeitung ? "Aufgabe bearbeiten" : "Neue Aufgabe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") {
                        sichern()
                        dismiss()
                    }
                    .disabled(titel.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                // Felder mit bestehenden Werten füllen (beim Bearbeiten)
                if let aufgabe {
                    titel = aufgabe.titel
                    kategorie = aufgabe.kategorie
                    wichtig = aufgabe.wichtig
                    dringend = aufgabe.dringend
                    istWiederkehrend = aufgabe.istWiederkehrend
                    wiederholungsintervall = aufgabe.wiederholungsintervall ?? "täglich"
                    if let datum = aufgabe.faelligkeitsdatum {
                        hatFaelligkeit = true
                        faelligkeitsdatum = datum
                    }
                }
            }
        }
    }

    // MARK: - Speichern

    /// Speichert die Aufgabe — erstellt eine neue oder aktualisiert die bestehende
    private func sichern() {
        let getrimmterTitel = titel.trimmingCharacters(in: .whitespaces)
        guard !getrimmterTitel.isEmpty else { return }

        if let aufgabe {
            // Bestehende Aufgabe aktualisieren
            aufgabe.titel = getrimmterTitel
            aufgabe.kategorie = kategorie
            aufgabe.faelligkeitsdatum = hatFaelligkeit ? faelligkeitsdatum : nil
            aufgabe.wichtig = wichtig
            aufgabe.dringend = dringend
            aufgabe.istWiederkehrend = istWiederkehrend
            aufgabe.wiederholungsintervall = istWiederkehrend ? wiederholungsintervall : nil
        } else {
            // Neue Aufgabe erstellen
            let neue = Aufgabe(
                titel: getrimmterTitel,
                faelligkeitsdatum: hatFaelligkeit ? faelligkeitsdatum : nil,
                kategorie: kategorie,
                istWiederkehrend: istWiederkehrend,
                wiederholungsintervall: istWiederkehrend ? wiederholungsintervall : nil,
                wichtig: wichtig,
                dringend: dringend
            )
            context.insert(neue)
        }
    }
}

#Preview("Neue Aufgabe") {
    AufgabeFormularView()
        .modelContainer(for: Aufgabe.self, inMemory: true)
}
