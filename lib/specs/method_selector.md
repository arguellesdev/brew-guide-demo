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
Active border: scaHerb #30622D
Button text: scaCitrus #FEC844
 
## Constraints
- Use semantic HTML. No div where a section or article would be correct.
- CSS via @css static getter on the component class.
- No JavaScript inline.
- Component is StatelessComponent (no interactivity needed server-side).
