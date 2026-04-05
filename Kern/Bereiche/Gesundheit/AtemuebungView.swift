import SwiftUI

/// Geführte Atemübung mit Animation
/// 4-7-8 Atemtechnik: 4s einatmen, 7s halten, 8s ausatmen
struct AtemuebungView: View {
    @State private var phase: AtemPhase = .bereit
    @State private var ringSkala: CGFloat = 0.3
    @State private var atemZyklus = 0
    @State private var timer: Timer?
    @State private var verbleibendeZeit = 0

    /// Die verschiedenen Phasen der Atemübung
    enum AtemPhase: String {
        case bereit = "Bereit?"
        case einatmen = "Einatmen…"
        case halten = "Halten…"
        case ausatmen = "Ausatmen…"
        case fertig = "Fertig!"
    }

    /// Dauer jeder Phase in Sekunden
    private let einatmenDauer = 4
    private let haltenDauer = 7
    private let ausatmenDauer = 8
    private let gesamtZyklen = 4

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // MARK: - Atemring
            ZStack {
                // Äußerer Ring
                Circle()
                    .stroke(Color.accentColor.opacity(0.2), lineWidth: 4)
                    .frame(width: 250, height: 250)

                // Animierter Ring
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 250, height: 250)
                    .scaleEffect(ringSkala)

                // Phase-Text
                VStack(spacing: 8) {
                    Text(phase.rawValue)
                        .font(.title2.bold())

                    if phase != .bereit && phase != .fertig {
                        Text("\(verbleibendeZeit)")
                            .font(.system(size: 36, weight: .light, design: .monospaced))
                            .contentTransition(.numericText())

                        Text("Zyklus \(atemZyklus)/\(gesamtZyklen)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // MARK: - Anleitung
            if phase == .bereit {
                VStack(spacing: 8) {
                    Text("4-7-8 Atemtechnik")
                        .font(.headline)
                    Text("4 Sekunden einatmen\n7 Sekunden halten\n8 Sekunden ausatmen")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            // MARK: - Start-Button
            Button {
                if phase == .bereit || phase == .fertig {
                    starten()
                } else {
                    stoppen()
                }
            } label: {
                Text(phase == .bereit || phase == .fertig ? "Starten" : "Stoppen")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(phase == .bereit || phase == .fertig ? Color.accentColor : .red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .navigationTitle("Atemübung")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Atemübung-Logik

    private func starten() {
        atemZyklus = 1
        naechstePhase(.einatmen)
    }

    private func stoppen() {
        timer?.invalidate()
        timer = nil
        phase = .bereit
        withAnimation(.easeInOut(duration: 0.5)) {
            ringSkala = 0.3
        }
    }

    private func naechstePhase(_ neuePhase: AtemPhase) {
        phase = neuePhase
        timer?.invalidate()

        switch neuePhase {
        case .einatmen:
            verbleibendeZeit = einatmenDauer
            // Ring vergrößern
            withAnimation(.easeInOut(duration: Double(einatmenDauer))) {
                ringSkala = 1.0
            }
            starteCountdown(dauer: einatmenDauer) {
                naechstePhase(.halten)
            }

        case .halten:
            verbleibendeZeit = haltenDauer
            starteCountdown(dauer: haltenDauer) {
                naechstePhase(.ausatmen)
            }

        case .ausatmen:
            verbleibendeZeit = ausatmenDauer
            // Ring verkleinern
            withAnimation(.easeInOut(duration: Double(ausatmenDauer))) {
                ringSkala = 0.3
            }
            starteCountdown(dauer: ausatmenDauer) {
                if atemZyklus >= gesamtZyklen {
                    phase = .fertig
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                } else {
                    atemZyklus += 1
                    naechstePhase(.einatmen)
                }
            }

        default:
            break
        }
    }

    /// Startet einen Countdown-Timer
    private func starteCountdown(dauer: Int, completion: @escaping () -> Void) {
        var verbleibend = dauer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            verbleibend -= 1
            verbleibendeZeit = verbleibend
            if verbleibend <= 0 {
                t.invalidate()
                completion()
            }
        }
    }
}

#Preview {
    NavigationStack {
        AtemuebungView()
    }
}
