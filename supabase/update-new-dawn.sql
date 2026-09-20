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
