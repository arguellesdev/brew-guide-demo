# Spec: CoffeeDetail
 
Framework: Jaspr (Dart), version 0.23.1
Rendering: SSR
File: lib/components/coffee_detail.dart
 
## Purpose
Display a single coffee recommendation returned by the Gemini API.
 
## Input (Dart record)
record CoffeeBean {
  String name;
  String origin;
  String roast;       // light | medium | dark
  String method;      // pour_over | espresso | cold_brew | french_press
  String description; // max 40 words
  String brewTime;
  String waterTemp;
  String grind;
  List<String> flavorNotes; // 4-5 items
}
 
## HTML structure
<article class="coffee-detail">
  <div class="tags">
    <span class="tag method">Pour over</span>
    <span class="tag roast">Light roast</span>
    <span class="tag origin">Ethiopia</span>
  </div>
  <h1>{name}</h1>
  <p class="description">{description}</p>
  <div class="metrics">
    <div class="metric"><span>Grind</span><strong>{grind}</strong></div>
    <div class="metric"><span>Water</span><strong>{waterTemp}</strong></div>
    <div class="metric"><span>Time</span><strong>{brewTime}</strong></div>
  </div>
  <ul class="flavor-notes">
    <li>{note}</li> <!-- repeat -->
  </ul>
</article>
 
## Constraints
- Use <article> as root element, not <div>.
- Flavor notes use <ul> and <li>, not divs.
- CSS via @css static getter.
