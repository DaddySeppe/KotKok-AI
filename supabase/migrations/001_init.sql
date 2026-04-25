create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  created_at timestamp with time zone default now() not null
);

create table if not exists public.ingredients (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  category text,
  quantity text,
  expiration_date date,
  estimated_price numeric default 0 not null,
  is_opened boolean default false not null,
  storage_location text,
  created_at timestamp with time zone default now() not null
);

create table if not exists public.shopping_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  estimated_price numeric default 0 not null,
  is_bought boolean default false not null,
  created_at timestamp with time zone default now() not null
);

create table if not exists public.user_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null unique,
  max_budget_per_meal numeric default 4.5 not null,
  dietary_preferences text[] default '{}'::text[] not null,
  allergies text[] default '{}'::text[] not null,
  default_cooking_time integer default 15 not null,
  dark_mode boolean default false not null,
  notifications_enabled boolean default true not null,
  created_at timestamp with time zone default now() not null
);

create table if not exists public.saved_recipes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  title text,
  description text,
  reason text,
  ingredients_used text[] default '{}'::text[] not null,
  missing_ingredients text[] default '{}'::text[] not null,
  steps text[] default '{}'::text[] not null,
  estimated_cost numeric default 0 not null,
  cooking_time_minutes integer default 0 not null,
  dish_count integer default 1 not null,
  waste_saving_score integer default 0 not null,
  student_score integer default 0 not null,
  created_at timestamp with time zone default now() not null
);

create table if not exists public.waste_stats (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  month text not null,
  products_saved integer default 0 not null,
  estimated_money_saved numeric default 0 not null,
  most_wasted_category text,
  created_at timestamp with time zone default now() not null
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name')
  on conflict (id) do update set full_name = excluded.full_name;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.ingredients enable row level security;
alter table public.shopping_items enable row level security;
alter table public.user_preferences enable row level security;
alter table public.saved_recipes enable row level security;
alter table public.waste_stats enable row level security;

create policy "Profiles can read own profile"
on public.profiles for select
using (auth.uid() = id);

create policy "Profiles can insert own profile"
on public.profiles for insert
with check (auth.uid() = id);

create policy "Profiles can update own profile"
on public.profiles for update
using (auth.uid() = id)
with check (auth.uid() = id);

create policy "Profiles can delete own profile"
on public.profiles for delete
using (auth.uid() = id);

create policy "Ingredients can read own rows"
on public.ingredients for select
using (auth.uid() = user_id);

create policy "Ingredients can insert own rows"
on public.ingredients for insert
with check (auth.uid() = user_id);

create policy "Ingredients can update own rows"
on public.ingredients for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Ingredients can delete own rows"
on public.ingredients for delete
using (auth.uid() = user_id);

create policy "Shopping items can read own rows"
on public.shopping_items for select
using (auth.uid() = user_id);

create policy "Shopping items can insert own rows"
on public.shopping_items for insert
with check (auth.uid() = user_id);

create policy "Shopping items can update own rows"
on public.shopping_items for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Shopping items can delete own rows"
on public.shopping_items for delete
using (auth.uid() = user_id);

create policy "Preferences can read own row"
on public.user_preferences for select
using (auth.uid() = user_id);

create policy "Preferences can insert own row"
on public.user_preferences for insert
with check (auth.uid() = user_id);

create policy "Preferences can update own row"
on public.user_preferences for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Preferences can delete own row"
on public.user_preferences for delete
using (auth.uid() = user_id);

create policy "Saved recipes can read own rows"
on public.saved_recipes for select
using (auth.uid() = user_id);

create policy "Saved recipes can insert own rows"
on public.saved_recipes for insert
with check (auth.uid() = user_id);

create policy "Saved recipes can update own rows"
on public.saved_recipes for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Saved recipes can delete own rows"
on public.saved_recipes for delete
using (auth.uid() = user_id);

create policy "Waste stats can read own rows"
on public.waste_stats for select
using (auth.uid() = user_id);

create policy "Waste stats can insert own rows"
on public.waste_stats for insert
with check (auth.uid() = user_id);

create policy "Waste stats can update own rows"
on public.waste_stats for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Waste stats can delete own rows"
on public.waste_stats for delete
using (auth.uid() = user_id);
