# AGENTS

Guidelines for GPT service modules.

- Keep API calls isolated in `apiClient.ts` with injectable `fetch` for testing.
- Pure helpers belong in `utils.ts` and should remain stateless.
- `promptHandler.ts` formats prompts without side effects.
- Place tests in `__tests__/` alongside the modules.
- Run `pre-commit run --files <files>` and `npm test -- --coverage` after changes.
