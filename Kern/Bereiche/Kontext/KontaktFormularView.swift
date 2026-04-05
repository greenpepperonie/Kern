import SwiftUI

/// Formular zum Erstellen und Bearbeiten eines Kontakts
struct KontaktFormularView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var kontakt: Kontakt?

    @State private var name: String = ""
    @State private var hatGeburtstag: Bool = false
    @State private var geburtstag: Date = .now
    @State private var notiz: String = ""
    @State private var erinnerungsintervall: Int = 30

    private var istBearbeitung: Bool { kontakt != nil }

    /// Vordefinierte Erinnerungsintervalle
    private let intervalle = [7, 14, 30, 60, 90]

    var body: some View {
        NavigationStack {
            Form {
                Section("Kontakt") {
                    TextField("Name", text: $name)
                }

                Section("Geburtstag") {
                    Toggle("Geburtstag eintragen", isOn: $hatGeburtstag)
                    if hatGeburtstag {
                        DatePicker(
                            "Datum",
                            selection: $geburtstag,
                            displayedComponents: .date
                        )
                    }
                }

                Section("Erinnerung") {
                    Picker("Alle … Tage erinnern", selection: $erinnerungsintervall) {
                        ForEach(intervalle, id: \.self) { tage in
                            Text("\(tage) Tage").tag(tage)
                        }
                    }
                }

                Section("Notiz") {
                    TextEditor(text: $notiz)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle(istBearbeitung ? "Kontakt bearbeiten" : "Neuer Kontakt")
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
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let kontakt {
                    name = kontakt.name
                    notiz = kontakt.notiz ?? ""
                    erinnerungsintervall = kontakt.erinnerungsintervallTage ?? 30
                    if let gb = kontakt.geburtstag {
                        hatGeburtstag = true
                        geburtstag = gb
                    }
                }
            }
        }
    }

    private func sichern() {
        let getrimmterName = name.trimmingCharacters(in: .whitespaces)
        guard !getrimmterName.isEmpty else { return }

        if let kontakt {
            kontakt.name = getrimmterName
            kontakt.geburtstag = hatGeburtstag ? geburtstag : nil
            kontakt.notiz = notiz.isEmpty ? nil : notiz
            kontakt.erinnerungsintervallTage = erinnerungsintervall
        } else {
            let neuer = Kontakt(
                name: getrimmterName,
                geburtstag: hatGeburtstag ? geburtstag : nil,
                letzterKontakt: .now,
                notiz: notiz.isEmpty ? nil : notiz,
                erinnerungsintervallTage: erinnerungsintervall
            )
            context.insert(neuer)
        }
    }
}
