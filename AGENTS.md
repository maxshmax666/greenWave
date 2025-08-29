# AGENTS

This repository contains a React Native (Expo) application for navigating through traffic lights with real-time phase detection.
New contributors can start by exploring the folders below to see how the app is assembled.

## Structure

- `src/features/navigation/` – navigation state, helpers, services, UI, and tests.
- `src/features/traffic/` – traffic-light detectors with feature-specific services and UI.
- `src/features/traffic/ui` – includes a voice phase logger hook and record button.
- `src/ui/` – shared React Native UI components.
- `src/services/` – networking helpers and cross-cutting domain services.
- `src/domain/` – shared domain types and matching utilities.
- `src/commands/` – application command handlers.
- `src/processors/` – data processors transforming inputs.
- `src/sources/` – external data sources.
- `src/stores/` – persistence adapters.
- `assets/` – static images and resources.
- `App.tsx` – application entry point; renders map, HUD, and menus.
- `data/app.log` – file logger output written via `src/services/logger.ts`.
- Analytics events are logged via `src/services/analytics.ts` which wraps `@react-native-firebase/analytics`.
- UI is split into `MapViewWrapper` and `MenuContainer` under `src/ui/` with side effects handled in hooks like `useSupabaseData` and `useMenu`.

## Newcomer tips

- Start with [`README.md`](README.md) and [`CHANGELOG.md`](CHANGELOG.md) to see recent changes.
- Navigation helpers live in `src/features/navigation` and are re-exported from `src/index.ts`.
- Use `createNavigation()` from `src/index.ts` to obtain test-friendly navigation helpers.
- Tests sit next to code; see `src/features/navigation/__tests__` for examples.

Service interfaces are named `SupabaseService`, `AnalyticsService`, etc., and live in `src/interfaces/`.

Tests live beside the code they verify, and coverage reports are stored under `coverage/`.

## Getting started

- Copy `.env.example` to `.env` and fill in the keys.
- `pnpm install` – install dependencies.
- `pnpm run clean` – reset caches and lockfile.
- `npx expo start` – launch the development server.
- `npm test -- --coverage` – run the Jest suite with coverage.
- `pnpm lint` – check JavaScript and TypeScript code style.
- Node scripts use the [`tsx`](https://github.com/privatenumber/tsx) loader via `node --loader tsx`.

Consult `README.md` for environment variables and more detailed setup steps.

## Guidelines

- Use functional components with hooks.
- Define component styles via `StyleSheet.create` blocks.
- Keep code formatted with Prettier/ESLint for TS/JS files.
- Python files must be formatted with `black` (line length 88, Python 3.11)
  and imports sorted with `isort` (profile "black", line length 88).
  Run these via `pre-commit run --files <py_files>` before committing.

## Checks

Run these commands before committing:

```bash
pre-commit run --files <files>
pnpm lint --format unix
npm test -- --coverage
```

Tests should pass and formatting hooks should run on the changed files. The `test` workflow uploads `coverage/lcov.info` to Codecov.

## For New Contributors

- Start the app with `npm start` to launch the Expo dev server.
- Feature modules under `src/features/` contain their own UI and services.
- Core logic and translations live under `src/` (`src/i18n.ts` wires up `src/locales`).
- Shared services are in `src/services/` and domain types in `src/domain/`.
- Jest tests reside in `src/__tests__`; add tests alongside new features.
