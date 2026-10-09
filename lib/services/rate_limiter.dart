/// Sliding-window cap on how many Gemini requests the whole server accepts.
///
/// Global, not per user: the app runs locally, so every visitor shares one IP anyway. It guards against a
/// runaway loop or a bug, not real spend. State lives in memory and resets on restart.
class RateLimiter {
  /// Max requests allowed within each window, e.g. `{Duration(minutes: 1): 10}`.
  final Map<Duration, int> limits;

  final List<DateTime> _hits = [];

  RateLimiter(this.limits);

  /// Records a request and returns true, or returns false (recording nothing) when any window is full.
  bool tryAcquire([DateTime? now]) {
    final at = now ?? DateTime.now();
    final longest = limits.keys.reduce((a, b) => a > b ? a : b);
    _hits.removeWhere((hit) => at.difference(hit) >= longest);

    for (final MapEntry(key: window, value: max) in limits.entries) {
      if (_hits.where((hit) => at.difference(hit) < window).length >= max) return false;
    }
    _hits.add(at);
    return true;
  }
}

/// Shared by /api/gemini and /api/compare so alternating between them doesn't double the quota.
final geminiRateLimiter = RateLimiter({
  const Duration(minutes: 1): 10,
  const Duration(hours: 1): 200,
});
