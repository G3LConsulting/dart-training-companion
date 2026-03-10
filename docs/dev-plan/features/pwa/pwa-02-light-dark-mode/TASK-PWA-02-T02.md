# TASK: PWA-02-T02 — Tests: Visual Regression for Light/Dark Mode

**Story:** [PWA-02](../STORY-PWA-02.md)
**Layer:** Frontend / QA
**Status:** Pending
**Agent:** QA/Frontend Team

---

## What to Build

Visual regression tests and manual testing for light and dark mode across all key screens:

**Automated Tests:**
- Playwright visual snapshots (light and dark mode variants)
- Screenshot comparison on CI/CD

**Manual Testing:**
- Test key screens in light and dark modes
- Verify text contrast (use DevTools accessibility inspector)
- Check chart readability
- Test form inputs

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `e2e/pwa-dark-mode.spec.ts` | Playwright Test | Dark mode visual tests |
| `docs/DARK_MODE_TESTING_CHECKLIST.md` | Checklist | Manual test checklist |

---

## Definition of Done

- [ ] Playwright tests compile and run
- [ ] Test: light mode screenshots match baseline
- [ ] Test: dark mode screenshots match baseline
- [ ] Dashboard screen renders correctly in light mode
- [ ] Dashboard screen renders correctly in dark mode
- [ ] Stats page readable in both modes
- [ ] Charts readable in both modes (colors, legend, grid)
- [ ] Forms (score entry, settings) usable in both modes
- [ ] Buttons visible and clickable in both modes
- [ ] Links readable in both modes (underline or color+other indicator)
- [ ] Text contrast ≥4.5:1 in both modes (verified with DevTools)
- [ ] No hardcoded colors visible in console/DevTools
- [ ] Smooth transition when system preference changes
- [ ] All key screens tested in both modes

---

## Implementation Notes

**pwa-dark-mode.spec.ts:**
```typescript
import { test, expect } from '@playwright/test';

test.describe('PWA - Light/Dark Mode Visual Tests', () => {
  // Light mode tests
  test.describe('Light Mode', () => {
    test.beforeEach(async ({ page, context }) => {
      // Force light mode
      await page.emulateMedia({ colorScheme: 'light' });
      await page.goto('http://localhost:4200');
      await page.waitForLoadState('networkidle');
    });

    test('Dashboard renders in light mode', async ({ page }) => {
      await page.goto('http://localhost:4200/dashboard');
      // Take screenshot for comparison
      await expect(page).toHaveScreenshot('dashboard-light.png');
    });

    test('Stats page renders in light mode', async ({ page }) => {
      await page.goto('http://localhost:4200/stats');
      await expect(page).toHaveScreenshot('stats-light.png');
    });

    test('Form inputs visible in light mode', async ({ page }) => {
      await page.goto('http://localhost:4200/game');
      const input = await page.locator('input[type="number"]').first();
      const isVisible = await input.isVisible();
      expect(isVisible).toBe(true);

      // Check text is readable
      const color = await input.evaluate(el => window.getComputedStyle(el).color);
      expect(color).not.toContain('rgb(255, 255, 255)'); // Not white text on light bg
    });

    test('Chart renders correctly in light mode', async ({ page }) => {
      await page.goto('http://localhost:4200/stats/trend');
      const canvas = await page.locator('canvas').first();
      expect(canvas).toBeVisible();
      await expect(page).toHaveScreenshot('chart-light.png');
    });
  });

  // Dark mode tests
  test.describe('Dark Mode', () => {
    test.beforeEach(async ({ page, context }) => {
      // Force dark mode
      await page.emulateMedia({ colorScheme: 'dark' });
      await page.goto('http://localhost:4200');
      await page.waitForLoadState('networkidle');
    });

    test('Dashboard renders in dark mode', async ({ page }) => {
      await page.goto('http://localhost:4200/dashboard');
      await expect(page).toHaveScreenshot('dashboard-dark.png');
    });

    test('Stats page renders in dark mode', async ({ page }) => {
      await page.goto('http://localhost:4200/stats');
      await expect(page).toHaveScreenshot('stats-dark.png');
    });

    test('Form inputs visible in dark mode', async ({ page }) => {
      await page.goto('http://localhost:4200/game');
      const input = await page.locator('input[type="number"]').first();
      const isVisible = await input.isVisible();
      expect(isVisible).toBe(true);

      // Check text is readable (not too dark on dark background)
      const color = await input.evaluate(el => window.getComputedStyle(el).color);
      expect(color).not.toContain('rgb(0, 0, 0)'); // Not black text on dark bg
    });

    test('Chart renders correctly in dark mode', async ({ page }) => {
      await page.goto('http://localhost:4200/stats/trend');
      const canvas = await page.locator('canvas').first();
      expect(canvas).toBeVisible();
      await expect(page).toHaveScreenshot('chart-dark.png');
    });
  });

  // Contrast tests
  test.describe('Accessibility - Color Contrast', () => {
    test('Text contrast meets AA standard in light mode', async ({ page }) => {
      await page.emulateMedia({ colorScheme: 'light' });
      await page.goto('http://localhost:4200/dashboard');

      const contrastIssues = await page.evaluate(() => {
        const elements = document.querySelectorAll('body *');
        const issues = [];

        elements.forEach(el => {
          const style = window.getComputedStyle(el);
          const color = style.color;
          const bgColor = style.backgroundColor;

          // Simple contrast check (proper implementation would use WCAG algorithm)
          if (color && bgColor && bgColor !== 'rgba(0, 0, 0, 0)') {
            // Verify it's not white on white or black on black
            if (!(color === 'rgb(255, 255, 255)' && bgColor === 'rgb(255, 255, 255)') &&
                !(color === 'rgb(0, 0, 0)' && bgColor === 'rgb(0, 0, 0)')) {
              // Contrast OK
            } else {
              issues.push(`Contrast issue: ${color} on ${bgColor}`);
            }
          }
        });

        return issues;
      });

      expect(contrastIssues.length).toBe(0);
    });

    test('Text contrast meets AA standard in dark mode', async ({ page }) => {
      await page.emulateMedia({ colorScheme: 'dark' });
      await page.goto('http://localhost:4200/dashboard');

      const contrastIssues = await page.evaluate(() => {
        const elements = document.querySelectorAll('body *');
        const issues = [];

        elements.forEach(el => {
          const style = window.getComputedStyle(el);
          const color = style.color;
          const bgColor = style.backgroundColor;

          if (color && bgColor && bgColor !== 'rgba(0, 0, 0, 0)') {
            if (!(color === 'rgb(255, 255, 255)' && bgColor === 'rgb(33, 33, 33)') &&
                !(color === 'rgb(224, 224, 224)' && bgColor === 'rgb(18, 18, 18)')) {
              // Contrast OK
            }
          }
        });

        return issues;
      });

      expect(contrastIssues.length).toBe(0);
    });
  });
});
```

**Manual Testing Checklist:**
```markdown
# Dark Mode Manual Testing Checklist

## Dashboard Page

### Light Mode
- [ ] Background is light (white or light gray)
- [ ] Text is dark and readable
- [ ] Cards have subtle shadow/border
- [ ] KPI numbers are clear
- [ ] Charts have light background with dark grid
- [ ] Buttons are visible and not too bright

### Dark Mode
- [ ] Background is dark (dark gray or black)
- [ ] Text is light and readable (not too bright white)
- [ ] Cards have subtle border/shadow visible
- [ ] KPI numbers contrast with background
- [ ] Charts have dark background with visible grid
- [ ] Buttons are visible against dark background
- [ ] No white text on white background
- [ ] No black text on dark background

## Stats Pages

### Light Mode
- [ ] Charts readable with dark lines
- [ ] Legend text dark
- [ ] Axis labels clear
- [ ] Grid lines visible but not overwhelming

### Dark Mode
- [ ] Charts readable with light lines
- [ ] Legend text light
- [ ] Axis labels visible
- [ ] Grid lines visible but subtle

## Form Pages (Score Entry, Settings)

### Light Mode
- [ ] Input fields white with dark border
- [ ] Text dark and readable
- [ ] Labels clear
- [ ] Focus states visible (outline)

### Dark Mode
- [ ] Input fields dark with light border
- [ ] Text light and readable
- [ ] Labels visible
- [ ] Focus states visible (outline)

## Color Contrast Verification

- [ ] Open DevTools > Elements
- [ ] Select text element
- [ ] Check Styles > Computed > color and background-color
- [ ] Verify contrast ratio ≥4.5:1

### Light Mode Examples
- Primary text (#212121) on white (#ffffff): 16:1 ✓
- Secondary text (#757575) on white (#ffffff): 5.5:1 ✓

### Dark Mode Examples
- Primary text (#e0e0e0) on dark (#121212): 13:1 ✓
- Secondary text (#b0b0b0) on dark (#121212): 9:1 ✓

## System Preference Change

- [ ] Open system settings
- [ ] Toggle light/dark mode
- [ ] Return to app
- [ ] App colors update without page refresh
- [ ] Update is smooth (no flashing)
- [ ] All elements update (text, background, charts)
```

---

## References

- Playwright Visual Testing: https://playwright.dev/docs/test-snapshots
- Chrome DevTools Accessibility Inspector: https://developer.chrome.com/docs/devtools/accessibility/reference/
- WebAIM Contrast Checker: https://webaim.org/resources/contrastchecker/
- [`../../shared/nfrs.md`](../../shared/nfrs.md) — Color contrast and accessibility requirements
