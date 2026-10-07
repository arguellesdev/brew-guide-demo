import '../services/gemini_service.dart';

/// Hand-written recipes shown when Gemini can't answer for a preset method.
/// Keyed by the same method ids Gemini returns.
const Map<String, CoffeeBean> houseGuides = {
  'pour_over': (
    name: 'Ethiopian Yirgacheffe',
    origin: 'Ethiopia',
    roast: 'light',
    method: 'pour_over',
    description: 'Bright, floral cup with a clean tea-like finish.',
    brewTime: '3-4 min',
    waterTemp: '94°C',
    grind: 'Medium',
    flavorNotes: ['Jasmine', 'Bergamot', 'Lemon', 'Honey'],
  ),
  'espresso': (
    name: 'Classic Brazilian Espresso',
    origin: 'Brazil',
    roast: 'dark',
    method: 'espresso',
    description: 'Bold, syrupy shot with a thick hazelnut crema.',
    brewTime: '25-30 sec',
    waterTemp: '93°C',
    grind: 'Fine',
    flavorNotes: ['Dark chocolate', 'Hazelnut', 'Caramel', 'Toasted almond'],
  ),
  'cold_brew': (
    name: 'Colombian Cold Brew',
    origin: 'Colombia',
    roast: 'medium',
    method: 'cold_brew',
    description: 'Smooth, low-acid concentrate that shines over ice.',
    brewTime: '12-16 hrs',
    waterTemp: '20°C',
    grind: 'Coarse',
    flavorNotes: ['Milk chocolate', 'Brown sugar', 'Cocoa', 'Cherry'],
  ),
  'french_press': (
    name: 'Sumatra Full Body',
    origin: 'Sumatra',
    roast: 'dark',
    method: 'french_press',
    description: 'Earthy, heavy-bodied cup with a long, rich finish.',
    brewTime: '4 min',
    waterTemp: '95°C',
    grind: 'Coarse',
    flavorNotes: ['Cedar', 'Dark cocoa', 'Molasses', 'Spice'],
  ),
};
