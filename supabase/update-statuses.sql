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
