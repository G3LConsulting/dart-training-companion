# TASK: PWA-01-T03 — Tests: Offline Functionality Smoke Tests

**Story:** [PWA-01](../STORY-PWA-01.md)
**Layer:** Frontend / QA
**Status:** Pending
**Agent:** QA/Frontend Team

---

## What to Build

Smoke tests and manual testing checklist for offline functionality and PWA installability:

**Automated Tests (Playwright):**
- Service worker registration
- Cache asset verification
- Network interception for offline simulation
- Offline indicator display
- Score entry offline persistence

**Manual Testing Checklist:**
- Install app on mobile (iOS/Android) and desktop (Windows/Mac)
- Launch app in standalone mode
- Test offline: disable network, verify features work
- Test sync: enable network, verify data syncs
- Verify Lighthouse PWA score ≥90

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `e2e/pwa-offline.spec.ts` | Playwright Test | Offline functionality tests |
| `e2e/pwa-manifest.spec.ts` | Playwright Test | Manifest and installability tests |
| `docs/PWA_TESTING_CHECKLIST.md` | Documentation | Manual testing checklist |

---

## Definition of Done

- [ ] Playwright tests compile and run
- [ ] Test: service worker registers successfully
- [ ] Test: static assets cached (app shell, CSS, JS)
- [ ] Test: offline indicator appears when offline
- [ ] Test: score entry works offline (without network)
- [ ] Test: history visible offline
- [ ] Test: stats loaded from cache offline
- [ ] Test: export button disabled with tooltip offline
- [ ] Test: leaderboard disabled offline
- [ ] Manual test: app installable on Chrome (Linux/Windows)
- [ ] Manual test: app installable on Safari (iOS)
- [ ] Manual test: app launches in standalone mode (no browser UI)
- [ ] Manual test: Lighthouse PWA score ≥90
- [ ] Manual test: offline mode: disable network in DevTools, app still functional
- [ ] Manual test: online mode: enable network, data syncs

---

## Implementation Notes

**pwa-offline.spec.ts:**
```typescript
import { test, expect } from '@playwright/test';

test.describe('PWA - Offline Functionality', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:4200');
    // Wait for service worker to register
    await page.waitForFunction(() => navigator.serviceWorker.controller);
  });

  test('Service worker registers successfully', async ({ page }) => {
    const swRegistered = await page.evaluate(() => {
      return navigator.serviceWorker.controller !== null;
    });
    expect(swRegistered).toBe(true);
  });

  test('Offline indicator displays when offline', async ({ page }) => {
    // Simulate offline
    await page.context().setOffline(true);
    await page.waitForSelector('.offline-indicator', { timeout: 5000 });
    const offlineIndicator = await page.locator('.offline-indicator').isVisible();
    expect(offlineIndicator).toBe(true);

    // Back online
    await page.context().setOffline(false);
    await page.waitForSelector('.offline-indicator:not(:visible)', { timeout: 5000 });
  });

  test('Score entry works offline', async ({ page }) => {
    // Load app, navigate to score entry
    await page.goto('http://localhost:4200/game');

    // Go offline
    await page.context().setOffline(true);

    // Enter score
    await page.fill('input[placeholder="Target"]', '20');
    await page.fill('input[placeholder="Multiplier"]', '3');
    await page.click('button:has-text("Record Dart")');

    // Verify dart recorded
    const dartList = await page.locator('.dart-item').count();
    expect(dartList).toBeGreaterThan(0);
  });

  test('History visible offline from cache', async ({ page }) => {
    // Load app, navigate to history
    await page.goto('http://localhost:4200/stats/history');

    // Allow time for cache
    await page.waitForTimeout(1000);

    // Go offline
    await page.context().setOffline(true);

    // Refresh page
    await page.reload();

    // Verify history loaded
    const historyItems = await page.locator('.history-item').count();
    expect(historyItems).toBeGreaterThan(0);
  });

  test('Export button disabled offline', async ({ page }) => {
    await page.goto('http://localhost:4200/profile');
    await page.context().setOffline(true);

    const exportButton = await page.locator('button:has-text("Export Data")');
    const isDisabled = await exportButton.isDisabled();
    expect(isDisabled).toBe(true);
  });

  test('Static assets cached', async ({ page, context }) => {
    // Clear cache
    await context.clearCookies();

    // First load (populate cache)
    await page.goto('http://localhost:4200');
    await page.waitForLoadState('networkidle');

    // Get asset requests
    const assetRequests = [];
    page.on('request', request => {
      if (request.resourceType() === 'stylesheet' ||
          request.resourceType() === 'script' ||
          request.resourceType() === 'image') {
        assetRequests.push(request.url());
      }
    });

    // Go offline and reload
    await context.setOffline(true);
    await page.reload();

    // Verify app still loads
    const appRoot = await page.locator('app-root');
    expect(appRoot).toBeDefined();
  });
});
```

**pwa-manifest.spec.ts:**
```typescript
import { test, expect } from '@playwright/test';

test.describe('PWA - Manifest & Installability', () => {
  test('Manifest file exists and is valid', async ({ page }) => {
    const response = await page.goto('http://localhost:4200/manifest.webmanifest');
    expect(response?.status()).toBe(200);

    const manifest = await response?.json();
    expect(manifest.name).toBe('Darts Companion');
    expect(manifest.short_name).toBe('Darts');
    expect(manifest.display).toBe('standalone');
    expect(manifest.start_url).toBe('/');
    expect(manifest.icons).toBeDefined();
    expect(manifest.icons.length).toBeGreaterThan(0);
  });

  test('App shell includes manifest link', async ({ page }) => {
    await page.goto('http://localhost:4200');
    const manifestLink = await page.locator('link[rel="manifest"]');
    expect(manifestLink).toBeDefined();
  });

  test('Icons are accessible', async ({ page }) => {
    const response = await page.goto('http://localhost:4200/assets/icons/icon-192x192.png');
    expect(response?.status()).toBe(200);

    const response512 = await page.goto('http://localhost:4200/assets/icons/icon-512x512.png');
    expect(response512?.status()).toBe(200);
  });

  test('Service worker file is accessible', async ({ page }) => {
    const response = await page.goto('http://localhost:4200/ngsw-worker.js');
    expect(response?.status()).toBe(200);
  });
});
```

**Manual Testing Checklist:**
```markdown
# PWA Manual Testing Checklist

## Desktop (Chrome/Edge on Windows/Mac)

- [ ] Open app in Chrome DevTools
- [ ] Navigate to Application > Manifest
- [ ] Verify manifest displays:
  - Name: "Darts Companion"
  - Display: "standalone"
  - Icons: 2 icons (192×192, 512×512)
- [ ] Click "Install app" button (should appear in address bar)
- [ ] App installs to Start Menu / Applications folder
- [ ] Launch installed app
- [ ] App opens in standalone mode (no browser UI)
- [ ] Address bar absent
- [ ] Window title shows "Darts Companion"

## Mobile (Chrome on Android / Safari on iOS)

### Android
- [ ] Open app in Chrome
- [ ] Tap menu (three dots) > "Install app"
- [ ] App installs to home screen
- [ ] Open installed app from home screen
- [ ] App launches in fullscreen (no browser chrome)
- [ ] Back button navigates within app
- [ ] Touch targets ≥44px

### iOS
- [ ] Open app in Safari
- [ ] Tap Share > Add to Home Screen
- [ ] App added to home screen with icon
- [ ] Open app from home screen
- [ ] App launches fullscreen (no Safari UI)
- [ ] Home indicator visible at bottom (system)

## Offline Testing

- [ ] Connected, app loads normally
- [ ] Open DevTools > Network tab
- [ ] Check "Offline" checkbox
- [ ] Refresh page
- [ ] App loads from service worker cache
- [ ] Offline indicator displays: "You are offline..."
- [ ] Score entry works offline:
  - Enter target, multiplier, score
  - Click "Record Dart"
  - Dart appears in list
- [ ] History visible and scrollable
- [ ] Stats show cached data
- [ ] Export button disabled with tooltip
- [ ] Sharing buttons disabled
- [ ] Leaderboards show message: "Offline"
- [ ] Uncheck "Offline" checkbox
- [ ] Online indicator disappears
- [ ] Data syncs if any offline entries exist

## Lighthouse PWA Audit

- [ ] Open DevTools > Lighthouse
- [ ] Select "PWA"
- [ ] Run audit
- [ ] Score ≥90
- [ ] All PWA criteria pass:
  - [ ] Is not an error page
  - [ ] Registers a service worker
  - [ ] Has a manifest for add to home screen
  - [ ] Manifest start URL is valid
  - [ ] Configured for a custom splash screen
  - [ ] Address bar matches brand colors
  - [ ] Displays correctly on portrait and landscape
  - [ ] Works when offline (or on slow connection)
  - [ ] Page transitions don't feel like they block on the network
  - [ ] Each page has a descriptive title
  - [ ] Links don't open external sites in same tab
  - [ ] Uses HTTPS
```

---

## References

- Playwright: https://playwright.dev/
- Service Worker API: https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API
- Lighthouse PWA Audit: https://web.dev/lighthouse-pwa/
- [`../../shared/nfrs.md`](../../shared/nfrs.md) — Offline testing and PWA requirements
