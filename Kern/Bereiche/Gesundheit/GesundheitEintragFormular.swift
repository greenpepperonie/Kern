import SwiftUI

/// Formular zum Erstellen eines neuen Gesundheitseintrags
/// Erfasst Schlaf, Energie, Symptome und optionale Notiz
struct GesundheitEintragFormular: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var schlafStunden: Double = 7.0
    @State private var energieLevel: Int = 3
    @State private var symptomText: String = ""
    @State private var symptome: [String] = []
    @State private var notiz: String = ""

    /// Vordefinierte häufige Symptome für schnelle Auswahl
    private let haeufigSymptome = [
        "Kopfschmerzen", "Müdigkeit", "Übelkeit", "Rückenschmerzen",
        "Schnupfen", "Husten", "Halsschmerzen", "Schlaflos",
        "Stress", "Verspannung"
    ]

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Schlaf
                Section("Schlaf") {
                    VStack {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.indigo)
                            Text("\(schlafStunden, specifier: "%.1f") Stunden")
                                .font(.headline)
                        }
                        Slider(value: $schlafStunden, in: 0...14, step: 0.5)
                    }
                }

                // MARK: - Energie
                Section("Energie-Level") {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundStyle(energieFarbe)
                            Text(energieText)
                                .font(.headline)
                        }

                        // 5 Stufen als Buttons
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { level in
                                Button {
                                    energieLevel = level
                                } label: {
                                    Text("\(level)")
                                        .font(.headline)
                                        .frame(width: 44, height: 44)
                                        .background(energieLevel == level ? energieFarbeFuer(level) : Color.secondary.opacity(0.2))
                                        .foregroundStyle(energieLevel == level ? .white : .primary)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // MARK: - Symptome
                Section("Symptome") {
                    // Schnellauswahl
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(haeufigSymptome, id: \.self) { symptom in
                                Button(symptom) {
                                    if symptome.contains(symptom) {
                                        symptome.removeAll { $0 == symptom }
                                    } else {
                                        symptome.append(symptom)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .tint(symptome.contains(symptom) ? .red : .secondary)
                            }
                        }
                    }

                    // Eigenes Symptom hinzufügen
                    HStack {
                        TextField("Eigenes Symptom…", text: $symptomText)
                            .onSubmit {
                                symptomHinzufuegen()
                            }
                        Button {
                            symptomHinzufuegen()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(symptomText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    // Ausgewählte Symptome
                    if !symptome.isEmpty {
                        ForEach(symptome, id: \.self) { symptom in
                            HStack {
                                Text(symptom)
                                Spacer()
                                Button {
                                    symptome.removeAll { $0 == symptom }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // MARK: - Notiz
                Section("Notiz (optional)") {
                    TextEditor(text: $notiz)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle("Neuer Eintrag")
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
                }
            }
        }
    }

    // MARK: - Hilfsfunktionen

    private func symptomHinzufuegen() {
        let text = symptomText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, !symptome.contains(text) else { return }
        symptome.append(text)
        symptomText = ""
    }

    private func sichern() {
        let eintrag = GesundheitsEintrag(
            schlafStunden: schlafStunden,
            energieLevel: energieLevel,
            symptome: symptome,
            notiz: notiz.isEmpty ? nil : notiz
        )
        context.insert(eintrag)
    }

    private var energieFarbe: Color { energieFarbeFuer(energieLevel) }

    private func energieFarbeFuer(_ level: Int) -> Color {
        switch level {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .mint
        case 5: return .green
        default: return .secondary
        }
    }

    private var energieText: String {
        switch energieLevel {
        case 1: return "Sehr niedrig"
        case 2: return "Niedrig"
        case 3: return "Mittel"
        case 4: return "Gut"
        case 5: return "Sehr gut"
        default: return "—"
        }
    }
}

#Preview {
    GesundheitEintragFormular()
        .modelContainer(for: GesundheitsEintrag.self, inMemory: true)
}
