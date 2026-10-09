import '../services/gemini_service.dart';

/// Typical numbers for one serving of each built-in method on /compare.
/// Real cups vary with recipe; these are mid-range values from common brew ratios.
/// Keyed by the same method ids used on the home page.
const Map<String, BrewProfile> brewProfiles = {
  'espresso': (
    name: 'Espresso',
    serving: 'Double shot, 36 mL',
    filter: 'Metal basket',
    description: 'Concentrated shot with crema, heavy body and bold intensity.',
    tds: 9.5,
    caffeineMg: 130,
    extractionYield: 19.5,
    body: 9,
    acidity: 7,
  ),
  'pour_over': (
    name: 'Pour over',
    serving: '300 mL cup',
    filter: 'Paper filter',
    description: 'Clean, bright cup; paper traps oils and fines for clarity.',
    tds: 1.35,
    caffeineMg: 165,
    extractionYield: 20.5,
    body: 3,
    acidity: 8,
  ),
  'cold_brew': (
    name: 'Cold brew',
    serving: '350 mL glass',
    filter: 'Cloth or paper',
    description: 'Steeped cold for 12-16 hours; smooth, sweet and mellow.',
    tds: 1.6,
    caffeineMg: 200,
    extractionYield: 18,
    body: 6,
    acidity: 3,
  ),
};

/// The metrics on /compare, in tab order. Each tab reveals one myth.
enum BrewMetric {
  tds('Strength (TDS %)'),
  caffeine('Caffeine (mg)'),
  extractionYield('Extraction yield (%)'),
  bodyAcidity('Body vs. acidity');

  const BrewMetric(this.label);

  final String label;
}

/// The myth each metric tab unveils.
const Map<BrewMetric, BrewMyth> metricMyths = {
  BrewMetric.tds: (
    claim: 'Pour over is weak, watery coffee.',
    truth:
        'It is more dilute (about 1.35% dissolved solids vs. 9.5% for espresso), '
        'but it pulls just as much flavor out of the beans. See the extraction yield tab: lighter, not weaker.',
  ),
  BrewMetric.caffeine: (
    claim: 'Espresso has the most caffeine.',
    truth:
        'Per sip, yes. Per serving, no: a double shot has about 130 mg, '
        'while a full cup of pour over or a glass of cold brew has more.',
  ),
  BrewMetric.extractionYield: (
    claim: 'Stronger coffee means more gets extracted from the beans.',
    truth:
        'Strength is how concentrated the cup is. Extraction is how much of the grounds dissolved. '
        'All three methods land near 18-22% extraction, despite very different strengths.',
  ),
  BrewMetric.bodyAcidity: (
    claim: 'Cold brew has no acid.',
    truth:
        'Cold water pulls out fewer of the bright-tasting acids, so it tastes much less acidic. '
        'But its pH is close to hot coffee: smoother, not acid-free.',
  ),
};
