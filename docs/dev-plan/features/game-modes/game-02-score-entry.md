# GAME-02 — In-Game Score Entry (501/301/Cricket)

**Feature:** Score Tracking & Game Modes
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Core score input UI for 501, 301, and Cricket modes. Supports both aggregate turn entry (numeric keypad for total turn score) and segment-by-segment entry (individual dart notation). Users can toggle between entry modes, and one-level undo is always available to revert the last scored turn.

> Implements: FR-G-02, TA §5 (Turn, CricketTurn entities), TA §4 (shared/components/score-input/)

---

## Acceptance Criteria

- [ ] Numeric keypad mode: user can enter 0–180 per turn; validation prevents out-of-rule-range scores
- [ ] Segment-by-segment mode: user enters each dart as `<multiplier><number>` (e.g., D20, T15, S5); validates legal dart ranges
- [ ] Toggle between entry modes is available and persists for the duration of the session
- [ ] Current score, remaining score, and player turn indicator are always visible and update in real time
- [ ] One-level undo button reverts the last scored turn and restores the previous game state
- [ ] Cricket mode: marks per number (15–20, Bull) are tracked and displayed per turn; points scored on open numbers are shown
- [ ] Score entry responds to user input within 100ms (NFR)
- [ ] Game state is persisted to localStorage after each turn (foundation for GAME-09 auto-save)
- [ ] Form validation prevents invalid entries (negative scores, out-of-range values, etc.)

---

## Technical Implementation Notes

- **Angular:** `features/game/mode-501/`, `mode-301/`, and `cricket/` directories each use the shared `shared/components/score-input/` component
- **State Management:** Turn data stored in a component-level state array; written to localStorage via GAME-09 logic after each turn
- **Turn entity shape:**
  ```
  {
    turnNumber: number,
    playerIndex: 0|1,
    score: number,
    remainingScore: number,
    isBust: boolean
  }
  ```
- **CricketTurn entity shape:**
  ```
  {
    turnNumber: number,
    playerIndex: 0|1,
    marksN15: number,
    marksN16: number,
    marksN17: number,
    marksN18: number,
    marksN19: number,
    marksN20: number,
    marksBull: number,
    pointsScored: number
  }
  ```
- **Performance:** Input validation and turn processing must complete within 100ms to meet NFR
- **Undo:** Maintain a single previous turn state; clicking undo pops from history and restores the board

---

## Dependencies

- GAME-01 (Game configuration established)
- Angular framework, reactive forms
- Game state service
- localStorage API (for GAME-09 integration)

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — Turn, CricketTurn, GameSession entities
- [Architecture](../../shared/architecture.md) — offline-first pattern, state management
- [API Contracts](../../shared/api-contracts.md) — Turn/CricketTurn payload structures
- [NFRs](../../shared/non-functional-requirements.md) — 100ms response time, accessibility (WCAG 2.1 AA)
