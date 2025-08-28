# greenwave-rn

React Native (Expo) app with real-time traffic-light detection, premium subscriptions, and analytics.

## Recent changes

- Converted remaining `.js` files to TypeScript and configured the `tsx` loader for Node scripts.
- Exported additional types and removed legacy interface stubs.
- Centralized interface exports under `src/interfaces/index.ts`.
- Added scaffolding for commands, processors, sources, and stores with shared interfaces.
- Refactored navigation facade with dependency resolver for easier testing.
- Removed stray `UNKNOWN.egg-info` directory and ignored Python packaging artifacts.
- Extracted light detection into `useLightDetector` hook and cycle upload into `lightCycleUploader` service.
- Retain previous recommendation when no traffic lights are on the route.
- Introduced navigation factory helpers for modular routing and easier tests.
- Added phase-change notifications to alert on traffic light transitions.
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
- Added traffic light management forms for lights and cycles.
- Enabled manual cycle entry with what-if analysis.
- Added database migrations and models for lights and cycles.
- Introduced camera screen with traffic light detection.
- Integrated premium subscription flow and analytics tracking.
- Switched traffic light detector to TFLite model inference.
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

Set the following environment variables for API access:

```
EXPO_PUBLIC_SUPABASE_URL
EXPO_PUBLIC_SUPABASE_ANON_KEY
EXPO_PUBLIC_ORS_API_KEY
```

## Running

Install dependencies and start Expo:

```
npm install
npx expo start -c
```

Run unit tests:

```
npm test -- --coverage
```

### Voice phase logger

On the traffic screen, tap the record button and speak a color followed by its start time (e.g., "green 12").
Records are stored locally and uploaded with `phaseSync.syncPhases()`.

### Debug APK build

To create a debug Android APK:

```
npm run apk:debug
```
