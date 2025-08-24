# Traffic light data schema

This project stores traffic light locations and cycle information using Supabase.

## Migrations

`supabase_migration_2025_08_24.sql` updates the database:

- Adds `intersection_name`, `tags`, `bearing_main`, and `bearing_secondary` to `public.lights`.
- Adds `dir`, `confidence`, `note`, and `inserted_via` to `public.light_cycles`.
- Creates indexes on `light_cycles` for faster queries.

## Dart models

- [`lib/data/models/light.dart`](../lib/data/models/light.dart) defines a `Light` with
  id, optional name and intersection name, coordinates, optional bearings, and tags.
- [`lib/data/models/light_cycle.dart`](../lib/data/models/light_cycle.dart) defines a `LightCycle`
  including direction, phase, timestamps, source, confidence, and notes.

## Repositories

- [`lib/data/repos/lights_repo.dart`](../lib/data/repos/lights_repo.dart) provides
  `list`, `get`, `insert`, and `update` operations for lights.
- [`lib/data/repos/cycles_repo.dart`](../lib/data/repos/cycles_repo.dart) provides
  `list`, `get`, `insert`, and `update` operations for light cycles and supports
  filtering by light, direction, and time range.

Run the migration with `supabase db push` to apply these schema changes.
