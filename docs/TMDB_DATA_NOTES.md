# TMDB Data Notes

## Provider Data — Two Endpoints, One Inconsistency

TMDB exposes two separate data sources for streaming provider information, and they are **not always in sync**:

| Endpoint | Used for | Freshness |
|---|---|---|
| `/discover/movie?with_watch_providers=8` | Populating content lists filtered by provider | Stale index, can lag by days/weeks |
| `/movie/{id}/watch/providers` | Per-title list of where to stream | Near real-time JustWatch data |

This means a movie like *Love Simon* can appear in a Netflix-filtered discover list even though `getWatchProviders` returns no Netflix for DE — because the discover index hasn't been updated since Netflix DE removed the title.

## Card Logo Design Decision

Card logos **do not call `getWatchProviders`** (that would be one extra API call per card, i.e. ~20 calls on every home screen render). Instead, logos on cards show the user's **currently subscribed services** from `prefs.subscribedServices` directly.

**Rationale:** The content appeared in the list because the user's selected providers were used as the discover filter. Showing those provider logos is the correct contextual signal — it tells the user "this content lives in your subscriptions world". Whether it's currently on Netflix vs. Amazon Prime within that set is not what the small card logo is trying to convey.

**Consequence:** If a user subscribes to Netflix + Disney+, all cards will show both logos regardless of which specific service hosts the title. The **detail screen** calls `getWatchProviders` and shows the accurate, real-time breakdown.

## No Automatic Verification

We deliberately do **not** verify discover results against `getWatchProviders` per-item, because:
- It costs N extra API calls per section (slow, expensive)
- Most streaming apps (JustWatch, Google TV, etc.) have the same lag
- The detail screen always shows the ground truth

This is a known, accepted limitation of TMDB's discover API.
