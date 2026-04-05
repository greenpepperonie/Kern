import SwiftUI
import PencilKit

/// Zeichnen-View mit PencilKit
/// Unterstützt Finger und Apple Pencil
struct ZeichenView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var canvasView = PKCanvasView()
    @State private var zeichnung = PKDrawing()

    /// Callback wenn die Zeichnung gesichert wird — gibt die PNG-Daten zurück
    var onSpeichern: ((Data) -> Void)?

    var body: some View {
        NavigationStack {
            ZeichenCanvasRepresentable(canvasView: $canvasView, zeichnung: $zeichnung)
                .navigationTitle("Zeichnen")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") { dismiss() }
                    }

                    ToolbarItem(placement: .principal) {
                        // Zeichnung leeren
                        Button {
                            zeichnung = PKDrawing()
                            canvasView.drawing = PKDrawing()
                        } label: {
                            Image(systemName: "trash")
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Sichern") {
                            // Zeichnung als PNG exportieren
                            let bild = zeichnung.image(from: zeichnung.bounds, scale: 2.0)
                            if let daten = bild.pngData() {
                                onSpeichern?(daten)
                            }
                            dismiss()
                        }
                    }
                }
        }
    }
}

/// UIViewRepresentable-Wrapper für PKCanvasView
/// Notwendig weil PencilKit kein natives SwiftUI-View hat
struct ZeichenCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var zeichnung: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput  // Finger + Pencil erlauben
        canvasView.tool = PKInkingTool(.pen, color: .label, width: 3)
        canvasView.backgroundColor = .systemBackground
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(zeichnung: $zeichnung)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var zeichnung: PKDrawing

        init(zeichnung: Binding<PKDrawing>) {
            _zeichnung = zeichnung
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            zeichnung = canvasView.drawing
        }
    }
}

#Preview {
    ZeichenView()
}
