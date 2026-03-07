# DRILL-01 — Drill Library

**Feature:** Training Drills
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
A browsable library of pre-defined drills organised by category (Accuracy, Scoring Power, Checkout) and difficulty (Beginner/Intermediate/Advanced). Available offline.
> Implements: FA FR-T-01
> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria
- [ ] Drills browsable in library view with search/filter options
- [ ] Drills organised by category: Accuracy, Scoring Power, Checkout (extensible for future categories)
- [ ] Drills organised by difficulty: Beginner, Intermediate, Advanced
- [ ] Each drill displays: name, description, methodology reference, difficulty badge, estimated duration
- [ ] Category and difficulty filters work independently and in combination
- [ ] Drill library available offline via service worker caching
- [ ] Drill metadata seeded or bundled as JSON (pre-defined drills)
- [ ] "Start Drill" action navigates to DRILL-02
- [ ] Search functionality (by name or description)

---

## Technical Implementation Notes

**Backend:**
- New entities: Drill (predefined) and CustomDrill (user-created)
- Drill entity: { drillId, name, description, category: enum (Accuracy, ScoringPower, Checkout), difficulty: enum (Beginner, Intermediate, Advanced), methodology: string, estimatedDuration: int (minutes), jsonSteps: string (serialised steps array) }
- Drill data seeded via EF Core data seeding or bundled as JSON file deployed with app
- API: GET /api/drills/library → { drills: [{ drillId, name, description, category, difficulty, methodology, estimatedDuration }] }
- Custom drills merged at query layer (GetDrillsQuery) to show both predefined + user's CustomDrills

**Angular:**
- Standalone component: features/drills/drill-library/
- Layout: grid of drill cards (2 columns on desktop, 1 on mobile)
- Drill card: image/icon, name, description excerpt, difficulty badge (color-coded), category tag, "Start" button
- Filters panel: checkboxes for category and difficulty, search input
- Search: client-side filter on name + description (or call GET /api/drills/library?search=term for server-side)
- Offline support: cache drill library JSON in service worker on first load
- "Start Drill" click: emit drillSelected event; parent router navigates to /drills/{drillId}/session (DRILL-02)

---

## Dependencies
- No MVP dependencies (post-MVP feature)
- Requires Drill entity design and data seeding strategy

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — Drill and CustomDrill entities, Category and Difficulty enums
- [Architecture](../../shared/architecture.md) — Query handler pattern, offline caching via service worker
- [API Contracts](../../shared/api-contracts.md) — GET /api/drills/library endpoint, DrillLibraryDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §13 (offline capability), drill library loads in <2s
