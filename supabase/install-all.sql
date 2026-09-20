-- ══════════════════════════════════════════════════════════════
-- Janet Wambui Kimiti campaign site — ONE-SHOT INSTALL
-- ══════════════════════════════════════════════════════════════
-- Paste this whole file into Supabase → SQL Editor → Run.
-- Safe to re-run: every statement is idempotent.
--
-- What it does, in order:
--   1. schema.sql            tables, columns, Row Level Security, grants, storage bucket
--   2. update-statuses.sql   pending/live/ended statuses, registration state, message column
--   3. seed.sql              the "A New Dawn" October intake programme
--   4. seed-basketball.sql   a generic PENDING basketball placeholder (hidden until published)
--   5. update-new-dawn.sql   the campaign poster and the full programme details
--
-- The individual files stay in this folder for reference and for running one at a time.



-- ══════════ schema.sql ══════════


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


-- ══════════ update-statuses.sql ══════════


-- Janet Wambui Kimiti campaign site — statuses, registration states and image uploads
-- Run AFTER supabase/schema.sql. Safe to re-run.
--
-- Adds:
--   1. janet_events.status            pending | live | ended   (pending = hidden draft)
--   2. janet_events.registration_open whether the registration form accepts entries
--   3. janet_events.status_note       optional custom message shown on the programmes page
--   4. a public Supabase Storage bucket "programme-images" so posters can be uploaded
--      from admin.html — no repository, no URLs to paste.
--
-- The site shows a message per programme:
--   live + registration_open          → "Registration open"
--   live + registration closed        → "Registration closed"
--   live + closes within 7 days       → "Registration closes soon"
--   ended                             → "This programme has ended"
--   pending                           → not shown on the public site at all
-- Any custom status_note overrides the automatic message.

-- ── 1. Columns ────────────────────────────────────────────────
alter table public.janet_events add column if not exists status text not null default 'live';
alter table public.janet_events add column if not exists registration_open boolean not null default true;
alter table public.janet_events add column if not exists status_note text;

-- keep old rows honest: anything previously switched off becomes a pending draft
update public.janet_events
   set status = 'pending'
 where is_active = false and status = 'live';

do $$ begin
  alter table public.janet_events
    add constraint janet_events_status_check check (status in ('pending', 'live', 'ended'));
exception when duplicate_object then null; end $$;

-- ── 2. Public read policy becomes status-based ────────────────
drop policy if exists "Public can read active events"   on public.janet_events;
drop policy if exists "Public can read published events" on public.janet_events;

create policy "Public can read published events"
  on public.janet_events for select
  to anon
  using (status <> 'pending');

-- ── 3. Poster image storage ───────────────────────────────────
insert into storage.buckets (id, name, public)
values ('programme-images', 'programme-images', true)
on conflict (id) do update set public = true;

drop policy if exists "Public can view programme images"   on storage.objects;
drop policy if exists "Admins can upload programme images" on storage.objects;
drop policy if exists "Admins can update programme images" on storage.objects;
drop policy if exists "Admins can delete programme images" on storage.objects;

create policy "Public can view programme images"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'programme-images');

create policy "Admins can upload programme images"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'programme-images');

create policy "Admins can update programme images"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'programme-images')
  with check (bucket_id = 'programme-images');

create policy "Admins can delete programme images"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'programme-images');


-- ══════════ seed.sql ══════════


-- Janet Wambui Kimiti campaign site — seed data
-- Run AFTER supabase/schema.sql. Safe to re-run.
--
-- Seeds the current programme: "A New Dawn" free skills training (October intake).
-- edit it any time from admin.html instead of re-running SQL.

insert into public.janet_events
  (slug, title, tag_line, description, event_date, location, courses, google_form_url, is_active)
values (
  'new-dawn',
  'A New Dawn: Free Skills Training',
  '100% Fully Sponsored — October Intake',
  'Kazi sio CV peke yake, ni SKILL! A New Dawn imefika na fursa 100% FULLY SPONSORED for the youths, young mothers and residents of Kahawa Sukari Ward. Practical skills, expert guidance and hands-on learning — Learn. Create. Earn. Classes start 5th October, na nafasi ni chache.',
  '2026-10-05',
  'Kahawa Sukari Ward',
  array['☕ Coffee Barista', '🍽️ Hospitality', '🧁 Baking & Pastry', '🥗 Nutrition'],
  null,
  true
)
-- Non-destructive on purpose: if the programme already exists (it does on the live site),
-- this leaves it exactly as it is. Edit it in admin.html instead of re-running SQL.
on conflict (slug) do nothing;


-- ══════════ seed-basketball.sql ══════════


-- Janet Wambui Kimiti campaign site — programme: Basketball (generic draft)
-- Run AFTER supabase/schema.sql and supabase/update-statuses.sql. Safe to re-run.
--
-- Deliberately GENERIC: a template placeholder you fill in from admin.html.
-- status = 'pending', so it is hidden from the public site until you publish it
-- (admin.html → Events → "Set live"). Nothing below is a confirmed arrangement.

-- ── Column guard ────────────────────────────────────────────────
-- Makes this file safe to run on its own. If the table is missing entirely,
-- the error below tells you exactly what to run first.
do $$ begin
  if to_regclass('public.janet_events') is null then
    raise exception 'Run supabase/schema.sql first — the janet_events table does not exist yet.';
  end if;
end $$;

alter table public.janet_events add column if not exists image_url text;
alter table public.janet_events add column if not exists details jsonb not null default '[]'::jsonb;
alter table public.janet_events add column if not exists status text not null default 'live';
alter table public.janet_events add column if not exists registration_open boolean not null default true;
alter table public.janet_events add column if not exists status_note text;
alter table public.janet_events add column if not exists is_active boolean not null default true;

insert into public.janet_events
  (slug, title, tag_line, description, event_date, location, courses, image_url, details, status, registration_open, status_note, is_active)
values (
  'basketball-tournament',
  'Basketball Tournament',
  'Community Sports',
  'A community basketball tournament for the young people of Kahawa Sukari Ward. Details will be announced shortly.',
  null,
  'To be confirmed',
  array['Team entry'],
  null,
  $json$
  [
    { "h": "About this programme", "b": "A community basketball tournament for the ward. Full details — date, venue, categories and prizes — will be confirmed and announced here." },
    { "h": "Who can take part", "b": "Open to teams and players from Kahawa Sukari Ward. Categories to be confirmed." },
    { "h": "What to bring", "b": "Team name and a contact person, and enough players per team for the format." },
    { "h": "Venue", "b": "To be confirmed." },
    { "h": "Registrations", "b": "Opens once the details are confirmed. Register your interest and we will contact you." }
  ]
  $json$::jsonb,
  'pending',
  false,
  'Dates and venue to be confirmed',
  false
)
on conflict (slug) do nothing;


-- ══════════ update-new-dawn.sql ══════════


-- Janet Wambui Kimiti campaign site — programme details for the October intake
-- Run AFTER supabase/schema.sql. Safe to re-run.
--
-- Adds the campaign poster image and the full programme details to the
-- "A New Dawn" event, so they appear on events.html and register.html.
--
-- ⚠️ The wording below is drafted copy to be reviewed by the campaign team —
-- adjust anything (dates, times, what's included) in admin.html or here.

-- ── Column guard ────────────────────────────────────────────────
-- Makes this file safe to run on its own. If the table is missing entirely,
-- the error below tells you exactly what to run first.
do $$ begin
  if to_regclass('public.janet_events') is null then
    raise exception 'Run supabase/schema.sql first — the janet_events table does not exist yet.';
  end if;
end $$;

alter table public.janet_events add column if not exists image_url text;
alter table public.janet_events add column if not exists details jsonb not null default '[]'::jsonb;
alter table public.janet_events add column if not exists status text not null default 'live';
alter table public.janet_events add column if not exists registration_open boolean not null default true;
alter table public.janet_events add column if not exists status_note text;
alter table public.janet_events add column if not exists is_active boolean not null default true;

update public.janet_events
set
  image_url = 'images/new-dawn-poster.png',
  details = $json$
  [
    {
      "h": "What you will learn",
      "b": "Practical, job-ready skills taught by working professionals:\n- Hands-on training in your chosen course\n- Customer care and workplace etiquette\n- Hygiene, safety and quality basics\n- Business skills for self-employment\n- A practical final assessment"
    },
    {
      "h": "How the programme runs",
      "b": "Four weeks of practical classes, Monday to Friday, 9:00am – 1:00pm. Groups are kept small so every learner gets real hands-on time with the tools and equipment."
    },
    {
      "h": "Course options",
      "b": "- ☕ Coffee Barista\n- 🍽️ Hospitality\n- 🧁 Baking & Pastry\n- 🥗 Nutrition"
    },
    {
      "h": "Who can join",
      "b": "Open to all youths, young mothers and residents of Kahawa Sukari Ward. No previous experience or qualifications needed — complete beginners are welcome."
    },
    {
      "h": "What is included",
      "b": "- 100% fully sponsored tuition — no fees\n- Training materials, tools and ingredients\n- Certificate of completion\n- Refreshments during sessions"
    },
    {
      "h": "What to bring",
      "b": "- National ID or birth certificate\n- A phone number we can reach you on\n- Commitment to attend all four weeks"
    },
    {
      "h": "Venue",
      "b": "Training takes place in Kahawa Sukari Ward. The exact venue will be confirmed by call or WhatsApp before classes begin."
    },
    {
      "h": "Deadline",
      "b": "Applications close when the October intake is full. Classes start 5th October — nafasi ni chache, register early."
    }
  ]
  $json$::jsonb
where slug = 'new-dawn';
