# GAME-01 — Game Setup & Mode Selection

## Metadata
- **Story:** GAME-01
- **Feature:** Score Tracking & Game Modes
- **Phase:** MVP
- **Status:** Planned
- **Agent:** Angular (Frontend)
- **Output:** Game setup component with mode-specific configuration UI
- **Notes:** Entry point to all game modes; validates user selections before launch

## Context
Implements:
- FA §FR-G-01 (Game mode selection and setup)
- TA §4 (Angular game features)

## Acceptance Criteria
- [ ] User can select game mode (501, 301, Cricket, Number Focus) from home screen or dedicated modes menu
- [ ] For 501/301: user selects player count (1 or 2) and configurable rules (double-in yes/no, double-out required)
- [ ] For Cricket: user selects game type (2-player pass-and-play or solo score drill mode) and optional configurable target score (default 300)
- [ ] For Cricket 2-player: user can enter name for second player
- [ ] For Number Focus: setup handled by GAME-07 (separate component)
- [ ] Game setup screen shows configuration summary with prominent "Start" button
- [ ] Invalid selections prevented (e.g., no start without mode selected)
- [ ] Setup transitions smoothly to in-game component

## Tasks

| Task ID | Title | Status |
|---------|-------|--------|
| T01 | Frontend: Game setup component with mode-specific options | Planned |
| T02 | Frontend: Mode-specific setup forms (501/301, Cricket) | Planned |
| T03 | Tests: Game setup component tests | Planned |

## Dependencies
- **INFRA-01:** Angular scaffold must exist with routing structure

## Shared References
- [Architecture](../../shared/ARCHITECTURE.md) — Angular feature module structure
- [Domain Model](../../shared/DOMAIN-MODEL.md) — GameSession configuration entities
