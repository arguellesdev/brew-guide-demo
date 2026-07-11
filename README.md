# Brew Guide

Specialty coffee recommendations powered by Gemini, built with Jaspr and Dart.

Demonstrated at Flutter Conf Orlando, July 16, 2026 — *"Building Modern Web Apps with Jaspr, Gemini and Antigravity"*

---

## Quick start

**Requirements:** Flutter 3.44.1+, Dart 3.12.1+, a [Gemini API key](https://aistudio.google.com) with billing enabled on the associated GCP project.

```bash
git clone https://github.com/aiarguelles/brew-guide.git
cd brew-guide
dart pub get
```

Create `start.sh` in the project root:

```bash
#!/bin/bash
export GEMINI_API_KEY="your_key_here"
jaspr serve
```

```bash
chmod +x start.sh
./start.sh
# → http://localhost:8080
```

> Always use `./start.sh`, not `jaspr serve`. The API key is not persisted between terminal sessions.

---

## How it works

The user selects a brewing method or types a preference. The Dart server sends that input to Gemini and redirects to a detail page rendered with real, semantic HTML — no canvas, no JavaScript required for the initial render.

```
Browser → POST /api/gemini → Dart server → Gemini API
                                    ↓
Browser ← SSR HTML page ← 302 /coffee?name=...
```

---

## Stack

- [Jaspr](https://jaspr.site) 0.23.1 — Dart SSR web framework
- [Gemini API](https://aistudio.google.com) (gemini-3.5-flash) — AI recommendations
- [Antigravity CLI](https://antigravity.google) (agy 1.0.5) — Spec-Driven Development

---

## Project structure

```
lib/
├── components/method_selector.dart   # Home page — four cards + Gemini input
├── constants/theme.dart              # SCA flavor wheel color palette
├── handlers/gemini_handler.dart      # POST /api/gemini
├── pages/coffee.dart                 # Coffee detail page
├── services/gemini_service.dart      # Gemini API client
└── specs/                            # SDD specification files
```
---

## Project structure detailed

```
flutter-conf-jaspr-demo/
├── lib/
│   ├── app.dart                    # Router — two routes: / and /coffee
│   ├── main.server.dart            # Server entry point, Gemini middleware
│   ├── main.client.dart            # Browser entry point (compiled to JS)
│   ├── main.server.options.dart    # Auto-generated — do not edit
│   ├── main.client.options.dart    # Auto-generated — do not edit
│   ├── components/
│   │   ├── header.dart             # Brew Guide wordmark, links to /
│   │   └── method_selector.dart    # Four cards + Gemini input + loading overlay
│   ├── constants/
│   │   └── theme.dart              # SCA color palette + global typography
│   ├── handlers/
│   │   └── gemini_handler.dart     # POST /api/gemini — calls Gemini, redirects
│   ├── pages/
│   │   ├── home.dart               # Home page wrapper (@client)
│   │   └── coffee.dart             # Coffee detail page (@client)
│   ├── services/
│   │   └── gemini_service.dart     # Gemini API client, returns CoffeeBean record
│   └── specs/
│       ├── method_selector.md      # SDD spec for MethodSelector component
│       ├── coffee_detail.md        # SDD spec for Coffee detail page
│       └── gemini_service.md       # SDD spec for GeminiService (shown on stage)
├── web/
│   └── favicon.ico
├── .env                            # GEMINI_API_KEY — gitignored, create manually
├── .gitignore
├── pubspec.yaml                    # jaspr: mode: server (critical — not static)
├── start.sh                        # Exports API key, then runs jaspr serve — gitignored
└── README.md
```

---

## Configuration

| File | Required | Purpose |
|---|---|---|
| `start.sh` | Yes | Exports `GEMINI_API_KEY` and starts the server |
| `.env` | Optional | Documents the key locally — not read automatically |

Both files are in `.gitignore`. Do not commit them.

`pubspec.yaml` must have `jaspr: mode: server`. The CLI scaffolds `mode: static` by default — this project will not work without that change.

---

## Gemini API key

Get a key at [aistudio.google.com](https://aistudio.google.com). The GCP project associated with the key must have billing enabled — the free tier quota is zero without it.

Verify the key before running the project:

```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent" \
  -H "X-goog-api-key: YOUR_KEY" \
  -H "Content-Type: application/json" \
  -X POST -d '{"contents":[{"parts":[{"text":"hello"}]}]}'
# 200 → key works   403 → invalid key or no billing   429 → quota exhausted
```

---

## Notes

- Jaspr 0.23.1 is pre-1.0. The API can change between minor releases.
- `@css` styles are globally scoped. All class names in this project are prefixed with the component name to avoid collisions.
- Gemini responses are non-deterministic. If you see `FormatException: Unexpected end of input`, the response was truncated — retry the request.

---

## Repository

**GitHub:** [github.com/aiarguelles/brew-guide](https://github.com/aiarguelles/brew-guide)

**Talk:** "Building Modern Web Apps with Jaspr, Gemini and Antigravity"
Flutter Conf Orlando — July 16, 2026
