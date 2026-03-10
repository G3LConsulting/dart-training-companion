# GAME-06 — Cricket Solo Score Drill

## Metadata
- **Story:** GAME-06
- **Feature:** Score Tracking & Game Modes
- **Phase:** MVP
- **Status:** Planned
- **Agent:** Angular (Frontend)
- **Output:** Cricket solo component, game logic, unit tests
- **Notes:** Single-player Cricket variation; focuses on achieving target score

## Context
Implements:
- FA §FR-G-01 (Cricket solo mode setup)

## Acceptance Criteria
- [ ] Single player closes all numbers (15–20 + bull) and accumulates points
- [ ] Session ends automatically when all numbers closed
- [ ] Total score and turns taken recorded
- [ ] Target score benchmark (configurable, default 300) displayed on screen
- [ ] Target is display-only (no pass/fail logic)
- [ ] No pass/fail — session always completes and saves regardless of score
- [ ] Results show: total score, turns, time duration, marks per number
- [ ] Results compared to personal history (best score, average score for this mode)
- [ ] Post-game summary follows same pattern as 501/301

## Tasks

| Task ID | Title | Status |
|---------|-------|--------|
| T01 | Frontend: Cricket solo drill component | Planned |
| T02 | Tests: Cricket solo drill tests | Planned |

## Dependencies
- **GAME-05:** Shares Cricket scoreboard infrastructure (marks tracking, closure detection)
- **GAME-04:** Session saving handles game completion

## Shared References
- [Architecture](../../shared/ARCHITECTURE.md) — Angular component patterns
- [Domain Model](../../shared/DOMAIN-MODEL.md) — GameSession configuration (target score in ConfigurationJson)
