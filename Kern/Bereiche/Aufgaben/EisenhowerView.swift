import SwiftUI
import SwiftData

/// Eisenhower-Matrix: 4-Quadranten-Ansicht zur Priorisierung
/// Teilt Aufgaben in wichtig/dringend Quadranten ein
struct EisenhowerView: View {
    @Query(filter: #Predicate<Aufgabe> { !$0.erledigt }) private var offeneAufgaben: [Aufgabe]

    /// Aufgaben für einen bestimmten Quadranten filtern
    private func aufgabenFuer(wichtig: Bool, dringend: Bool) -> [Aufgabe] {
        offeneAufgaben.filter { $0.wichtig == wichtig && $0.dringend == dringend }
    }

    var body: some View {
        VStack(spacing: 2) {
            // Spaltenüberschriften
            HStack {
                Spacer()
                Text("DRINGEND")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Text("NICHT DRINGEND")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.leading, 32)

            HStack(spacing: 2) {
                // Zeilenüberschriften
                VStack {
                    Text("WICHTIG")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 30)
                        .frame(maxHeight: .infinity)

                    Text("NICHT\nWICHTIG")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 30)
                        .frame(maxHeight: .infinity)
                }

                // Quadranten
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        // Q1: Wichtig & Dringend → Sofort erledigen
                        QuadrantView(
                            titel: "Sofort erledigen",
                            farbe: .red,
                            symbol: "flame.fill",
                            aufgaben: aufgabenFuer(wichtig: true, dringend: true)
                        )

                        // Q2: Wichtig & Nicht Dringend → Planen
                        QuadrantView(
                            titel: "Planen",
                            farbe: .blue,
                            symbol: "calendar",
                            aufgaben: aufgabenFuer(wichtig: true, dringend: false)
                        )
                    }

                    HStack(spacing: 2) {
                        // Q3: Nicht Wichtig & Dringend → Delegieren
                        QuadrantView(
                            titel: "Delegieren",
                            farbe: .orange,
                            symbol: "person.2.fill",
                            aufgaben: aufgabenFuer(wichtig: false, dringend: true)
                        )

                        // Q4: Nicht Wichtig & Nicht Dringend → Eliminieren
                        QuadrantView(
                            titel: "Eliminieren",
                            farbe: .secondary,
                            symbol: "trash",
                            aufgaben: aufgabenFuer(wichtig: false, dringend: false)
                        )
                    }
                }
            }
        }
        .padding(8)
        .navigationTitle("Eisenhower-Matrix")
    }
}

/// Ein einzelner Quadrant der Eisenhower-Matrix
struct QuadrantView: View {
    let titel: String
    let farbe: Color
    let symbol: String
    let aufgaben: [Aufgabe]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Quadrant-Header
            HStack {
                Image(systemName: symbol)
                    .foregroundStyle(farbe)
                Text(titel)
                    .font(.caption.bold())
                    .foregroundStyle(farbe)
                Spacer()
                Text("\(aufgaben.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Aufgabenliste
            if aufgaben.isEmpty {
                Text("Keine Aufgaben")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(aufgaben) { aufgabe in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(farbe)
                                    .frame(width: 6, height: 6)
                                Text(aufgabe.titel)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(farbe.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        EisenhowerView()
    }
    .modelContainer(for: Aufgabe.self, inMemory: true)
}
