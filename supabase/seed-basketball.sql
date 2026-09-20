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
