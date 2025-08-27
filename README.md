# greenwave-rn

React Native (Expo) app with real-time traffic-light detection, premium subscriptions, and analytics.

## Recent changes

- Reorganized navigation logic under `src/navigation` and scaffolded `src/traffic` and `src/ui` for upcoming features.
- Modularized navigation helpers for easier testing and reuse.
- Handled zero recommended speed to avoid divide-by-zero in nearest info calculation.
- Tracked traffic light phase durations for analytics.
- Added offline route caching to reuse the last fetched route when connectivity fails.
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
- Added notification service to emit signal change events.
- Updated cycle seconds translation for clarity.

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

### Debug APK build

To create a debug Android APK:

```
npx expo run:android --variant debug
```
