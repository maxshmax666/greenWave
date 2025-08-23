-- public.lights: добавить метаданные и теги
alter table public.lights
  add column if not exists intersection_name text,
  add column if not exists tags text[] default '{}',
  add column if not exists bearing_main smallint,      -- азимут главного направления (0..359)
  add column if not exists bearing_secondary smallint;  -- азимут второстепенного

-- public.light_cycles: расширить описательность
alter table public.light_cycles
  add column if not exists dir text check (dir in ('main','secondary','ped')) default 'main',
  add column if not exists confidence real default 1.0,     -- достоверность
  add column if not exists note text,
  add column if not exists inserted_via text check (inserted_via in ('camera','manual','import','whatif')) default 'camera';

-- ускоряющие индексы
create index if not exists idx_light_cycles_light_ts on public.light_cycles (light_id, start_ts);
create index if not exists idx_light_cycles_light_dir on public.light_cycles (light_id, dir);

-- удалить (опционально) todos вместе с политиками
drop policy if exists "todos read own"   on public.todos;
drop policy if exists "todos insert own" on public.todos;
drop policy if exists "todos update own" on public.todos;
drop policy if exists "todos delete own" on public.todos;
drop table  if exists public.todos cascade;
