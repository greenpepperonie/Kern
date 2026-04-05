import SwiftUI
import SwiftData

/// Fokus-Modus: Zeigt nur eine einzelne Aufgabe an
/// Reduziert Ablenkung, damit man sich auf das Wesentliche konzentrieren kann
struct FokusModusView: View {
    @Query(
        filter: #Predicate<Aufgabe> { !$0.erledigt },
        sort: \Aufgabe.erstelltAm
    ) private var offeneAufgaben: [Aufgabe]

    @Environment(\.dismiss) private var dismiss
    @State private var aktuellerIndex = 0

    /// Die aktuell angezeigte Aufgabe
    private var aktuelleAufgabe: Aufgabe? {
        guard !offeneAufgaben.isEmpty,
              aktuellerIndex < offeneAufgaben.count else { return nil }
        return offeneAufgaben[aktuellerIndex]
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            if let aufgabe = aktuelleAufgabe {
                // Fokus-Symbol
                Image(systemName: "scope")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.accentColor)

                // Aufgaben-Titel groß anzeigen
                Text(aufgabe.titel)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Kategorie und Fälligkeit
                VStack(spacing: 8) {
                    if !aufgabe.kategorie.isEmpty {
                        Text(aufgabe.kategorie)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(.quaternary)
                            .clipShape(Capsule())
                    }

                    if let datum = aufgabe.faelligkeitsdatum {
                        Label(datum.formatted(date: .abbreviated, time: .omitted),
                              systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Fortschrittsanzeige
                Text("Aufgabe \(aktuellerIndex + 1) von \(offeneAufgaben.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                // Aktionen
                VStack(spacing: 16) {
                    // Erledigt-Button
                    Button {
                        aufgabe.erledigt = true
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        // Zum nächsten, aber Index nicht erhöhen
                        // (da die erledigte Aufgabe aus der Query fällt)
                        if offeneAufgaben.count <= 1 {
                            // Keine weiteren Aufgaben
                        } else if aktuellerIndex >= offeneAufgaben.count - 1 {
                            aktuellerIndex = 0
                        }
                    } label: {
                        Label("Erledigt", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.white)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Überspringen-Button
                    Button {
                        naechsteAufgabe()
                    } label: {
                        Label("Überspringen", systemImage: "forward.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 32)

            } else {
                // Alle Aufgaben erledigt
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)

                Text("Alles erledigt!")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Du hast keine offenen Aufgaben.")
                    .foregroundStyle(.secondary)

                Spacer()
            }
        }
        .padding(.bottom, 32)
        .navigationTitle("Fokus-Modus")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Springt zur nächsten offenen Aufgabe
    private func naechsteAufgabe() {
        guard offeneAufgaben.count > 1 else { return }
        aktuellerIndex = (aktuellerIndex + 1) % offeneAufgaben.count
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

#Preview {
    NavigationStack {
        FokusModusView()
    }
    .modelContainer(for: Aufgabe.self, inMemory: true)
}
