-- =====================================================================
-- Supabase Storage: file buckets with the 2.5 MB limit (RAD) and per-user folders.
-- File path rule used by the app: <user_id>/<anything>.jpg  (first folder = the uploader)
-- =====================================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES
 ('avatars',          'avatars',          true,  2621440, ARRAY['image/jpeg','image/png','image/webp']),
 ('job-photos',       'job-photos',       false, 2621440, ARRAY['image/jpeg','image/png','image/webp']),
 ('pro-documents',    'pro-documents',    false, 2621440, ARRAY['application/pdf','image/jpeg','image/png']),
 ('dispute-evidence', 'dispute-evidence', false, 2621440, ARRAY['application/pdf','image/jpeg','image/png'])
ON CONFLICT (id) DO UPDATE SET file_size_limit = EXCLUDED.file_size_limit, allowed_mime_types = EXCLUDED.allowed_mime_types;

-- upload / change / delete only inside your own folder
CREATE POLICY "own folder write" ON storage.objects FOR INSERT TO authenticated
    WITH CHECK (bucket_id IN ('avatars','job-photos','pro-documents','dispute-evidence') AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY "own folder delete" ON storage.objects FOR DELETE TO authenticated
    USING (bucket_id IN ('avatars','job-photos','pro-documents','dispute-evidence') AND (storage.foldername(name))[1] = auth.uid()::text);

-- read: avatars are public; documents and evidence only the owner and admins; job photos any logged-in user who can see jobs
CREATE POLICY "avatars read"  ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "own and admin read" ON storage.objects FOR SELECT TO authenticated
    USING (bucket_id IN ('pro-documents','dispute-evidence') AND ((storage.foldername(name))[1] = auth.uid()::text OR public.is_admin()));
CREATE POLICY "job photos read" ON storage.objects FOR SELECT TO authenticated
    USING (bucket_id = 'job-photos');
