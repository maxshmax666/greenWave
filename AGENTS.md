# AGENTS

This repository contains a React Native (Expo) application.

## Structure
- `components/` – UI components written in TSX.
- `src/` – application logic and tests under `src/__tests__`.
- `services/` – service modules for networking and domain logic.
- `assets/` – static images and resources.

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
