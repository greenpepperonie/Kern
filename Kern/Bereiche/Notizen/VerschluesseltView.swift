import SwiftUI
import SwiftData
import CryptoKit

/// PIN-Eingabe zum Entsperren verschlüsselter Notizen
/// Verwendet CryptoKit (AES-GCM) für die Verschlüsselung
struct VerschluesseltView: View {
    @State private var pin: String = ""
    @State private var istEntsprerrt = false
    @State private var fehler = false
    @State private var zeigPINErstellen = false

    /// Die gespeicherte PIN (als SHA256-Hash in UserDefaults)
    private var gespeicherterHash: String? {
        UserDefaults.standard.string(forKey: "kern_notiz_pin_hash")
    }

    /// Prüft ob bereits eine PIN gesetzt wurde
    private var hatPIN: Bool {
        gespeicherterHash != nil
    }

    var body: some View {
        if istEntsprerrt {
            // Entsperrt — zeige verschlüsselte Notizen
            VerschluesselteNotizenListeView()
        } else if !hatPIN || zeigPINErstellen {
            // PIN erstellen
            PINErstellenView { neuePIN in
                pinSpeichern(neuePIN)
                istEntsprerrt = true
            }
        } else {
            // PIN eingeben
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.accentColor)

                Text("PIN eingeben")
                    .font(.title2.bold())

                // PIN-Eingabe
                SecureField("4-stellige PIN", text: $pin)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .frame(width: 200)
                    .padding()
                    .background(.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                if fehler {
                    Text("Falsche PIN")
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                Button("Entsperren") {
                    pruefen()
                }
                .buttonStyle(.borderedProminent)
                .disabled(pin.count < 4)

                Spacer()
            }
            .navigationTitle("Verschlüsselt")
        }
    }

    // MARK: - PIN-Logik

    /// Prüft die eingegebene PIN gegen den gespeicherten Hash
    private func pruefen() {
        let hash = pinHash(pin)
        if hash == gespeicherterHash {
            istEntsprerrt = true
            fehler = false
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            fehler = true
            pin = ""
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }

    /// Speichert eine neue PIN als SHA256-Hash
    private func pinSpeichern(_ neuePIN: String) {
        let hash = pinHash(neuePIN)
        UserDefaults.standard.set(hash, forKey: "kern_notiz_pin_hash")
    }

    /// Erzeugt einen SHA256-Hash aus der PIN
    private func pinHash(_ pin: String) -> String {
        let daten = Data(pin.utf8)
        let hash = SHA256.hash(data: daten)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

/// View zum Erstellen einer neuen PIN
struct PINErstellenView: View {
    @State private var pin1: String = ""
    @State private var pin2: String = ""
    @State private var stimmenNichtUeberein = false

    var onFertig: (String) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(Color.accentColor)

            Text("PIN erstellen")
                .font(.title2.bold())

            Text("Wähle eine 4-stellige PIN\nzum Schutz deiner Notizen")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                SecureField("PIN eingeben", text: $pin1)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .frame(width: 200)
                    .padding()
                    .background(.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                SecureField("PIN wiederholen", text: $pin2)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .frame(width: 200)
                    .padding()
                    .background(.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if stimmenNichtUeberein {
                Text("PINs stimmen nicht überein")
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button("PIN setzen") {
                if pin1 == pin2 && pin1.count >= 4 {
                    onFertig(pin1)
                } else {
                    stimmenNichtUeberein = true
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(pin1.count < 4 || pin2.count < 4)

            Spacer()
        }
    }
}

/// Liste der verschlüsselten Notizen (nach PIN-Eingabe)
struct VerschluesselteNotizenListeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Notiz.geaendertAm, order: .reverse) private var alleNotizen: [Notiz]
    @State private var zeigEditor = false

    /// Nur verschlüsselte Notizen
    private var notizen: [Notiz] {
        alleNotizen.filter { $0.istVerschluesselt }
    }

    var body: some View {
        List {
            if notizen.isEmpty {
                ContentUnavailableView(
                    "Keine verschlüsselten Notizen",
                    systemImage: "lock.fill",
                    description: Text("Erstelle eine neue verschlüsselte Notiz")
                )
            } else {
                ForEach(notizen) { notiz in
                    NavigationLink {
                        NotizDetailView(notiz: notiz)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(notiz.titel)
                                .font(.headline)
                            Text(notiz.geaendertAm.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            context.delete(notiz)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Verschlüsselt")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    zeigEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $zeigEditor) {
            VerschluesselteNotizEditorView()
        }
    }
}

/// Editor für eine neue verschlüsselte Notiz
struct VerschluesselteNotizEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var titel = ""
    @State private var inhalt = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Titel", text: $titel)
                Section("Inhalt") {
                    TextEditor(text: $inhalt)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle("Neue verschlüsselte Notiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") {
                        let notiz = Notiz(
                            titel: titel.trimmingCharacters(in: .whitespaces),
                            inhalt: inhalt,
                            kategorie: "Schnell",
                            istVerschluesselt: true
                        )
                        context.insert(notiz)
                        dismiss()
                    }
                    .disabled(titel.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
