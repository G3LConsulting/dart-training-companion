# GAME-02 — 501/301 Score Entry & Bust Detection

## Metadata
- **Story:** GAME-02
- **Feature:** Score Tracking & Game Modes
- **Phase:** MVP
- **Status:** Planned
- **Agent:** Angular (Frontend)
- **Output:** Score input widget, in-game component, game state service, unit tests
- **Notes:** Core gameplay loop for primary game modes; performance critical (100ms)

## Context
Implements:
- FA §FR-G-02 (Score entry and feedback)
- FA §FR-G-05 (Bust detection and handling)
- TA §4 (Angular game features)

## Acceptance Criteria
- [ ] Scores entered per turn (3 darts) via numeric keypad (default) or segment-by-segment entry
- [ ] User can toggle input method in settings
- [ ] After each entry: remaining score, current turn score, and round number displayed prominently
- [ ] Previous turn can be undone (one level only)
- [ ] Bust detected when: score goes below 1, or finishes on non-double (with double-out enabled)
- [ ] Bust shows clear "Bust!" notification and voids the turn (reverts to pre-turn state)
- [ ] Score entry responds within 100ms
- [ ] Pass-and-play (2-player): turns alternate between players, both scores/players visible at all times
- [ ] Game state persists through page refresh (handled by GAME-08)
- [ ] Accessibility: large touch targets, clear visual feedback

## Tasks

| Task ID | Title | Status |
|---------|-------|--------|
| T01 | Frontend: Score input widget (numeric keypad + segment-by-segment) | Planned |
| T02 | Frontend: 501/301 in-game component with scoreboard, bust detection, undo | Planned |
| T03 | Frontend: Game state service (manages turns, scores, player switching) | Planned |
| T04 | Tests: 501/301 game logic tests | Planned |

## Dependencies
- **GAME-01:** Game setup provides configuration (mode, player count, rules)

## Shared References
- [Architecture](../../shared/ARCHITECTURE.md) — Angular feature structure, service patterns
- [Domain Model](../../shared/DOMAIN-MODEL.md) — GameSession, Turn, PlayerScore entities
- [NFRs](../../shared/NFRs.md) — Performance targets (100ms score entry)
