-- Local test of the whole Supabase setup (run after the stub + 01..05 files). Prints a PASS/FAIL line per check and a summary.
\set ON_ERROR_STOP off
\set QUIET on
\pset tuples_only on
CREATE SCHEMA t; GRANT USAGE ON SCHEMA t TO PUBLIC;
CREATE TABLE t.results (n SERIAL, name TEXT, ok BOOLEAN); GRANT ALL ON t.results TO PUBLIC; GRANT ALL ON SEQUENCE t.results_n_seq TO PUBLIC;
CREATE FUNCTION t.check(p_name TEXT, p_ok BOOLEAN) RETURNS VOID LANGUAGE plpgsql AS $$ BEGIN INSERT INTO t.results (name, ok) VALUES (p_name, COALESCE(p_ok, false)); END $$;
-- run p_sql and expect it to fail with the given SQLSTATE
CREATE FUNCTION t.fails(p_name TEXT, p_sql TEXT, p_state TEXT) RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE p_sql;
    INSERT INTO t.results (name, ok) VALUES (p_name || ' (expected an error, got none)', false);
EXCEPTION WHEN OTHERS THEN
    INSERT INTO t.results (name, ok) VALUES (p_name || CASE WHEN SQLSTATE = p_state THEN '' ELSE ' (wrong error ' || SQLSTATE || ': ' || left(SQLERRM, 60) || ')' END, SQLSTATE = p_state);
END $$;
CREATE FUNCTION t.as_user(p_id UUID) RETURNS VOID LANGUAGE plpgsql AS $$ BEGIN PERFORM set_config('request.jwt.claim.sub', p_id::text, false); EXECUTE 'SET ROLE authenticated'; END $$;
CREATE FUNCTION t.as_anon() RETURNS VOID LANGUAGE plpgsql AS $$ BEGIN PERFORM set_config('request.jwt.claim.sub', '', false); EXECUTE 'SET ROLE anon'; END $$;
CREATE FUNCTION t.as_super() RETURNS VOID LANGUAGE plpgsql AS $$ BEGIN EXECUTE 'RESET ROLE'; PERFORM set_config('request.jwt.claim.sub', '', false); END $$;

-- ids
\set C1 '''00000000-0000-0000-0000-0000000000a1'''
\set C2 '''00000000-0000-0000-0000-0000000000a2'''
\set G1 '''00000000-0000-0000-0000-0000000000a3'''
\set P1 '''00000000-0000-0000-0000-0000000000b1'''
\set P2 '''00000000-0000-0000-0000-0000000000b2'''
\set P3 '''00000000-0000-0000-0000-0000000000b3'''
\set AD '''00000000-0000-0000-0000-0000000000c1'''
\set J1 '''00000000-0000-0000-0000-0000000000f1'''
\set J2 '''00000000-0000-0000-0000-0000000000f2'''
\set J3 '''00000000-0000-0000-0000-0000000000f3'''

-- ===== A. sign-up creates profiles =====
INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES
 (:C1,'ali@test.com','{"first_name":"Ali","last_name":"Yılmaz","preferred_lang":"en","role":"ADMIN"}'),
 (:C2,'ayse@test.com','{"first_name":"Ayşe","last_name":"Demir"}'),
 (:G1,'google@test.com','{"full_name":"Zeynep Kaya Öztürk","avatar_url":"http://x/a.png"}'),
 (:P1,'mehmet@test.com','{"first_name":"Mehmet","last_name":"Demir"}'),
 (:P2,'ahmet@test.com','{"first_name":"Ahmet","last_name":"Kaya"}'),
 (:P3,'selim@test.com','{"first_name":"Selim","last_name":"Aksoy"}'),
 (:AD,'hakan@test.com','{"first_name":"Hakan","last_name":"T"}');
UPDATE users SET role = 'ADMIN' WHERE id = :AD;
SELECT t.check('A1 profile created on sign-up', (SELECT count(*) FROM users) = 7);
SELECT t.check('A2 role in sign-up data is ignored (stays CUSTOMER)', (SELECT role FROM users WHERE id = :C1) = 'CUSTOMER');
SELECT t.check('A3 Google name split into first/last', (SELECT first_name || '|' || last_name FROM users WHERE id = :G1) = 'Zeynep|Kaya Öztürk');
INSERT INTO auth.users (id, phone) VALUES ('00000000-0000-0000-0000-0000000000a9', '905321234567');
INSERT INTO auth.users (id, phone) VALUES ('00000000-0000-0000-0000-0000000000aa', '4915112345678');
SELECT t.check('A5 phone sign-up: number stored with +90, empty name, CUSTOMER', (SELECT phone_number || '|' || first_name || '|' || role FROM users WHERE id = '00000000-0000-0000-0000-0000000000a9') = '+905321234567||CUSTOMER');
SELECT t.check('A6 non-Turkish phone does not break sign-up', (SELECT phone_number IS NULL FROM users WHERE id = '00000000-0000-0000-0000-0000000000aa'));
DELETE FROM auth.users WHERE id IN ('00000000-0000-0000-0000-0000000000a9','00000000-0000-0000-0000-0000000000aa');
SELECT t.check('A4 language preference saved (en)', (SELECT preferred_lang FROM users WHERE id = :C1) = 'en');

-- ===== B. professional registration and admin approval =====
SELECT t.as_user(:P1); SELECT fn_register_pro('Mavi Hat Su Tesisatı','plumbing',12,ARRAY['Kadıköy','Üsküdar']);
SELECT t.as_user(:P2); SELECT fn_register_pro('Kaya Tesisat','plumbing',8,ARRAY['Kadıköy']);
SELECT t.as_user(:P3); SELECT fn_register_pro('Aksoy Tesisat','plumbing',5,ARRAY['Maltepe']);
SELECT t.as_super();
SELECT t.check('B1 registered user became PRO, status PENDING', (SELECT role::text || verification::text FROM users u JOIN pro_profiles p ON p.user_id = u.id WHERE u.id = :P1) = 'PROPENDING');
SELECT t.as_user(:P1);
SELECT t.fails('B2 customer cannot register twice as pro', 'SELECT fn_register_pro(''x'',''plumbing'',1,ARRAY[''Kadıköy''])', '23514');
SELECT t.as_user(:P1);
SELECT t.fails('B3 unverified pro cannot submit offers', 'SELECT fn_submit_offer(''00000000-0000-0000-0000-0000000000f1'',''[{"kind":"LABOR","description":"x","quantity":1,"unit_price":100}]'',6,30,'''')', '42501');
SELECT t.fails('B4 document over 2.5 MB refused', 'INSERT INTO pro_documents (pro_id, doc_type, file_url, file_size_bytes) VALUES (my_pro_id(), ''TAX_CERTIFICATE'', ''x.pdf'', 3000000)', '23514');
INSERT INTO pro_documents (pro_id, doc_type, file_url, file_size_bytes) SELECT my_pro_id(), d, 'p1/' || d || '.pdf', 500000 FROM unnest(ARRAY['TAX_CERTIFICATE','MASTER_CERTIFICATE','CRIMINAL_RECORD']::document_type[]) d;
SELECT t.check('B5 pro uploaded 3 documents', (SELECT count(*) FROM pro_documents) = 3);
SELECT t.fails('B6 pro cannot approve own documents', 'SELECT fn_review_document((SELECT id FROM pro_documents LIMIT 1), ''VERIFIED'')', '42501');
SELECT t.fails('B7 pro cannot change own verification directly', 'UPDATE pro_profiles SET verification = ''VERIFIED''', '42501');
SELECT t.as_user(:AD);
SELECT t.fails('B8 cannot approve before documents verified', 'SELECT fn_decide_pro_application((SELECT id FROM pro_profiles WHERE user_id = ''00000000-0000-0000-0000-0000000000b1''), ''VERIFIED'')', '23514');
SELECT fn_review_document(id, 'VERIFIED') FROM pro_documents;
SELECT fn_decide_pro_application((SELECT id FROM pro_profiles WHERE user_id = :P1), 'VERIFIED');
SELECT fn_decide_pro_application((SELECT id FROM pro_profiles WHERE user_id = :P2), 'VERIFIED') WHERE false;  -- P2/P3 verified directly below as service role
SELECT t.check('B9 admin approved professional', (SELECT verification FROM pro_profiles WHERE user_id = :P1) = 'VERIFIED');
SELECT t.as_super();
UPDATE pro_profiles SET verification = 'VERIFIED' WHERE user_id IN (:P2, :P3);   -- (test shortcut)

-- ===== C. requests =====
SELECT t.as_user(:C1);
INSERT INTO job_requests (id, customer_id, category_id, title, description, district, neighborhood, address_line_masked, address_full_encrypted, status)
VALUES (:J1, :C1, 'plumbing', 'Bathroom sink leak', 'Water is leaking from under the bathroom sink.', 'Kadıköy', 'Caferağa', 'Caferağa Mah.', 'Caferağa Mah. Şair Nefi Sk. No:14 D:4', 'PENDING_OFFERS');
SELECT t.check('C1 customer created a request', (SELECT count(*) FROM job_requests) = 1);
SELECT t.fails('C2 cannot create a request for someone else', 'INSERT INTO job_requests (customer_id, category_id, title, description, district, neighborhood) VALUES (''00000000-0000-0000-0000-0000000000a2'',''plumbing'',''x'',''0123456789 ab'',''Kadıköy'',''Moda'')', '42501');
SELECT t.fails('C3 cannot create an already-scheduled request', 'INSERT INTO job_requests (customer_id, category_id, title, description, district, neighborhood, status) VALUES (auth.uid(),''plumbing'',''x'',''0123456789 ab'',''Kadıköy'',''Moda'',''SCHEDULED'')', '42501');
SELECT t.fails('C4 exact address column is not readable', 'SELECT address_full_encrypted FROM job_requests', '42501');
SELECT t.fails('C5 PIN column is not readable', 'SELECT completion_pin FROM job_requests', '42501');
SELECT t.check('C6 owner gets exact address through the function', fn_get_job_address(:J1) LIKE '%Şair Nefi%');
SELECT t.fails('C7 photo over 2.5 MB refused', 'INSERT INTO job_photos (job_id, file_url, file_size_bytes) VALUES (''00000000-0000-0000-0000-0000000000f1'', ''x.jpg'', 3000000)', '23514');
SELECT t.as_user(:C2);
SELECT t.check('C8 another customer cannot see the request', (SELECT count(*) FROM job_requests) = 0);
SELECT t.as_user(:P1);
SELECT t.check('C9 matching verified pro sees the request in the feed', (SELECT count(*) FROM job_requests) = 1);
SELECT t.check('C10 pro sees only the masked address', fn_get_job_address(:J1) = 'Caferağa Mah.');
SELECT t.as_user(:P3);
SELECT t.check('C11 pro from another district does not see it', (SELECT count(*) FROM job_requests) = 0);
SELECT t.as_anon();
SELECT t.check('C12 not-logged-in user can read categories', (SELECT count(*) FROM service_categories) = 8);
SELECT t.fails('C13 not-logged-in user cannot read requests', 'SELECT * FROM job_requests', '42501');

-- ===== D. offers =====
SELECT t.as_user(:P1);
SELECT fn_submit_offer(:J1, '[{"kind":"LABOR","description":"Valve replacement","quantity":1,"unit_price":1650},{"kind":"MATERIAL","description":"Brass valve","quantity":1,"unit_price":800}]', 6, 45, 'ok');
SELECT t.as_user(:P2);
SELECT fn_submit_offer(:J1, '[{"kind":"LABOR","description":"Work","quantity":1,"unit_price":1500},{"kind":"MATERIAL","description":"Parts","quantity":2,"unit_price":350}]', 3, 60, '');
SELECT t.fails('D1 same pro cannot bid twice', 'SELECT fn_submit_offer(''00000000-0000-0000-0000-0000000000f1'',''[{"kind":"LABOR","description":"x","quantity":1,"unit_price":5}]'',6,1,'''')', '23505');
SELECT t.check('D2 pro2 sees only own offer', (SELECT count(*) FROM offers) = 1);
SELECT t.as_user(:C1);
SELECT t.check('D3 customer sees both offers with correct totals', (SELECT string_agg(total_amount::text, ',' ORDER BY total_amount) FROM offers) = '2200.00,2450.00');
SELECT t.check('D4 offer items visible to the customer', (SELECT count(*) FROM offer_items) = 4);
SELECT t.check('D5 customer got "new offer" notifications', (SELECT count(*) FROM notifications WHERE type = 'NEW_OFFER') = 2);
SELECT t.as_user(:C2);
SELECT t.check('D6 other customer sees no offers', (SELECT count(*) FROM offers) = 0);

-- ===== E. cannot cheat around the functions =====
SELECT t.as_user(:C1);
SELECT t.fails('E1 cannot set status directly to RELEASED', 'UPDATE job_requests SET status = ''RELEASED''', '42501');
SELECT t.fails('E2 cannot write payments directly', 'INSERT INTO payments (job_id, offer_id, customer_id, pro_id, total_amount, platform_commission, pro_payout_amount) VALUES (gen_random_uuid(), gen_random_uuid(), auth.uid(), gen_random_uuid(), 10, 1, 9)', '42501');
SELECT t.fails('E3 cannot make yourself admin', 'UPDATE users SET role = ''ADMIN'' WHERE id = auth.uid()', '42501');
SELECT t.fails('E4 cannot write notifications for others', 'INSERT INTO notifications (user_id, type) VALUES (auth.uid(), ''SYSTEM'')', '42501');

-- ===== F. accept offer =====
SELECT t.as_user(:C2);
SELECT t.fails('F1 other customer cannot accept', 'SELECT * FROM fn_accept_offer(''00000000-0000-0000-0000-0000000000f1'', (SELECT id FROM offers LIMIT 1), ''tok'', ''4242'')', 'P0002');
SELECT t.as_user(:C1);
SELECT t.check('F2 accept offer returns payment and 6-digit PIN', (SELECT length(completion_pin) = 6 AND payment_id IS NOT NULL FROM fn_accept_offer(:J1, (SELECT id FROM offers WHERE total_amount = 2450), 'tok_visa', '4242')));
SELECT t.check('F3 pool locked with 10% commission', (SELECT status::text || total_amount || platform_commission || pro_payout_amount FROM payments) = 'LOCKED2450.00245.002205.00');
SELECT t.check('F4 other offer auto-rejected', (SELECT status FROM offers WHERE total_amount = 2200) = 'REJECTED');
SELECT t.fails('F5 second accept refused', 'SELECT * FROM fn_accept_offer(''00000000-0000-0000-0000-0000000000f1'', (SELECT id FROM offers WHERE total_amount = 2200), ''tok'', ''4242'')', '23514');
SELECT t.check('F6 customer can read own PIN', length(fn_my_job_pin(:J1)) = 6);
SELECT t.as_super();
SELECT t.fails('F7 database forbids a 2nd accepted offer', 'UPDATE offers SET status = ''ACCEPTED'' WHERE total_amount = 2200', '23505');

-- ===== G. messages =====
SELECT t.as_user(:P1);
INSERT INTO chat_messages (job_id, sender_id, message_text) VALUES (:J1, :P1, 'Hello, I will come tomorrow');
SELECT t.check('G1 accepted pro can message', (SELECT count(*) FROM chat_messages) = 1);
SELECT t.as_user(:P2);
SELECT t.check('G2 rejected pro cannot read messages', (SELECT count(*) FROM chat_messages) = 0);
SELECT t.fails('G3 rejected pro cannot send messages', 'INSERT INTO chat_messages (job_id, sender_id, message_text) VALUES (''00000000-0000-0000-0000-0000000000f1'', auth.uid(), ''hi'')', '42501');
SELECT t.as_user(:C1);
SELECT t.check('G4 customer reads the message', (SELECT count(*) FROM chat_messages) = 1);
SELECT t.as_user(:C2);
SELECT t.check('G5 other customer cannot read messages', (SELECT count(*) FROM chat_messages) = 0);
SELECT t.as_user(:P1);
SELECT t.check('G6 pro can see the customer name after acceptance', (SELECT count(*) FROM users WHERE id = :C1) = 1);
SELECT t.as_user(:P3);
SELECT t.check('G7 stranger cannot see customer profile', (SELECT count(*) FROM users WHERE id = :C1) = 0);

-- ===== H. appointment, address, progress, live location =====
SELECT t.as_user(:C1);
SELECT fn_request_appointment(:J1, NOW() + interval '1 day', NOW() + interval '1 day 2 hours');
SELECT t.as_user(:P1);
SELECT t.check('H1 pro still sees masked address before confirming', fn_get_job_address(:J1) = 'Caferağa Mah.');
SELECT t.fails('H2 cannot start the trip before the appointment is confirmed', 'SELECT fn_set_job_progress(''00000000-0000-0000-0000-0000000000f1'', ''PRO_EN_ROUTE'')', '23514');
SELECT fn_respond_appointment((SELECT id FROM appointments), true);
SELECT t.check('H3 exact address revealed after confirmation', fn_get_job_address(:J1) LIKE '%Şair Nefi%');
SELECT t.fails('H4 cannot skip a step (SCHEDULED to IN_PROGRESS)', 'SELECT fn_set_job_progress(''00000000-0000-0000-0000-0000000000f1'', ''IN_PROGRESS'')', '23514');
SELECT t.fails('H5 location not shared before the trip', 'SELECT fn_update_pro_location(41.0, 29.0)', '23514');
SELECT fn_set_job_progress(:J1, 'PRO_EN_ROUTE');
SELECT fn_update_pro_location(40.9901, 29.0250);
SELECT t.as_user(:C1);
SELECT t.check('H6 customer sees the pro location during the trip', (SELECT count(*) FROM pro_locations) = 1);
SELECT t.as_user(:C2);
SELECT t.check('H7 other customer cannot see the location', (SELECT count(*) FROM pro_locations) = 0);
SELECT t.as_user(:P1);
SELECT fn_set_job_progress(:J1, 'IN_PROGRESS');
SELECT fn_set_job_progress(:J1, 'COMPLETED');
SELECT t.as_user(:C1);
SELECT t.check('H8 customer was notified that the job is done', (SELECT count(*) FROM notifications WHERE type = 'JOB_COMPLETED') = 1);
SELECT t.as_user(:C2);
SELECT t.fails('H9 other customer cannot cancel the appointment', 'SELECT fn_cancel_appointment((SELECT id FROM appointments), ''x'')', 'P0002');

-- ===== I. approval, payout, review =====
SELECT t.as_user(:C1);
SELECT t.fails('I1 wrong PIN refused', 'SELECT * FROM fn_complete_work(''00000000-0000-0000-0000-0000000000f1'', ''000000'', 5)', '28P01');
SELECT t.check('I2 right PIN releases money (2450 / 2205 / 245)', (SELECT total_paid || '/' || pro_earnings || '/' || platform_fee FROM fn_complete_work(:J1, fn_my_job_pin(:J1), 5, 'Great work', ARRAY['ON_TIME','CLEAN'], false)) = '2450.00/2205.00/245.00');
SELECT t.check('I3 job RELEASED and payment RELEASED_TO_PRO', (SELECT j.status::text || p.status::text FROM job_requests j JOIN payments p ON p.job_id = j.id) = 'RELEASEDRELEASED_TO_PRO');
SELECT t.check('I4 pro rating summary updated', (SELECT rating_avg::text || '/' || total_reviews_count || '/' || completed_jobs_count FROM pro_public_profiles WHERE business_name LIKE 'Mavi%') = '5.00/1/1');
SELECT t.fails('I5 second review for the same job refused', 'SELECT fn_add_review(''00000000-0000-0000-0000-0000000000f1'', 4)', '23505');
SELECT t.check('I6 status history recorded', (SELECT count(*) FROM job_status_history) >= 4);
SELECT t.as_user(:P3);
SELECT t.check('I7 public pro cards do not expose private data', (SELECT count(*) FROM information_schema.columns WHERE table_name = 'pro_public_profiles' AND column_name IN ('iban_encrypted', 'user_id')) = 0);

-- ===== J. complaint and admin decision =====
SELECT t.as_user(:C2);
INSERT INTO job_requests (id, customer_id, category_id, title, description, district, neighborhood, address_full_encrypted) VALUES (:J2, :C2, 'plumbing', 'Pipe', 'Kitchen pipe is broken, please come.', 'Kadıköy', 'Moda', 'Moda Cd. 5');
SELECT t.as_user(:P2); SELECT fn_submit_offer(:J2, '[{"kind":"LABOR","description":"Pipe","quantity":1,"unit_price":650}]', 6, 30, '');
SELECT t.as_user(:C2); SELECT * FROM fn_accept_offer(:J2, (SELECT id FROM offers), 'tok', '1111');
SELECT t.fails('J1 cannot open a complaint on someone else''s job', 'SELECT fn_open_dispute(''00000000-0000-0000-0000-0000000000f1'', ''NO_SHOW'', ''x'')', 'P0002');
SELECT fn_open_dispute(:J2, 'NO_SHOW', 'The professional did not show up');
SELECT t.check('J2 complaint blocks the payment', (SELECT p.status::text || j.status::text FROM payments p JOIN job_requests j ON j.id = p.job_id WHERE j.id = :J2) = 'DISPUTEDDISPUTED');
SELECT t.fails('J3 customer cannot decide a dispute', 'SELECT fn_decide_dispute((SELECT id FROM disputes), ''FULL_REFUND'', ''x'')', '42501');
SELECT t.as_user(:AD);
SELECT t.check('J4 admin can read the complaint', (SELECT count(*) FROM disputes) = 1);
SELECT fn_decide_dispute((SELECT id FROM disputes), 'FULL_REFUND', 'No-show confirmed');
SELECT t.check('J5 refund applied and job cancelled', (SELECT p.status::text || j.status::text || d.status::text FROM payments p JOIN job_requests j ON j.id = p.job_id JOIN disputes d ON d.job_id = j.id WHERE j.id = :J2) = 'REFUNDED_TO_CUSTOMERCANCELLEDRESOLVED');
SELECT t.check('J6 decision written to the admin log', (SELECT count(*) FROM admin_actions WHERE action = 'DECIDE_DISPUTE') = 1);
SELECT fn_set_account_status(:P3, 'SUSPENDED');
SELECT t.as_user(:C1);
SELECT t.check('J7 customer cannot read the admin log', (SELECT count(*) FROM admin_actions) = 0);
SELECT t.as_user(:P3);
SELECT t.fails('J8 suspended pro cannot submit offers', 'SELECT fn_submit_offer(''00000000-0000-0000-0000-0000000000f2'', ''[{"kind":"LABOR","description":"x","quantity":1,"unit_price":5}]'', 6, 1, '''')', '42501');

-- ===== K. cancel a job: money goes back =====
SELECT t.as_user(:C2);
INSERT INTO job_requests (id, customer_id, category_id, title, description, district, neighborhood) VALUES (:J3, :C2, 'plumbing', 'Tap', 'Kitchen tap needs to be replaced.', 'Kadıköy', 'Moda');
SELECT t.as_user(:P2); SELECT fn_submit_offer(:J3, '[{"kind":"LABOR","description":"Tap","quantity":1,"unit_price":400}]', 6, 30, '');
SELECT t.as_user(:C2); SELECT * FROM fn_accept_offer(:J3, (SELECT id FROM offers WHERE job_id = :J3), 'tok', '1111');
SELECT fn_cancel_job(:J3);
SELECT t.check('K1 cancelling a scheduled job refunds the pool', (SELECT p.status::text || j.status::text FROM payments p JOIN job_requests j ON j.id = p.job_id WHERE j.id = :J3) = 'REFUNDED_TO_CUSTOMERCANCELLED');

-- ===== L. storage =====
SELECT t.as_super();
SELECT t.check('L1 buckets have the 2.5 MB limit', (SELECT count(*) FROM storage.buckets WHERE file_size_limit = 2621440) = 4);
SELECT t.as_user(:C1);
SELECT t.fails('L2 cannot upload into someone else''s folder', 'INSERT INTO storage.objects (bucket_id, name) VALUES (''job-photos'', ''00000000-0000-0000-0000-0000000000a2/x.jpg'')', '42501');
INSERT INTO storage.objects (bucket_id, name) VALUES ('job-photos', '00000000-0000-0000-0000-0000000000a1/x.jpg');
SELECT t.check('L3 can upload into own folder', (SELECT count(*) FROM storage.objects) >= 1);

SELECT t.as_super();
\pset tuples_only off
SELECT CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END AS result, name FROM t.results ORDER BY n;
SELECT count(*) FILTER (WHERE ok) AS passed, count(*) FILTER (WHERE NOT ok) AS failed FROM t.results;
