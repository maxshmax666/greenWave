# AGENTS

Guidelines for code under `src/`.

- Modules in `commands`, `processors`, `sources`, and `stores` should implement interfaces from `src/interfaces` and include tests.
- Use TypeScript with `strict` types enabled.
- Keep code formatted with ESLint and Prettier.
- After changes run:
  ```bash
  pre-commit run --files <files>
  npm test -- --coverage
  ```
  Ensure hooks and tests pass before committing.
