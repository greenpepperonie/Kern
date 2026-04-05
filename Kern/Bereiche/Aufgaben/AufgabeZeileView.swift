import SwiftUI

/// Eine einzelne Aufgaben-Zeile in der Liste
/// Zeigt Checkbox, Titel, Kategorie-Badge und optionales Fälligkeitsdatum
struct AufgabeZeileView: View {
    let aufgabe: Aufgabe
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox-Button zum Erledigen
            Button(action: onToggle) {
                Image(systemName: aufgabe.erledigt ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(aufgabe.erledigt ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                // Titel — durchgestrichen wenn erledigt
                Text(aufgabe.titel)
                    .strikethrough(aufgabe.erledigt)
                    .foregroundStyle(aufgabe.erledigt ? .secondary : .primary)

                HStack(spacing: 8) {
                    // Kategorie-Badge (wenn vorhanden)
                    if !aufgabe.kategorie.isEmpty {
                        Text(aufgabe.kategorie)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.quaternary)
                            .clipShape(Capsule())
                    }

                    // Fälligkeitsdatum (wenn vorhanden)
                    if let datum = aufgabe.faelligkeitsdatum {
                        Label(datum.formatted(date: .abbreviated, time: .omitted),
                              systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(datumFarbe(datum))
                    }

                    // Wiederkehrend-Symbol
                    if aufgabe.istWiederkehrend {
                        Image(systemName: "repeat")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Eisenhower-Indikatoren
            if aufgabe.wichtig || aufgabe.dringend {
                VStack(spacing: 2) {
                    if aufgabe.wichtig {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    if aufgabe.dringend {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Hilfsfunktionen

    /// Gibt die Farbe für das Fälligkeitsdatum zurück
    /// Rot wenn überfällig, Orange wenn heute, sonst sekundär
    private func datumFarbe(_ datum: Date) -> Color {
        if Calendar.current.isDateInToday(datum) {
            return .orange
        } else if datum < .now {
            return .red
        }
        return .secondary
    }
}
