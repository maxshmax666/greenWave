# AGENTS

Guidelines for the traffic feature.

- Keep detectors and services small and focused.
- Avoid side effects and external state.
- UI components use functional React with `StyleSheet.create`.
- Place tests beside the code they cover.
- After changes run:
  ```bash
  pre-commit run --files <files>
  pnpm test -- --coverage
  ```
