-- User profiles for Telegram auth
create table if not exists public.user_profiles (
  id uuid primary key default gen_random_uuid(),
  telegram_id bigint unique not null,
  username text,
  display_name text,
  avatar_url text,
  phone text,
  last_login_at timestamptz,
  created_at timestamptz not null default now()
);

-- Ordering settings (single row)
create table if not exists public.ordering_settings (
  id int primary key default 1,
  ordering_enabled boolean not null default true,
  preorder_enabled boolean not null default true,
  updated_at timestamptz not null default now()
);

insert into public.ordering_settings (id, ordering_enabled, preorder_enabled)
values (1, true, true)
on conflict (id) do nothing;

-- Orders
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_profile_id uuid not null references public.user_profiles(id) on delete cascade,
  order_type text not null check (order_type in ('regular', 'preorder')),
  status text not null check (status in ('pending', 'accepted', 'rejected', 'completed')),
  payload jsonb not null,
  created_at timestamptz not null default now()
);

create index if not exists orders_user_profile_id_idx on public.orders(user_profile_id);

-- RLS
alter table public.user_profiles enable row level security;
alter table public.ordering_settings enable row level security;
alter table public.orders enable row level security;

-- Public read of ordering settings
create policy "Public read ordering settings" on public.ordering_settings
  for select using (true);

-- Authenticated read/write for profiles and orders (for future Supabase auth usage)
create policy "Auth read profiles" on public.user_profiles
  for select using (auth.role() = 'authenticated');
create policy "Auth write profiles" on public.user_profiles
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "Auth read orders" on public.orders
  for select using (auth.role() = 'authenticated');
create policy "Auth write orders" on public.orders
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');
