# LEAD-04 — Sharing Stats & Achievements

**Feature:** Leaderboards
**Phase:** Post-MVP
**Status:** 🔲 Not started
**Agent:** —
**Output:** —
**Notes:** —

---

## Context
Generate shareable image cards for weekly summaries, personal bests, and drill results using the Web Share API.
> Implements: FA FR-L-04
> ⚠️ This story is Post-MVP and should not be started until MVP is complete and approved.

---

## Acceptance Criteria
- [ ] "Share" button available on: weekly summary card (STATS-06), personal bests (STATS-03), drill results (DRILL-04)
- [ ] Share action generates branded image card (canvas or SVG)
- [ ] Image card includes: metric value, date, user display name, app branding (logo + name)
- [ ] Uses Web Share API (navigator.share) for native sharing (iOS/Android)
- [ ] Fallback for unsupported browsers: copy link to clipboard or open share dialog modal
- [ ] Generated image can be downloaded or shared to social media / messaging apps
- [ ] Image filename: {type}_{date}_{displayName}.png (e.g. weekly_2025-03-07_john.png)

---

## Technical Implementation Notes

**Backend:**
- No backend generation required if images created client-side via Canvas API
- Optional: if server-side generation preferred, create ImageGenerationService endpoint
  - POST /api/share/generate → { type: 'weekly'|'pb'|'drill', data: {...} } → returns PNG blob URL
  - Use SkiaSharp or ImageSharp library for image generation on server
- For MVP (client-side): skip server generation; generate on client

**Angular:**
- Standalone component: shared/sharing/share-card-generator/
- Integration points:
  - features/stats/weekly-summary-card/ adds "Share" button
  - features/stats/personal-bests/ adds "Share" per PB
  - features/drills/drill-results/ adds "Share" button
- Share flow:
  - Click "Share" → call ShareCardGeneratorService.generateCard({ type, data })
  - Generate canvas image with:
    - App logo (top-left)
    - Metric value (large, center)
    - Metric label (below value)
    - Date (bottom-right)
    - Display name (bottom-left)
    - App name + branding (footer bar with brand color)
  - Set canvas background to gradient (app brand colors)
  - Use HTML2Canvas library or native Canvas API
- Export flow:
  - Convert canvas to Blob via canvas.toBlob()
  - Create File object: new File([blob], filename, { type: 'image/png' })
  - Call navigator.share({ title, text, files: [file] })
  - Catch: if unsupported, show fallback (download button or copy link)
- Fallback for unsupported browsers:
  - Download button: generate anchor tag with blob URL; trigger click
  - Copy link: create shareable URL (e.g. /achievements/{type}/{id}); copy to clipboard
- Responsive: canvas size adapts to device (1080x1920 on mobile, 1200x630 on desktop share card)

---

## Dependencies
- Depends on STATS-06 (weekly summary integration)
- Depends on STATS-03 (personal bests integration)
- Depends on DRILL-04 (drill results integration)
- Requires HTML2Canvas or Canvas API for image generation
- Requires Web Share API support (or fallback strategy)

---

## Shared References
- [Domain Model](../../shared/domain-model.md) — Weekly summary, PersonalBest, DrillResult data structures
- [Architecture](../../shared/architecture.md) — Service pattern for image generation, Web Share API wrapper
- [API Contracts](../../shared/api-contracts.md) — Optional: POST /api/share/generate endpoint for server-side generation
- [NFRs](../../shared/non-functional-requirements.md) — §12.1 (responsive share cards), image generation in <2s, Web Share API required (graceful fallback)
