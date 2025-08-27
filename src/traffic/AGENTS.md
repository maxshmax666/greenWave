# AGENTS

Guidelines for traffic-light detectors.

- Keep detection helpers small and focused.
- Avoid side effects and external state.
- Place tests in `__tests__/` beside detectors.
- After changes run:
  ```bash
  pre-commit run --files <files>
  npm test -- --coverage
  ```
