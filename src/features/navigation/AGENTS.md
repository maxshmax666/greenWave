# AGENTS

Guidelines for the navigation feature.

- Keep helpers and services pure and free of side effects.
- UI components use functional React with `StyleSheet.create`.
- Place tests next to the code they cover.
- After changes run:
  ```bash
  pre-commit run --files <files>
  pnpm test -- --coverage
  ```
