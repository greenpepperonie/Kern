import Foundation
import SwiftData

/// Ein Kontakt mit Geburtstag und Erinnerung für letzten Kontakt
@Model
class Kontakt {
    var name: String
    var geburtstag: Date?
    var letzterKontakt: Date?
    var notiz: String?
    var erinnerungsintervallTage: Int?     // Alle X Tage erinnern

    init(
        name: String,
        geburtstag: Date? = nil,
        letzterKontakt: Date? = nil,
        notiz: String? = nil,
        erinnerungsintervallTage: Int? = nil
    ) {
        self.name = name
        self.geburtstag = geburtstag
        self.letzterKontakt = letzterKontakt
        self.notiz = notiz
        self.erinnerungsintervallTage = erinnerungsintervallTage
    }
}
