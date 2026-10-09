-- Remove Electric sync for blobs and attachments (shapes are no longer used)
ALTER PUBLICATION electric_publication_default DROP TABLE public.blobs;
DO $$
DECLARE
    role_name text := coalesce(current_setting('vibekanban.electric_role_name', true), 'electric_sync');
BEGIN
    EXECUTE format('REVOKE SELECT ON TABLE public.blobs FROM %I', role_name);
END
$$;
ALTER TABLE public.blobs REPLICA IDENTITY DEFAULT;

ALTER PUBLICATION electric_publication_default DROP TABLE public.attachments;
DO $$
DECLARE
    role_name text := coalesce(current_setting('vibekanban.electric_role_name', true), 'electric_sync');
BEGIN
    EXECUTE format('REVOKE SELECT ON TABLE public.attachments FROM %I', role_name);
END
$$;
ALTER TABLE public.attachments REPLICA IDENTITY DEFAULT;
