# GAME-03 — Checkout Suggestions (501/301)

**Feature:** Score Tracking & Game Modes
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Optional in-game helper for 501 and 301 modes. When the remaining score falls between 2 and 170, a checkout hint component displays the optimal 3-dart checkout path (e.g., "T20, T20, D20"). Users can toggle this feature on or off via settings; the lookup table is hardcoded for offline operation.

> Implements: FR-G-03, no specific TA section — pure frontend feature

---

## Acceptance Criteria

- [ ] Checkout hint is displayed when remaining score is between 2 and 170 (inclusive)
- [ ] Hint displays up to 3-dart checkout path in human-readable format (e.g., "T20, T20, D20")
- [ ] No hint is shown for scores not achievable in 3 darts (161, 163, 165, 166, 168, 169)
- [ ] Setting to toggle hints on/off is available in user settings and persists (either in user profile or localStorage for guests)
- [ ] Hint updates in real time as the remaining score changes after each turn
- [ ] Checkout lookup table works fully offline (no API call needed)
- [ ] Hint is toggleable per session without affecting other sessions

---

## Technical Implementation Notes

- **Angular:** Create a `checkout-hint` component or pipe that consumes the remaining score and displays the suggestion
- **Checkout Lookup Table:** Hardcoded static object or array covering all finishes from 2 to 170
  - Covers standard double-out rule finishes
  - Excludes impossible scores: 161, 163, 165, 166, 168, 169
  - Example entry: `170: "T20, T20, D20"`, `2: "D1"`
- **Toggle State:** Stored in user preferences (UpdateProfileCommand if user is authenticated, or localStorage for guests)
- **Performance:** Lookup is O(1); display update within 100ms
- **UI/UX:** Display hint in a visually distinct area (e.g., sidebar or collapsible panel); make it easy to dismiss or hide

---

## Dependencies

- GAME-02 (Score entry and remaining score calculation)
- User profile service or localStorage (for toggle preference)
- Angular framework

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — User preferences structure
- [Architecture](../../shared/architecture.md) — offline-first pattern, client-side preference storage
- [API Contracts](../../shared/api-contracts.md) — UpdateProfileCommand (optional, for authenticated users)
- [NFRs](../../shared/non-functional-requirements.md) — offline capability, 100ms response time
