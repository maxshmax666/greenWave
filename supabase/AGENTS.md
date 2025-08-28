# Supabase

SQL migrations live under `migrations/` and seeds under `seed/`.
Run migrations locally with the Supabase CLI:

```bash
supabase db reset   # recreate database with latest migrations
supabase db push    # apply migrations to remote project
```

Keep SQL formatted and include RLS policies for new tables.
