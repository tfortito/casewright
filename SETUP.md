# Casewright SaaS — Setup &amp; Hosting (step by step)

This is a real multi-user web app: landing page, sign-up / log-in, and a
private database where each user's assurance cases are saved. It uses
**Supabase** (free) for the database + authentication, and **Vercel** or
**GitHub Pages** (free) to host the frontend.

You do not need to run any server or write any code. You'll create two free
accounts, paste two keys into one file, and deploy. About 20–30 minutes.

There are two parts:
- **Part A — Supabase** (the backend: database + login). Do this first.
- **Part B — Hosting** (put the site online).

---

## PART A — SUPABASE (backend)

### Step 1 — Create a Supabase project
1. Go to **supabase.com** → **Start your project** → sign in with GitHub (or email).
2. Click **New project**.
3. Name it `casewright`. Set a database password (save it somewhere; you
   won't need it day-to-day). Pick a region close to you (e.g. Frankfurt).
4. Click **Create new project**. Wait ~2 minutes while it provisions.

### Step 2 — Get your two keys
1. In the project, click the **gear icon (Project Settings)** in the left sidebar.
2. Click **API**.
3. Copy two values:
   - **Project URL** (looks like `https://abcdefgh.supabase.co`)
   - **anon public** key (a long string under "Project API keys")
   Keep these two handy for Step 4. (These are *public* keys — safe to put
   in your code. The database is protected by security rules, not by hiding
   the key.)

### Step 3 — Create the database tables
1. In the left sidebar, click **SQL Editor**.
2. Click **New query**.
3. Open the file **`schema.sql`** from this project, copy ALL of it, and
   paste it into the editor.
4. Click **Run** (bottom right). You should see "Success. No rows returned."
   This creates the `cases` table and — importantly — the security rules
   that make each user only able to see their own cases.

### Step 4 — Put your keys in the app
1. Open **`config.js`** in a text editor.
2. Replace the two placeholder values with your Project URL and anon key
   from Step 2:
   ```js
   window.CASEWRIGHT_CONFIG = {
     SUPABASE_URL:  "https://abcdefgh.supabase.co",
     SUPABASE_ANON_KEY: "eyJhbGci....(your long anon key)...."
   };
   ```
3. Save the file.

### Step 5 — (Optional) turn off email confirmation for easy testing
By default Supabase emails a confirmation link on sign-up. For quick testing
you can disable it:
1. Left sidebar → **Authentication** → **Providers** → **Email**.
2. Toggle **Confirm email** off → **Save**.
Now you can sign up and log in immediately without checking email. (Turn it
back on before real customers use it.)

---

## PART B — HOSTING (put it online)

You have the four files: `index.html` (landing), `app.html` (the app),
`config.js` (your keys), and `schema.sql` (already used in Step 3 — doesn't
need to be hosted, but it's harmless to include).

### Option 1 — Vercel (recommended for this)
1. Put all files in one folder.
2. Go to **vercel.com** → sign in with GitHub.
3. **Add New → Project**.
   - Easiest: first push the folder to a GitHub repo (see Option 2 steps
     A–B), then import it here. Or use the Vercel CLI / drag-and-drop.
4. Framework preset: **Other** (it's a static site). Click **Deploy**.
5. You get a live URL like `casewright.vercel.app`. `index.html` is the
   landing page; `/app.html` is the app.

### Option 2 — GitHub Pages (also free, gives a public repo)
**A. Create the repo**
1. github.com → **+** → **New repository** → name `casewright` → **Public**
   → **Create**.

**B. Upload the files**
1. **Add file → Upload files** → drag in `index.html`, `app.html`,
   `config.js` (and `schema.sql` if you like) → **Commit changes**.

**C. Turn on Pages**
1. **Settings** → **Pages** → Source: **Deploy from a branch** → Branch:
   **main**, folder **/(root)** → **Save**.
2. Wait ~1 minute. Your site is at
   `https://<username>.github.io/casewright/` (landing page), and the app
   at `https://<username>.github.io/casewright/app.html`.

### Custom domain (optional, either host)
Buy a domain (e.g. from Namecheap/Cloudflare) and follow the host's
"custom domain" instructions. Then update the Supabase **Authentication →
URL Configuration → Site URL** to your domain so auth redirects work.

---

## IMPORTANT — one Supabase setting for your live URL
Once hosted, tell Supabase your site's address so login works:
1. Supabase → **Authentication** → **URL Configuration**.
2. Set **Site URL** to your live URL (e.g. `https://casewright.vercel.app`).
3. Add the same URL under **Redirect URLs**. Save.

---

## Test it end to end
1. Open your live landing page → click **Start free**.
2. Create an account → you land in the app on "Your assurance cases".
3. Click **+ New case** → open it → click **Fill with worked example** →
   watch the readiness score, argument, and gaps populate.
4. Click **Save case**, go back to the list — your case is there with its
   score. Log out and back in — it's still there. That's the real database
   working.

## Updating later
Change a file, re-commit (GitHub) or redeploy (Vercel). The URL stays the
same. Your users' saved cases are in Supabase and are unaffected by
frontend updates.

## What you can honestly say now
"Casewright is a live web application — you can create an account and build
an ISO 8800 assurance case at [your URL]." That is now true. In a pitch or a
design-partner conversation, you can hand someone the link and they can use
it themselves.

## Costs
Supabase free tier: generous (plenty for validation and early customers).
Vercel/GitHub Pages: free. You pay nothing until you have real scale — at
which point Supabase's paid tier starts around \$25/mo. For now: \$0.

## Security note (honest)
The `anon` key is public by design; your data is protected by the
Row-Level Security policies in `schema.sql`, which enforce that a user can
only read/write their own cases. Do **not** paste your *service_role* key
(a different, secret key in Supabase settings) into any frontend file —
only the `anon` key belongs in `config.js`.
