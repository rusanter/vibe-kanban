DO $$
DECLARE
    role_name text := coalesce(current_setting('vibekanban.electric_role_name', true), 'electric_sync');
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = role_name) THEN
        EXECUTE format('CREATE ROLE %I WITH LOGIN REPLICATION', role_name);
    END IF;
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO %I', current_database(), role_name);
    EXECUTE format('GRANT USAGE ON SCHEMA public TO %I', role_name);
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'electric_publication_default') THEN
        CREATE PUBLICATION electric_publication_default;
    END IF;
END
$$;

CREATE OR REPLACE FUNCTION electric_sync_table(p_schema text, p_table text)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    qualified text := format('%I.%I', p_schema, p_table);
    role_name text := coalesce(current_setting('vibekanban.electric_role_name', true), 'electric_sync');
BEGIN
    EXECUTE format('ALTER TABLE %s REPLICA IDENTITY FULL', qualified);
    EXECUTE format('GRANT SELECT ON TABLE %s TO %I', qualified, role_name);
    EXECUTE format('ALTER PUBLICATION %I ADD TABLE %s', 'electric_publication_default', qualified);
END;
$$;

SELECT electric_sync_table('public', 'shared_tasks');
