# GAME-07 — Number Focus: In-Session Dart Entry

**Feature:** Score Tracking & Game Modes
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

The in-session screen for Number Focus training. Users record the outcome of each dart thrown (Triple, Double, Single, or Miss) via four large, easily tappable buttons. Real-time counters display darts remaining, hit/miss breakdown, and calculated accuracy percentage. One-level undo is available to correct the last entry, and session state is auto-saved to localStorage after each dart.

> Implements: FR-G-07, TA §5 (DartEntry entity)

---

## Acceptance Criteria

- [ ] Four large outcome buttons are displayed: Triple, Double, Single, Miss
- [ ] Real-time display shows:
  - Total darts thrown so far
  - Darts remaining (dartCount - thrown)
  - Count of Triples, Doubles, Singles, and Misses
  - Accuracy % = (darts that hit target ÷ total darts thrown) × 100
- [ ] One-level undo button is always visible; clicking it reverts the last dart entry and updates all counters
- [ ] Dart counter advances by 1 with each button tap
- [ ] Session automatically ends (navigates to GAME-08) when the dart count reaches the configured dartCount
- [ ] Game state is persisted to localStorage after each dart entry (foundation for GAME-09 auto-save)
- [ ] Score entry (button tap and counter update) responds within 100ms (NFR)
- [ ] UI is clear, accessible, and optimized for touch input

---

## Technical Implementation Notes

- **Angular:** Create standalone component `features/game/number-focus/nf-session/`
  - Four buttons (Triple, Double, Single, Miss) with large tap targets (min 44×44px for accessibility)
  - Real-time display section showing dart counters and accuracy %
  - Undo button prominently positioned
- **DartEntry entity shape:**
  ```
  {
    dartNumber: number (1 to dartCount),
    outcome: "Triple" | "Double" | "Single" | "Miss"
  }
  ```
- **State Management:** Maintain an array of DartEntry objects in component state
  - Add a new entry on each button tap
  - Undo pops the last entry from the array
  - Calculate accuracy in real time: `(triples + doubles + singles) ÷ total × 100`
- **Accuracy calculation:**
  - "Hit" = Triple, Double, or Single (outcome !== "Miss")
  - Accuracy % = (hit count ÷ total darts) × 100
  - Display to 1 decimal place (e.g., "87.5%")
- **localStorage persistence:** After each dart entry, write full session state to localStorage using GAME-09 pattern
- **Session completion:** When `dartEntries.length === dartCount`, automatically navigate to `number-focus/nf-results/` (GAME-08)
- **Performance:** Button tap handling, counter update, and localStorage write must complete within 100ms

---

## Dependencies

- GAME-06 (Session configuration and dartCount provided)
- Angular framework, standalone component setup
- Game state service
- localStorage API (for GAME-09 integration)

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — DartEntry entity, GameSession entity
- [Architecture](../../shared/architecture.md) — offline-first pattern, localStorage persistence
- [API Contracts](../../shared/api-contracts.md) — DartEntry schema
- [NFRs](../../shared/non-functional-requirements.md) — 100ms response time, touch-friendly UI, accessibility (WCAG 2.1 AA)
