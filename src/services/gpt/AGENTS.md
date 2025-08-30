# AGENTS

Guidelines for GPT service modules.

- Keep API calls isolated in `client.ts` with injectable `fetch` for testing.
- Pure helpers belong in `utils.ts` and should remain stateless.
- `prompt.ts` formats prompts without side effects.
- `parse.ts` extracts content from API responses.
- Place tests in `__tests__/` alongside the modules.
- Run `pre-commit run --files <files>` and `pnpm test -- --coverage` after changes.
