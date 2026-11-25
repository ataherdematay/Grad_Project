# Prod configuration

Run with `SPRING_PROFILES_ACTIVE=prod`. All values come from the environment; there are no defaults for secrets. The values below are placeholders, never real values. In prod the application refuses to start if a required variable is missing or unsafe.

What `prod` turns off: `DevSeeder`, `DevJobSeeder`, `/api/v1/dev/**` (including the payment demo clock `POST /api/v1/dev/jobs/{jobId}/payment/fast-forward`), the logging email sender, the HTML prototype (`/`, `/preview/**`), the legacy prototype API (`/api/offers`, `/api/payments/*` except the 3DS bank paths) and springdoc/Swagger. Error responses never include messages or stack traces.

| Variable | Required | Example placeholder | Purpose |
|---|---|---|---|
| `SPRING_PROFILES_ACTIVE` | yes | `prod` | Selects this profile. Without it the dev profile (loopback only) starts. |
| `DB_URL` | yes | `jdbc:postgresql://db.internal:5432/bitadilat` | PostgreSQL 16 JDBC URL. Flyway migrates on startup. |
| `DB_USER` | yes | `bitadilat_app` | Database user. |
| `DB_PASSWORD` | yes | `<db-password>` | Database password. |
| `JWT_SECRET` | yes | `<random, at least 32 bytes>` | HS256 signing key for access tokens. Shorter than 32 bytes fails startup. |
| `ADDRESS_KEY` | yes | `<base64 of 32 random bytes>` | AES-GCM key that encrypts stored addresses. |
| `MEDIA_SIGNING_KEY` | yes | `<random, at least 32 bytes>` | HMAC key for signed media URLs. |
| `MEDIA_STORAGE` | no | `local` or `supabase` | Storage backend for job photos & pro documents (default `local`). Set to `supabase` on stateless cloud hosts. |
| `MEDIA_DIR` | when `MEDIA_STORAGE=local` | `/var/lib/bitadilat/media` | Folder for uploaded files when using local disk storage. There is **no default in prod**: with `MEDIA_STORAGE=local` (also when unset) an empty `MEDIA_DIR` fails startup (`ProdConfigValidator`). With `MEDIA_STORAGE=supabase` it is not needed. The `./data/media` default exists only in the base/dev configuration (the prod profile overrides it with an empty value). |
| `SUPABASE_URL` | when `MEDIA_STORAGE=supabase` | `https://<project-ref>.supabase.co` | Supabase project URL for cloud object storage. |
| `SUPABASE_SERVICE_ROLE_KEY` | when `MEDIA_STORAGE=supabase` | `<supabase-service-role-key>` | Server-only Supabase `service_role` key used by `SupabaseMediaStorage`. |
| `SUPABASE_STORAGE_BUCKET` | no | `bitadilat-media` | Private Supabase Storage bucket name (default `bitadilat-media`). |
| `APP_PUBLIC_BASE_URL` | yes | `https://api.example.com` | Public base URL; used for signed media links and the bank 3DS return. |
| `BITADILAT_CORS_ORIGINS` | no (recommended) | `https://admin.example.com` | Comma-separated exact origins allowed by CORS. A `*` anywhere fails startup. Empty means CORS is closed. `CORS_ALLOWED_ORIGINS` is still read as a fallback. The dev profile reads the same names (default `http://localhost:*,http://127.0.0.1:*`). |
| `BITADILAT_BIND` | no | `0.0.0.0` | Bind address (default `0.0.0.0`). |
| `BITADILAT_PORT` | no | `8080` | HTTP port (default 8090). |
| `CRAFTGATE_API_KEY` | yes | `<craftgate-api-key>` | Craftgate API key. A key starting with `sandbox-demo` switches the gateway to a fake in-memory demo mode (no Craftgate call); in prod this fails startup. |
| `CRAFTGATE_SECRET_KEY` | yes | `<craftgate-secret-key>` | Craftgate secret key. |
| `CRAFTGATE_CALLBACK_KEY` | yes in prod | `<craftgate-callback-key>` | Verifies the 3DS callback hash. Required in prod (startup fails if empty); optional in dev, where a warning is logged. |
| `CRAFTGATE_BASE_URL` | no | `https://sandbox-api.craftgate.io` | Craftgate endpoint. The client currently accepts sandbox hosts only. |
| `SPRING_MAIL_HOST` | yes | `smtp.example.com` | SMTP host. Missing host fails startup. |
| `SPRING_MAIL_PORT` | no | `587` | SMTP port. STARTTLS and authentication are enabled. |
| `SPRING_MAIL_USERNAME` | usually | `<smtp-user>` | SMTP user. |
| `SPRING_MAIL_PASSWORD` | usually | `<smtp-password>` | SMTP password. |
| `BITADILAT_MAIL_FROM` | yes | `no-reply@example.com` | From address of outgoing mail (password reset codes). Missing value fails startup. |
| `BITADILAT_ADMIN_EMAIL` | first start only | `admin@example.com` | Email of the first admin. Used only when no admin exists. |
| `BITADILAT_ADMIN_PASSWORD` | first start only | `<strong password>` | At least 12 characters with a letter and a digit, at most 72 bytes. Stored as a BCrypt hash; never logged. Remove it after the first start. |

## Docker image

`backend/Dockerfile` defaults to the dev profile (used by `docker-compose.yml`). With `SPRING_PROFILES_ACTIVE=prod` the entrypoint starts no socat forward and the app binds `0.0.0.0:${BITADILAT_PORT:-8090}` itself, so publish container port 8090 and pass the variables above (for example with `--env-file`). Do not reuse `docker-compose.yml` for prod.

## Admin bootstrap

On startup, if no admin user exists:

- Both `BITADILAT_ADMIN_EMAIL` and `BITADILAT_ADMIN_PASSWORD` set and valid: the admin is created.
- Not set, invalid, weak, or the email already belongs to a regular user: an `ERROR` is logged, nobody is promoted, and the application keeps running.

If an admin already exists, nothing happens, so restarts are safe.
