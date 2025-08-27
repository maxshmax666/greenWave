# AGENTS

Guidelines for traffic-light domain utilities.

- Keep functions pure and focused on calculations.
- Type everything strictly with domain types.
- Place tests under `__tests__/` with filenames ending in `.test.ts`.
- After changes run:
  ```bash
  pre-commit run --files <files>
  npm test -- src/domain/phases.ts src/domain/__tests__/phases.test.ts
  ```
