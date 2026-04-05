import SwiftUI
import SwiftData

/// Hauptansicht für den Gesundheit-Tab
/// Zeigt Übersicht, Atemübung-Zugang und Gesundheitseinträge
struct GesundheitView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \GesundheitsEintrag.datum, order: .reverse) private var eintraege: [GesundheitsEintrag]
    @State private var zeigFormular = false

    /// Heutiger Eintrag (falls vorhanden)
    private var heutigerEintrag: GesundheitsEintrag? {
        eintraege.first { Calendar.current.isDateInToday($0.datum) }
    }

    /// Durchschnittliches Energie-Level der letzten 7 Tage
    private var durchschnittEnergie: Double? {
        let letzte7Tage = eintraege.prefix(7).compactMap(\.energieLevel)
        guard !letzte7Tage.isEmpty else { return nil }
        return Double(letzte7Tage.reduce(0, +)) / Double(letzte7Tage.count)
    }

    /// Durchschnittlicher Schlaf der letzten 7 Tage
    private var durchschnittSchlaf: Double? {
        let letzte7Tage = eintraege.prefix(7).compactMap(\.schlafStunden)
        guard !letzte7Tage.isEmpty else { return nil }
        return letzte7Tage.reduce(0, +) / Double(letzte7Tage.count)
    }

    var body: some View {
        List {
            // MARK: - Schnellzugriffe
            Section {
                NavigationLink {
                    HabitTrackingView()
                } label: {
                    HStack {
                        Image(systemName: "repeat.circle.fill")
                            .foregroundStyle(.purple)
                            .frame(width: 32)
                        Text("Habit Tracker")
                    }
                }

                NavigationLink {
                    AtemuebungView()
                } label: {
                    HStack {
                        Image(systemName: "wind")
                            .foregroundStyle(.cyan)
                            .frame(width: 32)
                        Text("Atemübung")
                    }
                }
            }

            // MARK: - Heutige Übersicht
            Section("Heute") {
                if let eintrag = heutigerEintrag {
                    // Schlaf
                    if let schlaf = eintrag.schlafStunden {
                        HStack {
                            Label("Schlaf", systemImage: "moon.fill")
                                .foregroundStyle(.indigo)
                            Spacer()
                            Text("\(schlaf, specifier: "%.1f") h")
                                .fontWeight(.semibold)
                        }
                    }

                    // Energie
                    if let energie = eintrag.energieLevel {
                        HStack {
                            Label("Energie", systemImage: "bolt.fill")
                                .foregroundStyle(.orange)
                            Spacer()
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { i in
                                    Circle()
                                        .fill(i <= energie ? .orange : .secondary.opacity(0.3))
                                        .frame(width: 10, height: 10)
                                }
                            }
                        }
                    }

                    // Symptome
                    if !eintrag.symptome.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Symptome", systemImage: "heart.text.square")
                                .foregroundStyle(.red)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(eintrag.symptome, id: \.self) { symptom in
                                        Text(symptom)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(.red.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Button {
                        zeigFormular = true
                    } label: {
                        Label("Heutigen Eintrag erfassen", systemImage: "plus.circle")
                    }
                }
            }

            // MARK: - 7-Tage-Durchschnitt
            if durchschnittEnergie != nil || durchschnittSchlaf != nil {
                Section("Letzte 7 Tage") {
                    if let schlaf = durchschnittSchlaf {
                        HStack {
                            Label("Ø Schlaf", systemImage: "moon.fill")
                            Spacer()
                            Text("\(schlaf, specifier: "%.1f") h")
                                .foregroundStyle(.secondary)
                        }
                    }
                    if let energie = durchschnittEnergie {
                        HStack {
                            Label("Ø Energie", systemImage: "bolt.fill")
                            Spacer()
                            Text("\(energie, specifier: "%.1f") / 5")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // MARK: - Verlauf
            Section("Verlauf") {
                if eintraege.isEmpty {
                    ContentUnavailableView(
                        "Keine Einträge",
                        systemImage: "heart.text.square",
                        description: Text("Erfasse deinen ersten Gesundheitseintrag")
                    )
                } else {
                    ForEach(eintraege) { eintrag in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(eintrag.datum.formatted(date: .abbreviated, time: .omitted))
                                    .font(.headline)
                                Spacer()
                                if let energie = eintrag.energieLevel {
                                    HStack(spacing: 2) {
                                        Image(systemName: "bolt.fill")
                                            .font(.caption)
                                        Text("\(energie)")
                                    }
                                    .foregroundStyle(.orange)
                                }
                            }

                            HStack(spacing: 16) {
                                if let schlaf = eintrag.schlafStunden {
                                    Label("\(schlaf, specifier: "%.1f")h", systemImage: "moon.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                if !eintrag.symptome.isEmpty {
                                    Label("\(eintrag.symptome.count) Symptome", systemImage: "bandage")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                context.delete(eintrag)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Gesundheit")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    zeigFormular = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $zeigFormular) {
            GesundheitEintragFormular()
        }
    }
}

#Preview {
    NavigationStack {
        GesundheitView()
    }
    .modelContainer(for: GesundheitsEintrag.self, inMemory: true)
}
