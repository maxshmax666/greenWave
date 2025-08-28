# AGENTS

Guidelines for the lights feature.

- UI components use functional React with `StyleSheet.create`.
- Keep services and hooks pure.
- Place tests next to the code they cover.
- After changes run:
  ```bash
  pre-commit run --files <files>
  npm test -- --coverage
  ```
