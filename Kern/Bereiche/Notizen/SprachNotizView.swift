import SwiftUI
import AVFoundation

/// Sprach-Notiz Aufnahme und Wiedergabe
/// Nutzt AVFoundation für Audio-Recording
struct SprachNotizView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var nimmtAuf = false
    @State private var spieltAb = false
    @State private var aufnahmePfad: URL?
    @State private var aufnahmeDauer: TimeInterval = 0
    @State private var timer: Timer?
    @State private var fehler: String?

    /// Callback wenn Aufnahme gesichert wird — gibt den Dateipfad zurück
    var onSpeichern: ((String) -> Void)?

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // MARK: - Aufnahme-Anzeige
                ZStack {
                    // Pulsierender Ring während Aufnahme
                    Circle()
                        .stroke(Color.red.opacity(nimmtAuf ? 0.3 : 0), lineWidth: 4)
                        .frame(width: 160, height: 160)
                        .scaleEffect(nimmtAuf ? 1.3 : 1)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: nimmtAuf)

                    Circle()
                        .fill(nimmtAuf ? Color.red.opacity(0.15) : Color.secondary.opacity(0.1))
                        .frame(width: 140, height: 140)

                    Image(systemName: nimmtAuf ? "waveform" : (aufnahmePfad != nil ? "play.fill" : "mic.fill"))
                        .font(.system(size: 48))
                        .foregroundStyle(nimmtAuf ? .red : Color.accentColor)
                        .symbolEffect(.variableColor, isActive: nimmtAuf)
                }

                // Dauer-Anzeige
                Text(zeitFormatiert(aufnahmeDauer))
                    .font(.system(size: 36, weight: .light, design: .monospaced))
                    .contentTransition(.numericText())

                // Fehlermeldung
                if let fehler {
                    Text(fehler)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                // MARK: - Steuerung
                HStack(spacing: 32) {
                    if aufnahmePfad != nil && !nimmtAuf {
                        // Abspielen-Button (wenn Aufnahme vorhanden)
                        Button {
                            if spieltAb {
                                wiedergabeStoppen()
                            } else {
                                abspielen()
                            }
                        } label: {
                            Image(systemName: spieltAb ? "stop.fill" : "play.fill")
                                .font(.title2)
                                .frame(width: 64, height: 64)
                                .background(.quaternary)
                                .clipShape(Circle())
                        }
                    }

                    // Aufnahme-Button
                    Button {
                        if nimmtAuf {
                            aufnahmeStoppen()
                        } else {
                            aufnahmeStarten()
                        }
                    } label: {
                        Image(systemName: nimmtAuf ? "stop.fill" : "mic.fill")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.white)
                            .background(nimmtAuf ? .red : Color.accentColor)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Sprach-Notiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") {
                        if let pfad = aufnahmePfad {
                            onSpeichern?(pfad.lastPathComponent)
                            dismiss()
                        }
                    }
                    .disabled(aufnahmePfad == nil || nimmtAuf)
                }
            }
        }
    }

    // MARK: - Aufnahme-Logik

    /// Startet die Audio-Aufnahme
    private func aufnahmeStarten() {
        // Audio-Session konfigurieren
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            fehler = "Audio-Session konnte nicht gestartet werden."
            return
        }

        // Dateipfad für die Aufnahme generieren
        let dateiname = "sprachnotiz_\(Date.now.timeIntervalSince1970).m4a"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioPfad = documentsPath.appendingPathComponent(dateiname)

        // Aufnahme-Einstellungen
        let einstellungen: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioPfad, settings: einstellungen)
            audioRecorder?.record()
            aufnahmePfad = audioPfad
            nimmtAuf = true
            aufnahmeDauer = 0
            fehler = nil

            // Timer für Dauer-Anzeige
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                aufnahmeDauer = audioRecorder?.currentTime ?? 0
            }
        } catch {
            fehler = "Aufnahme konnte nicht gestartet werden."
        }
    }

    /// Stoppt die Aufnahme
    private func aufnahmeStoppen() {
        audioRecorder?.stop()
        nimmtAuf = false
        timer?.invalidate()
        timer = nil

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Spielt die Aufnahme ab
    private func abspielen() {
        guard let pfad = aufnahmePfad else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: pfad)
            audioPlayer?.play()
            spieltAb = true
        } catch {
            fehler = "Wiedergabe fehlgeschlagen."
        }
    }

    /// Stoppt die Wiedergabe
    private func wiedergabeStoppen() {
        audioPlayer?.stop()
        spieltAb = false
    }

    /// Formatiert Sekunden in MM:SS
    private func zeitFormatiert(_ sekunden: TimeInterval) -> String {
        let min = Int(sekunden) / 60
        let sek = Int(sekunden) % 60
        return String(format: "%02d:%02d", min, sek)
    }
}

#Preview {
    SprachNotizView()
}
