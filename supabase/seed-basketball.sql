-- Janet Wambui Kimiti campaign site — pending programme: Basketball tournament
-- Run AFTER supabase/schema.sql. Safe to re-run.
--
-- This programme is created as a DRAFT: is_active = false, so it does NOT appear
-- on the public site yet. Publish it whenever you are ready:
--   admin.html → Events → "Activate"   (or set is_active = true here and re-run).
--
-- ⚠️ Every detail below (date, venue, categories, prizes) is a drafted placeholder —
-- confirm the real arrangements with the campaign team before activating.

insert into public.janet_events
  (slug, title, tag_line, description, event_date, location, courses, image_url, details, google_form_url, is_active)
values (
  'basketball-tournament',
  'Kahawa Sukari Youth Basketball Tournament',
  'Youth Sports · Team registrations open',
  'A New Dawn continues on the court. A fully sponsored basketball tournament for the young people of Kahawa Sukari Ward — come play, come support, and let us show what this ward can do.',
  '2026-11-14',
  'Kahawa Sukari Ward',
  array['🏀 Under-18 Teams', '🏀 Open Age (18+)', '🏀 Women''s Teams', '🏀 3x3 Streetball'],
  null,
  $json$
  [
    {
      "h": "Who can take part",
      "b": "- Teams from Kahawa Sukari Ward and neighbouring estates\n- Under-18, open age and women's categories\n- 3x3 streetball for informal teams and individuals\n- Free entry — no registration fee"
    },
    {
      "h": "How the tournament runs",
      "b": "Group stages on the Saturday, knockouts and finals on the Sunday. Games are short-format so every team plays several matches. Fixtures are announced on WhatsApp once entries close."
    },
    {
      "h": "What is provided",
      "b": "- Referees, scorekeeping and match balls\n- Bibs for teams without kit\n- Water and refreshments for players\n- Trophies, medals and certificates for the winners"
    },
    {
      "h": "What to bring",
      "b": "- Your team name and a contact person\n- At least five players per team\n- Appropriate footwear and sportswear"
    },
    {
      "h": "Venue",
      "b": "Kahawa Sukari Ward — the exact court will be confirmed by call or WhatsApp once entries close."
    },
    {
      "h": "Deadline",
      "b": "Team registrations close two weeks before the tournament, or earlier if the bracket fills. Register early to secure your slot."
    }
  ]
  $json$::jsonb,
  null,
  false
)
on conflict (slug) do nothing;
