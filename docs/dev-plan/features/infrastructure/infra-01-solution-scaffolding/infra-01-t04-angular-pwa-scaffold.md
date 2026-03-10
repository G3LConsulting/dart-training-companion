# INFRA-01-T04 — Angular 21 PWA Scaffold

| Metadata | Value |
|----------|-------|
| Story | [INFRA-01](../infra-01-solution-scaffolding.md) — Solution Scaffolding & Domain Model |
| Layer | Frontend |
| Status | 🔲 Not started |
| Agent | Frontend Lead |

## What to Build

Create Angular 21 PWA scaffold with standalone components, @angular/pwa integration, core routing structure, and environment configurations. The PWA must support offline-first design with service worker caching and manifest configuration.

## Files to Create or Modify

| File Path | Purpose | Type |
|-----------|---------|------|
| src/DartsCompanion.Web/angular.json | Angular build configuration | Create |
| src/DartsCompanion.Web/tsconfig.json | TypeScript configuration | Create |
| src/DartsCompanion.Web/package.json | NPM dependencies | Create |
| src/DartsCompanion.Web/src/main.ts | Application bootstrap | Create |
| src/DartsCompanion.Web/src/app.config.ts | Angular providers and config | Create |
| src/DartsCompanion.Web/src/app.routes.ts | Application routing | Create |
| src/DartsCompanion.Web/src/app.component.ts | Root component | Create |
| src/DartsCompanion.Web/src/app.component.html | Root template | Create |
| src/DartsCompanion.Web/src/app.component.css | Root styles | Create |
| src/DartsCompanion.Web/src/index.html | HTML entry point | Create |
| src/DartsCompanion.Web/src/styles.css | Global styles | Create |
| src/DartsCompanion.Web/src/environments/environment.ts | Development environment config | Create |
| src/DartsCompanion.Web/src/environments/environment.prod.ts | Production environment config | Create |
| src/DartsCompanion.Web/src/manifest.webmanifest | PWA manifest | Create |
| src/DartsCompanion.Web/src/icons/ | PWA icons (192x192, 512x512, etc.) | Create |
| src/DartsCompanion.Web/ngsw-config.json | Service Worker configuration | Create |
| src/DartsCompanion.Web/.gitignore | Git ignore file | Create |

## Definition of Done

- [ ] ng serve runs without errors at localhost:4200
- [ ] ng build completes successfully
- [ ] PWA manifest (manifest.webmanifest) is present and valid
- [ ] Service worker (ngsw) is registered in production build
- [ ] Standalone components configured in app.config.ts
- [ ] Routing skeleton includes placeholders for Game, Stats, Settings modules
- [ ] Angular Material or PrimeNG installed for UI components
- [ ] Environment configurations for API endpoint (localhost:8080 for dev, production URL for prod)
- [ ] TypeScript strict mode enabled
- [ ] Linting and formatting tools configured (ESLint, Prettier)

## Implementation Notes

1. **Project Creation**:
   - Use `ng new DartsCompanion.Web --standalone --routing`
   - Navigate to src/DartsCompanion.Web directory
   - Install dependencies: `npm install`

2. **Standalone Components**:
   - Use bootstrapApplication(AppComponent, appConfig) in main.ts
   - Define all providers in app.config.ts
   - Use `standalone: true` in component decorators

3. **PWA Configuration**:
   - Run `ng add @angular/pwa` to scaffold PWA files
   - Configure manifest.webmanifest with app name, icons, start URL, theme colors
   - Ensure service worker caching strategy in ngsw-config.json for API endpoints and static assets
   - Generate PWA icons (192x192, 512x512 minimum)

4. **Routing Structure**:
   - Create routes for: Home, Game, Stats, Settings, Auth
   - Use lazy loading for feature modules
   - Define in app.routes.ts as route array

5. **Environment Configuration**:
   - environment.ts: API at http://localhost:8080
   - environment.prod.ts: API at production URL
   - Import via import { environment } from './environments/environment'

6. **UI Framework Setup**:
   - Consider Angular Material: `ng add @angular/material`
   - Or PrimeNG: `npm install primeng`
   - Install bootstrap or Tailwind if preferred for styling

7. **Development Tools**:
   - ESLint: `npm install --save-dev @angular-eslint/schematics`
   - Prettier: `npm install --save-dev prettier`
   - Add pre-commit hooks via husky

## References

- [Architecture](../../../shared/architecture.md)
- [Technical Approach §6](../../../shared/technical-approach.md#section-6-frontend-architecture)
