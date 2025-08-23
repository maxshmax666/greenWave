-- public.record_marks
create table if not exists public.record_marks (
  id bigserial primary key,
  lat double precision not null,
  lon double precision not null,
  note text,
  ts timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete cascade
);
alter table public.record_marks enable row level security;
create policy "marks read all"   on public.record_marks for select using (true);
create policy "marks insert own" on public.record_marks for insert with check (auth.uid() = created_by);
create policy "marks update own" on public.record_marks for update using (auth.uid() = created_by);
