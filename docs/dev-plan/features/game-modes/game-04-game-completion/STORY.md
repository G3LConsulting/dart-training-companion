# GAME-04 — Game Completion & Post-Game Summary

## Metadata
- **Story:** GAME-04
- **Feature:** Score Tracking & Game Modes
- **Phase:** MVP
- **Status:** Planned
- **Agent:** Angular (Frontend), C# (Backend)
- **Output:** Post-game summary component, CreateSessionCommand API endpoint, session save service, unit tests
- **Notes:** Final step of game loop; integrates with backend persistence

## Context
Implements:
- FA §FR-G-04 (Post-game summary and stats)
- TA §6 (CreateSessionCommand CQRS pattern)

## Acceptance Criteria
- [ ] When game ends (checkout completed or all rounds finished), post-game summary displayed
- [ ] Summary shows: total turns, 3-dart average, highest turn, checkout scored (if applicable)
- [ ] Summary includes comparison to personal best (PB) for same game mode
- [ ] Completed game automatically saved to history via API
- [ ] User can start new game in same mode or return to home screen
- [ ] Works for both 1-player and 2-player games
- [ ] For 2-player: summary shows winner and individual stats
- [ ] API call completes within 2 seconds
- [ ] Offline fallback: session queued for sync when offline (GAME-08)

## Tasks

| Task ID | Title | Status |
|---------|-------|--------|
| T01 | API: CreateSessionCommand with handler and validator | Planned |
| T02 | Frontend: Post-game summary component | Planned |
| T03 | Frontend: Session save logic (call CreateSessionCommand API) | Planned |
| T04 | Tests: CreateSession command tests | Planned |

## Dependencies
- **GAME-02:** Score entry provides game data and stats

## Shared References
- [Architecture](../../shared/ARCHITECTURE.md) — CQRS pattern, Angular feature structure
- [Domain Model](../../shared/DOMAIN-MODEL.md) — GameSession, Turn, SessionStats entities
- [API Contracts](../../shared/API-CONTRACTS.md) — POST /api/sessions endpoint specification
