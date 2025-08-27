# AGENTS

Guidelines for React Native UI components.

- Use functional components and hooks.
- Style via `StyleSheet.create`.
- Place component tests under `__tests__/`.
- After changes run:
  ```bash
  pre-commit run --files <files>
  npm test -- --coverage
  ```
