# Running BiTadilat

## 1. With Docker (recommended)

Requires Docker Desktop. From the repo root:

```bash
cp .env.example .env            # optional; defaults work
export CRAFTGATE_API_KEY=...    # optional sandbox keys; without them only the card payment step fails
export CRAFTGATE_SECRET_KEY=...
docker compose up --build
```

- Postgres 16 (db `bitadilat`, user `bitadilat`) with named volume `pgdata`; backend waits for its healthcheck.
- Backend runs the `dev` profile: Flyway migrates, the demo data is seeded, `POST /api/v1/dev/reset` reloads the seed.
- Ports are bound to host loopback only. Change them with `BACKEND_PORT` / `POSTGRES_PORT` (for example `BACKEND_PORT=18090 POSTGRES_PORT=15432 docker compose up`).
- Why socat: the `dev` profile refuses to start unless it binds 127.0.0.1 (`DevProfileGuard`). Inside the container the app binds loopback and socat forwards container port 8091 to it, so the host port mapping works. Every request through socat reaches the app from 127.0.0.1, so `POST /api/v1/dev/reset` accepts anyone who can reach port 8091; that is why compose publishes it on the host's loopback only. Do not publish 8091 on a public interface.
- Without `CRAFTGATE_API_KEY` / `CRAFTGATE_SECRET_KEY`, compose passes the placeholder `not-configured` (the backend refuses to start with empty keys): everything works except the card payment step, which returns a gateway error.
- Reset everything: `docker compose down -v`.
- Compose always runs the `dev` profile. The same image runs `prod` without compose: with `SPRING_PROFILES_ACTIVE=prod` the entrypoint starts no socat, the app binds `0.0.0.0:8090` itself, so publish container port 8090 (for example `-p 8090:8090`) and pass the variables listed in [`docs/spec/PROD_CONFIG.md`](spec/PROD_CONFIG.md) (DB, `JWT_SECRET`, `ADDRESS_KEY`, `MEDIA_SIGNING_KEY`, `APP_PUBLIC_BASE_URL`, `CRAFTGATE_*` including `CRAFTGATE_CALLBACK_KEY`, `SPRING_MAIL_HOST`, `BITADILAT_MAIL_FROM`, `BITADILAT_ADMIN_EMAIL` / `BITADILAT_ADMIN_PASSWORD` on first start). Missing required values stop the app at startup.

## 2. Without Docker

```bash
brew install postgresql@16 openjdk@21
brew services start postgresql@16
createdb bitadilat        # app database (dev profile default: localhost:5432, user = your macOS user)
createdb bitadilat_test   # backend tests

cd backend
export CRAFTGATE_API_KEY=... CRAFTGATE_SECRET_KEY=...   # required: sandbox keys, or any placeholder if you skip payments
./mvnw spring-boot:run     # dev profile, http://127.0.0.1:8090
```

Environment variables (dev defaults in parentheses): `DB_URL` (local `bitadilat`), `DB_USER` (your OS user), `DB_PASSWORD`, `BITADILAT_PORT` (8090), `BITADILAT_BIND` (127.0.0.1; the dev profile accepts loopback only), `JWT_SECRET`, `ADDRESS_KEY`, `MEDIA_SIGNING_KEY`, `MEDIA_DIR`, `BITADILAT_CORS_ORIGINS` (`http://localhost:*,http://127.0.0.1:*`; the old name `CORS_ALLOWED_ORIGINS` is still read as a fallback), `APP_PUBLIC_BASE_URL`, `CRAFTGATE_API_KEY` and `CRAFTGATE_SECRET_KEY` (no default, required), `CRAFTGATE_CALLBACK_KEY` (optional in dev), `CRAFTGATE_BASE_URL` (sandbox). The `prod` profile has no defaults for secrets and adds mail and admin bootstrap variables; the full list is in [`docs/spec/PROD_CONFIG.md`](spec/PROD_CONFIG.md).

## 3. Flutter apps

```bash
flutter pub get                                   # once, at the repo root (workspace)
cd apps/mobile && flutter run --dart-define=API_BASE_URL=http://localhost:8090   # iOS Simulator
cd apps/admin  && flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8090
```

Demo logins: see README (password `Demo1234!`). The admin account works only in the web panel.

## 4. Tests

```bash
# backend: uses a Testcontainers Postgres when Docker is running, otherwise local bitadilat_test
cd backend && ./mvnw test
# override the fallback DB: TEST_DB_URL, TEST_DB_USER, TEST_DB_PASSWORD

# flutter (from repo root)
for d in apps/mobile apps/admin packages/bitadilat_ui; do (cd $d && flutter analyze && flutter test); done
(cd packages/bitadilat_api && flutter analyze && dart test)
```

Backend tests mock Craftgate (fake keys in `src/test/resources/application.properties`); no secrets are needed.

## 5. CI

`.github/workflows/backend.yml` (Java 21, Postgres 16 service, `./mvnw -B test`) and `.github/workflows/flutter.yml` (Flutter 3.47.3: analyze + test for the apps and packages, then an admin `flutter build web`) run on push and pull requests to `feature/flutter-app`, `develop` and `main`.
