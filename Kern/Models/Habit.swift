import Foundation
import SwiftData

/// Ein benutzerdefiniertes Habit (Gewohnheit) zum täglichen Tracken
@Model
class Habit {
    var name: String
    var symbol: String                 // SF Symbol Name
    var farbe: String                  // Farbname für die Darstellung
    var erstelltAm: Date

    init(
        name: String,
        symbol: String = "checkmark.circle",
        farbe: String = "blue",
        erstelltAm: Date = .now
    ) {
        self.name = name
        self.symbol = symbol
        self.farbe = farbe
        self.erstelltAm = erstelltAm
    }
}

/// Ein einzelner Eintrag: "Habit X wurde an Tag Y erledigt"
@Model
class HabitEintrag {
    var habitName: String              // Referenz zum Habit
    var datum: Date                    // Tag an dem das Habit erledigt wurde

    init(habitName: String, datum: Date = .now) {
        self.habitName = habitName
        self.datum = Calendar.current.startOfDay(for: datum)
    }
}
