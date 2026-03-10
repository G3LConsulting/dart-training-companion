# LEAD-04 — Sharing Stats & Achievements

**Feature:** Leaderboards & Sharing
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Context

Players want to celebrate their achievements and share progress with friends. Generating shareable image cards (social media style) makes stats tangible and drives organic sharing. Branding the cards with app logo reinforces brand presence across social platforms.

> Implements: FA §FR-L-04

---

## Acceptance Criteria

- [ ] User can share: weekly summary, PB achievement, drill result as generated image card
- [ ] Share opens device native share sheet (Web Share API)
- [ ] Shared cards include app branding

---

## Technical Implementation Notes

> ⚠️ No detailed TA spec exists for this feature yet. The following is derived from the FA and general architecture patterns.

- Angular canvas-based image generation service:
  - Weekly summary card: stats summary (avg, games played, mode breakdown)
  - PB achievement card: drill/mode, old PB, new PB, date
  - Drill result card: drill name, score, stars, target
  - All cards include app logo/branding and timestamp
- Share button components on:
  - Stats/dashboard view (weekly summary)
  - PB detail page (STAT-03)
  - Drill result screen (DRILL-04)
- Web Share API integration:
  - Convert canvas to Blob
  - Share via navigator.share() if available
  - Fallback to copy-to-clipboard for unsupported browsers
- Optional: Backend image generation service for consistency across platforms
- Optional: Share analytics tracking (which cards shared, engagement)

---

## Dependencies

- STAT-06 — Weekly Stats Summary — Weekly summary card content
- STAT-03 — Personal Bests — PB achievement card content
- DRILL-04 — Drill Completion & Results — Drill result card content

---

## Shared References

- ../../shared/architecture.md
- ../../shared/entities.md
