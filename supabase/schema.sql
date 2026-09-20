-- Janet Wambui Kimiti campaign site — database schema
-- Run this once in the Supabase dashboard → SQL Editor → New query → Run.
-- Safe to re-run: every statement is idempotent.
-- Project: vhecbmrrtkscwhgbmqcz.supabase.co
--
-- What this creates
--   1. janet_events         — programmes shown on events.html, edited in admin.html
--   2. janet_registrations  — every submission from register.html
--   3. Row Level Security   — the public may READ active events and SUBMIT registrations,
--                             and nothing else. Signed-in admins can manage everything.
--
-- Note: gen_random_uuid() is built into Postgres 13+ (Supabase runs 15+), so no extension is needed.

-- ─────────────────────────────────────────────────────────────
-- 1 · Events
-- ─────────────────────────────────────────────────────────────
create table if not exists public.janet_events (
  id              uuid primary key default gen_random_uuid(),
  created_at      timestamptz not null default now(),
  slug            text not null,
  title           text not null,
  tag_line        text,
  description     text,
  event_date      date,
  location        text,
  courses         text[] not null default '{}',
  image_url       text,
  details         jsonb not null default '[]'::jsonb,
  status          text not null default 'live',        -- pending | live | ended
  registration_open boolean not null default true,
  status_note     text,
  google_form_url text,
  is_active       boolean not null default true        -- deprecated: superseded by status
);

-- For databases created before these columns existed:
alter table public.janet_events add column if not exists image_url text;
alter table public.janet_events add column if not exists details jsonb not null default '[]'::jsonb;
alter table public.janet_events add column if not exists status text not null default 'live';
alter table public.janet_events add column if not exists registration_open boolean not null default true;
alter table public.janet_events add column if not exists status_note text;

create unique index if not exists janet_events_slug_key on public.janet_events (slug);

alter table public.janet_events enable row level security;

drop policy if exists "Public can read active events"    on public.janet_events;
drop policy if exists "Public can read published events" on public.janet_events;
drop policy if exists "Admins can read all events"       on public.janet_events;
drop policy if exists "Admins can insert events"         on public.janet_events;
drop policy if exists "Admins can update events"         on public.janet_events;
drop policy if exists "Admins can delete events"         on public.janet_events;

create policy "Public can read published events"
  on public.janet_events for select
  to anon
  using (status <> 'pending');

create policy "Admins can read all events"
  on public.janet_events for select
  to authenticated
  using (true);

create policy "Admins can insert events"
  on public.janet_events for insert
  to authenticated
  with check (true);

create policy "Admins can update events"
  on public.janet_events for update
  to authenticated
  using (true) with check (true);

create policy "Admins can delete events"
  on public.janet_events for delete
  to authenticated
  using (true);

-- ─────────────────────────────────────────────────────────────
-- 2 · Registrations
-- ─────────────────────────────────────────────────────────────
create table if not exists public.janet_registrations (
  id               uuid primary key default gen_random_uuid(),
  created_at       timestamptz not null default now(),
  event_slug       text not null default 'new-dawn',
  event_title      text,
  full_name        text not null,
  phone            text not null,
  whatsapp         text,
  estate           text,
  age_group        text,
  applicant_type   text,
  primary_course   text,
  second_course    text,
  notes            text,
  consent          boolean not null default false,
  status           text not null default 'new',   -- new | contacted | enrolled | declined
  source           text default 'website'
);

create index if not exists janet_registrations_event_idx  on public.janet_registrations (event_slug, created_at desc);
create index if not exists janet_registrations_status_idx on public.janet_registrations (status, created_at desc);

alter table public.janet_registrations enable row level security;

drop policy if exists "Public can submit registrations"  on public.janet_registrations;
drop policy if exists "Admins can read registrations"    on public.janet_registrations;
drop policy if exists "Admins can update registrations"  on public.janet_registrations;
drop policy if exists "Admins can delete registrations"  on public.janet_registrations;

-- The public (anon key) may only INSERT, and only when consent was given.
-- They can never read, change or delete a registration.
create policy "Public can submit registrations"
  on public.janet_registrations for insert
  to anon, authenticated
  with check (consent = true);

create policy "Admins can read registrations"
  on public.janet_registrations for select
  to authenticated
  using (true);

create policy "Admins can update registrations"
  on public.janet_registrations for update
  to authenticated
  using (true) with check (true);

create policy "Admins can delete registrations"
  on public.janet_registrations for delete
  to authenticated
  using (true);

-- ─────────────────────────────────────────────────────────────
-- 3 · Table privileges (RLS above still applies on top of these)
-- ─────────────────────────────────────────────────────────────
grant usage on schema public to anon, authenticated;

grant select                         on public.janet_events        to anon;
grant select, insert, update, delete on public.janet_events        to authenticated;

grant insert                         on public.janet_registrations to anon;
grant select, insert, update, delete on public.janet_registrations to authenticated;

-- ─────────────────────────────────────────────────────────────
-- 4 · Poster image storage (uploaded from admin.html)
-- ─────────────────────────────────────────────────────────────
insert into storage.buckets (id, name, public)
values ('programme-images', 'programme-images', true)
on conflict (id) do update set public = true;

drop policy if exists "Public can view programme images"   on storage.objects;
drop policy if exists "Admins can upload programme images" on storage.objects;
drop policy if exists "Admins can update programme images" on storage.objects;
drop policy if exists "Admins can delete programme images" on storage.objects;

create policy "Public can view programme images"
  on storage.objects for select to anon, authenticated
  using (bucket_id = 'programme-images');

create policy "Admins can upload programme images"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'programme-images');

create policy "Admins can update programme images"
  on storage.objects for update to authenticated
  using (bucket_id = 'programme-images') with check (bucket_id = 'programme-images');

create policy "Admins can delete programme images"
  on storage.objects for delete to authenticated
  using (bucket_id = 'programme-images');
