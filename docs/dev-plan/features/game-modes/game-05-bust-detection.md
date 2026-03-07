# GAME-05 — Bust & Rule Enforcement (501/301)

**Feature:** Score Tracking & Game Modes
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Automatic detection and enforcement of bust rules in 501 and 301 games. When a turn would result in a score below 1, a score of exactly 1, or (if double-out is enabled) a finish not on a double, the turn is voided as a bust, the score reverts, and a clear "Bust!" notification is displayed. The busted turn is still recorded for statistics purposes.

> Implements: FR-G-05, TA §5 (Turn.IsBust field)

---

## Acceptance Criteria

- [ ] Score drops below 1 after a turn → automatically marked as bust; score reverts to pre-turn value
- [ ] Score equals exactly 1 after a turn (impossible to finish on 1) → automatically marked as bust; score reverts
- [ ] If double-out rule is enabled in configuration: finishing on a non-double (single or triple) → automatically marked as bust; score reverts
- [ ] "Bust!" notification displayed prominently (e.g., toast, overlay, or in-line alert) immediately after bust detection
- [ ] Busted turn is recorded with `IsBust=true` in the Turn entity (persisted for historical/statistical purposes)
- [ ] Turn history and undo (GAME-02) continue to function correctly after a bust
- [ ] Bust detection logic runs synchronously within 100ms (NFR)
- [ ] Error messages clearly explain why the turn was busted (e.g., "Bust! Score would be 0.")

---

## Technical Implementation Notes

- **Angular:** Bust detection logic implemented in the game state service or score-entry component logic
  - Check runs immediately on score submission (before updating the Turn array)
  - Validation order: (1) score < 1, (2) score == 1, (3) double-out rule (if enabled)
- **Turn entity field:** `IsBust: boolean` flagged in the Turn payload
  - Busted turns still added to the turns[] array (for stats/undo), but marked IsBust=true
  - Score field remains unchanged (pre-bust value), or capture pre-turn value separately for undo
- **Double-out rule check:** Read `ConfigurationJson.doubleIn` to determine if rule applies
  - On finish (score = 0 after turn), verify the last dart was a double
  - If not a double and doubleIn=true, mark as bust
- **UI/UX:**
  - Display bust notification with visual emphasis (red color, icon, animation)
  - Include an explanatory message ("Score cannot be 0 after a non-double" or similar)
  - Maintain score board state (don't clear it; keep visual feedback of what was entered)
- **Performance:** Validation must complete within 100ms to avoid noticeable lag

---

## Dependencies

- GAME-02 (Score entry component and Turn state management)
- Game state service
- ConfigurationJson structure (from GAME-01)

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — Turn entity, GameMode enum, ConfigurationJson structure
- [Architecture](../../shared/architecture.md) — game state management, validation patterns
- [API Contracts](../../shared/api-contracts.md) — Turn entity schema (IsBust field)
- [NFRs](../../shared/non-functional-requirements.md) — 100ms response time, accessibility (error messaging)
