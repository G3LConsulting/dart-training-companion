# GAME-01 — Game Setup

**Feature:** Score Tracking & Game Modes
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Pre-game setup screen where users select their game mode (501/301/Cricket/Number Focus), number of players, rule options, and game-specific configuration. The ConfigurationJson captures all mode-specific settings for later use throughout the session and when persisting to the server.

> Implements: FR-G-01, TA §6 (CreateSessionCommand structure, ConfigurationJson)

---

## Acceptance Criteria

- [ ] Mode selection screen displays 4 modes with clear labels and descriptions
- [ ] 501/301 mode: optional double-in toggle, 1–2 player selection; Player 2 name input field appears for 2-player games
- [ ] Cricket mode: choose between 2-player pass-and-play OR solo drill mode; optional target score field for solo mode
- [ ] Number Focus mode: target number selector (1–20 + Bull), dart count slider/input (10–200 in steps of 10, default 50)
- [ ] Config summary screen displayed before starting, showing all selected settings
- [ ] ConfigurationJson correctly populated for each mode:
  - 501/301: `{ startingScore, doubleIn, player2Name? }`
  - Cricket: `{ soloMode: boolean, targetScore? }`
  - Number Focus: `{ targetNumber: number|"bull", dartCount: number }`
- [ ] Confirm button navigates to the appropriate in-game screen for the selected mode
- [ ] Form validation prevents invalid configurations (e.g., empty Player 2 name if 2-player selected)

---

## Technical Implementation Notes

- **Angular:** Create standalone component `features/game/game-setup/` with mode-specific config panels
  - Each mode has its own sub-component or conditional form sections
  - ConfigurationJson is populated client-side and packaged with the POST /api/sessions request (sent in GAME-04, not here)
- **State Management:** Use a game state service to capture the full configuration
- **No backend API call at setup time** — the session is only saved to the server on completion (see GAME-04)
- **UI/UX:** Clear labeling, tooltips for rules (double-in, Cricket variants), responsive layout for number selector

---

## Dependencies

- PROF-01 (User profile exists; optional for personalized defaults)
- Angular framework, standalone component setup
- Game state service for configuration management

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — GameMode enum, ConfigurationJson structure, Player entity
- [Architecture](../../shared/architecture.md) — offline-first pattern, client-side state management
- [API Contracts](../../shared/api-contracts.md) — CreateSessionCommand schema (POST /api/sessions)
- [NFRs](../../shared/non-functional-requirements.md) — responsive design, accessibility (WCAG 2.1 AA)
