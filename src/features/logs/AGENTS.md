# AGENTS

Guidelines for the log viewing feature.

- Use functional React components with `StyleSheet.create` for styles.
- Include tests alongside components to verify rendered output.
- After changes run:
  ```bash
  pre-commit run --files <files>
  npm test -- --coverage
  ```
