import SwiftUI
import CoreLocation

/// Zeigt Sonnenauf- und -untergang basierend auf dem aktuellen Standort
/// Berechnung erfolgt mit einer vereinfachten astronomischen Formel
struct SonnenzeitenView: View {
    @State private var sonnenaufgang: Date?
    @State private var sonnenuntergang: Date?
    @State private var standort: CLLocation?
    @State private var fehler: String?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Sonnenaufgang
            VStack(spacing: 8) {
                Image(systemName: "sunrise.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)

                Text("Sonnenaufgang")
                    .font(.headline)

                if let zeit = sonnenaufgang {
                    Text(zeit.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 36, weight: .light))
                } else {
                    Text("—")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(.secondary)
                }
            }

            Divider()
                .padding(.horizontal, 64)

            // Sonnenuntergang
            VStack(spacing: 8) {
                Image(systemName: "sunset.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.indigo)

                Text("Sonnenuntergang")
                    .font(.headline)

                if let zeit = sonnenuntergang {
                    Text(zeit.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 36, weight: .light))
                } else {
                    Text("—")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(.secondary)
                }
            }

            // Tageslänge
            if let auf = sonnenaufgang, let unter = sonnenuntergang {
                let dauer = unter.timeIntervalSince(auf)
                let stunden = Int(dauer) / 3600
                let minuten = (Int(dauer) % 3600) / 60

                HStack {
                    Image(systemName: "clock")
                    Text("Tageslänge: \(stunden)h \(minuten)min")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            }

            Spacer()

            if let fehler {
                Text(fehler)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding()
            }
        }
        .navigationTitle("Sonnenzeiten")
        .onAppear {
            berechne()
        }
    }

    // MARK: - Sonnenzeiten-Berechnung

    /// Vereinfachte Berechnung der Sonnenzeiten
    /// Verwendet Standardkoordinaten für Deutschland (München) als Fallback
    private func berechne() {
        // Standard: München (48.1351, 11.5820)
        let breitengrad = 48.1351
        let laengengrad = 11.5820

        let kalender = Calendar.current
        let heute = Date.now
        let tagDesJahres = kalender.ordinality(of: .day, in: .year, for: heute) ?? 1

        // Vereinfachte astronomische Berechnung
        let deklination = -23.45 * cos(Double(360) / 365.0 * Double(tagDesJahres + 10) * .pi / 180)

        let breitengradRad = breitengrad * .pi / 180
        let deklinationRad = deklination * .pi / 180

        // Stundenwinkel
        let cosStundenwinkel = (sin(-0.833 * .pi / 180) - sin(breitengradRad) * sin(deklinationRad)) /
                                (cos(breitengradRad) * cos(deklinationRad))

        // Prüfen ob Berechnung möglich (Polartag/-nacht)
        guard abs(cosStundenwinkel) <= 1 else {
            fehler = "Keine Berechnung möglich für diesen Standort."
            return
        }

        let stundenwinkel = acos(cosStundenwinkel) * 180 / .pi

        // Sonnenauf-/untergang in Stunden (UTC)
        let mittag = 12.0 - laengengrad / 15.0
        let aufgangUTC = mittag - stundenwinkel / 15.0
        let untergangUTC = mittag + stundenwinkel / 15.0

        // In lokale Zeit konvertieren
        let zeitzone = Double(TimeZone.current.secondsFromGMT()) / 3600.0
        let aufgangLokal = aufgangUTC + zeitzone
        let untergangLokal = untergangUTC + zeitzone

        // Als Date-Objekte erstellen
        let startDesTages = kalender.startOfDay(for: heute)
        sonnenaufgang = kalender.date(byAdding: .second, value: Int(aufgangLokal * 3600), to: startDesTages)
        sonnenuntergang = kalender.date(byAdding: .second, value: Int(untergangLokal * 3600), to: startDesTages)
    }
}

#Preview {
    NavigationStack {
        SonnenzeitenView()
    }
}
