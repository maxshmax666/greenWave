# AGENTS

This repository contains a React Native (Expo) application.

## Structure
- `components/` – React Native UI components.
- `src/` – application logic, translations under `src/locales`, and Jest tests in `src/__tests__`.
- `services/` – networking helpers and domain services.
- `domain/` – pure domain logic shared by services and components.
- `assets/` – static images and resources.
- `App.js` – application entry point; renders map, HUD, and menus.

Run logic tests with Jest; coverage is generated under `coverage/`.

## Guidelines
- Use functional components with hooks.
- Define component styles via `StyleSheet.create` blocks.
- Keep code formatted with Prettier/ESLint for TS/JS files.
- Python files, if added, must be formatted with `black` and sorted with `isort`.

## Checks
Run these commands before committing:

```bash
pre-commit run --files <files>
npm test -- --coverage
```

Tests should pass and formatting hooks should run on the changed files.

## For New Contributors
- Start the app with `npm start` to launch the Expo dev server.
- UI components live in `components/` and rely on hooks for state.
- Core logic and translations live under `src/` (`src/i18n.ts` wires up `src/locales`).
- Network and domain helpers are in `services/` and `domain/`.
- Jest tests reside in `src/__tests__`; add tests alongside new features.
