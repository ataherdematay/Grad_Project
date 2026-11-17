# BiTadilat on Supabase: setup guide

PostgreSQL on the Supabase **free plan**. Login with **Google or email + password**. Everything works in **Turkish and English**.

## 1. Create the project (one person, e.g. you)
1. Go to supabase.com, sign in, **New project**. Name `bitadilat`, pick a strong database password (save it in a password manager, do not share it in chat), region **Frankfurt (eu-central-1)**, the closest to Istanbul.
2. Invite Hakan and Ata: Project → Settings → Team (or share the project URL and the **anon** key with them; never share the `service_role` key or the database password in the repo).

## 2. Create the database
Open **SQL Editor**, paste each file and press **Run**, in this order:
1. `01_schema.sql` tables
2. `02_functions.sql` rules (accept offer, pay, complete, dispute...) and the sign-up trigger
3. `03_security.sql` who can see/change what (Row Level Security)
4. `04_storage.sql` photo/document buckets (2.5 MB limit)
5. `05_seed_categories.sql` the 8 service categories in TR and EN

Each should say "Success". If one fails, send me the error text.

## 3. Turn on login
- Authentication → Providers → **Email**: on. For the demo, turn **Confirm email** off so test accounts work immediately.
- Authentication → Providers → **Google**: on. You need a Google Cloud OAuth client (Client ID and Secret). Supabase shows the exact "Callback URL" to paste in Google Cloud. Add `http://localhost:3000` (or the app's URL) under Authentication → URL Configuration.

## 4. Make the first admin
1. Sign up once in the app/site with the admin's email (this creates the profile).
2. SQL Editor: `UPDATE public.users SET role = 'ADMIN' WHERE email = 'admin@yourmail.com';`
   (Nobody can make themselves admin from the app. This is the only way.)

## 5. Connect the apps
Project Settings → API: copy the **Project URL** and the **anon public key**. These two values go in the apps (they are safe to put in a client app because Row Level Security protects the data). The `service_role` key stays secret, and only a backend uses it.

## 6. Test
Sign up a customer and a professional (the professional applies with `fn_register_pro`, uploads 3 documents, the admin approves with `fn_review_document` and `fn_decide_pro_application`), create a request, bid, accept, complete. `test/` has a full automated version of this flow (78 checks).

## Free plan limits to know
500 MB database, 1 GB file storage, 50,000 monthly active users; a project with no activity for a week is **paused** (you press Restore). Enough for the course project and the demo.
