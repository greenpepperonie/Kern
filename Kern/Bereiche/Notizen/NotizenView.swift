import SwiftUI
import SwiftData

/// Hauptansicht für den Notizen-Tab
/// Zeigt alle Notizen mit Kategorie-Filter, Suche und Schnell-Erstellen
struct NotizenView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Notiz.geaendertAm, order: .reverse) private var notizen: [Notiz]
    @State private var viewModel = NotizenViewModel()
    @State private var suchtext = ""
    @State private var zeigSprachNotiz = false
    @State private var zeigZeichnen = false

    /// Gefilterte Notizen nach Kategorie und Suchtext
    private var gefilterteNotizen: [Notiz] {
        var ergebnis = notizen

        // Kategorie-Filter
        if let kat = viewModel.ausgewaehlteKategorie {
            ergebnis = ergebnis.filter { $0.kategorie == kat }
        }

        // Suchtext-Filter
        if !suchtext.isEmpty {
            ergebnis = ergebnis.filter {
                $0.titel.localizedCaseInsensitiveContains(suchtext) ||
                $0.inhalt.localizedCaseInsensitiveContains(suchtext)
            }
        }

        return ergebnis
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Kategorie-Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Alle-Button
                    kategorieButton(nil, label: "Alle")

                    ForEach(NotizenViewModel.kategorien, id: \.self) { kat in
                        kategorieButton(kat, label: kat)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(.bar)

            // MARK: - Notizenliste
            List {
                // Schnellzugriffe
                Section {
                    NavigationLink {
                        VerschluesseltView()
                    } label: {
                        Label("Verschlüsselte Notizen", systemImage: "lock.fill")
                    }

                    Button {
                        zeigSprachNotiz = true
                    } label: {
                        Label("Sprach-Notiz aufnehmen", systemImage: "mic.fill")
                    }

                    Button {
                        zeigZeichnen = true
                    } label: {
                        Label("Skizze erstellen", systemImage: "pencil.tip.crop.circle")
                    }
                }
                if notizen.isEmpty {
                    ContentUnavailableView(
                        "Keine Notizen",
                        systemImage: "note.text",
                        description: Text("Tippe auf + um deine erste Notiz zu erstellen")
                    )
                } else if gefilterteNotizen.isEmpty {
                    ContentUnavailableView(
                        "Keine Treffer",
                        systemImage: "magnifyingglass",
                        description: Text("Ändere den Filter oder Suchbegriff")
                    )
                } else {
                    ForEach(gefilterteNotizen) { notiz in
                        NavigationLink {
                            NotizDetailView(notiz: notiz)
                        } label: {
                            notizZeile(notiz)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.notizLoeschen(notiz, context: context)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $suchtext, prompt: "Notizen durchsuchen")
        .navigationTitle("Notizen")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.zeigNeueNotizSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.zeigNeueNotizSheet) {
            NotizEditorView()
        }
        .sheet(isPresented: $zeigSprachNotiz) {
            SprachNotizView { pfad in
                // Sprach-Notiz als Notiz speichern
                let notiz = Notiz(
                    titel: "Sprach-Notiz \(Date.now.formatted(date: .abbreviated, time: .shortened))",
                    kategorie: "Schnell",
                    hatAufnahme: true,
                    aufnahmePfad: pfad
                )
                context.insert(notiz)
            }
        }
        .sheet(isPresented: $zeigZeichnen) {
            ZeichenView { daten in
                // Skizze als Datei speichern und Notiz erstellen
                let dateiname = "skizze_\(Date.now.timeIntervalSince1970).png"
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let pfad = documentsPath.appendingPathComponent(dateiname)
                try? daten.write(to: pfad)

                let notiz = Notiz(
                    titel: "Skizze \(Date.now.formatted(date: .abbreviated, time: .shortened))",
                    kategorie: "Idee"
                )
                context.insert(notiz)
            }
        }
    }

    // MARK: - Komponenten

    /// Kategorie-Filter-Button
    @ViewBuilder
    private func kategorieButton(_ kategorie: String?, label: String) -> some View {
        let istAktiv = viewModel.ausgewaehlteKategorie == kategorie
        Button(label) {
            viewModel.ausgewaehlteKategorie = kategorie
        }
        .buttonStyle(.bordered)
        .tint(istAktiv ? .accentColor : .secondary)
    }

    /// Notiz-Zeile in der Liste
    @ViewBuilder
    private func notizZeile(_ notiz: Notiz) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(notiz.titel)
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                if notiz.istVerschluesselt {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                if notiz.hatAufnahme {
                    Image(systemName: "waveform")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }

            // Vorschau des Inhalts
            if !notiz.inhalt.isEmpty {
                Text(notiz.inhalt)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Text(notiz.kategorie)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.quaternary)
                    .clipShape(Capsule())

                Spacer()

                Text(notiz.geaendertAm.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        NotizenView()
    }
    .modelContainer(for: Notiz.self, inMemory: true)
}
