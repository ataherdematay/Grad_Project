-- =====================================================================
-- Business rules as database functions. The app (Supabase client) or Hakan's backend
-- calls these; each one checks WHO is calling through auth.uid(), applies the rule
-- and changes everything in ONE transaction.
-- SECURITY DEFINER = runs with owner rights, so the checks inside the function are the security.
-- =====================================================================

CREATE SEQUENCE IF NOT EXISTS dispute_case_seq START 101;

-- ---------- helpers ----------
CREATE OR REPLACE FUNCTION is_admin() RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
    SELECT EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'ADMIN' AND status = 'ACTIVE');
$$;

CREATE OR REPLACE FUNCTION my_pro_id() RETURNS UUID LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
    SELECT id FROM pro_profiles WHERE user_id = auth.uid();
$$;

-- Is the caller the customer, or the professional of the accepted offer, of this job?
CREATE OR REPLACE FUNCTION is_job_party(p_job_id UUID) RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
    SELECT EXISTS (
        SELECT 1 FROM job_requests j
        LEFT JOIN offers o ON o.id = j.selected_offer_id
        WHERE j.id = p_job_id
          AND (j.customer_id = auth.uid() OR o.pro_id = (SELECT id FROM pro_profiles WHERE user_id = auth.uid())));
$$;

CREATE OR REPLACE FUNCTION has_offer_on_job(p_job_id UUID) RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
    SELECT EXISTS (SELECT 1 FROM offers WHERE job_id = p_job_id AND pro_id = (SELECT id FROM pro_profiles WHERE user_id = auth.uid()));
$$;

CREATE OR REPLACE FUNCTION owns_job(p_job_id UUID) RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
    SELECT EXISTS (SELECT 1 FROM job_requests WHERE id = p_job_id AND customer_id = auth.uid());
$$;

-- Can the caller (a verified professional) see this open request in the feed?
CREATE OR REPLACE FUNCTION pro_sees_job(p_job_id UUID) RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
    SELECT EXISTS (
        SELECT 1 FROM job_requests j, pro_profiles p
        WHERE j.id = p_job_id AND j.status = 'PENDING_OFFERS'
          AND p.user_id = auth.uid() AND p.verification = 'VERIFIED' AND p.accepting_jobs
          AND (j.category_id = p.primary_category_id OR EXISTS (SELECT 1 FROM pro_categories c WHERE c.pro_id = p.id AND c.category_id = j.category_id))
          AND EXISTS (SELECT 1 FROM pro_service_areas a WHERE a.pro_id = p.id AND a.district = j.district));
$$;

CREATE OR REPLACE FUNCTION notify(p_user UUID, p_type notification_type, p_job UUID, p_data JSONB DEFAULT '{}') RETURNS VOID
LANGUAGE sql AS $$ INSERT INTO notifications (user_id, type, job_id, data) VALUES (p_user, p_type, p_job, p_data); $$;

-- ---------- sign-up: create the profile row when a login account is created ----------
-- Works for Google (name comes from Google) and for email + password (app sends first_name / last_name in sign-up data).
-- The role can only be CUSTOMER here. Becoming a professional goes through fn_register_pro; ADMIN is set by hand.
CREATE OR REPLACE FUNCTION handle_new_user() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_full TEXT; v_first TEXT; v_last TEXT; v_lang TEXT;
BEGIN
    v_full  := COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', '');
    v_first := COALESCE(NULLIF(NEW.raw_user_meta_data->>'first_name', ''), NULLIF(split_part(v_full, ' ', 1), ''), 'User');
    v_last  := COALESCE(NULLIF(NEW.raw_user_meta_data->>'last_name', ''),
                        NULLIF(btrim(substr(v_full, length(split_part(v_full, ' ', 1)) + 1)), ''), '-');
    v_lang  := CASE WHEN NEW.raw_user_meta_data->>'preferred_lang' IN ('tr', 'en') THEN NEW.raw_user_meta_data->>'preferred_lang' ELSE 'tr' END;
    INSERT INTO users (id, email, first_name, last_name, preferred_lang, avatar_url, kvkk_accepted_at)
    VALUES (NEW.id, NEW.email, v_first, v_last, v_lang, NEW.raw_user_meta_data->>'avatar_url',
            CASE WHEN NEW.raw_user_meta_data->>'kvkk_accepted' = 'true' THEN NOW() END);
    RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ---------- professional registration ----------
CREATE OR REPLACE FUNCTION fn_register_pro(p_business TEXT, p_category VARCHAR, p_experience INT, p_districts TEXT[]) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_pro UUID; d TEXT;
BEGIN
    IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Login required' USING ERRCODE = 'insufficient_privilege'; END IF;
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'CUSTOMER') THEN
        RAISE EXCEPTION 'Only a customer account can apply as a professional' USING ERRCODE = 'check_violation';
    END IF;
    INSERT INTO pro_profiles (user_id, business_name, primary_category_id, experience_years)
    VALUES (auth.uid(), p_business, p_category, COALESCE(p_experience, 1)) RETURNING id INTO v_pro;
    FOREACH d IN ARRAY COALESCE(p_districts, '{}') LOOP INSERT INTO pro_service_areas VALUES (v_pro, d); END LOOP;
    UPDATE users SET role = 'PRO' WHERE id = auth.uid();
    RETURN v_pro;
END $$;

-- ---------- offers ----------
-- p_items example: [{"kind":"LABOR","description":"Valve replacement","quantity":1,"unit_price":1650},
--                   {"kind":"MATERIAL","description":"Brass valve","quantity":1,"unit_price":800}]
CREATE OR REPLACE FUNCTION fn_submit_offer(p_job_id UUID, p_items JSONB, p_warranty INT, p_arrival_min INT, p_note TEXT, p_available_from TIMESTAMPTZ DEFAULT NULL)
RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_pro UUID := my_pro_id(); v_offer UUID; v_labor NUMERIC(10,2); v_mat NUMERIC(10,2); v_cust UUID;
BEGIN
    IF v_pro IS NULL THEN RAISE EXCEPTION 'Only professionals can submit offers' USING ERRCODE = 'insufficient_privilege'; END IF;
    IF NOT EXISTS (SELECT 1 FROM pro_profiles p JOIN users u ON u.id = p.user_id
                   WHERE p.id = v_pro AND p.verification = 'VERIFIED' AND u.status = 'ACTIVE') THEN
        RAISE EXCEPTION 'Professional is not verified or not active' USING ERRCODE = 'insufficient_privilege';
    END IF;
    SELECT customer_id INTO v_cust FROM job_requests WHERE id = p_job_id AND status = 'PENDING_OFFERS';
    IF NOT FOUND THEN RAISE EXCEPTION 'Job is not open for offers' USING ERRCODE = 'check_violation'; END IF;

    SELECT COALESCE(SUM((i->>'quantity')::numeric * (i->>'unit_price')::numeric) FILTER (WHERE i->>'kind' = 'LABOR'), 0),
           COALESCE(SUM((i->>'quantity')::numeric * (i->>'unit_price')::numeric) FILTER (WHERE i->>'kind' = 'MATERIAL'), 0)
      INTO v_labor, v_mat FROM jsonb_array_elements(p_items) i;
    IF v_labor + v_mat <= 0 THEN RAISE EXCEPTION 'Offer total must be greater than zero' USING ERRCODE = 'check_violation'; END IF;

    INSERT INTO offers (job_id, pro_id, labor_amount, materials_amount, total_amount, warranty_months, estimated_arrival_minutes, available_from, note)
    VALUES (p_job_id, v_pro, v_labor, v_mat, v_labor + v_mat, COALESCE(p_warranty, 6), p_arrival_min, p_available_from, p_note)
    RETURNING id INTO v_offer;
    INSERT INTO offer_items (offer_id, kind, description, quantity, unit_price)
    SELECT v_offer, (i->>'kind')::offer_item_kind, i->>'description', (i->>'quantity')::numeric, (i->>'unit_price')::numeric
    FROM jsonb_array_elements(p_items) i;
    PERFORM notify(v_cust, 'NEW_OFFER', p_job_id, jsonb_build_object('offer_id', v_offer, 'total', v_labor + v_mat));
    RETURN v_offer;
END $$;

-- Accept an offer: row lock (only one winner), other offers rejected, money locked in the pool, PIN created.
-- p_provider_ref / p_card_last4 come from the payment provider (test mode for the project).
CREATE OR REPLACE FUNCTION fn_accept_offer(p_job_id UUID, p_offer_id UUID, p_provider_ref TEXT, p_card_last4 CHAR(4))
RETURNS TABLE (payment_id UUID, completion_pin VARCHAR) LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_job job_requests%ROWTYPE; v_offer offers%ROWTYPE; v_pin VARCHAR(6); v_pay UUID; v_comm NUMERIC(10,2); v_pro_user UUID;
BEGIN
    SELECT * INTO v_job FROM job_requests WHERE id = p_job_id FOR UPDATE;
    IF NOT FOUND OR v_job.customer_id IS DISTINCT FROM auth.uid() THEN
        RAISE EXCEPTION 'Job not found for this customer' USING ERRCODE = 'no_data_found';
    END IF;
    IF v_job.status <> 'PENDING_OFFERS' THEN
        RAISE EXCEPTION 'An offer was already accepted or the job is closed (status %)', v_job.status USING ERRCODE = 'check_violation';
    END IF;
    SELECT * INTO v_offer FROM offers WHERE id = p_offer_id AND job_id = p_job_id AND status = 'PENDING' FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Offer is not available' USING ERRCODE = 'no_data_found'; END IF;

    UPDATE offers SET status = 'ACCEPTED' WHERE id = p_offer_id;
    UPDATE offers SET status = 'REJECTED', rejection_reason = 'ANOTHER_OFFER_ACCEPTED' WHERE job_id = p_job_id AND id <> p_offer_id AND status = 'PENDING';

    v_pin  := lpad((floor(random() * 1000000))::int::text, 6, '0');
    v_comm := ROUND(v_offer.total_amount * 0.10, 2);
    INSERT INTO payments (job_id, offer_id, customer_id, pro_id, total_amount, platform_commission, pro_payout_amount, status, provider_ref, card_last4, locked_at)
    VALUES (p_job_id, p_offer_id, v_job.customer_id, v_offer.pro_id, v_offer.total_amount, v_comm, v_offer.total_amount - v_comm, 'LOCKED', p_provider_ref, p_card_last4, NOW())
    RETURNING id INTO v_pay;
    UPDATE job_requests SET status = 'SCHEDULED', selected_offer_id = p_offer_id, completion_pin = v_pin WHERE id = p_job_id;

    SELECT user_id INTO v_pro_user FROM pro_profiles WHERE id = v_offer.pro_id;
    PERFORM notify(v_pro_user, 'OFFER_ACCEPTED', p_job_id);
    PERFORM notify(v_job.customer_id, 'PAYMENT_LOCKED', p_job_id, jsonb_build_object('amount', v_offer.total_amount));
    RETURN QUERY SELECT v_pay, v_pin;
END $$;

-- A payment attempt that failed (3D Secure error): nothing is charged, offer stays open. Records the error for the "Payment Failed" screen.
CREATE OR REPLACE FUNCTION fn_record_failed_payment(p_job_id UUID, p_offer_id UUID, p_error_code VARCHAR, p_card_last4 CHAR(4)) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    IF NOT owns_job(p_job_id) THEN RAISE EXCEPTION 'Job not found for this customer' USING ERRCODE = 'no_data_found'; END IF;
    PERFORM notify(auth.uid(), 'PAYMENT_FAILED', p_job_id, jsonb_build_object('offer_id', p_offer_id, 'error', p_error_code, 'card_last4', p_card_last4));
END $$;

CREATE OR REPLACE FUNCTION fn_reject_offer(p_offer_id UUID, p_reason VARCHAR, p_note TEXT DEFAULT NULL) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_job UUID; v_pro_user UUID;
BEGIN
    UPDATE offers o SET status = 'REJECTED', rejection_reason = p_reason, rejection_note = p_note
    FROM job_requests j
    WHERE o.id = p_offer_id AND o.job_id = j.id AND j.customer_id = auth.uid() AND o.status = 'PENDING' AND j.status = 'PENDING_OFFERS'
    RETURNING o.job_id INTO v_job;
    IF NOT FOUND THEN RAISE EXCEPTION 'Offer cannot be rejected' USING ERRCODE = 'no_data_found'; END IF;
    SELECT p.user_id INTO v_pro_user FROM offers o JOIN pro_profiles p ON p.id = o.pro_id WHERE o.id = p_offer_id;
    PERFORM notify(v_pro_user, 'OFFER_REJECTED', v_job, jsonb_build_object('reason', p_reason));
END $$;

-- ---------- appointments ----------
CREATE OR REPLACE FUNCTION fn_request_appointment(p_job_id UUID, p_start TIMESTAMPTZ, p_end TIMESTAMPTZ) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_id UUID; v_pro_user UUID;
BEGIN
    IF NOT owns_job(p_job_id) THEN RAISE EXCEPTION 'Job not found for this customer' USING ERRCODE = 'no_data_found'; END IF;
    IF NOT EXISTS (SELECT 1 FROM job_requests WHERE id = p_job_id AND status = 'SCHEDULED') THEN
        RAISE EXCEPTION 'Appointments can be set only after an offer is accepted' USING ERRCODE = 'check_violation';
    END IF;
    UPDATE appointments SET status = 'CANCELLED', cancel_reason = 'REPLACED', cancelled_by = auth.uid()
        WHERE job_id = p_job_id AND status IN ('REQUESTED', 'CONFIRMED', 'RESCHEDULE_REQUESTED');
    INSERT INTO appointments (job_id, starts_at, ends_at) VALUES (p_job_id, p_start, p_end) RETURNING id INTO v_id;
    SELECT p.user_id INTO v_pro_user FROM job_requests j JOIN offers o ON o.id = j.selected_offer_id JOIN pro_profiles p ON p.id = o.pro_id WHERE j.id = p_job_id;
    PERFORM notify(v_pro_user, 'APPOINTMENT_CONFIRMED', p_job_id, jsonb_build_object('status', 'REQUESTED', 'starts_at', p_start));
    RETURN v_id;
END $$;

CREATE OR REPLACE FUNCTION fn_respond_appointment(p_appointment_id UUID, p_accept BOOLEAN) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_a appointments%ROWTYPE; v_cust UUID;
BEGIN
    SELECT * INTO v_a FROM appointments WHERE id = p_appointment_id AND status = 'REQUESTED' FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Appointment not found' USING ERRCODE = 'no_data_found'; END IF;
    IF NOT EXISTS (SELECT 1 FROM job_requests j JOIN offers o ON o.id = j.selected_offer_id
                   WHERE j.id = v_a.job_id AND o.pro_id = my_pro_id()) THEN
        RAISE EXCEPTION 'Only the professional of this job can answer' USING ERRCODE = 'insufficient_privilege';
    END IF;
    UPDATE appointments SET status = CASE WHEN p_accept THEN 'CONFIRMED'::appointment_status ELSE 'RESCHEDULE_REQUESTED'::appointment_status END WHERE id = p_appointment_id;
    SELECT customer_id INTO v_cust FROM job_requests WHERE id = v_a.job_id;
    PERFORM notify(v_cust, 'APPOINTMENT_CONFIRMED', v_a.job_id, jsonb_build_object('status', CASE WHEN p_accept THEN 'CONFIRMED' ELSE 'RESCHEDULE_REQUESTED' END, 'starts_at', v_a.starts_at));
END $$;

CREATE OR REPLACE FUNCTION fn_cancel_appointment(p_appointment_id UUID, p_reason VARCHAR, p_note TEXT DEFAULT NULL) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_a appointments%ROWTYPE; v_cust UUID; v_pro_user UUID;
BEGIN
    SELECT * INTO v_a FROM appointments WHERE id = p_appointment_id AND status IN ('REQUESTED', 'CONFIRMED', 'RESCHEDULE_REQUESTED') FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Appointment not found' USING ERRCODE = 'no_data_found'; END IF;
    IF NOT is_job_party(v_a.job_id) THEN RAISE EXCEPTION 'Not allowed' USING ERRCODE = 'insufficient_privilege'; END IF;
    IF NOT EXISTS (SELECT 1 FROM job_requests WHERE id = v_a.job_id AND status = 'SCHEDULED') THEN
        RAISE EXCEPTION 'Appointment can be cancelled only before the job starts' USING ERRCODE = 'check_violation';
    END IF;
    UPDATE appointments SET status = 'CANCELLED', cancel_reason = p_reason, cancel_note = p_note, cancelled_by = auth.uid() WHERE id = p_appointment_id;
    SELECT j.customer_id, p.user_id INTO v_cust, v_pro_user FROM job_requests j JOIN offers o ON o.id = j.selected_offer_id JOIN pro_profiles p ON p.id = o.pro_id WHERE j.id = v_a.job_id;
    PERFORM notify(CASE WHEN auth.uid() = v_cust THEN v_pro_user ELSE v_cust END, 'APPOINTMENT_CANCELLED', v_a.job_id, jsonb_build_object('reason', p_reason));
END $$;

-- Customer cancels the whole job. If money is in the pool it goes back to the customer (RAD: no deduction before the job starts).
CREATE OR REPLACE FUNCTION fn_cancel_job(p_job_id UUID) RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_job job_requests%ROWTYPE;
BEGIN
    SELECT * INTO v_job FROM job_requests WHERE id = p_job_id AND customer_id = auth.uid() FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Job not found' USING ERRCODE = 'no_data_found'; END IF;
    IF v_job.status NOT IN ('DRAFT', 'PENDING_OFFERS', 'ESCROW_PENDING', 'SCHEDULED') THEN
        RAISE EXCEPTION 'Job cannot be cancelled in status %', v_job.status USING ERRCODE = 'check_violation';
    END IF;
    UPDATE payments SET status = 'REFUNDED_TO_CUSTOMER', refunded_at = NOW() WHERE job_id = p_job_id AND status = 'LOCKED';
    UPDATE appointments SET status = 'CANCELLED', cancel_reason = 'JOB_CANCELLED', cancelled_by = auth.uid()
        WHERE job_id = p_job_id AND status IN ('REQUESTED', 'CONFIRMED', 'RESCHEDULE_REQUESTED');
    UPDATE offers SET status = 'REJECTED', rejection_reason = 'JOB_CANCELLED' WHERE job_id = p_job_id AND status = 'PENDING';
    UPDATE job_requests SET status = 'CANCELLED' WHERE id = p_job_id;
END $$;

-- ---------- job progress (professional) ----------
CREATE OR REPLACE FUNCTION fn_set_job_progress(p_job_id UUID, p_to job_status) RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_job job_requests%ROWTYPE;
BEGIN
    SELECT j.* INTO v_job FROM job_requests j JOIN offers o ON o.id = j.selected_offer_id
    WHERE j.id = p_job_id AND o.pro_id = my_pro_id() FOR UPDATE OF j;
    IF NOT FOUND THEN RAISE EXCEPTION 'Job not found for this professional' USING ERRCODE = 'no_data_found'; END IF;
    IF NOT ((v_job.status = 'SCHEDULED'    AND p_to = 'PRO_EN_ROUTE') OR
            (v_job.status = 'PRO_EN_ROUTE' AND p_to = 'IN_PROGRESS') OR
            (v_job.status = 'IN_PROGRESS'  AND p_to = 'COMPLETED')) THEN
        RAISE EXCEPTION 'Invalid status change % -> %', v_job.status, p_to USING ERRCODE = 'check_violation';
    END IF;
    IF p_to = 'PRO_EN_ROUTE' AND NOT EXISTS (SELECT 1 FROM appointments WHERE job_id = p_job_id AND status = 'CONFIRMED') THEN
        RAISE EXCEPTION 'The appointment must be confirmed first' USING ERRCODE = 'check_violation';
    END IF;
    UPDATE job_requests SET status = p_to WHERE id = p_job_id;
    IF p_to = 'COMPLETED' THEN
        UPDATE appointments SET status = 'DONE' WHERE job_id = p_job_id AND status = 'CONFIRMED';
        PERFORM notify(v_job.customer_id, 'JOB_COMPLETED', p_job_id);
    END IF;
END $$;

-- Live navigation: only while the professional is on the way / working
CREATE OR REPLACE FUNCTION fn_update_pro_location(p_lat NUMERIC, p_lng NUMERIC) RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_pro UUID := my_pro_id();
BEGIN
    IF v_pro IS NULL OR NOT EXISTS (SELECT 1 FROM job_requests j JOIN offers o ON o.id = j.selected_offer_id
                                     WHERE o.pro_id = v_pro AND j.status IN ('PRO_EN_ROUTE', 'IN_PROGRESS')) THEN
        RAISE EXCEPTION 'Location is shared only during an active job' USING ERRCODE = 'check_violation';
    END IF;
    INSERT INTO pro_locations (pro_id, lat, lng) VALUES (v_pro, p_lat, p_lng)
    ON CONFLICT (pro_id) DO UPDATE SET lat = EXCLUDED.lat, lng = EXCLUDED.lng, updated_at = NOW();
END $$;

-- ---------- completion, review, money release ----------
CREATE OR REPLACE FUNCTION fn_complete_work(p_job_id UUID, p_pin VARCHAR, p_rating INT DEFAULT NULL, p_review TEXT DEFAULT NULL,
                                            p_tags TEXT[] DEFAULT '{}', p_show_full_name BOOLEAN DEFAULT FALSE)
RETURNS TABLE (total_paid NUMERIC, pro_earnings NUMERIC, platform_fee NUMERIC) LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_job job_requests%ROWTYPE; v_pay payments%ROWTYPE;
BEGIN
    SELECT * INTO v_job FROM job_requests WHERE id = p_job_id AND customer_id = auth.uid() FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Job not found' USING ERRCODE = 'no_data_found'; END IF;
    IF v_job.status NOT IN ('SCHEDULED', 'PRO_EN_ROUTE', 'IN_PROGRESS', 'COMPLETED') THEN
        RAISE EXCEPTION 'Job cannot be completed from status %', v_job.status USING ERRCODE = 'check_violation';
    END IF;
    IF v_job.completion_pin IS DISTINCT FROM p_pin THEN RAISE EXCEPTION 'Wrong completion PIN' USING ERRCODE = 'invalid_password'; END IF;
    SELECT * INTO v_pay FROM payments WHERE job_id = p_job_id FOR UPDATE;
    IF v_pay.status IS DISTINCT FROM 'LOCKED' THEN RAISE EXCEPTION 'Payment is not in the pool' USING ERRCODE = 'check_violation'; END IF;

    UPDATE payments SET status = 'RELEASED_TO_PRO', released_at = NOW() WHERE id = v_pay.id;
    UPDATE job_requests SET status = 'RELEASED' WHERE id = p_job_id;
    UPDATE appointments SET status = 'DONE' WHERE job_id = p_job_id AND status = 'CONFIRMED';
    UPDATE pro_profiles SET completed_jobs_count = completed_jobs_count + 1 WHERE id = v_pay.pro_id;
    IF p_rating IS NOT NULL THEN
        INSERT INTO reviews (job_id, customer_id, pro_id, rating, tags, comment, show_full_name)
        VALUES (p_job_id, v_job.customer_id, v_pay.pro_id, p_rating, COALESCE(p_tags, '{}'), p_review, p_show_full_name);
    END IF;
    RETURN QUERY SELECT v_pay.total_amount, v_pay.pro_payout_amount, v_pay.platform_commission;
END $$;

-- The customer can add the review later (rating step after approval)
CREATE OR REPLACE FUNCTION fn_add_review(p_job_id UUID, p_rating INT, p_review TEXT DEFAULT NULL, p_tags TEXT[] DEFAULT '{}', p_show_full_name BOOLEAN DEFAULT FALSE) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_id UUID; v_pro UUID;
BEGIN
    SELECT p.pro_id INTO v_pro FROM payments p JOIN job_requests j ON j.id = p.job_id
    WHERE p.job_id = p_job_id AND j.customer_id = auth.uid() AND j.status = 'RELEASED';
    IF NOT FOUND THEN RAISE EXCEPTION 'You can rate a job only after it is completed' USING ERRCODE = 'check_violation'; END IF;
    INSERT INTO reviews (job_id, customer_id, pro_id, rating, tags, comment, show_full_name)
    VALUES (p_job_id, auth.uid(), v_pro, p_rating, COALESCE(p_tags, '{}'), p_review, p_show_full_name) RETURNING id INTO v_id;
    RETURN v_id;
END $$;

-- ---------- address and PIN (hidden columns, shown only to the right people) ----------
CREATE OR REPLACE FUNCTION fn_get_job_address(p_job_id UUID) RETURNS TEXT LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
DECLARE v_job job_requests%ROWTYPE;
BEGIN
    SELECT * INTO v_job FROM job_requests WHERE id = p_job_id;
    IF NOT FOUND THEN RETURN NULL; END IF;
    IF v_job.customer_id = auth.uid() OR is_admin() THEN RETURN v_job.address_full_encrypted; END IF;
    -- the accepted professional sees the exact address only after the appointment is confirmed
    IF is_job_party(p_job_id) AND EXISTS (SELECT 1 FROM appointments WHERE job_id = p_job_id AND status IN ('CONFIRMED', 'DONE')) THEN
        RETURN v_job.address_full_encrypted;
    END IF;
    RETURN v_job.address_line_masked;
END $$;

CREATE OR REPLACE FUNCTION fn_my_job_pin(p_job_id UUID) RETURNS VARCHAR LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
    SELECT completion_pin FROM job_requests WHERE id = p_job_id AND customer_id = auth.uid();
$$;

-- ---------- complaints ----------
CREATE OR REPLACE FUNCTION fn_open_dispute(p_job_id UUID, p_type dispute_type, p_description TEXT) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_id UUID; v_pro UUID;
BEGIN
    SELECT pro_id INTO v_pro FROM payments WHERE job_id = p_job_id AND customer_id = auth.uid() AND status = 'LOCKED' FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'No locked payment for this job' USING ERRCODE = 'no_data_found'; END IF;
    INSERT INTO disputes (case_no, job_id, opened_by, against_pro_id, type, description)
    VALUES ('CMP-' || nextval('dispute_case_seq'), p_job_id, auth.uid(), v_pro, p_type, p_description) RETURNING id INTO v_id;
    UPDATE payments SET status = 'DISPUTED' WHERE job_id = p_job_id;
    UPDATE job_requests SET status = 'DISPUTED' WHERE id = p_job_id;
    RETURN v_id;
END $$;

CREATE OR REPLACE FUNCTION fn_decide_dispute(p_dispute_id UUID, p_decision dispute_decision, p_reason TEXT) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_d disputes%ROWTYPE; v_pay payments%ROWTYPE;
BEGIN
    IF NOT is_admin() THEN RAISE EXCEPTION 'Only an administrator can decide a dispute' USING ERRCODE = 'insufficient_privilege'; END IF;
    SELECT * INTO v_d FROM disputes WHERE id = p_dispute_id AND status IN ('OPEN', 'UNDER_REVIEW') FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Dispute not open' USING ERRCODE = 'no_data_found'; END IF;
    SELECT * INTO v_pay FROM payments WHERE job_id = v_d.job_id FOR UPDATE;

    UPDATE disputes SET status = CASE WHEN p_decision = 'REJECT_COMPLAINT' THEN 'REJECTED'::dispute_status ELSE 'RESOLVED'::dispute_status END,
        decision = p_decision, decision_reason = p_reason, decided_by = auth.uid(), decided_at = NOW() WHERE id = p_dispute_id;
    IF p_decision = 'FULL_REFUND' THEN
        UPDATE payments SET status = 'REFUNDED_TO_CUSTOMER', refunded_at = NOW() WHERE id = v_pay.id;
        UPDATE job_requests SET status = 'CANCELLED' WHERE id = v_d.job_id;
    ELSIF p_decision = 'SPLIT_50_50' THEN
        UPDATE payments SET status = 'PARTIALLY_REFUNDED', refunded_at = NOW(), released_at = NOW() WHERE id = v_pay.id;
        UPDATE job_requests SET status = 'RELEASED' WHERE id = v_d.job_id;
    ELSE
        UPDATE payments SET status = 'RELEASED_TO_PRO', released_at = NOW() WHERE id = v_pay.id;
        UPDATE job_requests SET status = 'RELEASED' WHERE id = v_d.job_id;
    END IF;
    INSERT INTO admin_actions (admin_id, action, target_type, target_id, details)
    VALUES (auth.uid(), 'DECIDE_DISPUTE', 'dispute', p_dispute_id, jsonb_build_object('decision', p_decision, 'reason', p_reason));
    PERFORM notify(v_d.opened_by, 'DISPUTE_UPDATE', v_d.job_id, jsonb_build_object('decision', p_decision));
END $$;

-- ---------- admin ----------
CREATE OR REPLACE FUNCTION fn_review_document(p_doc_id UUID, p_status verification_status, p_note TEXT DEFAULT NULL) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    IF NOT is_admin() THEN RAISE EXCEPTION 'Admin only' USING ERRCODE = 'insufficient_privilege'; END IF;
    UPDATE pro_documents SET status = p_status, review_note = p_note, reviewed_by = auth.uid(), reviewed_at = NOW() WHERE id = p_doc_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Document not found' USING ERRCODE = 'no_data_found'; END IF;
    INSERT INTO admin_actions (admin_id, action, target_type, target_id, details)
    VALUES (auth.uid(), 'REVIEW_DOCUMENT', 'pro_document', p_doc_id, jsonb_build_object('status', p_status, 'note', p_note));
END $$;

-- Approve / reject a professional application. Approval needs all three documents verified.
CREATE OR REPLACE FUNCTION fn_decide_pro_application(p_pro_id UUID, p_status verification_status) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    IF NOT is_admin() THEN RAISE EXCEPTION 'Admin only' USING ERRCODE = 'insufficient_privilege'; END IF;
    IF p_status = 'VERIFIED' AND (SELECT count(DISTINCT doc_type) FROM pro_documents
         WHERE pro_id = p_pro_id AND status = 'VERIFIED' AND doc_type IN ('TAX_CERTIFICATE', 'MASTER_CERTIFICATE', 'CRIMINAL_RECORD')) < 3 THEN
        RAISE EXCEPTION 'All three documents must be verified first' USING ERRCODE = 'check_violation';
    END IF;
    UPDATE pro_profiles SET verification = p_status,
        identity_verified = (p_status = 'VERIFIED'), tax_verified = (p_status = 'VERIFIED'), criminal_record_verified = (p_status = 'VERIFIED')
    WHERE id = p_pro_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Professional not found' USING ERRCODE = 'no_data_found'; END IF;
    INSERT INTO admin_actions (admin_id, action, target_type, target_id, details)
    VALUES (auth.uid(), 'DECIDE_PRO_APPLICATION', 'pro_profile', p_pro_id, jsonb_build_object('status', p_status));
END $$;

CREATE OR REPLACE FUNCTION fn_set_account_status(p_user_id UUID, p_status account_status) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    IF NOT is_admin() THEN RAISE EXCEPTION 'Admin only' USING ERRCODE = 'insufficient_privilege'; END IF;
    UPDATE users SET status = p_status WHERE id = p_user_id AND role <> 'ADMIN';
    IF NOT FOUND THEN RAISE EXCEPTION 'User not found' USING ERRCODE = 'no_data_found'; END IF;
    INSERT INTO admin_actions (admin_id, action, target_type, target_id, details)
    VALUES (auth.uid(), 'SET_ACCOUNT_STATUS', 'user', p_user_id, jsonb_build_object('status', p_status));
END $$;

-- ---------- public view of professionals (no private data) ----------
CREATE OR REPLACE VIEW pro_public_profiles AS
SELECT p.id AS pro_id, p.business_name, u.first_name, left(u.last_name, 1) || '.' AS last_initial, u.avatar_url,
       p.primary_category_id, p.experience_years, p.bio, p.rating_avg, p.total_reviews_count, p.completed_jobs_count,
       (p.verification = 'VERIFIED') AS is_verified, p.identity_verified, p.criminal_record_verified
FROM pro_profiles p JOIN users u ON u.id = p.user_id
WHERE u.status = 'ACTIVE';
