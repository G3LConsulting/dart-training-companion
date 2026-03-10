# GAME-05 — Cricket Pass-and-Play

## Metadata
- **Story:** GAME-05
- **Feature:** Score Tracking & Game Modes
- **Phase:** MVP
- **Status:** Planned
- **Agent:** Angular (Frontend)
- **Output:** Cricket scoreboard component, cricket game state service, unit tests
- **Notes:** Two-player competitive Cricket mode; includes mark tracking and point scoring

## Context
Implements:
- FA §FR-G-01 (Cricket 2-player setup and mode)
- FA §FR-G-02 (Cricket score entry and turn tracking)

## Acceptance Criteria
- [ ] Two players take turns, each marking numbers 15–20 and bull
- [ ] Three marks closes a number; further marks on closed numbers score points for that player
- [ ] Scoreboard shows: marks per number per player, running points total, current player indicator
- [ ] Turn can be undone (one level)
- [ ] Game ends when: all numbers closed by both players, or by user decision
- [ ] Post-game summary shows: marks per round (MPR), points for each player, game duration, winner
- [ ] Pass-and-play: clear player indicator, turn alternation smooth
- [ ] Touch-friendly interface for multiple darts per turn

## Tasks

| Task ID | Title | Status |
|---------|-------|--------|
| T01 | Frontend: Cricket scoreboard component with marks tracking | Planned |
| T02 | Frontend: Cricket game state service | Planned |
| T03 | Tests: Cricket game logic tests | Planned |

## Dependencies
- **GAME-01:** Game setup provides 2-player configuration
- **GAME-04:** Session saving handles game completion

## Shared References
- [Architecture](../../shared/ARCHITECTURE.md) — Angular feature structure, service patterns
- [Domain Model](../../shared/DOMAIN-MODEL.md) — GameSession, CricketTurn, CricketMark entities
