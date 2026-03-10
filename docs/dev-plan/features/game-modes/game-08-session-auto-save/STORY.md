# GAME-08 — Session Auto-Save & Resume

## Metadata
- **Story:** GAME-08
- **Feature:** Score Tracking & Game Modes
- **Phase:** MVP
- **Status:** Planned
- **Agent:** Angular (Frontend)
- **Output:** Auto-save service, resume prompt component, integration across all game modes
- **Notes:** Offline-first; persists in-progress game state; enables resume on app reopening

## Context
Implements:
- FA §FR-G-09 (Auto-save and resume)
- TA §3 (Offline-first architecture)

## Acceptance Criteria
- [ ] After every scored turn (501/301/Cricket) or every dart entry (Number Focus), state saved to localStorage
- [ ] On app open with saved state: resume prompt shown ("Resume" / "Discard" options)
- [ ] Resume restores exact session state (all turns, marks, darts entered)
- [ ] Discard clears saved state, no data saved to history
- [ ] Only one in-progress session per device
- [ ] Starting new game with saved session prompts confirmation before discarding
- [ ] Auto-save does not delay score entry (≤ 100ms total latency)
- [ ] Saved state includes: mode, config, all turns/darts, timestamp
- [ ] Works offline; session syncs to API when reconnected (via GAME-04)

## Tasks

| Task ID | Title | Status |
|---------|-------|--------|
| T01 | Frontend: Auto-save service (writes to localStorage after each score/dart) | Planned |
| T02 | Frontend: Resume prompt component (shown on app init) | Planned |
| T03 | Tests: Auto-save and resume tests | Planned |

## Dependencies
- **GAME-02, GAME-05, GAME-07:** Trigger auto-save events
- **GAME-04:** Session save API (sync when online)

## Shared References
- [Architecture](../../shared/ARCHITECTURE.md) — Offline-first design, localStorage patterns
- [NFRs](../../shared/NFRs.md) — Performance targets (100ms score entry)
