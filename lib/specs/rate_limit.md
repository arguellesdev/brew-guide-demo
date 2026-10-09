# Spec: Rate limit

`lib/services/rate_limiter.dart`. Caps how many Gemini requests the server accepts, to stop a runaway loop
or bug from burning credits.

## Behavior
- One global `geminiRateLimiter`: 10 requests per minute and 200 per hour (sliding windows).
- Shared by `POST /api/gemini` and `POST /api/compare`, so alternating endpoints doesn't double the quota.
- Global, not per IP: the app runs locally, so every visitor shares one IP. Add per-IP (reading
  `X-Forwarded-For` only behind a trusted proxy) if it is ever deployed.
- In memory: resets on restart and isn't shared across instances.
- Counts submissions, not Gemini calls, so the one-time retry on `busy`/`badResponse` stays inside the budget.
- Empty input and a missing signing key are rejected before the check and consume nothing.

## Failure path
Over the cap, the handler throws `GeminiException(GeminiFailure.rateLimited)` and no Gemini call is made:
- Preset card on home: 302 `/coffee?...&fallback=1` with the house recipe (works without Gemini).
- Free text on home: 302 `/?error=rateLimited&q=<text>`.
- Compare: 302 `/compare?error=rateLimited&q=<text>`.
The message ("That's a lot of coffee in a short time...") lives in each page's `_errorMessages`.

## QA
- `RateLimiter.tryAcquire` takes an injectable `now` for deterministic checks.
- A rejected request records nothing, so waiting out the window restores access.
