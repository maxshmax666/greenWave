-- public.light_cycles
create table if not exists public.light_cycles (
  id bigserial primary key,
  light_id bigint references public.lights(id) on delete cascade,
  phase text check (phase in ('red','green','yellow')) not null,
  start_ts timestamptz not null,
  end_ts   timestamptz not null,
  source text default 'camera',
  created_by uuid references auth.users(id),
  created_at timestamptz default now()
);
alter table public.light_cycles enable row level security;
create policy "cycles read all"   on public.light_cycles for select using (true);
create policy "cycles insert own" on public.light_cycles for insert with check (auth.uid() = created_by);
create policy "cycles update own" on public.light_cycles for update using (auth.uid() = created_by);
