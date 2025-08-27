# AGENTS

Guidelines for code in `src/services`.

- Provide small, focused helpers for networking, logging, and analytics.
- Export typed interfaces from `src/interfaces` where possible.
- Place service tests in `__tests__/` beside the code.
- Mock `fetch` and external APIs in tests; avoid real network calls.
- Run `pre-commit run --files <files>` and `npm test -- --coverage` after changes.
