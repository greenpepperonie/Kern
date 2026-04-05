import SwiftUI
import SwiftData

/// Habit Tracking Hauptansicht
/// Zeigt alle Habits mit heutigem Status, Wochenansicht und Verlaufs-Charts
struct HabitTrackingView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Habit.erstelltAm) private var habits: [Habit]
    @Query private var eintraege: [HabitEintrag]
    @State private var zeigNeuesHabit = false
    @State private var neuerName = ""
    @State private var neuesSymbol = "checkmark.circle"
    @State private var neueFarbe = "blue"

    private let verfuegbareFarben = ["blue", "green", "orange", "red", "purple", "pink", "mint", "indigo"]
    private let verfuegbareSymbole = [
        "checkmark.circle", "figure.walk", "book.fill", "drop.fill",
        "moon.fill", "fork.knife", "dumbbell.fill", "heart.fill",
        "brain.head.profile", "cup.and.saucer.fill"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Heute
                if habits.isEmpty {
                    ContentUnavailableView(
                        "Keine Habits",
                        systemImage: "repeat.circle",
                        description: Text("Erstelle dein erstes Habit")
                    )
                    .padding(.top, 64)
                } else {
                    // Heutige Übersicht
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Heute")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(habits) { habit in
                            let istHeute = istErledigtAn(habit: habit, datum: .now)
                            HStack(spacing: 12) {
                                // Abhak-Button
                                Button {
                                    toggleHabit(habit)
                                } label: {
                                    Image(systemName: istHeute ? "\(habit.symbol).fill" : habit.symbol)
                                        .font(.title2)
                                        .foregroundStyle(istHeute ? farbeFuer(habit.farbe) : .secondary)
                                        .frame(width: 44, height: 44)
                                }
                                .buttonStyle(.plain)

                                Text(habit.name)
                                    .font(.body)
                                    .strikethrough(istHeute)
                                    .foregroundStyle(istHeute ? .secondary : .primary)

                                Spacer()

                                // Streak
                                let streak = berechneStreak(habit)
                                if streak > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "flame.fill")
                                            .font(.caption)
                                            .foregroundStyle(.orange)
                                        Text("\(streak)")
                                            .font(.caption.bold())
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(.quaternary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    habitLoeschen(habit)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                        }
                    }

                    // MARK: - Wochenansicht (GitHub-Style)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Letzte 7 Wochen")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(habits) { habit in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habit.name)
                                    .font(.caption.bold())
                                    .padding(.horizontal)

                                GitHubStyleGrid(
                                    habit: habit,
                                    eintraege: eintraege.filter { $0.habitName == habit.name },
                                    farbe: farbeFuer(habit.farbe)
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top, 8)

                    // MARK: - Verlaufs-Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Verlauf (30 Tage)")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(habits) { habit in
                            VerlaufsChart(
                                habitName: habit.name,
                                eintraege: eintraege.filter { $0.habitName == habit.name },
                                farbe: farbeFuer(habit.farbe)
                            )
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Habit Tracker")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    zeigNeuesHabit = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Neues Habit", isPresented: $zeigNeuesHabit) {
            TextField("Name (z.B. Wasser trinken)", text: $neuerName)
            Button("Erstellen") {
                let name = neuerName.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { return }
                let habit = Habit(name: name, symbol: neuesSymbol, farbe: neueFarbe)
                context.insert(habit)
                neuerName = ""
            }
            Button("Abbrechen", role: .cancel) { neuerName = "" }
        }
    }

    // MARK: - Hilfsfunktionen

    /// Prüft ob ein Habit an einem bestimmten Tag erledigt wurde
    private func istErledigtAn(habit: Habit, datum: Date) -> Bool {
        let tag = Calendar.current.startOfDay(for: datum)
        return eintraege.contains { $0.habitName == habit.name && $0.datum == tag }
    }

    /// Toggled ein Habit für heute
    private func toggleHabit(_ habit: Habit) {
        let heute = Calendar.current.startOfDay(for: .now)
        if let bestehend = eintraege.first(where: { $0.habitName == habit.name && $0.datum == heute }) {
            context.delete(bestehend)
        } else {
            let eintrag = HabitEintrag(habitName: habit.name)
            context.insert(eintrag)
        }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Berechnet den aktuellen Streak eines Habits
    private func berechneStreak(_ habit: Habit) -> Int {
        let kalender = Calendar.current
        var streak = 0
        var tag = kalender.startOfDay(for: .now)

        while true {
            if eintraege.contains(where: { $0.habitName == habit.name && $0.datum == tag }) {
                streak += 1
                guard let vortag = kalender.date(byAdding: .day, value: -1, to: tag) else { break }
                tag = vortag
            } else {
                break
            }
        }
        return streak
    }

    private func habitLoeschen(_ habit: Habit) {
        // Alle Einträge des Habits löschen
        for eintrag in eintraege where eintrag.habitName == habit.name {
            context.delete(eintrag)
        }
        context.delete(habit)
    }

    /// Konvertiert Farbnamen in SwiftUI Color
    func farbeFuer(_ name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        case "pink": return .pink
        case "mint": return .mint
        case "indigo": return .indigo
        default: return .blue
        }
    }
}

// MARK: - GitHub-Style Wochenansicht

/// Zeigt die letzten 7 Wochen als Kästchen-Grid (wie GitHub Contributions)
struct GitHubStyleGrid: View {
    let habit: Habit
    let eintraege: [HabitEintrag]
    let farbe: Color

    /// Die letzten 49 Tage (7 Wochen)
    private var tage: [Date] {
        let kalender = Calendar.current
        let heute = kalender.startOfDay(for: .now)
        return (0..<49).compactMap { offset in
            kalender.date(byAdding: .day, value: -48 + offset, to: heute)
        }
    }

    var body: some View {
        // 7 Spalten (Wochen) x 7 Zeilen (Tage)
        let spalten = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)

        LazyVGrid(columns: spalten, spacing: 3) {
            ForEach(tage, id: \.self) { tag in
                let istErledigt = eintraege.contains { $0.datum == tag }
                RoundedRectangle(cornerRadius: 2)
                    .fill(istErledigt ? farbe : farbe.opacity(0.1))
                    .frame(height: 14)
            }
        }
    }
}

// MARK: - Verlaufs-Chart (Linien-Chart)

/// Einfacher Linien-Chart der letzten 30 Tage
/// Zeigt kumulative Erledigungen als Balken
struct VerlaufsChart: View {
    let habitName: String
    let eintraege: [HabitEintrag]
    let farbe: Color

    /// Erledigungen pro Tag der letzten 30 Tage (0 oder 1)
    private var tagesWerte: [(Date, Bool)] {
        let kalender = Calendar.current
        let heute = kalender.startOfDay(for: .now)
        return (0..<30).compactMap { offset in
            guard let tag = kalender.date(byAdding: .day, value: -29 + offset, to: heute) else { return nil }
            let erledigt = eintraege.contains { $0.datum == tag }
            return (tag, erledigt)
        }
    }

    /// Erfolgsquote der letzten 30 Tage
    private var erfolgsquote: Double {
        let erledigte = tagesWerte.filter(\.1).count
        return Double(erledigte) / 30.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Chart-Header
            HStack {
                Text(habitName)
                    .font(.subheadline.bold())
                Spacer()
                Text("\(Int(erfolgsquote * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(erfolgsquote >= 0.7 ? .green : erfolgsquote >= 0.4 ? .orange : .red)
            }

            // Balken-Chart
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(tagesWerte, id: \.0) { tag, erledigt in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(erledigt ? farbe : farbe.opacity(0.15))
                        .frame(height: erledigt ? 24 : 4)
                }
            }
            .frame(height: 24)

            // Legende
            HStack {
                Text("Vor 30 Tagen")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Heute")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        HabitTrackingView()
    }
    .modelContainer(for: [Habit.self, HabitEintrag.self], inMemory: true)
}
