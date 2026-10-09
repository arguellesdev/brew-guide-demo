# Spec: Compare (methods & myths)

Framework: Jaspr (Dart), version 0.23
Rendering: SSR, no @client. Interactivity is HTML + CSS only.
File: lib/pages/compare.dart (class `Compare`), data in lib/data/brew_profiles.dart
Route: GET /compare, form POST /api/compare (lib/handlers/gemini_handler.dart)

## Purpose
Compare espresso, pour over and cold brew, plus one method the user types in (estimated by
Gemini), across four metrics. Each metric tab unveils one common coffee myth.

## Entry point
Home page "Compare methods & bust myths" link (`a.compare-link` in method_selector.dart).

## Data
- `BrewProfile` (gemini_service.dart): name, serving, filter, description, tds (%), caffeineMg,
  extractionYield (%), body (1-10), acidity (1-10).
- `brewProfiles`: fixed values for espresso, pour_over, cold_brew (typical single serving).
- `BrewMetric`: tds, caffeine, extractionYield, bodyAcidity (tab order). Each value carries its own `BrewMyth` (`metric.myth`), so no metric can lack one.
- The user's method is rebuilt from query params by `comparisonFromQuery` (no server state):
  name, serving, filter, description, tds, caffeine, yield, body, acidity, myth, truth.
  Missing or unparseable numbers → treated as no custom method. Numbers are clamped.

## HTML structure
<section class="compare-page"><div class="compare-content">
  h1, p.subtitle, [ErrorBanner]
  div.compare-panel
    fieldset.tabs.metric-tabs   → label.tab > input[type=radio][name=metric]#metric-<metric>
    div.metric-view[data-metric] (one per metric)
      figure.chart > ol.bar-groups > li.bar-group[data-method] > label[for=pick-<id>] (bars, name, AI tag)
                   (+ li.placeholder > label[for=custom-method] when no custom method)
                   ul.legend (body vs. acidity only), figcaption
      details.myth > summary (Myth label, claim, "Unveil") + p (truth)
    fieldset.tabs.method-picks  → label.tab > input[type=radio][name=pick]#pick-<id>
    article.method-card[data-method] (one per column): h3, p.meta, dl stats, description, [details.myth from Gemini]
  form.compare-input POST /api/compare (onsubmit = loadingOnSubmitJs)
    label[for=custom-method], input#custom-method[name=method][required][maxlength=40], button
  LoadingOverlay("Measuring your method...")

## Interaction (no JS)
- `.compare-panel:has(#metric-X:checked)` shows the matching `.metric-view`.
- `.compare-panel:has(#pick-X:checked)` shows the matching `.method-card` and highlights its bars.
- Clicking a bar selects that method (bars are labels for the pick radios).
- Bars replay a grow animation each time their chart becomes visible; disabled for prefers-reduced-motion.
- Values are printed above bars (no hover-only tooltip, so touch and screen readers get them).

## States
- Idle/empty: three built-in columns plus a dashed "Your method" slot that focuses the input.
- Loading: shared full-screen overlay with rotating facts.
- Success: fourth column tagged "AI estimate", selected by default; its card shows Gemini's myth.
- Error: ErrorBanner + input refilled with `q`, button reads "Try again".
  Keys: busy, timeout, badResponse, unavailable, notABrewMethod, empty.

## Server: POST /api/compare
- Trims, collapses whitespace, caps input at 40 chars before sending to Gemini.
- Clips each Gemini text field (name 40, serving 40, filter 40, description 160, myth 160, truth 300) at a word boundary before the redirect, keeping the URL short. Clips, never rejects: rejecting would trigger a paid retry.
- `compareMethod` (gemini_service.dart) → 302 /compare?<profile params>.
- Failure → 302 /compare?error=<GeminiFailure.name>&q=<text>.
