import Foundation

/// Service für die Kommunikation mit der Claude API (Anthropic)
/// Wird für KI-Lernassistent und Einkaufslisten-Kategorisierung verwendet
class ClaudeAPIService {
    /// Singleton-Instanz
    static let shared = ClaudeAPIService()

    /// API-Key aus UserDefaults laden (wird in den Einstellungen gesetzt)
    var apiKey: String? {
        UserDefaults.standard.string(forKey: "anthropic_api_key")
    }

    /// Prüft ob ein API-Key konfiguriert ist
    var istKonfiguriert: Bool {
        guard let key = apiKey else { return false }
        return !key.isEmpty
    }

    private let baseURL = "https://api.anthropic.com/v1/messages"
    private let model = "claude-sonnet-4-20250514"

    // MARK: - Flashcards generieren

    /// Generiert Flashcards zu einem Thema mit bestimmtem Schwierigkeitsgrad
    /// - Parameters:
    ///   - thema: Das Lernthema (z.B. "Photosynthese", "Französische Revolution")
    ///   - schwierigkeitsgrad: Level des Lernenden (z.B. "8 Jahre alt", "Schüler", "Student")
    ///   - anzahl: Wie viele Karten generiert werden sollen
    /// - Returns: Array von (Frage, Antwort) Tuples
    func flashcardsGenerieren(
        thema: String,
        schwierigkeitsgrad: String,
        anzahl: Int = 10
    ) async throws -> [(frage: String, antwort: String)] {
        let prompt = """
        Erstelle genau \(anzahl) Lernkarten (Flashcards) zum Thema "\(thema)".

        Schwierigkeitsgrad: \(schwierigkeitsgrad)

        Antworte NUR mit einem JSON-Array in diesem Format, ohne weitere Erklärung:
        [{"frage": "...", "antwort": "..."}]

        Die Fragen sollen klar und präzise sein.
        Die Antworten sollen kurz und verständlich sein, passend zum Schwierigkeitsgrad.
        Alles auf Deutsch.
        """

        let antwort = try await sendeAnfrage(prompt: prompt)

        // JSON parsen
        guard let jsonData = antwort.data(using: .utf8) else {
            throw ClaudeAPIFehler.ungueltigeAntwort
        }

        struct FlashcardJSON: Codable {
            let frage: String
            let antwort: String
        }

        let karten = try JSONDecoder().decode([FlashcardJSON].self, from: jsonData)
        return karten.map { (frage: $0.frage, antwort: $0.antwort) }
    }

    // MARK: - Einkaufs-Kategorie bestimmen

    /// Bestimmt die passende Kategorie für einen Einkaufsartikel
    /// - Parameter artikelName: Name des Artikels (z.B. "Hafermilch")
    /// - Returns: Kategoriename (z.B. "Milchprodukte")
    func einkaufskategorieBerechnen(_ artikelName: String) async throws -> String {
        let kategorien = "Obst & Gemüse, Milchprodukte, Fleisch & Fisch, Backwaren, Getränke, Haushalt, Tiefkühl, Snacks, Sonstiges"

        let prompt = """
        Ordne den Einkaufsartikel "\(artikelName)" einer dieser Kategorien zu:
        \(kategorien)

        Antworte NUR mit dem Kategorienamen, ohne weitere Erklärung.
        """

        let antwort = try await sendeAnfrage(prompt: prompt)
        return antwort.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - API-Kommunikation

    /// Sendet eine Anfrage an die Claude API und gibt die Textantwort zurück
    private func sendeAnfrage(prompt: String) async throws -> String {
        guard let apiKey, !apiKey.isEmpty else {
            throw ClaudeAPIFehler.keinAPIKey
        }

        guard let url = URL(string: baseURL) else {
            throw ClaudeAPIFehler.ungueltigeURL
        }

        // Request Body
        let body: [String: Any] = [
            "model": model,
            "max_tokens": 2048,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        // HTTP-Status prüfen
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeAPIFehler.netzwerkFehler
        }

        guard httpResponse.statusCode == 200 else {
            throw ClaudeAPIFehler.httpFehler(statusCode: httpResponse.statusCode)
        }

        // Antwort parsen
        struct APIAntwort: Codable {
            struct Content: Codable {
                let text: String
            }
            let content: [Content]
        }

        let apiAntwort = try JSONDecoder().decode(APIAntwort.self, from: data)
        guard let text = apiAntwort.content.first?.text else {
            throw ClaudeAPIFehler.ungueltigeAntwort
        }

        return text
    }
}

// MARK: - Fehlertypen

enum ClaudeAPIFehler: LocalizedError {
    case keinAPIKey
    case ungueltigeURL
    case netzwerkFehler
    case httpFehler(statusCode: Int)
    case ungueltigeAntwort

    var errorDescription: String? {
        switch self {
        case .keinAPIKey: return "Kein API-Key konfiguriert. Bitte in den Einstellungen hinterlegen."
        case .ungueltigeURL: return "Ungültige API-URL."
        case .netzwerkFehler: return "Netzwerkfehler. Bitte Internetverbindung prüfen."
        case .httpFehler(let code): return "API-Fehler (HTTP \(code))."
        case .ungueltigeAntwort: return "Ungültige Antwort von der API."
        }
    }
}
