import SwiftUI

/// Formular zum Erstellen einer neuen Flashcard
struct FlashcardFormularView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let deckName: String
    @State private var frage: String = ""
    @State private var antwort: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Frage") {
                    TextEditor(text: $frage)
                        .frame(minHeight: 80)
                }

                Section("Antwort") {
                    TextEditor(text: $antwort)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Neue Karte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") {
                        let karte = Flashcard(
                            frage: frage.trimmingCharacters(in: .whitespaces),
                            antwort: antwort.trimmingCharacters(in: .whitespaces),
                            deck: deckName
                        )
                        context.insert(karte)
                        dismiss()
                    }
                    .disabled(
                        frage.trimmingCharacters(in: .whitespaces).isEmpty ||
                        antwort.trimmingCharacters(in: .whitespaces).isEmpty
                    )
                }
            }
        }
    }
}
