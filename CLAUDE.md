# Kern — iOS App · CLAUDE.md

This file is the single source of truth for the Kern project.
Read it fully at the start of every session before writing any code.

---

## Project Overview

**App name:** Kern  
**Platform:** iOS 17+, iPhone only (kein iPad-Support)  
**Language:** Swift 5.9 / SwiftUI  
**Data:** SwiftData (local only — no cloud, no backend, no login)  
**UI language:** German throughout  
**Target device:** iPhone 13 (390x844pt, personal use, not for App Store)  
**Orientation:** Portrait only  
**Simulator:** iPhone 17 (nächstliegendes Display 393x852pt, iOS 26.4)  
**Developer:** Beginner — prefer clear, well-commented code over clever abstractions

---

## Core Principles

1. **Offline-first, always.** No network requests except MeteoBlue weather API and future AI features.
2. **No account, no login.** The app opens directly to content.
3. **Privacy by default.** All user data stays on device. Export function gives full control.
4. **German UI.** All labels, buttons, alerts, placeholders, and error messages in German.
5. **Simple beats clever.** When in doubt, choose the more readable implementation.
6. **Comment everything non-obvious.** The developer is learning Swift — add explanatory comments.

---

## Architecture

```
Kern/
├── KernApp.swift                  # App entry point
├── ContentView.swift              # Root tab navigation
├── CLAUDE.md                      # This file
│
├── Models/                        # SwiftData models
│   ├── Aufgabe.swift
│   ├── Notiz.swift
│   ├── Flashcard.swift
│   ├── Lernset.swift
│   ├── GesundheitsEintrag.swift
│   └── Kontakt.swift
│
├── Bereiche/                      # One folder per app section
│   ├── Aufgaben/
│   ├── Notizen/
│   ├── Lernen/
│   ├── Gesundheit/
│   └── Kontext/
│
├── Shared/                        # Reusable components
│   ├── Components/
│   ├── Extensions/
│   └── Utilities/
│
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings        # German strings (if needed)
```

**Pattern:** MVVM (Model–View–ViewModel). Keep Views thin. Logic goes in ViewModels.  
**Navigation:** TabView with 5 tabs (one per Bereich). Use NavigationStack inside each tab.  
**Storage:** SwiftData for structured data. FileManager for images (Inspiration Board). UserDefaults for settings only.

---

## Tab Structure

| Tab | Icon (SF Symbol) | German Label |
|-----|-----------------|--------------|
| 1 | `checkmark.circle` | Aufgaben |
| 2 | `note.text` | Notizen |
| 3 | `brain.head.profile` | Lernen |
| 4 | `heart.text.square` | Gesundheit |
| 5 | `location.circle` | Kontext |

---

## Feature List

Features marked **(Zukunft)** are planned but not built yet. Do not scaffold them — only build when explicitly requested.

### Bereich 1 — Aufgaben & Fokus
- [x] Aufgaben-CRUD (Erstellen, Bearbeiten, Löschen, Erledigen mit Swipe-Aktionen)
- [x] Timer, Stoppuhr, Wecker (3-in-1 mit Segmented-Picker)
- [x] Wiederkehrende Aufgaben (täglich/wöchentlich/monatlich im Formular)
- [x] Einkaufsliste (9 Kategorien, smarte Gruppierung, schnelles Hinzufügen)
- [x] Eisenhower-Matrix (4-Quadranten Ansicht für Aufgaben)
- [x] Wochenreview (Statistiken, Trend, Kategorien-Aufschlüsselung)
- [x] Fokus-Modus (eine Aufgabe im Fokus, Erledigen/Überspringen)
- [ ] **BUG:** Einkaufslisteneinträge erscheinen als offene Aufgaben → müssen separiert werden
- [ ] Mehrere Einkaufslisten (z.B. Rewe, Aldi, DM) mit eigenem Model
- [ ] KI-Kategoriezuordnung für Einkaufsitems (Item+Kategorie merken für Zukunft)
- [ ] **(Zukunft)** KI-Priorisierung

### Bereich 2 — Notizen & Kreativität
- [x] Schnell-Notizen (ein Tipp, sofort schreiben)
- [x] Ideen-Capture (Kategorie-Filter: Schnell, Idee, Brain Dump)
- [x] Brain Dump (als Kategorie in Notizen — freies Schreiben)
- [x] Sprach-Notizen (Aufnahme + Wiedergabe mit AVFoundation)
- [x] Markdown-Unterstützung (Editor + Vorschau Toggle)
- [x] Zeichnen / Skizzen (PencilKit, Finger + Apple Pencil)
- [x] Verschlüsselte Notizen (PIN mit SHA256-Hash, CryptoKit)
- [ ] **(Zukunft)** Inspiration-Board mit Bildern

### Bereich 3 — Lernen
- [x] Flashcards mit Spaced Repetition (SM-2 Algorithmus)
- [x] Eigene Quiz-Fragen / Lernkarten erstellen
- [x] Lernstreaks & Gamification (Streak, Statistiken, Motivation)
- [ ] KI-Lernassistent: Thema wählen + Schwierigkeitsgrad (Kind/Schüler/Student/…) → KI generiert Flashcards

### Bereich 4 — Gesundheit & Wohlbefinden
- [x] Schlaf-Tracker (Slider 0–14h, 7-Tage-Durchschnitt)
- [x] Atemübungen (4-7-8 Technik mit Ring-Animation, 4 Zyklen)
- [x] Energie-Level tracken (täglicher Eintrag 1–5 mit Farbskala)
- [x] Symptom-Tagebuch (vordefinierte + eigene Symptome)
- [ ] Habit Tracking (eigene Kategorien erstellen, tägliches Abhaken, Verlaufs-Charts)
- [ ] **(Zukunft)** HealthKit-Integration

### Bereich 5 — Kontext & Erinnerungen
- [ ] Standort-basierte Erinnerungen (CoreLocation) — **(Zukunft)**
- [x] Geburtstags-Erinnerungen (30-Tage-Vorschau, "Heute/Morgen/In X Tagen")
- [x] Letzter Kontakt tracken (Swipe zum Markieren, überfällige Kontakte)
- [ ] Kalender (nur lesen, EventKit) — **(Zukunft)**
- [x] Sonnenauf- und -untergang anzeigen (astronomische Berechnung)
- [ ] **(Zukunft)** Siri-Shortcuts

### Allgemein
- [x] Export-Funktion aller Nutzerdaten (JSON + Share-Sheet)
- [x] Einstellungen-View (erreichbar via Zahnrad im Aufgaben-Tab)

---

## Data Models (Starter Definitions)

```swift
// Aufgabe
@Model class Aufgabe {
    var titel: String
    var erledigt: Bool
    var faelligkeitsdatum: Date?
    var kategorie: String          // z.B. "Einkauf", "Arbeit"
    var istWiederkehrend: Bool
    var wiederholungsintervall: String?  // "täglich", "wöchentlich"
    var wichtig: Bool              // für Eisenhower
    var dringend: Bool             // für Eisenhower
    var erstelltAm: Date
}

// Notiz
@Model class Notiz {
    var titel: String
    var inhalt: String             // Markdown-Text
    var kategorie: String          // "Schnell", "Idee", "Brain Dump"
    var istVerschluesselt: Bool
    var hatAufnahme: Bool          // Sprach-Notiz
    var aufnahmePfad: String?
    var erstelltAm: Date
    var geaendertAm: Date
}

// Flashcard
@Model class Flashcard {
    var frage: String
    var antwort: String
    var deck: String
    var naechsteWiederholung: Date
    var intervall: Int             // SM-2: Tage bis zur nächsten Wiederholung
    var wiederholungen: Int
    var easeFactor: Double         // SM-2: Schwierigkeitsfaktor
}

// GesundheitsEintrag
@Model class GesundheitsEintrag {
    var datum: Date
    var schlafStunden: Double?
    var energieLevel: Int?         // 1–5
    var symptome: [String]
    var notiz: String?
}

// Kontakt
@Model class Kontakt {
    var name: String
    var geburtstag: Date?
    var letzterKontakt: Date?
    var notiz: String?
    var erinnerungsintervallTage: Int?
}
```

---

## Design Guidelines

- **Framework:** SwiftUI natively — no UIKit unless unavoidable
- **Color scheme:** System colors (`Color.primary`, `.secondary`, `.accentColor`) — supports automatic Dark Mode
- **Accent color:** Define once in Assets.xcassets as "AccentColor" — use a calm teal/green
- **Typography:** SF Pro (system default) — use `.headline`, `.body`, `.caption` semantic styles
- **Spacing:** Use 8pt grid (8, 16, 24, 32)
- **Corner radius:** 12pt for cards, 8pt for smaller elements
- **Minimum tap target:** 44x44pt (Apple HIG requirement)
- **Haptic feedback:** Use for completions, deletions, and confirmations

---

## Development Phases

Build in this order. Complete and test each phase before moving on.

### Phase 0 — Projekt-Setup ✅
1. ~~Xcode-Projekt anlegen (SwiftUI, SwiftData)~~
2. ~~Ordnerstruktur gemäß Architektur erstellen~~
3. ~~TabView mit 5 leeren Tabs aufbauen~~
4. ~~SwiftData Container konfigurieren~~
5. ~~App-Icon Platzhalter setzen~~

### Phase 1 — Aufgaben & Fokus ✅
~~Timer → Wiederkehrende Aufgaben → Einkaufsliste → Eisenhower-Matrix → Fokus-Modus → Wochenreview~~

### Phase 2 — Notizen & Kreativität ✅
~~Schnell-Notizen → Kategorien → Markdown → Sprach-Notizen → Zeichnen → Verschlüsselung~~

### Phase 3 — Lernen ✅
~~Flashcard-Deck → SM-2-Algorithmus → Quiz → Streaks~~

### Phase 4 — Gesundheit ✅
~~Schlaf → Energie → Atemübungen → Symptom-Tagebuch~~

### Phase 5 — Kontext & Erinnerungen ✅
~~Geburtstage → Letzter Kontakt → Sonnenzeiten~~ (Kalender/Standort → Zukunft)

### Phase 6 — Polish & Export ✅ (Basis)
~~Export-Funktion~~ → Einstellungen-View (Widgets, App-Icon, Onboarding → Zukunft)

---

## API: MeteoBlue Wetter

- Endpoint: `https://my.meteoblue.com/packages/basic-1h`
- Auth: API-Key als Umgebungsvariable `METEOBLUE_API_KEY` (niemals im Code hardcoden)
- Koordinaten: werden beim ersten Start via CoreLocation ermittelt und gecacht
- Daten werden maximal 1x pro Stunde abgerufen und lokal gecacht

---

## Coding Conventions

```swift
// Dateinamen: PascalCase, nach Feature benannt
// z.B. AufgabenListeView.swift, FlashcardViewModel.swift

// Variablen/Funktionen: camelCase, auf Deutsch wenn sinnvoll
var aufgabenListe: [Aufgabe] = []
func aufgabeHinzufuegen(_ titel: String) { }

// Konstanten: camelCase
let maxEnergieLevelWert = 5

// MARK: Kommentare zur Strukturierung nutzen
// MARK: - View Body
// MARK: - Helper Functions

// Jede nicht-triviale Funktion bekommt einen Kommentar
// der erklärt WAS sie tut, nicht WIE
```

---

## Wichtige iOS-Frameworks

| Framework | Verwendung |
|-----------|-----------|
| SwiftUI | Alle Views |
| SwiftData | Lokale Datenpersistenz |
| AVFoundation | Sprach-Notizen (Aufnahme & Wiedergabe) |
| CoreLocation | Standort-Erinnerungen |
| EventKit | Kalender (nur lesen) |
| UserNotifications | Alle Benachrichtigungen |
| PencilKit | Zeichnen / Skizzen |
| CryptoKit | Verschlüsselte Notizen |
| URLSession | MeteoBlue API |

---

## Was Claude Code NICHT tun soll

- Keine externen Swift Package Manager Dependencies hinzufügen ohne explizite Anfrage
- Keine UIKit-Views verwenden wenn SwiftUI ausreicht
- Keine Netzwerkanfragen außer MeteoBlue (und später explizit genehmigte AI-APIs)
- Keine Daten auf externe Server senden
- Keine `// TODO:` ohne Erklärung hinterlassen
- Keine Zukunfts-Features (markiert mit "Zukunft") bauen ohne explizite Anweisung

---

## Session-Start Checkliste

Am Anfang jeder Claude Code Session:
1. Diese Datei lesen
2. Aktuellen Build-Status prüfen (welche Features sind fertig?)
3. Nur an dem arbeiten, was explizit angefragt wird
4. Nach jeder größeren Änderung: kurz zusammenfassen was geändert wurde

---

*Letzte Aktualisierung: 2026-04-05 — V1 fertig, Nutzerfeedback eingearbeitet*  
*Nächster Schritt: Einkaufsliste-Bug fixen, Habit Tracking, KI-Integration (Lernen + Einkauf)*
