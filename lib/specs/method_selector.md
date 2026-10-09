# Spec: MethodSelector
 
Framework: Jaspr (Dart), version 0.23.1
Rendering: SSR, no @client annotation
File: lib/components/method_selector.dart
 
## Purpose
Display four brewing method cards and a Gemini text input.
When a method card is tapped, navigate to /coffee/:method.
When the Gemini input is submitted, POST to /api/gemini with the text.
 
## Methods
- pour_over: label "Pour over", description "Clean, floral, bright"
- espresso:  label "Espresso",  description "Bold, intense, crema"
- cold_brew: label "Cold brew", description "Smooth, low acid"
- french_press: label "French press", description "Full body, rich"
 
## HTML structure
<section class="method-selector">
  <h1>Brew Guide</h1>
  <p class="subtitle">Select a brewing method</p>
  <div class="method-grid">
    <a class="method-card" href="/coffee/pour_over">...</a>
    <!-- repeat for each method -->
  </div>
  <div class="gemini-input">
    <input type="text" placeholder="Describe what you are looking for..." />
    <button type="submit">Ask Gemini</button>
  </div>
</section>
 
## Colors (from lib/constants/theme.dart)
Background cards: colorBackground #F5EFE4
Active border: scaWine #692729
Button text: scaCitrus #f6b36fff

## Constraints
- Use semantic HTML. No div where a section or article would be correct.
- CSS via @css static getter on the component class.
- No JavaScript inline.
- Component is StatelessComponent (no interactivity needed server-side).

## Error handling
- Input: `error` (a GeminiFailure name or 'empty') and `query` (the last free-text request), both from the URL.
- Shows an .error-banner with a friendly message per error; unknown values get a generic message.
- Refills the text input with `query`; the button reads "Try again" when retrying.
- Each method card form posts a hidden `method` field so the server can fall back to a house guide.
- The text input is `required`; the loading overlay starts on form `onsubmit` (after validation).
- The error banner and loading overlay are shared components: lib/components/error_banner.dart and
  lib/components/loading_overlay.dart (`loadingOnSubmitJs`).

## Compare link
Below the text input, `a.compare-link` ("Compare methods & bust myths") → /compare. See compare_methods.md.
