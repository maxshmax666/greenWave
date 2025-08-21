-- public.lights
create table if not exists public.lights (
  id bigserial primary key,
  name text,
  lat double precision not null,
  lon double precision not null,
  created_by uuid references auth.users(id),
  created_at timestamptz default now()
);
alter table public.lights enable row level security;
create policy "lights read all"   on public.lights for select using (true);
create policy "lights insert own" on public.lights for insert with check (auth.uid() = created_by);
create policy "lights update own" on public.lights for update using (auth.uid() = created_by);
