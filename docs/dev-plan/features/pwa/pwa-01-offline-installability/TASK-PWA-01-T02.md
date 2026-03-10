# TASK: PWA-01-T02 — Frontend: PWA Manifest Configuration & App Shell

**Story:** [PWA-01](../STORY-PWA-01.md)
**Layer:** Frontend
**Status:** Pending
**Agent:** Frontend Team

---

## What to Build

Configure PWA manifest and app shell for installability on Chrome, Safari, and other browsers:

**manifest.webmanifest:**
- App name: "Darts Companion"
- Short name: "Darts"
- Display mode: "standalone" (hide browser UI)
- Theme color: primary app color
- Background color: white/light
- Icons: 192×192 and 512×512 PNG images
- Start URL: "/" (root path)
- Scope: "/" (entire app)

**App Shell Integration:**
- Link manifest in index.html head
- Register service worker in main.ts
- Add offline indicator component to app shell
- Add meta viewport tag for mobile viewport

---

## Files

| File Path | Type | Purpose |
|-----------|------|---------|
| `src/manifest.webmanifest` | Manifest | PWA manifest configuration |
| `src/assets/icons/icon-192x192.png` | Image | App icon 192×192 |
| `src/assets/icons/icon-512x512.png` | Image | App icon 512×512 |
| `src/index.html` | HTML | Link manifest, meta tags |
| `src/main.ts` | TypeScript | Service worker registration |
| `src/app/app.component.ts` | Component | Offline indicator logic |

---

## Definition of Done

- [ ] manifest.webmanifest created with all required fields
- [ ] App name: "Darts Companion"
- [ ] Short name: "Darts"
- [ ] Display: "standalone"
- [ ] Icons: 192×192 and 512×512 present and readable
- [ ] Theme color set to primary app color (e.g., #1976d2)
- [ ] Background color set to white or light color
- [ ] Start URL: "/"
- [ ] Scope: "/"
- [ ] index.html links manifest: `<link rel="manifest" href="/manifest.webmanifest">`
- [ ] index.html includes viewport meta tag: `<meta name="viewport" content="width=device-width, initial-scale=1">`
- [ ] index.html includes theme-color meta tag
- [ ] main.ts registers service worker: `platformBrowserDynamic().bootstrapModule(AppModule)`
- [ ] App shell displays offline indicator when navigator.onLine = false
- [ ] Offline indicator shows clear message: "You are offline. Some features are unavailable."
- [ ] Lighthouse PWA audit passes (≥90 score on Chrome DevTools)
- [ ] App installable on Chrome and Safari (shows "Install" prompt)
- [ ] App launches in standalone mode without browser UI

---

## Implementation Notes

**manifest.webmanifest:**
```json
{
  "name": "Darts Companion",
  "short_name": "Darts",
  "description": "Track your dart game statistics and improve your skills.",
  "start_url": "/",
  "scope": "/",
  "display": "standalone",
  "theme_color": "#1976d2",
  "background_color": "#ffffff",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "/assets/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "/assets/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any"
    }
  ]
}
```

**index.html Head:**
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Darts Companion</title>
  <base href="/" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="theme-color" content="#1976d2" />
  <meta name="description" content="Track your dart game statistics." />
  <link rel="icon" type="image/x-icon" href="favicon.ico" />
  <link rel="manifest" href="/manifest.webmanifest" />
  <link rel="apple-touch-icon" href="assets/icons/icon-192x192.png" />
</head>
<body>
  <app-root></app-root>
</body>
</html>
```

**main.ts Service Worker Registration:**
```typescript
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule } from './app/app.module';
import { environment } from './environments/environment';

if (environment.production) {
  enableProdMode();
}

platformBrowserDynamic()
  .bootstrapModule(AppModule, {
    ngZone: 'zone.js',
    preserveContent: true
  })
  .catch(err => console.error(err));

// Service worker registration is handled by @angular/service-worker package
// In angular.json: "serviceWorker": true
```

**angular.json Configuration:**
```json
{
  "projects": {
    "DartsCompanion.Web": {
      "architect": {
        "build": {
          "options": {
            "outputPath": "dist/DartsCompanion.Web",
            "serviceWorker": true,
            "ngswConfigPath": "ngsw-config.json"
          }
        }
      }
    }
  }
}
```

**App Shell Offline Indicator (app.component.ts):**
```typescript
export class AppComponent implements OnInit {
  isOnline = true;

  constructor(private cdr: ChangeDetectorRef) {}

  ngOnInit() {
    this.isOnline = navigator.onLine;

    window.addEventListener('online', () => {
      this.isOnline = true;
      this.cdr.markForCheck();
    });

    window.addEventListener('offline', () => {
      this.isOnline = false;
      this.cdr.markForCheck();
    });
  }
}
```

**App Shell Template (app.component.html):**
```html
<div class="app-container">
  <!-- Offline Indicator -->
  <div *ngIf="!isOnline" class="offline-indicator">
    <svg class="icon" viewBox="0 0 24 24">
      <path d="M1 9l2 2c4.97-4.97 13.03-4.97 18 0l2-2C16.93 2.93 7.08 2.93 1 9zm8 8l3 3 3-3c-1.65-1.66-4.34-1.66-6 0zm-4-4l2 2c2.76-2.76 7.24-2.76 10 0l2-2C15.14 9.14 8.87 9.14 5 13z"/>
    </svg>
    <span>You are offline. Some features are unavailable.</span>
  </div>

  <!-- Main App Content -->
  <router-outlet></router-outlet>
</div>
```

**App Shell Styles:**
```scss
.offline-indicator {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-sm) var(--spacing-md);
  background-color: var(--color-orange);
  color: white;
  font-size: 14px;
  position: sticky;
  top: 0;
  z-index: 100;

  .icon {
    width: 20px;
    height: 20px;
    fill: currentColor;
  }
}
```

---

## References

- [`../../shared/architecture.md`](../../shared/architecture.md) — PWA architecture
- PWA Manifest Spec: https://www.w3.org/TR/appmanifest/
- Web App Manifest: https://web.dev/add-manifest/
- Installability Criteria: https://web.dev/installable-manifest/
- Angular Service Worker: https://angular.io/guide/service-worker-devops
