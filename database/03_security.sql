-- =====================================================================
-- Security: Row Level Security (who can see / change which rows) + grants.
-- Roles in Supabase: anon (not logged in), authenticated (logged in), service_role (backend/admin key, bypasses RLS).
-- Rule of thumb used here: apps READ through tables (filtered by policies) and WRITE important things
-- only through the fn_* functions in 02_functions.sql.
-- =====================================================================

-- more helpers (SECURITY DEFINER so policies do not call each other in a loop)
CREATE OR REPLACE FUNCTION can_see_job(p_job_id UUID) RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
    SELECT owns_job(p_job_id) OR is_admin() OR pro_sees_job(p_job_id) OR has_offer_on_job(p_job_id) OR is_job_party(p_job_id);
$$;

-- Customer and the accepted professional of the same job may see each other's name
CREATE OR REPLACE FUNCTION shares_job_with(p_user UUID) RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
    SELECT EXISTS (
        SELECT 1 FROM job_requests j JOIN offers o ON o.id = j.selected_offer_id JOIN pro_profiles p ON p.id = o.pro_id
        WHERE (j.customer_id = auth.uid() AND p.user_id = p_user) OR (p.user_id = auth.uid() AND j.customer_id = p_user));
$$;

-- ---------- turn RLS on for every table ----------
DO $$ DECLARE t TEXT; BEGIN
    FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    END LOOP;
END $$;

-- ---------- start from zero access, then open only what is needed ----------
REVOKE ALL ON ALL TABLES    IN SCHEMA public FROM anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon, authenticated;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC, anon, authenticated;

-- categories are public (also for the landing page)
GRANT SELECT ON service_categories TO anon, authenticated;
CREATE POLICY categories_read ON service_categories FOR SELECT USING (is_active);

-- users
GRANT SELECT (id, email, phone_number, first_name, last_name, role, status, preferred_lang, avatar_url, kvkk_accepted_at, created_at) ON users TO authenticated;
GRANT UPDATE (first_name, last_name, phone_number, preferred_lang, avatar_url, kvkk_accepted_at) ON users TO authenticated;
CREATE POLICY users_select ON users FOR SELECT TO authenticated USING (id = auth.uid() OR is_admin() OR shares_job_with(id));
CREATE POLICY users_update ON users FOR UPDATE TO authenticated USING (id = auth.uid()) WITH CHECK (id = auth.uid());

CREATE POLICY saved_addresses_own ON saved_addresses FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
GRANT SELECT, INSERT, UPDATE, DELETE ON saved_addresses TO authenticated;

-- professionals
GRANT SELECT ON pro_profiles TO authenticated;
GRANT UPDATE (business_name, bio, experience_years, accepting_jobs, emergency_calls, iban_encrypted) ON pro_profiles TO authenticated;
CREATE POLICY pro_select ON pro_profiles FOR SELECT TO authenticated USING (user_id = auth.uid() OR is_admin());
CREATE POLICY pro_update ON pro_profiles FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
GRANT SELECT ON pro_public_profiles TO authenticated;

GRANT SELECT, INSERT, DELETE ON pro_categories, pro_service_areas TO authenticated;
CREATE POLICY pro_cat_read   ON pro_categories    FOR SELECT TO authenticated USING (true);
CREATE POLICY pro_cat_write  ON pro_categories    FOR INSERT TO authenticated WITH CHECK (pro_id = my_pro_id());
CREATE POLICY pro_cat_delete ON pro_categories    FOR DELETE TO authenticated USING (pro_id = my_pro_id());
CREATE POLICY pro_area_read   ON pro_service_areas FOR SELECT TO authenticated USING (true);
CREATE POLICY pro_area_write  ON pro_service_areas FOR INSERT TO authenticated WITH CHECK (pro_id = my_pro_id());
CREATE POLICY pro_area_delete ON pro_service_areas FOR DELETE TO authenticated USING (pro_id = my_pro_id());

GRANT SELECT, DELETE ON pro_documents TO authenticated;
GRANT INSERT (pro_id, doc_type, file_url, file_size_bytes) ON pro_documents TO authenticated;
CREATE POLICY doc_read   ON pro_documents FOR SELECT TO authenticated USING (pro_id = my_pro_id() OR is_admin());
CREATE POLICY doc_insert ON pro_documents FOR INSERT TO authenticated WITH CHECK (pro_id = my_pro_id());
CREATE POLICY doc_delete ON pro_documents FOR DELETE TO authenticated USING (pro_id = my_pro_id() AND status = 'PENDING');

GRANT SELECT ON pro_locations TO authenticated;
CREATE POLICY loc_read ON pro_locations FOR SELECT TO authenticated USING (is_admin() OR EXISTS (
    SELECT 1 FROM job_requests j JOIN offers o ON o.id = j.selected_offer_id
    WHERE o.pro_id = pro_locations.pro_id AND j.customer_id = auth.uid() AND j.status IN ('PRO_EN_ROUTE', 'IN_PROGRESS')));

-- requests (exact address and PIN are NOT readable columns: use fn_get_job_address / fn_my_job_pin)
GRANT SELECT (id, customer_id, category_id, title, description, urgency, preferred_date, preferred_date_label, preferred_time_slot, city, district, neighborhood,
              address_line_masked, geo_lat, geo_lng, status, selected_offer_id, created_at, updated_at) ON job_requests TO authenticated;
GRANT INSERT (id, customer_id, category_id, title, description, urgency, preferred_date, preferred_date_label, preferred_time_slot, city, district, neighborhood,
              address_line_masked, address_full_encrypted, geo_lat, geo_lng, status) ON job_requests TO authenticated;
GRANT UPDATE (title, description, urgency, preferred_date, preferred_date_label, preferred_time_slot, district, neighborhood,
              address_line_masked, address_full_encrypted, status) ON job_requests TO authenticated;
CREATE POLICY job_read   ON job_requests FOR SELECT TO authenticated USING (customer_id = auth.uid() OR can_see_job(id));
CREATE POLICY job_insert ON job_requests FOR INSERT TO authenticated
    WITH CHECK (customer_id = auth.uid() AND status IN ('DRAFT', 'PENDING_OFFERS')
                AND EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND status = 'ACTIVE'));
CREATE POLICY job_update ON job_requests FOR UPDATE TO authenticated
    USING (customer_id = auth.uid() AND status IN ('DRAFT', 'PENDING_OFFERS'))
    WITH CHECK (customer_id = auth.uid() AND status IN ('DRAFT', 'PENDING_OFFERS'));

GRANT SELECT, INSERT, DELETE ON job_photos TO authenticated;
CREATE POLICY photo_read   ON job_photos FOR SELECT TO authenticated USING (can_see_job(job_id));
CREATE POLICY photo_insert ON job_photos FOR INSERT TO authenticated WITH CHECK (owns_job(job_id));
CREATE POLICY photo_delete ON job_photos FOR DELETE TO authenticated USING (owns_job(job_id));

-- offers (created only by fn_submit_offer)
GRANT SELECT ON offers, offer_items TO authenticated;
CREATE POLICY offer_read ON offers FOR SELECT TO authenticated USING (owns_job(job_id) OR pro_id = my_pro_id() OR is_admin());
CREATE POLICY item_read  ON offer_items FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM offers o WHERE o.id = offer_id));

GRANT SELECT ON appointments, job_status_history TO authenticated;
CREATE POLICY appt_read ON appointments       FOR SELECT TO authenticated USING (is_job_party(job_id) OR is_admin());
CREATE POLICY hist_read ON job_status_history FOR SELECT TO authenticated USING (is_job_party(job_id) OR is_admin());

GRANT SELECT ON payments TO authenticated;
CREATE POLICY pay_read ON payments FOR SELECT TO authenticated USING (customer_id = auth.uid() OR pro_id = my_pro_id() OR is_admin());

-- messages
GRANT SELECT ON chat_messages TO authenticated;
GRANT INSERT (job_id, sender_id, message_text, attachment_url) ON chat_messages TO authenticated;
GRANT UPDATE (is_read) ON chat_messages TO authenticated;
CREATE POLICY chat_read   ON chat_messages FOR SELECT TO authenticated USING (is_job_party(job_id) OR is_admin());
CREATE POLICY chat_insert ON chat_messages FOR INSERT TO authenticated WITH CHECK (sender_id = auth.uid() AND is_job_party(job_id));
CREATE POLICY chat_read_flag ON chat_messages FOR UPDATE TO authenticated USING (is_job_party(job_id) AND sender_id <> auth.uid()) WITH CHECK (is_job_party(job_id));

-- reviews are public to logged-in users (created by functions)
GRANT SELECT ON reviews TO authenticated;
CREATE POLICY review_read ON reviews FOR SELECT TO authenticated USING (true);

-- complaints
GRANT SELECT ON disputes TO authenticated;
CREATE POLICY dispute_read ON disputes FOR SELECT TO authenticated USING (opened_by = auth.uid() OR against_pro_id = my_pro_id() OR is_admin());
GRANT SELECT ON dispute_evidence TO authenticated;
GRANT INSERT (dispute_id, file_url, file_size_bytes) ON dispute_evidence TO authenticated;
CREATE POLICY evidence_read   ON dispute_evidence FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM disputes d WHERE d.id = dispute_id));
CREATE POLICY evidence_insert ON dispute_evidence FOR INSERT TO authenticated
    WITH CHECK (EXISTS (SELECT 1 FROM disputes d WHERE d.id = dispute_id AND d.opened_by = auth.uid()));

GRANT SELECT ON admin_actions TO authenticated;
CREATE POLICY admin_log_read ON admin_actions FOR SELECT TO authenticated USING (is_admin());

-- notifications
GRANT SELECT, DELETE ON notifications TO authenticated;
GRANT UPDATE (is_read) ON notifications TO authenticated;
CREATE POLICY notif_read   ON notifications FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY notif_update ON notifications FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY notif_delete ON notifications FOR DELETE TO authenticated USING (user_id = auth.uid());

-- ---------- functions the logged-in app may call ----------
GRANT EXECUTE ON FUNCTION is_admin(), my_pro_id(), is_job_party(UUID), has_offer_on_job(UUID), owns_job(UUID), pro_sees_job(UUID),
                          can_see_job(UUID), shares_job_with(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION fn_register_pro(TEXT, VARCHAR, INT, TEXT[]), fn_submit_offer(UUID, JSONB, INT, INT, TEXT, TIMESTAMPTZ),
    fn_accept_offer(UUID, UUID, TEXT, CHAR), fn_record_failed_payment(UUID, UUID, VARCHAR, CHAR), fn_reject_offer(UUID, VARCHAR, TEXT),
    fn_request_appointment(UUID, TIMESTAMPTZ, TIMESTAMPTZ), fn_respond_appointment(UUID, BOOLEAN), fn_cancel_appointment(UUID, VARCHAR, TEXT),
    fn_cancel_job(UUID), fn_set_job_progress(UUID, job_status), fn_update_pro_location(NUMERIC, NUMERIC),
    fn_complete_work(UUID, VARCHAR, INT, TEXT, TEXT[], BOOLEAN), fn_add_review(UUID, INT, TEXT, TEXT[], BOOLEAN),
    fn_get_job_address(UUID), fn_my_job_pin(UUID), fn_open_dispute(UUID, dispute_type, TEXT), fn_decide_dispute(UUID, dispute_decision, TEXT),
    fn_review_document(UUID, verification_status, TEXT), fn_decide_pro_application(UUID, verification_status), fn_set_account_status(UUID, account_status)
    TO authenticated;
-- notify() and handle_new_user() are internal: nobody calls them from the app.
