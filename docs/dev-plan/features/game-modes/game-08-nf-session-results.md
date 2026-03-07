# GAME-08 — Number Focus: Session Results & Stats

**Feature:** Score Tracking & Game Modes
**Phase:** MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context

Results and statistics screen displayed after a Number Focus session completes. Shows a detailed breakdown of hit outcomes, calculated accuracy metrics, and personal best comparison. The session is automatically saved to the server at this stage.

> Implements: FR-G-08, TA §5 (DartEntry, PersonalBest entities), TA §6 (CreateSessionCommand)

---

## Acceptance Criteria

- [ ] Hit breakdown section displays:
  - Count and percentage for Triples, Doubles, Singles, and Misses
  - Example: "Triples: 12 (24%)"
- [ ] Accuracy % = (hit darts ÷ total darts) × 100, displayed as a primary metric (e.g., "87.5% Accuracy")
- [ ] Weighted accuracy = (Triples×3 + Doubles×2 + Singles×1) ÷ (total darts × 3) × 100, displayed as secondary metric (e.g., "Weighted: 65.2%")
- [ ] Personal best comparison displays for this target number:
  - Show if accuracy beats the user's previous PB for this number
  - Show if weighted accuracy beats the user's previous PB for this number
  - Highlight new PBs with visual emphasis
- [ ] Session is automatically saved via POST /api/sessions with dartEntries[] included
- [ ] Navigation options include:
  - "Train Again" (restart with the same target number and dart count)
  - "New Number" (return to GAME-06 setup)
  - "Home" (return to home screen)
- [ ] If offline, session is queued for later sync; "saved offline" message is displayed
- [ ] Error handling gracefully informs user if save fails and offers retry option

---

## Technical Implementation Notes

- **Angular:** Create standalone component `features/game/number-focus/nf-results/`
  - Display hit breakdown with counts and percentages
  - Show accuracy and weighted accuracy prominently
  - Include PB comparison section
  - Provide navigation buttons to home, retry, or new number
- **Accuracy calculations:**
  - Accuracy % = (count of Triple + Double + Single) ÷ total darts × 100
  - Weighted accuracy = (Triples×3 + Doubles×2 + Singles×1) ÷ (total darts × 3) × 100
  - Format to 1 decimal place (e.g., "87.5%")
- **CreateSessionCommand for Number Focus:**
  ```
  {
    gameMode: "NumberFocus",
    startedAt: ISO8601 datetime,
    completedAt: ISO8601 datetime,
    configurationJson: {
      targetNumber: number | "bull",
      dartCount: number
    },
    dartEntries: DartEntry[]
  }
  ```
- **PersonalBest comparison:**
  - MetricKey format: `nf_accuracy_{number}` and `nf_weighted_accuracy_{number}`
  - Examples: `nf_accuracy_20`, `nf_weighted_accuracy_bull`, `nf_accuracy_15`
  - Query existing PersonalBest for this user and target number
  - If new accuracy > old accuracy, highlight and display "New PB!"
  - If new weighted accuracy > old weighted accuracy, highlight and display "New Weighted PB!"
- **Session save logic:**
  - Call POST /api/sessions with CreateSessionCommand
  - On offline: queue to IndexedDB using PROF-03 pattern; display "saved offline" toast
  - On success: clear localStorage in-progress session
- **Navigation:**
  - "Train Again": reload GAME-07 with same config (dartCount, targetNumber)
  - "New Number": navigate to GAME-06
  - "Home": navigate to home route

---

## Dependencies

- GAME-07 (DartEntry array collected during session)
- GAME-04 pattern (session save logic, POST /api/sessions, offline queue)
- PROF-03 (IndexedDB offline queue for session sync)
- Authentication service (for user context when saving)
- PersonalBest domain model and lookup service

---

## Shared References

- [Domain Model](../../shared/domain-model.md) — DartEntry, GameSession, PersonalBest entities; GameMode enum
- [Architecture](../../shared/architecture.md) — offline-first pattern, IndexedDB queue integration
- [API Contracts](../../shared/api-contracts.md) — CreateSessionCommand schema, POST /api/sessions endpoint
- [NFRs](../../shared/non-functional-requirements.md) — offline capability, error handling, accessibility
