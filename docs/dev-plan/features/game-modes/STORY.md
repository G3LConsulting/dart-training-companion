# GAME-MODES Feature Story

## Metadata
- **Feature:** Score Tracking & Game Modes
- **Phase:** MVP
- **Status:** Planned
- **Agent:** Angular (Frontend), C# (Backend)
- **Output:** Game setup components, state services, API endpoints, game-specific UI
- **Notes:** Core gameplay loop; all game types (501, 301, Cricket, Number Focus) depend on this feature

## Context
Implements:
- FA §FR-G-01 through §FR-G-09 (Game Features specification)
- TA §4 (Angular game features), TA §6 (CQRS session commands), TA §3 (offline-first architecture)

## Acceptance Criteria
- [ ] User can launch any of four game modes from home screen
- [ ] Each mode has appropriate setup with configurable options
- [ ] In-game state is tracked accurately and persisted locally
- [ ] Score/dart entry responds within 100ms
- [ ] All modes support undo (one level)
- [ ] Games automatically saved to API on completion
- [ ] Session state can be resumed from device storage
- [ ] All game logic is tested with comprehensive unit test coverage

## Tasks

| Task ID | Title | Story Link | Status |
|---------|-------|------------|--------|
| GAME-01 | Game Setup & Mode Selection | [./game-01-game-setup/STORY.md](./game-01-game-setup/STORY.md) | Planned |
| GAME-02 | 501/301 Score Entry & Bust Detection | [./game-02-501-301-score-entry/STORY.md](./game-02-501-301-score-entry/STORY.md) | Planned |
| GAME-03 | Checkout Suggestions | [./game-03-checkout-suggestions/STORY.md](./game-03-checkout-suggestions/STORY.md) | Planned |
| GAME-04 | Game Completion & Post-Game Summary | [./game-04-game-completion/STORY.md](./game-04-game-completion/STORY.md) | Planned |
| GAME-05 | Cricket Pass-and-Play | [./game-05-cricket-pass-and-play/STORY.md](./game-05-cricket-pass-and-play/STORY.md) | Planned |
| GAME-06 | Cricket Solo Score Drill | [./game-06-cricket-solo-drill/STORY.md](./game-06-cricket-solo-drill/STORY.md) | Planned |
| GAME-07 | Number Focus Session | [./game-07-number-focus/STORY.md](./game-07-number-focus/STORY.md) | Planned |
| GAME-08 | Session Auto-Save & Resume | [./game-08-session-auto-save/STORY.md](./game-08-session-auto-save/STORY.md) | Planned |

## Dependencies
- **INFRA-01:** Angular scaffold and routing structure
- **AUTH-01:** User authentication and session context
- **STORAGE-01:** LocalStorage and API client infrastructure

## Shared References
- [Architecture](/sessions/gracious-gallant-clarke/mnt/Darts%20training%20PWA/dev-plan/shared/ARCHITECTURE.md) — Angular feature structure, CQRS pattern, offline-first design
- [Domain Model](/sessions/gracious-gallant-clarke/mnt/Darts%20training%20PWA/dev-plan/shared/DOMAIN-MODEL.md) — GameSession, Turn, DartEntry, CricketTurn entities
- [API Contracts](/sessions/gracious-gallant-clarke/mnt/Darts%20training%20PWA/dev-plan/shared/API-CONTRACTS.md) — POST /api/sessions, GET /api/sessions/{id}
- [NFRs](/sessions/gracious-gallant-clarke/mnt/Darts%20training%20PWA/dev-plan/shared/NFRs.md) — Performance targets (100ms score entry), offline requirements
