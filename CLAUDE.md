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

1. **Offline-first, always.** No network requests except Claude API (KI-Features) and MeteoBlue weather API.
2. **No account, no login.** The app opens directly to content.
3. **Privacy by default.** All user data stays on device. Export function gives full control.
4. **German UI.** All labels, buttons, alerts, placeholders, and error messages in German.
5. **Simple beats clever.** When in doubt, choose the more readable implementation.
6. **Comment everything non-obvious.** The developer is learning Swift — add explanatory comments.

---

## Architecture

```
Kern/
├── KernApp.swift                  # App entry point + SwiftData Container
├── ContentView.swift              # Root tab navigation (5 Tabs)
├── CLAUDE.md                      # This file
│
├── Models/                        # SwiftData models (8 Models)
│   ├── Aufgabe.swift
│   ├── Notiz.swift
│   ├── Flashcard.swift
│   ├── Lernset.swift
│   ├── GesundheitsEintrag.swift
│   ├── Kontakt.swift
│   ├── EinkaufsArtikel.swift      # + KategorieMapping (KI-Cache)
│   └── Habit.swift                # + HabitEintrag
│
├── Bereiche/
│   ├── Aufgaben/                  # 9 Dateien: CRUD, Timer, Einkaufslisten, Eisenhower, Fokus, Review
│   ├── Notizen/                   # 7 Dateien: Editor, Detail, Sprach, Zeichnen, Verschlüsselung
│   ├── Lernen/                    # 6 Dateien: SM-2, Flashcards, Lernsets, Streaks, KI-Assistent
│   ├── Gesundheit/                # 4 Dateien: Einträge, Atemübung, Habit Tracking
│   └── Kontext/                   # 3 Dateien: Kontakte, Sonnenzeiten
│
├── Shared/
│   ├── Components/
│   ├── Extensions/
│   └── Utilities/                 # DatenExport, Einstellungen, ClaudeAPIService
│
└── Resources/
    └── Assets.xcassets            # AccentColor (Teal), AppIcon Platzhalter
```

**Pattern:** MVVM (Model–View–ViewModel). Keep Views thin. Logic goes in ViewModels.  
**Navigation:** TabView with 5 tabs (one per Bereich). Use NavigationStack inside each tab.  
**Storage:** SwiftData for structured data. FileManager for images/audio. UserDefaults for settings + API-Key.

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
- [x] ~~BUG:~~ Einkaufslisteneinträge aus Aufgabenliste gefiltert
- [x] Mehrere Einkaufslisten (z.B. Rewe, Aldi) mit eigenem EinkaufsArtikel-Model
- [x] KI-Kategoriezuordnung (Regelwerk + KategorieMapping-Cache, Claude API vorbereitet)
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
- [x] KI-Lernassistent: Thema + Schwierigkeitsgrad → Claude API generiert Flashcards

### Bereich 4 — Gesundheit & Wohlbefinden
- [x] Schlaf-Tracker (Slider 0–14h, 7-Tage-Durchschnitt)
- [x] Atemübungen (4-7-8 Technik mit Ring-Animation, 4 Zyklen)
- [x] Energie-Level tracken (täglicher Eintrag 1–5 mit Farbskala)
- [x] Symptom-Tagebuch (vordefinierte + eigene Symptome)
- [x] Habit Tracking (eigene Habits, Streaks, GitHub-Style Grid + Verlaufs-Charts)
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

## Data Models (aktuelle Definitionen — 8 Models + 2 Hilfsmodels)

Alle Models sind in `Kern/Models/` definiert. Details siehe jeweilige Datei.

| Model | Datei | Zweck |
|-------|-------|-------|
| `Aufgabe` | Aufgabe.swift | Aufgaben mit Eisenhower, Wiederholung |
| `Notiz` | Notiz.swift | Notizen mit Markdown, Verschlüsselung, Sprache |
| `Flashcard` | Flashcard.swift | Lernkarten mit SM-2 Parametern |
| `Lernset` | Lernset.swift | Gruppierung von Flashcards |
| `GesundheitsEintrag` | GesundheitsEintrag.swift | Schlaf, Energie, Symptome |
| `Kontakt` | Kontakt.swift | Kontakte mit Geburtstag, Erinnerungsintervall |
| `EinkaufsArtikel` | EinkaufsArtikel.swift | Eigenes Model für Einkaufslisten (getrennt von Aufgaben) |
| `KategorieMapping` | EinkaufsArtikel.swift | Cache für KI-Kategoriezuordnungen |
| `Habit` | Habit.swift | Benutzerdefinierte Gewohnheiten |
| `HabitEintrag` | Habit.swift | Tägliche Habit-Erledigungen |

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

## API: Claude (Anthropic) — KI-Features

- Implementierung: `ClaudeAPIService.swift` (Singleton, direkter REST-Call via URLSession)
- Model: `claude-sonnet-4-20250514`
- Auth: API-Key in UserDefaults (`anthropic_api_key`), eingegeben über Einstellungen-View
- Endpunkt: `https://api.anthropic.com/v1/messages`
- Verwendung:
  1. **Einkaufsliste:** Kategoriezuordnung (aktuell regelbasiert, KI-Call vorbereitet)
  2. **Lernen:** `flashcardsGenerieren()` — Thema + Schwierigkeitsgrad → JSON-Array mit Frage/Antwort
- Caching: `KategorieMapping`-Model speichert einmal zugewiesene Kategorien lokal

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

| Framework | Verwendung | Status |
|-----------|-----------|--------|
| SwiftUI | Alle Views | ✅ aktiv |
| SwiftData | Lokale Datenpersistenz (10 Models) | ✅ aktiv |
| AVFoundation | Sprach-Notizen (Aufnahme & Wiedergabe) | ✅ aktiv |
| PencilKit | Zeichnen / Skizzen | ✅ aktiv |
| CryptoKit | Verschlüsselte Notizen (SHA256) | ✅ aktiv |
| URLSession | Claude API + MeteoBlue | ✅ aktiv |
| CoreLocation | Standort-Erinnerungen | Zukunft |
| EventKit | Kalender (nur lesen) | Zukunft |
| UserNotifications | Benachrichtigungen | Zukunft |

---

## Was Claude Code NICHT tun soll

- Keine externen Swift Package Manager Dependencies hinzufügen ohne explizite Anfrage
- Keine UIKit-Views verwenden wenn SwiftUI ausreicht
- Keine Netzwerkanfragen außer Claude API (Anthropic) und MeteoBlue
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

*Letzte Aktualisierung: 2026-04-05 — V2 fertig, Feedback umgesetzt, KI-Integration aktiv*  
*Nächster Schritt: Testen auf iPhone 13, Feinschliff*
