import SwiftUI

/// Hauptansicht für Timer, Stoppuhr und Wecker
/// Wechsel zwischen den drei Modi über ein Segmented-Picker
struct TimerView: View {
    @State private var ausgewaehlterModus = 0

    var body: some View {
        VStack(spacing: 0) {
            // Modus-Auswahl
            Picker("Modus", selection: $ausgewaehlterModus) {
                Text("Timer").tag(0)
                Text("Stoppuhr").tag(1)
                Text("Wecker").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            // Anzeige je nach Modus
            switch ausgewaehlterModus {
            case 0:
                CountdownTimerView()
            case 1:
                StoppuhrView()
            case 2:
                WeckerView()
            default:
                EmptyView()
            }
        }
        .navigationTitle("Timer")
    }
}

// MARK: - Countdown-Timer

/// Countdown-Timer mit einstellbarer Dauer
/// Zeigt die verbleibende Zeit als großen Ring an
struct CountdownTimerView: View {
    @State private var gesamtSekunden: Int = 300   // Standard: 5 Minuten
    @State private var verbleibendeSekunden: Int = 300
    @State private var laeuft = false
    @State private var timer: Timer?

    // Voreinstellungen in Sekunden
    private let voreinstellungen: [(String, Int)] = [
        ("1 Min", 60),
        ("5 Min", 300),
        ("10 Min", 600),
        ("15 Min", 900),
        ("25 Min", 1500),
        ("30 Min", 1800),
    ]

    /// Fortschritt als Wert zwischen 0.0 und 1.0
    private var fortschritt: Double {
        guard gesamtSekunden > 0 else { return 0 }
        return Double(verbleibendeSekunden) / Double(gesamtSekunden)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Timer-Ring mit Zeitanzeige
            ZStack {
                // Hintergrund-Ring
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 12)

                // Fortschritts-Ring
                Circle()
                    .trim(from: 0, to: fortschritt)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: fortschritt)

                // Zeitanzeige in der Mitte
                Text(zeitFormatiert(verbleibendeSekunden))
                    .font(.system(size: 56, weight: .light, design: .monospaced))
                    .contentTransition(.numericText())
            }
            .frame(width: 250, height: 250)

            // Voreinstellungen (nur wenn nicht läuft)
            if !laeuft && verbleibendeSekunden == gesamtSekunden {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(voreinstellungen, id: \.1) { name, sekunden in
                            Button(name) {
                                gesamtSekunden = sekunden
                                verbleibendeSekunden = sekunden
                            }
                            .buttonStyle(.bordered)
                            .tint(gesamtSekunden == sekunden ? .accentColor : .secondary)
                        }
                    }
                    .padding(.horizontal)
                }
            }

            Spacer()

            // Steuerung
            HStack(spacing: 32) {
                // Reset-Button
                Button {
                    zuruecksetzen()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .frame(width: 64, height: 64)
                        .background(.quaternary)
                        .clipShape(Circle())
                }
                .disabled(!laeuft && verbleibendeSekunden == gesamtSekunden)

                // Start/Pause-Button
                Button {
                    if laeuft {
                        pausieren()
                    } else {
                        starten()
                    }
                } label: {
                    Image(systemName: laeuft ? "pause.fill" : "play.fill")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.white)
                        .background(laeuft ? .orange : .accentColor)
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 32)
        }
    }

    // MARK: - Timer-Steuerung

    private func starten() {
        laeuft = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if verbleibendeSekunden > 0 {
                verbleibendeSekunden -= 1
            } else {
                // Timer abgelaufen
                pausieren()
                // Haptisches Feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }

    private func pausieren() {
        laeuft = false
        timer?.invalidate()
        timer = nil
    }

    private func zuruecksetzen() {
        pausieren()
        verbleibendeSekunden = gesamtSekunden
    }

    /// Formatiert Sekunden in MM:SS oder HH:MM:SS
    private func zeitFormatiert(_ sekunden: Int) -> String {
        let stunden = sekunden / 3600
        let minuten = (sekunden % 3600) / 60
        let sek = sekunden % 60
        if stunden > 0 {
            return String(format: "%d:%02d:%02d", stunden, minuten, sek)
        }
        return String(format: "%02d:%02d", minuten, sek)
    }
}

// MARK: - Stoppuhr

/// Stoppuhr mit Runden-Funktion
struct StoppuhrView: View {
    @State private var verstricheneZeit: TimeInterval = 0
    @State private var laeuft = false
    @State private var timer: Timer?
    @State private var runden: [TimeInterval] = []
    @State private var startZeit: Date?
    @State private var akkumulierteZeit: TimeInterval = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Zeitanzeige
            Text(stoppuhrFormatiert(verstricheneZeit))
                .font(.system(size: 56, weight: .light, design: .monospaced))
                .contentTransition(.numericText())

            Spacer()

            // Runden-Liste
            if !runden.isEmpty {
                List {
                    ForEach(Array(runden.enumerated().reversed()), id: \.offset) { index, zeit in
                        HStack {
                            Text("Runde \(index + 1)")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(stoppuhrFormatiert(zeit))
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
                .listStyle(.plain)
                .frame(maxHeight: 200)
            }

            // Steuerung
            HStack(spacing: 32) {
                // Runde / Reset
                Button {
                    if laeuft {
                        // Runde hinzufügen
                        runden.append(verstricheneZeit)
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    } else if verstricheneZeit > 0 {
                        // Zurücksetzen
                        verstricheneZeit = 0
                        akkumulierteZeit = 0
                        runden.removeAll()
                    }
                } label: {
                    Image(systemName: laeuft ? "flag.fill" : "arrow.counterclockwise")
                        .font(.title2)
                        .frame(width: 64, height: 64)
                        .background(.quaternary)
                        .clipShape(Circle())
                }
                .disabled(!laeuft && verstricheneZeit == 0)

                // Start/Pause
                Button {
                    if laeuft {
                        pausieren()
                    } else {
                        starten()
                    }
                } label: {
                    Image(systemName: laeuft ? "pause.fill" : "play.fill")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.white)
                        .background(laeuft ? .orange : .green)
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 32)
        }
    }

    private func starten() {
        laeuft = true
        startZeit = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if let start = startZeit {
                verstricheneZeit = akkumulierteZeit + Date().timeIntervalSince(start)
            }
        }
    }

    private func pausieren() {
        laeuft = false
        timer?.invalidate()
        timer = nil
        akkumulierteZeit = verstricheneZeit
        startZeit = nil
    }

    /// Formatiert TimeInterval in MM:SS.CC (Hundertstel)
    private func stoppuhrFormatiert(_ zeit: TimeInterval) -> String {
        let minuten = Int(zeit) / 60
        let sekunden = Int(zeit) % 60
        let hundertstel = Int((zeit.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minuten, sekunden, hundertstel)
    }
}

// MARK: - Wecker

/// Einfacher Wecker — setzt eine Uhrzeit, zu der ein Alarm ausgelöst wird
struct WeckerView: View {
    @State private var weckzeit = Date()
    @State private var istAktiv = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            if istAktiv {
                // Aktiver Wecker: Anzeige der eingestellten Zeit
                VStack(spacing: 16) {
                    Image(systemName: "alarm.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.accentColor)
                        .symbolEffect(.pulse, isActive: true)

                    Text("Wecker gestellt für")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(weckzeit.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 48, weight: .light))
                }
            } else {
                // Wecker einstellen
                DatePicker(
                    "Weckzeit",
                    selection: $weckzeit,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
            }

            Spacer()

            // Aktivieren / Deaktivieren
            Button {
                istAktiv.toggle()
                if istAktiv {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            } label: {
                Text(istAktiv ? "Wecker ausschalten" : "Wecker stellen")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(istAktiv ? .red : .accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    NavigationStack {
        TimerView()
    }
}
