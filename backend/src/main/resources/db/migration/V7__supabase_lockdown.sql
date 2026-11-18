-- Supabase publishes every table in the public schema through its automatic REST API (PostgREST), reachable with the
-- public anon key. This backend is the only intended client (it connects as the table owner and bypasses RLS), so we turn
-- row level security on for every table with no policies, and take away the API roles' rights.
-- On a plain PostgreSQL (local, Testcontainers) the API roles do not exist and only the RLS part runs; it is harmless there.
DO $$
DECLARE t RECORD; r TEXT;
BEGIN
    -- flyway_schema_history is skipped: Flyway keeps a second connection open on it, so locking it from inside a migration waits forever.
    FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename <> 'flyway_schema_history' LOOP
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t.tablename);
    END LOOP;
    FOREACH r IN ARRAY ARRAY['anon', 'authenticated'] LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r) THEN
            EXECUTE format('REVOKE ALL ON ALL TABLES IN SCHEMA public FROM %I', r);
            EXECUTE format('REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM %I', r);
            EXECUTE format('REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM %I', r);
            EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM %I', r);
        END IF;
    END LOOP;
END $$;
