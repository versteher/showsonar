# Product TODOs

## UX

### Card logos: show active filter provider only
Currently all subscribed service logos show on every card. Better: if a single
provider is active in the filter bar, show only that logo. If multiple providers
are selected, show none (ambiguous which one serves the title).
Requires passing the active filter context down to `MediaCard`.

---

## Architecture / API

### TMDB data staleness — discover vs. watch/providers inconsistency
TMDB's `/discover` index (used to populate all content lists) can lag **days to
weeks** behind actual provider availability. The `/movie/{id}/watch/providers`
endpoint (used on the detail screen) is near real-time. The two diverge when a
title leaves a platform.

**See:** `docs/TMDB_DATA_NOTES.md`

**Long-term fix options:**
- Subscribe to JustWatch's direct API or a commercial aggregator (e.g. Reelgood,
  Watchmode) — real-time, but paid.
- Keep TMDB for discovery; show a "availability may have changed" disclaimer on
  cards that don't verify via `getWatchProviders`.

### TMDB free tier capacity analysis

**Rate limit:** 30 req / 10 s per proxy IP = **180 req/min**

#### Calls per user session
| Event | Calls | Cached after? |
|---|---|---|
| Cold home screen load | ~40–57 | Yes (keepAlive) |
| Provider counts bar | ~20–40 | Yes (keepAlive) |
| Detail screen open | ~3 (details + providers + trailer) | 5 min TTL |
| Search query | 1 | No |

#### Concurrent users the free tier can serve
With cold starts (worst case — new users or cache miss):

| Scenario | Calls/user | Users/min at 180 req/min limit |
|---|---|---|
| Cold home load (current) | 50 | **~3–4 concurrent** |
| + N+1 provider verify (20 cards) | 70 | **~2–3 concurrent** |
| Warm (cached, detail opens only) | 3 | **~60 concurrent** |

> ⚠️ The **provider counts bar** alone uses ~40 calls per user cold start.
> It's keepAlive cached, so a user only pays it once per app session — but
> at scale this is the biggest call multiplier.

#### Practical read
- **Solo / dev use:** No problem whatsoever.
- **Small beta (~10–20 concurrent users):** Fine if sessions are staggered.
  Riverpod keepAlive means most users after the first have warm caches.
- **Public launch (100+ concurrent):** Would need either:
  1. A server-side cache layer (Redis/CDN) in front of the TMDB proxy — costs
     near zero and removes the per-user cold start completely.
  2. Or a TMDB commercial plan (no public pricing, contact-based).

#### Easiest scaling fix
Add HTTP caching headers (`Cache-Control: public, max-age=300`) to the FastAPI
proxy responses. A CDN (Cloudflare free tier) in front would then serve all
users from cache — TMDB calls drop to near zero regardless of user count.
