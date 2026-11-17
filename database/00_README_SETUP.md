# BiTadilat on Supabase: setup guide

PostgreSQL on the Supabase **free plan**. Login with **phone number + SMS code** (the chosen login). Everything works in **Turkish and English**.

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
- Authentication → Providers → **Phone**: on. Pick ONE way to get codes:
  - **Course / testing (free, no SMS provider):** same page → **Test Phone Numbers & OTPs**: add e.g. `905551110001=123456` and `905551110002=123456` (numbers without `+`). These numbers log in with the fixed code; no real SMS is sent.
  - **Real SMS:** choose Twilio / Vonage / MessageBird / TextLocal and paste its keys (a paid service; the Supabase free plan does not include SMS). Needed only for real phones.
  Admin login: create the admin as a test number, then make it admin (below).
- (Optional, later) Providers → **Google** or **Email**: not used by the current screens.

## 4. Make the first admin
1. Log in once with the admin's phone number (this creates the profile).
2. SQL Editor: `UPDATE public.users SET role = 'ADMIN' WHERE phone_number = '+905551110001';`
   (Nobody can make themselves admin from the app. This is the only way.)

## 5. Connect the apps
Project Settings → API: copy the **Project URL** and the **anon public key**. These two values go in the apps (they are safe to put in a client app because Row Level Security protects the data). The `service_role` key stays secret, and only a backend uses it.

## 6. Test
Sign up a customer and a professional (the professional applies with `fn_register_pro`, uploads 3 documents, the admin approves with `fn_review_document` and `fn_decide_pro_application`), create a request, bid, accept, complete. `test/` has a full automated version of this flow (78 checks).

## Free plan limits to know
500 MB database, 1 GB file storage, 50,000 monthly active users; a project with no activity for a week is **paused** (you press Restore). Enough for the course project and the demo.
