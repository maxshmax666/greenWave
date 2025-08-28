-- Create lights table
create table if not exists public.lights (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  latitude double precision not null,
  longitude double precision not null,
  created_at timestamptz not null default now()
);

-- Create light_phases table
create table if not exists public.light_phases (
  id uuid primary key default gen_random_uuid(),
  light_id uuid not null references public.lights(id) on delete cascade,
  phase text not null,
  started_at timestamptz not null default now(),
  ended_at timestamptz
);

-- Indices
create index if not exists light_phases_light_id_idx on public.light_phases(light_id);
create index if not exists light_phases_started_at_idx on public.light_phases(started_at);

-- RLS
alter table public.lights enable row level security;
alter table public.light_phases enable row level security;

-- Anonymous read
create policy "Anon read lights" on public.lights
  for select using (true);
create policy "Anon read light_phases" on public.light_phases
  for select using (true);

-- Authenticated write
create policy "Auth write lights" on public.lights
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');
create policy "Auth write light_phases" on public.light_phases
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');
