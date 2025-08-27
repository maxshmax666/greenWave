# AGENTS

Guidelines for navigation helpers.

- Keep functions pure and free of side effects.
- Place tests next to the helpers they cover.
- After changes run:
  ```bash
  pre-commit run --files <files>
  npm test -- --coverage
  ```
