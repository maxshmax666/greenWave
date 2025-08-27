# AGENTS - domain

Domain logic is pure and framework-agnostic.

## Guidelines
- Keep functions side-effect free.
- Ensure each utility has focused Jest tests.

## Checks
Run before committing changes in this directory:

```bash
pre-commit run --files <files>
npm test -- src/domain/__tests__
```
