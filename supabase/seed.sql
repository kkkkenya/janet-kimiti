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
