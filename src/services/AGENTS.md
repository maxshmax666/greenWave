# AGENTS

Guidelines for code in `src/services`.

- Provide small, focused helpers for networking, logging, and analytics.
- Export typed interfaces from `src/interfaces` where possible.
- Service tests reside in `src/services/__tests__` to share common mocks.
- Mock `fetch` and external APIs in tests; avoid real network calls.
- Run `pre-commit run --files <files>` and `npm test -- --coverage` after changes.
