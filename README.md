# greenWave

[![CI](https://github.com/maxshmax666/greenWave/actions/workflows/ci.yml/badge.svg)](https://github.com/maxshmax666/greenWave/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/maxshmax666/greenWave/branch/main/graph/badge.svg)](https://codecov.io/gh/maxshmax666/greenWave)

React Native (Expo) app with real-time traffic-light detection, premium subscriptions, and analytics.

See [docs/API.md](docs/API.md) for available REST endpoints.

## Branches

- `main` – protected, production-ready releases.
- `develop` – integration branch for upcoming work.
- `feature/*` – feature development branches.
- `hotfix/*` – urgent fixes based off `main`.

## Creating a Pull Request

```bash
git checkout -b feature/<name>
pre-commit run --files <files>
pnpm lint --format unix
pnpm test --coverage
git commit -am "feat: add amazing thing"
git push origin feature/<name>
```

Open a pull request on GitHub and request a review.

### Branch protection

- Direct pushes to `main` are blocked.
- Merging into `main` requires at least one approved review.

## Recent changes

- Navigation settings moved under the navigation feature with lead-time preference stored via a dedicated store and used as the default for green-phase notifications.
- Renamed GPT API client to `client.ts` and split prompt formatting and response parsing into `prompt.ts` and `parse.ts`.
- Configured pnpm with hoisted node linker for Expo 53 compatibility and removed `tflite-react-native`.
- Centralized core creation in `src/core.ts` and simplified exports.
- Driving HUD reacts to speech-setting toggles.
- Navigation advisor treats `NaN` speeds as `0` to avoid invalid recommendations.
- `createCore` now accepts a custom registry for improved testability.
- Renamed maneuver panel style for consistent naming.
- Consolidated traffic services under `src/services/traffic` with new guidelines.
- Streamlined registry manager exports and covered them with tests.
- Added log viewer screen to inspect `data/app.log` from the menu.
- Added notifications for upcoming green phases.
- Added lead-time setting for green-phase notifications.
- Persisted lead-time preference across sessions.
- Fixed green-phase notification trigger to respect lead time.
- `subscribeToPhaseChanges` now returns an unsubscribe callback to remove listeners.
- Extracted registry manager into dedicated module for improved testability.
- Added registry manager factory for isolated module registries in tests.
- Added modular GPT service with API client, prompt formatter, and utilities.
- Routed `onMessage` handling through a type-specific handler map.
- Split `onMessage` into parsing, validation, and handling modules.
- Moved validation helpers to `src/utils` for reuse.
- Made module registry injectable for easier overriding in tests.
- Resolved dependency vulnerabilities via `npm audit fix`.
- Documented GitHub Actions `test` workflow and provided logger usage example.
- CI now runs tests with coverage and uploads reports to Codecov.
- Added API reference documentation and `.env.example` template.
- Added pull request guide and template for contributors.
- Added quality workflow to CI.
- Added design tokens (`src/styles/tokens.ts`) and a reusable `Card` UI component.
- Introduced light/dark theme switcher with persisted preference.
- Integrated combobox-based search in the toolbar.
- Extracted `calcSpeedRange` helper for isolated testing.
- Added avatar upload and selection for customizable map markers.
- Module registries can now be overridden for easier testing.
- Implemented speed range calculation for green-window recommendations in `SpeedAdvisor`.
- Added destination selection to navigation helpers.
- Included `.env.example` with required keys.
- Introduced SpeedAdvisor component to compute safe speed ranges for green windows.

- Added LightStatusBadge component showing upcoming traffic-light phases.
- Added markup mode toggle for map overlays.
- Exposed grouped modules in `index.ts` for easier testing.
- Introduced shared Supabase client (`src/lib/supabase.ts`) and a lights service with CRUD and phase helpers, backed by Vitest tests.
- Added lights migration and seed data for traffic-light management.
- Added `.npmrc` with `shamefully-hoist=false` and expanded npm scripts for development and diagnostics.
- Pinned Expo, React, React Native, and Metro versions and switched to `pnpm`.
- Added `clean` script for wiping caches and reinstalling dependencies.
- Covered invalid JSON and missing type cases in `onMessage` tests.
- Unified test command across documentation.
- Dropped coverage npm script; run tests with `pnpm test --coverage`.
- Re-exported `cloneNavigationState` from the navigation feature and removed duplicate implementation.
- Renamed project heading to "greenWave".
- Added tests to ensure navigation maneuvers remain isolated between runs.
- `createNavigation` now deep clones state to avoid mutating `hudInfo`.
- Added coverage script for easier local test runs.
- Improved map reference mocking in tests.
- Introduced `onMessage` service with dedicated parsing, validation, and handling helpers.
- Added GitHub Actions test workflow with Codecov coverage uploads.
- Split navigation factory into a dedicated `navigationFactory` module for easier testing.
- Added typed configuration objects for Supabase and analytics services.
- Exposed command, processor, source, and store interfaces via directory `index.ts` files.
- Split map and menu UI into `MapViewWrapper` and `MenuContainer` components with hooks for Supabase data and menu state.
- Exposed `cloneNavigationState` to deep copy navigation state and allow custom initial state injection.
- Renamed service interfaces to `SupabaseService` and `AnalyticsService`.
- Expanded test coverage for navigation helpers and cycle upload failure paths.
- Converted remaining `.js` files to TypeScript and configured the `tsx` loader for Node scripts.
- Exported additional types and removed legacy interface stubs.
- Centralized interface exports under `src/interfaces/index.ts`.
- Added scaffolding for commands, processors, sources, and stores with shared interfaces.
- Refactored navigation facade with dependency resolver for easier testing.
- Removed stray `UNKNOWN.egg-info` directory and ignored Python packaging artifacts.
- Extracted light detection into `useLightDetector` hook and cycle upload into `lightCycleUploader` service.
- Retain previous recommendation when no traffic-lights are on the route.
- Introduced navigation factory helpers for modular routing and easier tests.
- Added phase-change notifications to alert on traffic-light transitions.
- Switched analytics tracking to `@react-native-firebase/analytics` with a typed service wrapper.
- Grouped navigation and traffic modules under `src/features/` with co-located services, UI, and tests.
- Documented traffic-light domain guidelines and moved phase helpers to `src/domain`.
- Standardized phase color mapping to green for clearer signal status.
- Modularized navigation helpers for easier testing and reuse.
- Exposed navigation helpers via `src/index.ts` facade for simpler imports.
- Handled zero recommended speed to avoid divide-by-zero in nearest info calculation.
- Tracked traffic-light phase durations for analytics.
- Added offline route caching to reuse the last fetched route when connectivity fails.
- Introduced persistent theme color with settings screen.
- Added voice guidance for maneuvers with Expo Speech and a settings toggle.
- Introduced voice phase logger with offline storage and synchronization service.
- Consolidated project structure by moving `components/` and `services/` into `src/`.
- Fixed HUD maneuver spacing.
- Updated localization string spacing.
- Added traffic-light management forms for lights and cycles.
- Enabled manual cycle entry with what-if analysis.
- Added database migrations and models for lights and cycles.
- Introduced camera screen with traffic-light detection.
- Integrated premium subscription flow and analytics tracking.
- Switched traffic-light detector to TFLite model inference.
- Implemented fetch helper with timeout and error handling.
- Guarded route parsing and handled route fetch errors gracefully.
- Externalized translations into locale files and expanded component test coverage.
- Refined speed banner recommendation copy.
- Improved route fetch error handling.
- Added file logging for diagnostics.
- Refactored navigation logic into testable helpers.
- Added GitHub Actions workflow for cached tests.
- Configured ESLint and Prettier for consistent formatting.
- Converted remaining JavaScript files to TypeScript.
- Introduced typed interfaces for analytics, network, and Supabase services.
- Fixed main-direction color mapping and exposed green windows as domain helpers.
- Updated cycle seconds translation for clarity.

See [CHANGELOG.md](CHANGELOG.md) for a full history.

## Environment

Copy `.env.example` to `.env` and set the following environment variables for API access:

```
SUPABASE_URL
SUPABASE_ANON_KEY
ORS_API_KEY
```

## Running

Install dependencies and start Expo:

```
pnpm install
npx expo start -c
```

Run unit tests:

```
pnpm test --coverage
```

### Database

Manage Supabase migrations with the CLI:

```
supabase db reset   # recreate database with latest migrations
supabase db push    # apply migrations to the remote project
```

### Debugging

Write debug messages to `data/app.log` with the logger:

```ts
import { log } from 'src/services/logger';

await log('INFO', 'App started');
```

Each line follows `YYYY-MM-DD HH:MM:SS [LEVEL] message`. View the file with `tail -f data/app.log` or via the in-app log viewer.

### Voice phase logger

On the traffic screen, tap the record button and speak a color followed by its start time (e.g., "green 12").
Records are stored locally and uploaded with `phaseSync.syncPhases()`.

### Debug APK build

To create a debug Android APK:

```
npm run apk:debug
```

## Recovery build

If dependencies become corrupted:

```
pnpm run clean
pnpm install
```

## TypeScript migration plan

- Adopt TypeScript incrementally; new files use `strictNullChecks`.
- Expose interfaces from each module's `index.ts` to guide refactors.
- Supabase and analytics services accept typed config objects.
- Use the `tsx` loader directly without a build step.
- Ensure `pnpm test --coverage` and `pnpm run lint` pass after each change.
