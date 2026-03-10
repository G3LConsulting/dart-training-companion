# GAME-03 — Checkout Suggestions

## Metadata
- **Story:** GAME-03
- **Feature:** Score Tracking & Game Modes
- **Phase:** MVP
- **Status:** Planned
- **Agent:** Angular (Frontend)
- **Output:** Checkout calculator service, suggestion display component, unit tests
- **Notes:** Enhancement to 501/301 gameplay; helps users find optimal finishing combinations

## Context
Implements:
- FA §FR-G-03 (Checkout suggestions)

## Acceptance Criteria
- [ ] When remaining score ≤ 170 in 501/301, optimal checkout combination displayed on screen
- [ ] Checkout suggestions can be toggled on/off in settings (persisted to localStorage)
- [ ] Suggestions show correct combinations for all standard checkouts (e.g., 170 = T20 + T20 + Bull, 40 = D20)
- [ ] Checkout display includes multiple options where available (e.g., 100 = T20 + D20 OR B20 + D20)
- [ ] Edge cases handled correctly: no checkout for 169, 168, 166, 165, 163, 162, 159
- [ ] Suggestion updates in real-time as score changes
- [ ] Accessibility: high contrast, readable font size

## Tasks

| Task ID | Title | Status |
|---------|-------|--------|
| T01 | Frontend: Checkout calculator service + display component | Planned |
| T02 | Tests: Checkout calculation tests | Planned |

## Dependencies
- **GAME-02:** Score entry provides remaining score

## Shared References
- [Architecture](../../shared/ARCHITECTURE.md) — Angular services and components
- [Domain Model](../../shared/DOMAIN-MODEL.md) — Checkout data structures
