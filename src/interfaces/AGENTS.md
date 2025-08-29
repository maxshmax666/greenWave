# AGENTS

Guidelines for interface definitions under `src/interfaces`.

- Define TypeScript interfaces and types shared across commands, processors, sources, and stores.
- Re-export interfaces from `index.ts` for centralized access.
- Keep files free of implementation logic.
- Run `pre-commit run --files <files>` and `pnpm test -- --coverage` after modifying interfaces.
