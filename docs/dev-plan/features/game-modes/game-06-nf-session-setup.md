# GAME-06 — Number Focus: Session Setup

**Feature:** Score Tracking & Game Modes
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Dedicated setup screen for Number Focus training sessions. Users select a target number (1–20 or Bull) and configure the session by choosing the number of darts to throw (10–200 in steps of 10, with a default of 50). A configuration summary is displayed before starting the session.

> Implements: FR-G-06, TA §5 (GameSession.ConfigurationJson for NF)

---

## Acceptance Criteria

- [ ] Target number selector displays all 21 options: numbers 1–20 and Bull, with clear labels
- [ ] Dart count input/slider accepts values from 10 to 200 in increments of 10
- [ ] Default dart count is 50
- [ ] Configuration summary screen displays before starting, showing "Training [number], [count] darts"
- [ ] Confirm/Start button navigates to the in-session screen (GAME-07) with configuration applied
- [ ] ConfigurationJson is correctly populated with: `{ targetNumber: number|"bull", dartCount: number }`
- [ ] Form validation prevents invalid selections (e.g., missing target number, out-of-range dart count)
- [ ] UI is responsive and accessible (WCAG 2.1 AA)

---

## Technical Implementation Notes

- **Angular:** Create standalone component `features/game/number-focus/nf-setup/`
  - Radio button or button grid for target number selection (1–20, Bull)
  - Slider or numeric input with step=10 for dart count (min=10, max=200)
  - Summary section showing the final configuration
- **ConfigurationJson structure for Number Focus:**
  ```
  {
    targetNumber: number (1-20) | "bull",
    dartCount: number (10-200, step 10)
  }
  ```
- **No backend API call at setup time** — all configuration is captured client-side and packaged with the session save in GAME-04 or GAME-08
- **State Management:** Temporary form state stored in component; passed to game state service on confirmation
- **Defaults:** dartCount defaults to 50; user must explicitly select a target number
- **Navigation:** On "Start" or "Confirm", navigate to `number-focus/nf-session/` route (GAME-07)

---

## Dependencies

- GAME-01 (User navigates to GAME-06 from the main game setup screen, selecting Number Focus mode)
- Angular framework, standalone component setup
- Game state service for configuration management

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — ConfigurationJson structure, GameMode enum
- [Architecture](../../shared/architecture.md) — offline-first pattern, client-side state management
- [API Contracts](../../shared/api-contracts.md) — CreateSessionCommand schema (ConfigurationJson field)
- [NFRs](../../shared/non-functional-requirements.md) — responsive design, accessibility (WCAG 2.1 AA)
