# AGENTS

Guidelines for tests under `src/services/__tests__`.

- Use Jest with manual mocks; avoid real network or notification calls.
- Prefer `jest.mock` for services like `expo-notifications` and fetch helpers.
- Run `pre-commit run --files <files>` and `pnpm test -- --coverage` after editing tests.
