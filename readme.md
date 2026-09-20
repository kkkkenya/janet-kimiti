# Janet Wambui Kimiti — Campaign Website

Static campaign site for **Hon. Janet Wambui Kimiti ("Mama Sukari")**, MCA candidate, Kahawa Sukari Ward 0572 — Democratic Congress Party (DCP).

No build step, no framework, no npm. Plain HTML + CSS + vanilla JS, with **Supabase** as the backend for programmes and registrations.

---

## Pages

| File | What it is |
|---|---|
| `index.html` | Home — hero, the 5-point contract, about, support (Till 5973293) |
| `events.html` | Programmes & events, loaded live from Supabase |
| `register.html` | Registration form (built-in, Google-Form style) — writes to Supabase |
| `admin.html` | Admin: manage events **and** view/export registrations (login required) |
| `supabase-config.js` | Public Supabase URL + publishable key |
| `supabase/schema.sql` | Database schema + Row Level Security (run once) |
| `supabase/seed.sql` | Seeds the "A New Dawn" October intake programme |
| `images/` | DCP logo, Janet portrait, campaign photo |

---

## Supabase setup (one time)

1. Open the project **vhecbmrrtkscwhgbmqcz** → **SQL Editor** → New query.
2. Paste and run **`supabase/schema.sql`**. This creates `janet_events` and `janet_registrations` with Row Level Security:
   - the public can **read active events** and **submit registrations** — nothing else;
   - signed-in admins can read, edit and delete everything.
3. Run **`supabase/seed.sql`** to add the "A New Dawn" intake (or add events by hand in `admin.html`).
4. **Create an admin login:** Authentication → Users → **Add user** (email + password). Use that login on `admin.html`. There is no public sign-up — only users you create can log in.

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

Vercel deploys automatically. No build command needed — it is a static site; the output directory is the repository root.

---

## Editing content

| You want to change | Where |
|---|---|
| Programmes, dates, courses, opening/closing a programme | `admin.html` (no code, no redeploy) |
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
- The admin's Google Form field is kept for compatibility but the built-in form is now the default path.
