import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/error_banner.dart';
import '../components/loading_overlay.dart';
import '../constants/theme.dart';
import '../data/brew_profiles.dart';
import '../services/compare_signature.dart';
import '../services/gemini_service.dart';

/// Messages for each failure /api/compare can send back (see GeminiFailure).
const _errorMessages = {
  'busy': 'Gemini is busy brewing for others. Give it a moment and try again.',
  'timeout': 'That took longer than expected. Please try again.',
  'badResponse': 'Gemini\'s numbers came out a bit garbled. Please try again.',
  'unavailable': 'Our AI barista is offline right now. The three built-in methods above still work.',
  'notABrewMethod': 'That doesn\'t look like a brewing method. Try something like AeroPress or Moka pot.',
  'empty': 'Type a brewing method to compare, like AeroPress.',
};

/// Column id for the user's method. The built-in ids come from [brewProfiles].
const _customId = 'custom';

/// Every column id the page might render, for the `:has()` selection rules.
const _allIds = ['espresso', 'pour_over', 'cold_brew', _customId];

/// Rebuilds the user's comparison from /compare query params.
/// Returns null (the empty state) when params are missing, a hand-edited URL doesn't parse, or the
/// signature from /api/compare doesn't match, so text typed into a URL never shows as an "AI estimate".
MethodComparison? comparisonFromQuery(Map<String, String> q) {
  if (!verifyCompareParams(q)) return null;
  final name = (q['name'] ?? '').trim();
  final tds = double.tryParse(q['tds'] ?? '');
  final caffeine = int.tryParse(q['caffeine'] ?? '');
  final extractionYield = double.tryParse(q['yield'] ?? '');
  final body = int.tryParse(q['body'] ?? '');
  final acidity = int.tryParse(q['acidity'] ?? '');
  if (name.isEmpty || tds == null || caffeine == null || extractionYield == null || body == null || acidity == null) {
    return null;
  }
  return (
    profile: (
      name: name,
      serving: q['serving'] ?? '',
      filter: q['filter'] ?? '',
      description: q['description'] ?? '',
      tds: tds.clamp(0.1, 20.0),
      caffeineMg: caffeine.clamp(0, 600),
      extractionYield: extractionYield.clamp(1.0, 35.0),
      body: body.clamp(1, 10),
      acidity: acidity.clamp(1, 10),
    ),
    myth: (claim: q['myth'] ?? '', truth: q['truth'] ?? ''),
  );
}

/// Bar chart of espresso, pour over, cold brew and one AI-estimated method, with a myth per metric.
///
/// Fully server-rendered: metric tabs and method picks are radio inputs, and CSS `:has(:checked)`
/// shows the matching chart and card. No JavaScript beyond the shared loading overlay.
class Compare extends StatelessComponent {
  /// The user's method from Gemini, or null before they've added one.
  final MethodComparison? custom;

  /// A [GeminiFailure] name (or 'empty') when the last request failed.
  final String? error;

  /// The user's last method text, refilled so retrying is one click.
  final String query;

  const Compare({super.key, this.custom, this.error, this.query = ''});

  @override
  Component build(BuildContext context) {
    final columns = [
      for (final entry in brewProfiles.entries) (id: entry.key, profile: entry.value, isEstimate: false, myth: null),
      if (custom case final c?) (id: _customId, profile: c.profile, isEstimate: true, myth: c.myth),
    ];
    final selectedId = custom != null ? _customId : columns.first.id;
    final errorMessage = error == null ? null : _errorMessages[error] ?? 'Something went wrong. Please try again.';
    final canRetry = error != null && query.isNotEmpty;

    return section(classes: 'compare-page', [
      h1([Component.text('Compare brewing methods')]),
      p(classes: 'subtitle', [Component.text('Four numbers behind the most common coffee myths')]),
      if (errorMessage != null) ErrorBanner(message: errorMessage),
      div(classes: 'compare-panel', [
        fieldset(classes: 'tabs metric-tabs', [
          legend(classes: 'visually-hidden', [Component.text('Metric')]),
          for (final metric in BrewMetric.values)
            label(classes: 'tab', [
              input(
                type: InputType.radio,
                name: 'metric',
                id: 'metric-${metric.name}',
                checked: metric == BrewMetric.values.first,
              ),
              span([Component.text(metric.label)]),
            ]),
        ]),
        for (final metric in BrewMetric.values)
          div(
            classes: 'metric-view',
            attributes: {'data-metric': metric.name},
            [
              _chart(metric, columns),
              _myth(metric.myth),
            ],
          ),
        fieldset(classes: 'tabs method-picks', [
          legend([Component.text('Details for')]),
          for (final c in columns)
            label(classes: 'tab', [
              input(type: InputType.radio, name: 'pick', id: 'pick-${c.id}', checked: c.id == selectedId),
              span([Component.text(c.profile.name)]),
            ]),
        ]),
        for (final c in columns) _card(c.id, c.profile, c.myth),
      ]),
      form(
        classes: 'compare-input',
        method: FormMethod.post,
        action: '/api/compare',
        attributes: {'onsubmit': loadingOnSubmitJs},
        [
          label(htmlFor: 'custom-method', [
            Component.text(custom == null ? 'Add your own method' : 'Compare a different method'),
          ]),
          div(classes: 'input-row', [
            input(
              type: InputType.text,
              name: 'method',
              id: 'custom-method',
              value: query,
              attributes: {
                'placeholder': 'e.g. AeroPress, Moka pot, Turkish coffee',
                'maxlength': '40',
                // The browser blocks empty submits before they reach the server.
                'required': '',
              },
            ),
            button(type: ButtonType.submit, [Component.text(canRetry ? 'Try again' : 'Compare with AI')]),
          ]),
          if (custom == null)
            p(classes: 'hint', [
              Component.text('Gemini estimates its numbers and unveils one myth about it.'),
            ]),
        ],
      ),
      const LoadingOverlay(message: 'Measuring your method...'),
    ]);
  }

  Component _chart(
    BrewMetric metric,
    List<({String id, BrewProfile profile, bool isEstimate, BrewMyth? myth})> columns,
  ) {
    final isPair = metric == BrewMetric.bodyAcidity;
    // Fixed scale per metric, so the built-in bars never move when the AI estimate changes.
    final maxValue = metric.scaleMax;

    return figure(classes: 'chart', [
      ol(classes: 'bar-groups', [
        for (final c in columns)
          li(
            classes: 'bar-group',
            attributes: {'data-method': c.id},
            [
              label(htmlFor: 'pick-${c.id}', [
                span(classes: 'bar-area', [
                  if (isPair) ...[
                    _bar('body', c.profile.body.toDouble(), maxValue, '${c.profile.body}', 'Body'),
                    _bar('acidity', c.profile.acidity.toDouble(), maxValue, '${c.profile.acidity}', 'Acidity'),
                  ] else
                    _bar('single', _value(metric, c.profile), maxValue, _format(metric, c.profile), null),
                ]),
                span(classes: 'method-name', [Component.text(c.profile.name)]),
                if (c.isEstimate) span(classes: 'estimate-tag', [Component.text('AI estimate')]),
              ]),
            ],
          ),
        if (custom == null)
          li(classes: 'bar-group placeholder', [
            // Clicking the empty slot jumps to the input that fills it.
            label(htmlFor: 'custom-method', [
              span(classes: 'bar-area', [
                span(classes: 'slot', [Component.text('?')]),
              ]),
              span(classes: 'method-name', [Component.text('Your method')]),
            ]),
          ]),
      ]),
      if (isPair)
        ul(classes: 'legend', [
          li([span(classes: 'swatch body', []), Component.text('Body (1-10)')]),
          li([span(classes: 'swatch acidity', []), Component.text('Acidity (1-10)')]),
        ]),
      figcaption([Component.text('${metric.label}, typical values for one serving. Real cups vary with recipe.')]),
    ]);
  }

  Component _bar(String kind, double value, double maxValue, String text, String? seriesName) {
    // A floor keeps tiny values visible and clickable.
    final percent = (value / maxValue * 100).clamp(2, 100);
    return span(classes: 'bar $kind', styles: Styles(height: percent.percent), [
      span(classes: 'value', [
        if (seriesName != null) span(classes: 'visually-hidden', [Component.text('$seriesName ')]),
        Component.text(text),
      ]),
    ]);
  }

  Component _myth(BrewMyth myth) {
    return details(classes: 'myth', [
      summary([
        span(classes: 'myth-label', [Component.text('Myth')]),
        span(classes: 'claim', [Component.text(myth.claim)]),
        span(classes: 'reveal', [Component.text('Unveil')]),
      ]),
      p([Component.text(myth.truth)]),
    ]);
  }

  Component _card(String id, BrewProfile profile, BrewMyth? myth) {
    return article(
      classes: 'method-card',
      attributes: {'data-method': id},
      [
        h3([Component.text(profile.name)]),
        p(classes: 'meta', [
          Component.text([profile.serving, profile.filter].where((part) => part.isNotEmpty).join(' · ')),
        ]),
        dl([
          div([
            dt([Component.text('Strength (TDS)')]),
            dd([Component.text('${_number(profile.tds)}%')]),
          ]),
          div([
            dt([Component.text('Caffeine')]),
            dd([Component.text('${profile.caffeineMg} mg')]),
          ]),
          div([
            dt([Component.text('Extraction yield')]),
            dd([Component.text('${_number(profile.extractionYield)}%')]),
          ]),
          div([
            dt([Component.text('Body / acidity')]),
            dd([Component.text('${profile.body} / ${profile.acidity}')]),
          ]),
        ]),
        if (profile.description.isNotEmpty) p(classes: 'description', [Component.text(profile.description)]),
        if (myth != null && myth.claim.isNotEmpty) _myth(myth),
      ],
    );
  }

  /// Value of a single-series metric. Never called for [BrewMetric.bodyAcidity]: that chart draws two bars
  /// from `body` and `acidity` directly (fixed 1-10 scale).
  static double _value(BrewMetric metric, BrewProfile p) => switch (metric) {
    BrewMetric.tds => p.tds,
    BrewMetric.caffeine => p.caffeineMg.toDouble(),
    BrewMetric.extractionYield => p.extractionYield,
    BrewMetric.bodyAcidity => throw StateError('bodyAcidity is a pair chart; read body and acidity directly'),
  };

  static String _format(BrewMetric metric, BrewProfile p) => switch (metric) {
    BrewMetric.tds => '${_number(p.tds)}%',
    BrewMetric.caffeine => '${p.caffeineMg} mg',
    BrewMetric.extractionYield => '${_number(p.extractionYield)}%',
    BrewMetric.bodyAcidity => '${p.body} / ${p.acidity}',
  };

  /// 9.5 → "9.5", 18.0 → "18", 1.35 → "1.35".
  static String _number(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';

  static const _transition = Duration(milliseconds: 200);

  static GridTemplate _columns(TrackRepeat repeat, TrackSize size) => GridTemplate(
    columns: GridTracks([
      GridTrack.repeat(repeat, [GridTrack(size)]),
    ]),
  );

  @css
  static List<StyleRule> get styles => [
    css('.compare-page', [
      css('&').styles(
        display: Display.flex,
        maxWidth: 900.px,
        padding: Padding.symmetric(vertical: 3.rem, horizontal: 1.rem),
        margin: Margin.symmetric(vertical: Unit.zero, horizontal: Unit.auto),
        boxSizing: BoxSizing.borderBox,
        flexDirection: FlexDirection.column,
        alignItems: AlignItems.stretch,
        raw: {'width': '100%'},
      ),
      css('h1').styles(
        margin: Margin.only(bottom: 0.5.rem),
        textAlign: TextAlign.center,
        fontSize: 2.5.rem,
      ),
      css('.subtitle').styles(
        margin: Margin.only(bottom: 2.rem),
        color: colorTextMuted,
        textAlign: TextAlign.center,
        fontSize: 1.1.rem,
      ),
      css('.visually-hidden').styles(
        position: Position.absolute(),
        width: 1.px,
        height: 1.px,
        padding: Padding.zero,
        overflow: Overflow.hidden,
        whiteSpace: WhiteSpace.noWrap,
        raw: {'clip': 'rect(0 0 0 0)', 'margin': '-1px', 'border': '0'},
      ),
    ]),
    css('.compare-panel', [
      css('&').styles(
        display: Display.flex,
        padding: Padding.all(1.rem),
        border: Border.all(style: BorderStyle.solid, color: colorBorder, width: 1.px),
        radius: BorderRadius.circular(12.px),
        flexDirection: FlexDirection.column,
        gap: Gap.all(1.25.rem),
        backgroundColor: colorSurface,
      ),
      // Tabs: radios kept focusable for keyboard use but visually replaced by their label.
      css('.tabs', [
        css('&').styles(
          display: Display.grid,
          padding: Padding.all(0.25.rem),
          margin: Margin.zero,
          border: Border.all(style: BorderStyle.solid, color: colorBorder, width: 1.px),
          radius: BorderRadius.circular(12.px),
          gridTemplate: _columns(TrackRepeat.autoFit, TrackSize.minmax(TrackSize(8.rem), TrackSize.fr(1))),
          gap: Gap.all(0.25.rem),
        ),
        css('legend').styles(
          padding: Padding.symmetric(horizontal: 0.25.rem),
          color: colorTextMuted,
          fontSize: 0.85.rem,
        ),
        css('.tab', [
          css('&').styles(
            display: Display.flex,
            position: Position.relative(),
            minHeight: 3.rem,
            padding: Padding.symmetric(horizontal: 0.75.rem),
            radius: BorderRadius.circular(8.px),
            cursor: Cursor.pointer,
            transition: Transition('background-color', duration: _transition, curve: Curve.ease),
            justifyContent: JustifyContent.center,
            alignItems: AlignItems.center,
            color: colorTextMid,
            textAlign: TextAlign.center,
            fontSize: 0.9.rem,
            fontWeight: FontWeight.w500,
          ),
          css('&:hover').styles(backgroundColor: scaHerbTint),
          css('input').styles(
            position: Position.absolute(),
            opacity: 0,
            raw: {'inset': '0', 'margin': '0', 'pointer-events': 'none'},
          ),
          css('&:has(input:checked)').styles(color: scaCitrus, backgroundColor: scaWine),
          css('&:has(input:focus-visible)').styles(
            outline: Outline(style: OutlineStyle.solid, color: scaHerb, width: OutlineWidth(2.px), offset: 2.px),
          ),
        ]),
      ]),
      css('.chart', [
        css('&').styles(margin: Margin.zero),
        css('.bar-groups').styles(
          display: Display.grid,
          padding: Padding.zero,
          margin: Margin.zero,
          gridTemplate: _columns(TrackRepeat.autoFit, TrackSize.minmax(TrackSize(3.5.rem), TrackSize.fr(1))),
          gap: Gap.all(0.5.rem),
          listStyle: ListStyle.none,
        ),
        css('.bar-group label').styles(
          display: Display.flex,
          minWidth: Unit.zero,
          cursor: Cursor.pointer,
          flexDirection: FlexDirection.column,
          alignItems: AlignItems.center,
          gap: Gap.all(0.35.rem),
        ),
        css('.bar-area').styles(
          display: Display.flex,
          height: 12.rem,
          padding: Padding.only(top: 1.5.rem),
          boxSizing: BoxSizing.borderBox,
          border: Border.only(
            bottom: BorderSide(style: BorderStyle.solid, color: colorBorder, width: 1.px),
          ),
          justifyContent: JustifyContent.center,
          alignItems: AlignItems.end,
          gap: Gap.all(0.3.rem),
          raw: {'width': '100%'},
        ),
        css('.bar', [
          css('&').styles(
            display: Display.block,
            position: Position.relative(),
            width: 2.rem,
            radius: BorderRadius.only(topLeft: Radius.circular(6.px), topRight: Radius.circular(6.px)),
            opacity: 0.4,
            transition: Transition('opacity', duration: _transition, curve: Curve.ease),
            backgroundColor: scaHerb,
            // Replays whenever the chart goes from display:none to visible, i.e. on every tab switch.
            raw: {'animation': 'bar-grow 0.5s ease-out', 'transform-origin': 'bottom'},
          ),
          css('&.body').styles(width: 1.4.rem, backgroundColor: scaChocolate),
          css('&.acidity').styles(width: 1.4.rem, backgroundColor: scaCitrus),
          css('.value').styles(
            position: Position.absolute(bottom: 100.percent, left: 50.percent),
            transform: Transform.translate(x: (-50).percent),
            color: colorTextDark,
            fontSize: 0.8.rem,
            fontWeight: FontWeight.w700,
            whiteSpace: WhiteSpace.noWrap,
            raw: {'padding-bottom': '0.2rem'},
          ),
        ]),
        css('.bar-group:hover .bar').styles(opacity: 0.8),
        css('.method-name').styles(
          maxWidth: 100.percent,
          overflow: Overflow.hidden,
          color: colorTextMid,
          textAlign: TextAlign.center,
          fontSize: 0.85.rem,
          textOverflow: TextOverflow.ellipsis,
          whiteSpace: WhiteSpace.noWrap,
        ),
        css('.estimate-tag').styles(
          padding: Padding.symmetric(vertical: 0.1.rem, horizontal: 0.4.rem),
          radius: BorderRadius.circular(4.px),
          color: scaHerb,
          fontSize: 0.7.rem,
          fontWeight: FontWeight.w700,
          backgroundColor: scaHerbTint,
        ),
        css('.placeholder .slot').styles(
          display: Display.flex,
          width: 2.rem,
          height: 60.percent,
          border: Border.all(style: BorderStyle.dashed, color: colorTextMuted, width: 2.px),
          radius: BorderRadius.only(topLeft: Radius.circular(6.px), topRight: Radius.circular(6.px)),
          justifyContent: JustifyContent.center,
          alignItems: AlignItems.center,
          color: colorTextMuted,
          fontWeight: FontWeight.w700,
        ),
        css('.legend').styles(
          display: Display.flex,
          padding: Padding.zero,
          margin: Margin.only(top: 0.75.rem),
          justifyContent: JustifyContent.center,
          gap: Gap.all(1.25.rem),
          listStyle: ListStyle.none,
          color: colorTextMid,
          fontSize: 0.85.rem,
        ),
        css('.swatch', [
          css('&').styles(
            display: Display.inlineBlock,
            width: 0.8.rem,
            height: 0.8.rem,
            margin: Margin.only(right: 0.4.rem),
            radius: BorderRadius.circular(3.px),
            raw: {'vertical-align': 'middle'},
          ),
          css('&.body').styles(backgroundColor: scaChocolate),
          css('&.acidity').styles(backgroundColor: scaCitrus),
        ]),
        css('figcaption').styles(
          margin: Margin.only(top: 0.75.rem),
          color: colorTextMuted,
          textAlign: TextAlign.center,
          fontSize: 0.8.rem,
        ),
      ]),
      css('.myth', [
        css('&').styles(
          margin: Margin.only(top: 1.rem),
          border: Border.only(
            left: BorderSide(style: BorderStyle.solid, color: scaWine, width: 4.px),
          ),
          radius: BorderRadius.circular(8.px),
          backgroundColor: colorBackground,
        ),
        css('summary', [
          css('&').styles(
            display: Display.flex,
            minHeight: 3.rem,
            padding: Padding.symmetric(vertical: 0.5.rem, horizontal: 1.rem),
            boxSizing: BoxSizing.borderBox,
            radius: BorderRadius.circular(8.px),
            cursor: Cursor.pointer,
            alignItems: AlignItems.center,
            gap: Gap.all(0.75.rem),
            listStyle: ListStyle.none,
            color: colorTextDark,
          ),
          css('&::-webkit-details-marker').styles(display: Display.none),
          css('&:focus-visible').styles(
            outline: Outline(style: OutlineStyle.solid, color: scaHerb, width: OutlineWidth(2.px), offset: 2.px),
          ),
        ]),
        css('.myth-label').styles(
          padding: Padding.symmetric(vertical: 0.15.rem, horizontal: 0.5.rem),
          radius: BorderRadius.circular(4.px),
          color: scaWine,
          fontSize: 0.75.rem,
          fontWeight: FontWeight.w700,
          textTransform: TextTransform.upperCase,
          backgroundColor: scaWineTint,
        ),
        css('.claim').styles(
          flex: const Flex(grow: 1),
          fontWeight: FontWeight.w500,
        ),
        css('.reveal').styles(
          color: scaHerb,
          fontSize: 0.85.rem,
          fontWeight: FontWeight.w700,
          whiteSpace: WhiteSpace.noWrap,
        ),
        css('&[open] .reveal').styles(display: Display.none),
        css('p').styles(
          padding: Padding.only(left: 1.rem, right: 1.rem, bottom: 0.75.rem),
          margin: Margin.zero,
          fontSize: 0.95.rem,
          lineHeight: 1.5.em,
        ),
      ]),
      css('.method-card', [
        css('h3').styles(margin: Margin.zero),
        css('.meta').styles(
          margin: Margin.only(top: 0.25.rem, bottom: 0.75.rem),
          color: colorTextMuted,
          fontSize: 0.85.rem,
          fontStyle: FontStyle.italic,
        ),
        css('dl').styles(
          display: Display.grid,
          margin: Margin.zero,
          gridTemplate: _columns(TrackRepeat.autoFit, TrackSize.minmax(TrackSize(8.rem), TrackSize.fr(1))),
          gap: Gap.all(0.5.rem),
        ),
        css('dl > div').styles(
          padding: Padding.symmetric(vertical: 0.5.rem, horizontal: 0.75.rem),
          border: Border.all(style: BorderStyle.solid, color: colorBorder, width: 1.px),
          radius: BorderRadius.circular(8.px),
        ),
        css('dt').styles(color: colorTextMuted, fontSize: 0.8.rem),
        css('dd').styles(
          margin: Margin.zero,
          color: colorTextDark,
          fontSize: 1.05.rem,
          fontWeight: FontWeight.w700,
        ),
        css('.description').styles(
          margin: Margin.only(top: 0.75.rem),
          fontSize: 0.95.rem,
          lineHeight: 1.5.em,
        ),
      ]),
    ]),
    css('.compare-page .compare-input', [
      css('&').styles(
        display: Display.flex,
        margin: Margin.only(top: 2.rem),
        flexDirection: FlexDirection.column,
        gap: Gap.all(0.5.rem),
      ),
      css('label').styles(
        color: colorTextDark,
        fontSize: 1.rem,
        fontWeight: FontWeight.w700,
      ),
      css('.input-row').styles(
        display: Display.flex,
        flexWrap: FlexWrap.wrap,
        gap: Gap.all(0.5.rem),
      ),
      css('input', [
        css('&').styles(
          minWidth: 12.rem,
          minHeight: 3.rem,
          padding: Padding.symmetric(horizontal: 1.rem),
          boxSizing: BoxSizing.borderBox,
          border: Border.all(style: BorderStyle.solid, color: colorBorder, width: 1.px),
          radius: BorderRadius.circular(8.px),
          outline: Outline(style: OutlineStyle.none),
          transition: Transition('border-color', duration: _transition, curve: Curve.ease),
          flex: const Flex(grow: 1),
          color: colorTextDark,
          fontSize: 0.95.rem,
          backgroundColor: colorSurface,
        ),
        css('&:focus-visible').styles(
          border: Border.all(style: BorderStyle.solid, color: scaHerb, width: 2.px),
        ),
      ]),
      css('button', [
        css('&').styles(
          minHeight: 3.rem,
          padding: Padding.symmetric(horizontal: 2.rem),
          border: Border.none,
          radius: BorderRadius.circular(8.px),
          cursor: Cursor.pointer,
          flex: const Flex(grow: 1),
          color: scaCitrus,
          fontSize: 0.95.rem,
          fontWeight: FontWeight.w700,
          whiteSpace: WhiteSpace.noWrap,
          backgroundColor: scaWine,
        ),
        css('&:hover').styles(opacity: 0.9),
        css('&:focus-visible').styles(
          outline: Outline(style: OutlineStyle.solid, color: scaHerb, width: OutlineWidth(2.px), offset: 2.px),
        ),
      ]),
      css('.hint').styles(
        margin: Margin.zero,
        color: colorTextMuted,
        fontSize: 0.85.rem,
      ),
    ]),
    // Tabs and picks rely on :has(). Without it nothing is hidden, so every chart and card stays readable.
    css.supports('selector(:has(*))', [
      css('.compare-page .metric-view, .compare-page .method-card').styles(display: Display.none),
      for (final metric in BrewMetric.values)
        css('.compare-page:has(#metric-${metric.name}:checked) .metric-view[data-metric="${metric.name}"]').styles(
          display: Display.block,
        ),
      for (final id in _allIds) ...[
        css('.compare-page:has(#pick-$id:checked) .method-card[data-method="$id"]').styles(display: Display.block),
        css('.compare-page:has(#pick-$id:checked) .bar-group[data-method="$id"] .bar').styles(opacity: 1),
        css('.compare-page:has(#pick-$id:checked) .bar-group[data-method="$id"] .method-name').styles(
          color: colorTextDark,
          fontWeight: FontWeight.w700,
        ),
      ],
    ]),
    css('@keyframes bar-grow', [
      css('from').styles(raw: {'transform': 'scaleY(0)'}),
    ]),
    css.media(MediaQuery.raw('(prefers-reduced-motion: reduce)'), [
      css('.compare-panel .bar').styles(raw: {'animation': 'none'}),
    ]),
  ];
}
