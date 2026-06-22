-- =========================================================
-- Peso-Tracker — Esquema Supabase (backup / referencia)
-- Ya está aplicado en el proyecto rocfrkqpjzgihrvyzizc.
-- Seguridad: "capability key". La RLS valida el header HTTP
-- x-space-key; sin ese token, ninguna fila es visible/editable.
-- El token vive en el #hash del link, NO en este repo.
-- =========================================================

create or replace function public.current_space_key()
returns text language sql stable
set search_path = '' as $$
  select nullif(current_setting('request.headers', true)::json ->> 'x-space-key', '')
$$;

create table if not exists public.weight_entries (
  id          uuid primary key default gen_random_uuid(),
  space_key   text not null,
  entry_date  date not null,
  entry_time  text,
  weight      numeric(5,1),
  waist       numeric(5,1),
  note        text,
  created_at  timestamptz not null default now()
);

create table if not exists public.weight_events (
  id          uuid primary key default gen_random_uuid(),
  space_key   text not null,
  label       text,
  category    text,
  start_date  date not null,
  end_date    date,
  note        text,
  created_at  timestamptz not null default now()
);

create table if not exists public.weight_settings (
  space_key      text primary key,
  start_weight   numeric,
  target_weight  numeric,
  height_cm      numeric,
  alert_weight   numeric,
  updated_at     timestamptz not null default now()
);

create index if not exists idx_entries_space_date on public.weight_entries (space_key, entry_date);
create index if not exists idx_events_space_start on public.weight_events (space_key, start_date);

grant usage on schema public to anon;
grant select, insert, update, delete on public.weight_entries  to anon;
grant select, insert, update, delete on public.weight_events   to anon;
grant select, insert, update, delete on public.weight_settings to anon;

alter table public.weight_entries  enable row level security;
alter table public.weight_events   enable row level security;
alter table public.weight_settings enable row level security;

drop policy if exists entries_space on public.weight_entries;
create policy entries_space on public.weight_entries for all to anon
  using  (space_key is not null and space_key = public.current_space_key())
  with check (space_key is not null and space_key = public.current_space_key());

drop policy if exists events_space on public.weight_events;
create policy events_space on public.weight_events for all to anon
  using  (space_key is not null and space_key = public.current_space_key())
  with check (space_key is not null and space_key = public.current_space_key());

drop policy if exists settings_space on public.weight_settings;
create policy settings_space on public.weight_settings for all to anon
  using  (space_key is not null and space_key = public.current_space_key())
  with check (space_key is not null and space_key = public.current_space_key());
