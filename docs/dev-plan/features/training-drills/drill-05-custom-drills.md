# DRILL-05 — Custom Drills

**Feature:** Training Drills
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Users can define their own drills with a name, target, and goal, saved under "My Drills" in their profile.
> Implements: FA FR-T-05
> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria
- [ ] "Create Drill" form available (button in drill library or profile drills section)
- [ ] Form fields: drill name, description, target score, goal description
- [ ] Validation: name required, target must be positive number, description optional
- [ ] Custom drills saved under "My Drills" section in profile
- [ ] Custom drills appear in drill library with "Custom" badge
- [ ] Each custom drill shows: name, description, target, edit + delete actions
- [ ] Edit functionality: form pre-fills with existing drill data, updates on save
- [ ] Delete functionality: confirmation dialog, removes drill from user's list
- [ ] Custom drills start from same DRILL-02 flow as predefined drills

---

## Technical Implementation Notes

**Backend:**
- New entity: CustomDrill { customDrillId, userId, name, description, targetScore: decimal, goal: string, createdAt, modifiedAt, isDeleted: bool }
- Unique constraint: (userId, name) to prevent duplicate names per user
- CreateCustomDrillCommand handler: validates input, creates CustomDrill, returns CustomDrillDto
- UpdateCustomDrillCommand handler: validates ownership, updates fields, soft-delete support
- DeleteCustomDrillCommand handler: soft-delete or permanent delete with confirmation
- GetMyDrillsQuery handler: loads all non-deleted CustomDrills for user
- Merge logic in GetDrillsQuery: union of predefined Drills + user's CustomDrills
- API endpoints:
  - POST /api/drills/custom → CreateCustomDrillCommand
  - PUT /api/drills/custom/{customDrillId} → UpdateCustomDrillCommand
  - DELETE /api/drills/custom/{customDrillId} → DeleteCustomDrillCommand
  - GET /api/drills/my-drills → GetMyDrillsQuery

**Angular:**
- Standalone component: features/drills/custom-drill-form/ (create/edit shared form)
- Route: /drills/custom/new (create), /drills/custom/{customDrillId}/edit (edit)
- Form fields:
  - name (text input, required)
  - description (textarea, optional)
  - targetScore (number input, required, min > 0)
  - goal (textarea, optional)
- Submit button: creates or updates via API
- Cancel button: navigates back to profile or drill library
- Error handling: validation messages, network errors
- Standalone component: features/profile/my-drills-section/ (lists user's custom drills)
- List displays: drill name, description excerpt, target, edit + delete action buttons
- Delete action: confirmation modal before submission
- Edit action: navigates to custom-drill-form with pre-filled data
- Integration in drill library (DRILL-01): add "My Drills" filter tab; show custom drills with "Custom" badge; "Create" button below list

---

## Dependencies
- Depends on DRILL-01 (drill library integration)
- Depends on PROF-01 (user profile context)
- Requires CustomDrill entity

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — CustomDrill entity, user ownership model
- [Architecture](../../shared/architecture.md) — Command handler pattern, soft-delete pattern
- [API Contracts](../../shared/api-contracts.md) — POST/PUT/DELETE /api/drills/custom endpoints, CustomDrillDto schema
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive form), form submission in <2s
