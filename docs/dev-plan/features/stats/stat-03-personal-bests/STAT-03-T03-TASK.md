# STAT-03-T03 — Frontend: Personal Bests View + Notification

**Story:** [STAT-03](../STAT-03-STORY.md)
**Layer:** Frontend (Angular)
**Status:** Not Started
**Assigned To:** —
**Complexity:** M

---

## What to Build

Create personal bests view component displaying PBs grouped by game mode. Also create toast notification component to show congratulations when a new PB is achieved during gameplay.

---

## Files to Create/Modify

| Path | Purpose | Status |
|------|---------|--------|
| `src/app/features/stats/personal-bests/personal-bests.component.ts` | Main view component | To Create |
| `src/app/features/stats/personal-bests/personal-bests.component.html` | Template | To Create |
| `src/app/features/stats/personal-bests/personal-bests.component.scss` | Styles | To Create |
| `src/app/shared/components/pb-notification/pb-notification.component.ts` | Toast notification component | To Create |
| `src/app/core/api/stats-api.service.ts` | Add getPersonalBests method | To Modify |

---

## Implementation Notes

### PersonalBestsComponent

- Fetch PBs on init
- Display grouped by game mode
- Show metric type and value
- Show achievement date
- Mobile-friendly list layout

### PBNotificationComponent

Toast notification showing:
- Congratulations message
- New PB value
- Metric type and game mode
- Auto-dismiss after 5 seconds

Use Angular Material Snackbar or custom toast service.

---

## Definition of Done

- [ ] Personal bests view created and responsive
- [ ] PBs grouped by game mode correctly
- [ ] Toast notification appears on new PB
- [ ] Notification auto-dismisses
- [ ] Mobile-friendly layout
- [ ] Data binding working
- [ ] Error states handled
- [ ] Unit tests verify component logic
- [ ] No console errors or warnings

---

## References

- [Angular Material Snackbar](https://material.angular.io/components/snackbar/overview)
- [Toast Notifications](../../../shared/FRONTEND-PATTERNS.md#toast-notifications)
