import SwiftUI
import SwiftData

/// Hauptansicht für den Kontext-Tab
/// Zeigt Kontakte, bevorstehende Geburtstage und Sonnenzeiten
struct KontextView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Kontakt.name) private var kontakte: [Kontakt]
    @State private var zeigFormular = false

    /// Kontakte deren Geburtstag in den nächsten 30 Tagen liegt
    private var bevorsthendeGeburtstage: [Kontakt] {
        let kalender = Calendar.current
        let heute = kalender.startOfDay(for: .now)
        guard let in30Tagen = kalender.date(byAdding: .day, value: 30, to: heute) else { return [] }

        return kontakte.filter { kontakt in
            guard let geburtstag = kontakt.geburtstag else { return false }
            // Geburtstag auf dieses Jahr setzen
            var komponenten = kalender.dateComponents([.month, .day], from: geburtstag)
            komponenten.year = kalender.component(.year, from: heute)
            guard let diesjaehrig = kalender.date(from: komponenten) else { return false }
            return diesjaehrig >= heute && diesjaehrig <= in30Tagen
        }
        .sorted { a, b in
            let kalender = Calendar.current
            let tagA = kalender.dateComponents([.month, .day], from: a.geburtstag!)
            let tagB = kalender.dateComponents([.month, .day], from: b.geburtstag!)
            if tagA.month != tagB.month { return tagA.month! < tagB.month! }
            return tagA.day! < tagB.day!
        }
    }

    /// Kontakte bei denen der letzte Kontakt überfällig ist
    private var ueberfaelligeKontakte: [Kontakt] {
        kontakte.filter { kontakt in
            guard let letzter = kontakt.letzterKontakt,
                  let intervall = kontakt.erinnerungsintervallTage else { return false }
            let faelligkeit = Calendar.current.date(byAdding: .day, value: intervall, to: letzter) ?? .now
            return faelligkeit <= .now
        }
    }

    var body: some View {
        List {
            // MARK: - Schnellzugriffe
            Section {
                NavigationLink {
                    SonnenzeitenView()
                } label: {
                    Label("Sonnenzeiten", systemImage: "sunrise.fill")
                }
            }

            // MARK: - Bevorstehende Geburtstage
            if !bevorsthendeGeburtstage.isEmpty {
                Section("Bevorstehende Geburtstage") {
                    ForEach(bevorsthendeGeburtstage) { kontakt in
                        HStack {
                            Image(systemName: "gift.fill")
                                .foregroundStyle(.pink)
                            VStack(alignment: .leading) {
                                Text(kontakt.name)
                                    .font(.headline)
                                if let gb = kontakt.geburtstag {
                                    Text(geburtstagFormatiert(gb))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if let gb = kontakt.geburtstag {
                                Text(tagebishin(gb))
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.pink.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }

            // MARK: - Überfällige Kontakte
            if !ueberfaelligeKontakte.isEmpty {
                Section("Überfällig — Kontakt aufnehmen") {
                    ForEach(ueberfaelligeKontakte) { kontakt in
                        HStack {
                            Image(systemName: "person.crop.circle.badge.clock")
                                .foregroundStyle(.orange)
                            VStack(alignment: .leading) {
                                Text(kontakt.name)
                                    .font(.headline)
                                if let letzter = kontakt.letzterKontakt {
                                    Text("Letzter Kontakt: \(letzter.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            // Als kontaktiert markieren
                            Button {
                                kontakt.letzterKontakt = .now
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            } label: {
                                Image(systemName: "checkmark.circle")
                                    .foregroundStyle(.green)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            // MARK: - Alle Kontakte
            Section("Kontakte (\(kontakte.count))") {
                if kontakte.isEmpty {
                    ContentUnavailableView(
                        "Keine Kontakte",
                        systemImage: "person.crop.circle",
                        description: Text("Füge deinen ersten Kontakt hinzu")
                    )
                } else {
                    ForEach(kontakte) { kontakt in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(kontakt.name)
                                    .font(.headline)
                                HStack(spacing: 12) {
                                    if kontakt.geburtstag != nil {
                                        Image(systemName: "gift")
                                            .font(.caption)
                                            .foregroundStyle(.pink)
                                    }
                                    if let letzter = kontakt.letzterKontakt {
                                        Label(letzter.formatted(date: .abbreviated, time: .omitted),
                                              systemImage: "clock")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                context.delete(kontakt)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                kontakt.letzterKontakt = .now
                            } label: {
                                Label("Kontaktiert", systemImage: "checkmark")
                            }
                            .tint(.green)
                        }
                    }
                }
            }
        }
        .navigationTitle("Kontext")
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
            KontaktFormularView()
        }
    }

    // MARK: - Hilfsfunktionen

    /// Formatiert einen Geburtstag (Tag.Monat)
    private func geburtstagFormatiert(_ datum: Date) -> String {
        datum.formatted(.dateTime.day().month(.wide))
    }

    /// Berechnet "In X Tagen" oder "Heute" für einen Geburtstag
    private func tagebishin(_ geburtstag: Date) -> String {
        let kalender = Calendar.current
        let heute = kalender.startOfDay(for: .now)
        var komponenten = kalender.dateComponents([.month, .day], from: geburtstag)
        komponenten.year = kalender.component(.year, from: heute)
        guard let diesjaehrig = kalender.date(from: komponenten) else { return "" }

        let tage = kalender.dateComponents([.day], from: heute, to: diesjaehrig).day ?? 0
        if tage == 0 { return "Heute!" }
        if tage == 1 { return "Morgen" }
        return "In \(tage) Tagen"
    }
}

#Preview {
    NavigationStack {
        KontextView()
    }
    .modelContainer(for: Kontakt.self, inMemory: true)
}
