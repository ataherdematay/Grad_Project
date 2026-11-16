# Running BiTadilat

## 1. With Docker (recommended)

Requires Docker Desktop. From the repo root:

```bash
cp .env.example .env            # optional; defaults work
export CRAFTGATE_API_KEY=...    # optional, sandbox keys for payments; never commit them
export CRAFTGATE_SECRET_KEY=...
docker compose up --build
```

- Postgres 16 (db `bitadilat`, user `bitadilat`) with named volume `pgdata`; backend waits for its healthcheck.
- Backend runs the `dev` profile: Flyway migrates, the demo data is seeded, `POST /api/v1/dev/reset` reloads the seed.
- Ports are bound to host loopback only. Change them with `BACKEND_PORT` / `POSTGRES_PORT` (for example `BACKEND_PORT=18090 POSTGRES_PORT=15432 docker compose up`).
- Why socat: the `dev` profile refuses to start unless it binds 127.0.0.1 (`DevProfileGuard`). Inside the container the app binds loopback and socat forwards container port 8091 to it, so the host port mapping works and `/dev/reset` still sees a loopback caller.
- Reset everything: `docker compose down -v`.
- `SPRING_PROFILES_ACTIVE=prod` is not meant for compose (needs JWT_SECRET, ADDRESS_KEY, MEDIA_SIGNING_KEY, APP_PUBLIC_BASE_URL and no socat).

## 2. Without Docker

```bash
brew install postgresql@16 openjdk@21
brew services start postgresql@16
createdb bitadilat        # app database (dev profile default: localhost:5432, user = your macOS user)
createdb bitadilat_test   # backend tests

cd backend
export CRAFTGATE_API_KEY=... CRAFTGATE_SECRET_KEY=...   # optional
./mvnw spring-boot:run     # dev profile, http://127.0.0.1:8090
```

Environment variables (all have dev defaults except where noted): `DB_URL`, `DB_USER`, `DB_PASSWORD`, `BITADILAT_PORT` (8090), `BITADILAT_BIND` (127.0.0.1), `JWT_SECRET`, `ADDRESS_KEY`, `MEDIA_SIGNING_KEY`, `MEDIA_DIR`, `CORS_ALLOWED_ORIGINS`, `APP_PUBLIC_BASE_URL`, `CRAFTGATE_API_KEY`, `CRAFTGATE_SECRET_KEY`, `CRAFTGATE_CALLBACK_KEY`, `CRAFTGATE_BASE_URL`. In `prod`, all secrets and DB settings are required.

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
