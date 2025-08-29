# Changelog

## 2025-08

- refactor: extract registry manager factory for isolated tests
- refactor: convert remaining `.js` files to `.ts`/`.tsx` and add `tsx` loader
- chore: refine navigation initialization for improved testability
- feat: scaffold command and data layers
- feat: centralize command, processor, source, and store interfaces
- chore: remove stray `UNKNOWN.egg-info` directory and ignore Python packaging artifacts
- fix: handle empty lights array to preserve recommendations when no lights are present
- docs: hyphenate the term traffic-light for consistency
- feat: add speech guidance for maneuvers
- feat: add theme state with settings screen
- refactor: group navigation and traffic modules under `src/features`
- refactor: simplify navigation dependency resolution and expose `cloneNavigationState` helper
