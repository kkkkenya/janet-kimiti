# Janet Wambui Kimiti — Campaign Website

Static campaign site for **Hon. Janet Wambui Kimiti ("Mama Sukari")**, MCA candidate, Kahawa Sukari Ward 0572 — Democratic Congress Party (DCP).

No build step, no framework, no npm. Plain HTML + CSS + vanilla JS, with **Supabase** as the backend for programmes and registrations.

---

## Pages

| File | URL | What it is |
|---|---|---|
| `index.html` | `/` | Home — hero, the 5-point contract, about, support (Till 5973293) |
| `programmes.html` | `/programmes` | Programmes — card grid with search and a detail sheet; past programmes grouped below. With only one programme it switches to a rich full-width layout |
| `register.html` | `/register` | **Main registration page** — built-in form (Google-Form style) that writes to Supabase. Works standalone, per programme via `?event=slug`, and shows a programme chooser when several are open |
| `admin.html` | `/admin` | Admin: manage programmes (poster, details) **and** view/export registrations (login required) |
| `supabase-config.js` | — | Public Supabase URL + publishable key |
| `supabase/schema.sql` | — | Database schema + Row Level Security (run once) |
| `supabase/seed.sql` | — | Seeds the "A New Dawn" October intake programme |
| `supabase/seed-basketball.sql` | — | Adds the basketball tournament as a **draft** (hidden until you activate it) |
| `supabase/update-new-dawn.sql` | — | Adds the campaign poster and the full programme details to that programme |
| `vercel.json` | — | Clean URLs (`/programmes`, `/register`, `/admin`), old-link redirects, security headers |
| `images/` | `/images/…` | DCP logo, Janet portrait, campaign photo, programme posters |

The admin lives at **https://janet-kimiti.vercel.app/admin** (`vercel.json` → `cleanUrls`). The page keeps `noindex` and is protected by the Supabase login — the registration data cannot be read without an account.

Old links keep working: `/events` and `/events.html` redirect permanently to `/programmes`.

---

## Supabase setup (one time)

1. Open the project **vhecbmrrtkscwhgbmqcz** → **SQL Editor** → New query.
2. Paste and run **`supabase/schema.sql`**. This creates `janet_events` and `janet_registrations` with Row Level Security:
   - the public can **read active events** and **submit registrations** — nothing else;
   - signed-in admins can read, edit and delete everything.
3. Run **`supabase/seed.sql`** to add the "A New Dawn" intake (or add programmes by hand in `admin.html`).
4. Run **`supabase/seed-basketball.sql`** if you want the basketball tournament — it is inserted as a **draft** (`is_active = false`), so it stays hidden until you press *Activate* on it in `admin.html`.
5. Run **`supabase/update-new-dawn.sql`** to attach the campaign poster image and the full programme details (what you'll learn, what's included, what to bring, venue, deadline).
6. **Create an admin login:** Authentication → Users → **Add user** (email + password). Use that login on `admin.html`. There is no public sign-up — only users you create can log in.

> ⚠️ Never put a `service_role` / secret key in this repo. `supabase-config.js` holds only the **publishable** key, which is safe in a browser and in a public repo because Row Level Security decides what it can do.

---

## Local preview

Double-click any `.html` file, or serve the folder:

```bash
python -m http.server 8080
# then open http://localhost:8080/index.html
```

Use a local server (not `file://`) when testing the form, so the Supabase calls and the `?event=` links behave exactly like production.

---

## Deploy

Hosted on **Vercel**, connected to this repository's `main` branch.

```
git add .
git commit -m "your message"
git push
```

Vercel deploys automatically. No build command needed — it is a static site; the output directory is the repository root. `vercel.json` turns on clean URLs, so pages are served without `.html`:

| Page | URL |
|---|---|
| Home | https://janet-kimiti.vercel.app/ |
| Programmes | https://janet-kimiti.vercel.app/programmes |
| Register | https://janet-kimiti.vercel.app/register |
| Admin | https://janet-kimiti.vercel.app/admin |

The same file redirects the old `/events` and `/events.html` links to `/programmes`, and adds `noindex` plus basic security headers.

> Moving off Vercel later? Clean URLs then need the same rewrite rules on the new host, or a folder-per-page layout (`programmes/index.html`).

---

## Scaling to many programmes

The site is built to handle a growing programme list without a redesign:

| Where | With one programme | With many |
|---|---|---|
| `events.html` | One rich full-width card: large poster, description, expandable details | Responsive card grid (thumbnail, tag, title, date, courses) with a **search box**, a live count, and a **detail sheet** that opens the full poster and every detail block without leaving the page |
| Past programmes | — | Automatically grouped under **Previous programmes**, marked *Finished* |
| `index.html` band | Names the single programme with a direct *Register for this programme* button | Shows “N programmes open now”, lists the next three, and sends visitors to the full list |
| `register.html` | Straight to the form for that programme | Adds a **“Which programme are you registering for?”** chooser at the top; switching it updates the form, poster and details |

Adding a programme is always just `admin.html` → save. Nothing else needs changing.

## Navigation

All public pages (`/`, `/programmes`, `/register`) share **one navigation bar**: the brand, then **Programmes** and **The Contract**, then the **Support** button. On phones the second link collapses so Programmes is always visible.

Every generic link labelled *Register* or *Programmes* — in the nav, the hero, the band and the page headings — opens the **Programmes tab**. Registration is then reached from a specific programme: each programme card and detail sheet has its own **Register** button that opens `/register?event=<slug>`. So the flow is always: choose a programme → register for it.

## Editing content

| You want to change | Where |
|---|---|
| Programmes, dates, courses, opening/closing a programme | `admin.html` (no code, no redeploy) |
| A programme's poster image | `admin.html` → **Poster / image URL** — upload the file into `images/`, then enter `images/your-file.png` |
| A programme's details (what's included, what to bring, venue, deadline) | `admin.html` → **+ Add more details** — one heading + text per block; lines starting with `-` become bullets |
| Registration questions | `register.html` — the sections marked `01`, `02`, `03` |
| Who can see registrations | Supabase → Authentication → Users (add/remove admins) |
| Home page copy, contract points, Till number | `index.html` (plain HTML) |
| Colours, fonts | The `:root` block at the top of each page — `--green`, `--accent`, `--red`, `--mint`, `--paper` |
| Phone / WhatsApp number | Search for `0708 276 788` (every page) and `0708276788` |
| Registration table columns | `supabase/schema.sql` **and** the payload in `register.html` |

### Reading registrations

`admin.html` → **Registrations** tab: totals by status, filter by programme or status, search by name/phone/estate, click a phone number to open WhatsApp, set status (new → contacted → enrolled → declined), and **Export CSV** for Excel or a calling sheet.

---

## Data & privacy

- A registration stores: name, phone, WhatsApp, estate, age group, applicant type, course choices, notes, consent, timestamp.
- Consent is required to submit (`with check (consent = true)` in the schema), and the public key can never read the data back.
- Export a CSV as a backup before big cleanup operations.

## Known gaps

- Home page still has two placeholders: Janet's full bio and the authorized-by / IEBC disclaimer line. Both should be filled before public launch.
- The programme details added to "A New Dawn" (class hours, what's included, what to bring, venue, deadline) are **drafted placeholders** — confirm the real arrangements with the campaign team and edit them in `admin.html`.
- The admin's Google Form field is kept for compatibility but the built-in form is now the default path.
- Registration page is the main entry point; `events.html` is the programmes subpage beneath it.
