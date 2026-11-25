# Running the backend on Supabase (PostgreSQL)

Supabase is used **only as the hosted PostgreSQL database**. The Spring Boot API is the only client: login (JWT), payments
(Craftgate) and all rules stay in the API. Flyway (`V1`–`V7`) creates the whole schema; do not run any other SQL by hand.

## 1. Create the project (Alaa)
1. supabase.com → New project, **Free plan**, region **Frankfurt (eu-central-1)**. Keep the database password in a password manager.
2. Leave the project **empty**. Do not run the old `database/` SQL files from the `feature/supabase-data-layer` branch: their tables use the same names as Flyway's and would collide.
3. Press **Connect → Session pooler** and copy the host and the user (`postgres.<project-ref>`).
   Use the Session pooler (port 5432). The direct connection is IPv6 only; the Transaction pooler (6543) breaks Flyway.

## 2. Give the connection details to the backend (Alaa → Hakan, privately, never in Git or a group chat)
```
SPRING_PROFILES_ACTIVE=prod
DB_URL=jdbc:postgresql://<pooler-host>:5432/postgres?sslmode=require
DB_USER=postgres.<project-ref>
DB_PASSWORD=<the database password>
JWT_SECRET=<random, 32+ bytes>
ADDRESS_KEY=<base64 32 bytes>
MEDIA_SIGNING_KEY=<random, 32+ bytes>
MEDIA_STORAGE=supabase
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_SERVICE_ROLE_KEY=<service_role secret key from Supabase Project Settings -> API>
SUPABASE_STORAGE_BUCKET=bitadilat-media
APP_PUBLIC_BASE_URL=<public https address of the API>
CORS_ALLOWED_ORIGINS=<admin web address>
CRAFTGATE_API_KEY / CRAFTGATE_SECRET_KEY / CRAFTGATE_CALLBACK_KEY
```
The public `anon` key is **not** needed anywhere. `SUPABASE_SERVICE_ROLE_KEY` is required only when `MEDIA_STORAGE=supabase` so the backend can store and load private job photos and pro verification documents in Supabase Storage.

## 3. First start
The API runs Flyway: 31 tables, 8 categories, 39 Istanbul districts. `V7__supabase_lockdown.sql` turns on row level security
for every table and removes the rights of Supabase's public REST API roles, so the public anon key cannot read any data.
The backend connects as the table owner (`postgres.<ref>`), which is not affected by RLS.

After the first successful start, run this once in the Supabase SQL Editor (Flyway's own table cannot be locked from inside a migration):
```sql
ALTER TABLE public.flyway_schema_history ENABLE ROW LEVEL SECURITY;
```

## 4. Limits to know
- Free plan: 500 MB database; the project **pauses after about 7 days without activity** (resume it in the dashboard before a demo).
- Uploaded files go to **Supabase Storage** when `MEDIA_STORAGE=supabase` (`SupabaseMediaStorage`, private bucket `bitadilat-media`), or to `MEDIA_DIR` (local disk) when `MEDIA_STORAGE=local` (the default). To enable cloud media storage in Supabase: create a **private** bucket named `bitadilat-media` in the Supabase Dashboard (Storage → New bucket → keep *Public bucket* off) and set `MEDIA_STORAGE=supabase`, `SUPABASE_URL`, and `SUPABASE_SERVICE_ROLE_KEY`.
- Phone + SMS login is not implemented in the backend (it uses email + password). Needs a team decision.

## 5. Tested on Supabase (2026-11-19)
Flyway V1-V7 ran on a fresh Supabase project (PostgreSQL 17) and the API started (Hibernate `validate` passed).
Notes from that run:
- A new project created with "Enable automatic RLS" has a helper function `public.rls_auto_enable()`; Flyway refuses a non-empty schema, so run `DROP FUNCTION public.rls_auto_enable() CASCADE;` once (or leave that option unticked).
- `prod` mode uses `ProdEmailSender` (Resend HTTPS API via `RESEND_API_KEY`; starts cleanly with a warning if `RESEND_API_KEY` is not yet set), and real Craftgate sandbox keys. For a local test against Supabase you can also use `SPRING_PROFILES_ACTIVE=staging` with `SPRING_DATASOURCE_URL/USERNAME/PASSWORD`, and placeholder Craftgate keys.
