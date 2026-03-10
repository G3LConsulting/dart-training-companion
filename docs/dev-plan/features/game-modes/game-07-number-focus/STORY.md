# GAME-07 — Number Focus Session

## Metadata
- **Story:** GAME-07
- **Feature:** Score Tracking & Game Modes
- **Phase:** MVP
- **Status:** Planned
- **Agent:** Angular (Frontend)
- **Output:** Setup component, session component, results component, state service, unit tests
- **Notes:** Accuracy-focused drill mode; measures consistency on specific numbers

## Context
Implements:
- FA §FR-G-06 (Number Focus setup)
- FA §FR-G-07 (Dart entry and live feedback)
- FA §FR-G-08 (Results and personal best comparison)

## Acceptance Criteria
- [ ] User selects target number (1–20 or Bull) and dart count (10–200, increments of 10, default 50)
- [ ] Per-dart entry via 4 large buttons: Triple, Double, Single, Miss
- [ ] Screen shows: target number, dart counter (X/Y), running hit breakdown, accuracy %
- [ ] Last dart entry can be undone
- [ ] Session ends automatically when dart counter reaches set size
- [ ] Results show: breakdown (counts + percentages), accuracy %, weighted accuracy %
- [ ] Weighted accuracy: (Triple_count*3 + Double_count*2 + Single_count*1) / (Total_darts*3) * 100
- [ ] Comparison to personal best (accuracy and weighted accuracy) for this specific target number
- [ ] Data persisted: date, target, set size, counts (T/D/S/M), accuracy, weighted accuracy
- [ ] UI responsive and accessible; large touch targets

## Tasks

| Task ID | Title | Status |
|---------|-------|--------|
| T01 | Frontend: Number Focus setup component | Planned |
| T02 | Frontend: Number Focus in-session component | Planned |
| T03 | Frontend: Number Focus results component | Planned |
| T04 | Frontend: Number Focus game state service | Planned |
| T05 | Tests: Number Focus logic tests | Planned |

## Dependencies
- **GAME-01:** Game setup, GAME-04:** Session saving

## Shared References
- [Architecture](../../shared/ARCHITECTURE.md) — Angular component and service patterns
- [Domain Model](../../shared/DOMAIN-MODEL.md) — GameSession, DartEntry, DartOutcome entities
- [API Contracts](../../shared/API-CONTRACTS.md) — POST /api/sessions
