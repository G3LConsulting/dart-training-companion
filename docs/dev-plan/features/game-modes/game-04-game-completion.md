# GAME-04 — Game Completion & Post-Game Summary

**Feature:** Score Tracking & Game Modes
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

When a game ends (501/301 checked out, Cricket closed, Number Focus dart count completed), the session is automatically saved to the server and a post-game summary screen displays key statistics and personal best comparisons. Users can then start a new game, return home, or perform other actions.

> Implements: FR-G-04, TA §6 (CreateSessionCommand), TA §5 (GameSession, Turn, CricketTurn entities)

---

## Acceptance Criteria

- [ ] Session is automatically saved via POST /api/sessions on game completion (no user action required)
- [ ] Post-game summary screen displays:
  - Total turns played
  - 3-dart average (501/301 only)
  - Highest single turn score (501/301 only)
  - Checkout score and remaining turns (501/301 only)
  - Marks per round (Cricket only)
  - Weighted accuracy (Number Focus only)
- [ ] Personal best comparison: metrics that beat the user's current PB are highlighted
- [ ] Summary screen provides two main navigation options: "New Game" (returns to GAME-01) and "Home" (returns to home screen)
- [ ] Session data is cleared from localStorage after successful server save
- [ ] If the server save fails (offline), the session is queued in IndexedDB for later sync (PROF-03)
- [ ] Offline save shows a "Saved offline — will sync when online" message
- [ ] Error handling gracefully informs the user if the save attempt fails and offers retry/offline options

---

## Technical Implementation Notes

- **CreateSessionCommand schema:**
  ```
  {
    gameMode: GameMode,
    startedAt: ISO8601 datetime,
    completedAt: ISO8601 datetime,
    player2Name?: string,
    configurationJson: ConfigurationJson,
    turns?: Turn[],
    cricketTurns?: CricketTurn[],
    dartEntries?: DartEntry[]
  }
  ```
- **CreateSessionCommandValidator:** Ensures GameMode IsInEnum, CompletedAt > StartedAt, and turns/dartEntries arrays are not empty for their respective modes
- **Angular:** Create `features/game/game-summary/` standalone component
  - Calls `POST /api/sessions` with the completed session
  - On offline: serialize session to IndexedDB queue using PROF-03 pattern; display "saved offline" toast
- **localStorage cleanup:** Clear the in-progress session key (e.g., `darts_companion_in_progress`) after successful save
- **Stats calculation:**
  - 3-dart average: total score ÷ turn count × 3
  - Highest turn: max score in turns array
  - Cricket marks per round: aggregate from CricketTurn entities
  - Number Focus weighted accuracy: (Triples×3 + Doubles×2 + Singles×1) ÷ (total darts × 3) × 100
- **Personal Best comparison:** Compare new session metrics against PersonalBest entity; highlight improvements

---

## Dependencies

- GAME-02 (501/301/Cricket score entry and turn recording)
- GAME-07 (Number Focus dart entry)
- PROF-03 (IndexedDB offline queue for session sync)
- Authentication service (for user context when saving)
- API client with POST /api/sessions endpoint

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — GameSession, Turn, CricketTurn, DartEntry, PersonalBest entities
- [Architecture](../../shared/architecture.md) — offline-first pattern, IndexedDB queue integration
- [API Contracts](../../shared/api-contracts.md) — CreateSessionCommand schema, POST /api/sessions endpoint
- [NFRs](../../shared/non-functional-requirements.md) — offline capability, error handling, accessibility
