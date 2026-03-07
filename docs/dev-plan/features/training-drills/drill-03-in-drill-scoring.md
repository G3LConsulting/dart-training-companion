# DRILL-03 — In-Drill Scoring & Guidance

**Feature:** Training Drills
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Step-by-step guided scoring during a drill. Each step shows instructions, accepts result input, and shows pass/fail for drills with outcomes.
> Implements: FA FR-T-03
> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria
- [ ] Step-by-step UI displays current step number and total steps
- [ ] Each step shows: instruction/prompt, input field(s) for result
- [ ] Result input accepted (numeric, pass/fail toggle, or other drill-specific format)
- [ ] Pass/fail indicator shown per step (if drill defines expected outcome)
- [ ] Cumulative running score displayed and updated after each step
- [ ] Undo functionality: previous step button with data rollback (1 level deep)
- [ ] Next step button disabled if current step invalid; error message shown
- [ ] Progress bar shows completion % based on step count
- [ ] Finish button shown on last step (replaces "Next")

---

## Technical Implementation Notes

**Backend:**
- DrillResult entity: { drillResultId, drillSessionId, stepResults: [{ stepNumber, input, passedStep: bool?, timestamp }], score: decimal, completedAt? }
- Drill steps defined in Drill.JsonSteps as serialised array: [{ stepNumber, instruction, expectedOutcome?, inputType }]
- Drilling-specific scoring logic handled per drill type (injectable strategy pattern)
- SaveDrillResultCommand handler: validates all steps, computes final score, creates DrillResult

**Angular:**
- Standalone component: features/drills/drill-scoring/
- Component state: { currentStepIndex, stepResults, runningScore, isUndoAvailable }
- Input component varies by drill type (numeric input, toggle, dropdown, etc.)
- Logic:
  - Display current step instruction from drill.steps[currentStepIndex]
  - Accept user input via appropriate input component
  - On Next: validate input, compute step score/pass status, update runningScore, increment currentStepIndex
  - On Undo: pop last result, decrement currentStepIndex, rollback runningScore
  - Undo button enabled only if stepResults.length > 1
  - On Finish (last step): POST SaveDrillResultCommand with all stepResults
- Drill-type strategy: load appropriate input component based on drill category/type
- Responsive: full-width on mobile, centered card on desktop
- Navigation: beforeUnload warning if user tries to leave mid-drill

---

## Dependencies
- Depends on DRILL-02 (drill session context)
- Requires drill-specific scoring strategies
- Uses DrillResult entity

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — DrillSession, Drill, DrillResult entities
- [Architecture](../../shared/architecture.md) — Strategy pattern for drill-specific scoring, Command handler pattern
- [API Contracts](../../shared/api-contracts.md) — POST /api/drills/{drillSessionId}/results endpoint
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive inputs), step validation in <500ms
