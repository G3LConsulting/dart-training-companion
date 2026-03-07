# GAME-09 — Session Auto-Save & Resume

**Feature:** Score Tracking & Game Modes
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Automatic client-side persistence of in-progress game sessions to localStorage after every scored turn or dart. On app launch, if a saved session exists, the user is prompted to resume or discard it. This enables graceful handling of accidental app closures and network interruptions, providing a smooth continuity experience.

> Implements: FR-G-09, TA §3 (offline-first, localStorage for in-progress sessions)

---

## Acceptance Criteria

- [ ] After each turn is scored (501/301/Cricket) or each dart is entered (Number Focus), the full current game state is written to localStorage
- [ ] localStorage key used is consistently named (e.g., `darts_companion_in_progress`)
- [ ] Only one in-progress session per device is stored at a time (new session overwrites previous, if any)
- [ ] On app launch, if an in-progress session exists in localStorage, a resume/discard prompt is displayed
- [ ] Resume option: restores all game state including mode, configuration, all turns/darts so far, player turn indicator, and scores
- [ ] Discard option: clears the localStorage entry and allows user to proceed to home
- [ ] After game completion (GAME-04/GAME-08), the in-progress session is cleared from localStorage
- [ ] In-progress session data is local only (not synced to server) until the game is completed
- [ ] If a user force-quits or closes the browser, they can still resume on the next app launch
- [ ] Prompt is clear and offers equal weight to both resume and discard actions (no aggressive default)

---

## Technical Implementation Notes

- **localStorage persistence strategy:**
  - Key: `darts_companion_in_progress` (consistent across all game modes)
  - Value: JSON stringified object containing full session state
  - Written after every turn/dart via a game state service method
  - Cleared after session completion (via GAME-04/GAME-08 save handler)
- **In-progress session object structure:**
  ```
  {
    gameMode: GameMode,
    configurationJson: ConfigurationJson,
    turns?: Turn[],
    cricketTurns?: CricketTurn[],
    dartEntries?: DartEntry[],
    player2Name?: string,
    currentPlayerIndex: number,
    startedAt: ISO8601 datetime,
    savedAt: ISO8601 datetime,
    currentScore?: number,
    currentRemainingScore?: number (501/301 only)
  }
  ```
- **Angular implementation:**
  - Check for in-progress session in `AppComponent` or a route guard (e.g., home route guard)
  - On app initialization, query localStorage for `darts_companion_in_progress`
  - If found, display a modal or dialog with "Resume" and "Discard" buttons
  - Resume: load the session state into the game state service and navigate directly to the appropriate game screen (mode-501, cricket, nf-session, etc.)
  - Discard: remove localStorage entry and proceed normally
- **Game state service integration:**
  - Add a method `saveInProgressSession()` that stringifies and writes to localStorage
  - Add a method `loadInProgressSession()` that retrieves and parses from localStorage
  - Add a method `clearInProgressSession()` that removes the key
  - Call `saveInProgressSession()` after every turn/dart update (GAME-02, GAME-07)
  - Call `clearInProgressSession()` after successful server save (GAME-04, GAME-08)
- **Error handling:**
  - If localStorage read/write fails, log the error and proceed without persistence (degrade gracefully)
  - If the stored session is malformed, discard it and prompt user
- **Timing:**
  - Save is triggered synchronously after each turn/dart entry
  - Prompt check happens once at app initialization (in AppComponent or route guard)
  - Prompt appears before user navigates to home; no background syncing needed

---

## Dependencies

- GAME-02 (501/301/Cricket turn entry; calls saveInProgressSession after each turn)
- GAME-07 (Number Focus dart entry; calls saveInProgressSession after each dart)
- GAME-04 (501/301/Cricket game completion; calls clearInProgressSession)
- GAME-08 (Number Focus game completion; calls clearInProgressSession)
- Game state service (provides persistence methods)
- Angular AppComponent or router guards (for resume prompt at launch)
- localStorage API

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — GameSession, Turn, CricketTurn, DartEntry entities; GameMode enum; ConfigurationJson structure
- [Architecture](../../shared/architecture.md) — offline-first pattern, localStorage for session recovery, state management
- [API Contracts](../../shared/api-contracts.md) — Session entity schemas (Turn, CricketTurn, DartEntry)
- [NFRs](../../shared/non-functional-requirements.md) — offline capability, user experience (graceful degradation), accessibility
