# How the app (Ata) and the backend (Hakan) use the database

Reading data = normal table queries (the database filters by who is logged in). Writing important data = call a `fn_*` function. With the Supabase client: `supabase.rpc('fn_accept_offer', params: {...})`.

## Ata's repository interface (`mobile/lib/core/repositories/job_repository.dart`) -> database
| App method | Database |
|---|---|
| `getCustomerJobs()` | `select` from `job_requests` (+ `offers`, `payments`, `job_photos`), own rows only |
| `getJobById(id)` | same, one row; exact address via `fn_get_job_address(id)`; PIN via `fn_my_job_pin(id)` |
| `createJob(job)` | `insert` into `job_requests` (status `PENDING_OFFERS`), photos into `job_photos` and Storage `job-photos` |
| `acceptOffer(jobId, offerId)` | `rpc fn_accept_offer(p_job_id, p_offer_id, p_provider_ref, p_card_last4)` returns payment id + PIN |
| `updateJobStatus(jobId, status)` | `rpc fn_set_job_progress(p_job_id, p_to)` (pro: on the way / in progress / completed) |
| `completeWork(jobId, pin, rating, review)` | `rpc fn_complete_work(p_job_id, p_pin, p_rating, p_review, p_tags, p_show_full_name)` |
| `getAvailableProJobs()` | `select` from `job_requests` (the pro sees only matching open requests in their districts) |
| `submitProBid(jobId, offer)` | `rpc fn_submit_offer(p_job_id, p_items, p_warranty, p_arrival_min, p_note)`; items = labor and material lines |
| `getChatMessages(jobId)` / `sendChatMessage` | `select` / `insert` on `chat_messages` (only the two parties, only after acceptance) |

## Model fields that need a small mapping in the app
- `ServiceCategory.name/description`: use `name_tr`/`name_en` and `description_tr`/`description_en` by the selected language. `startingPrice` = `base_inspection_fee`.
- `JobRequest.escrowLocked`: true when the job's `payments.status = 'LOCKED'`. `photoUrls`: from `job_photos`.
- `JobStatus`: the app's 7 values are a subset of the database's 10 (extra: `DRAFT`, `ESCROW_PENDING`, `DISPUTED`). Add `disputed` to the app for the complaint screens.
- `OfferStatus.completed`: not stored; derive it from the job status `RELEASED`.
- `ProProfile`: read from the view `pro_public_profiles` (name, business, rating, counts, verified flags). `badges` can be built from the flags.
- `UserModel.phoneNumber` is optional in the database (login is by email/Google); the app should allow empty.
- `ChatMessage.senderName`: join with `users` (allowed between the two parties).

## Screens that use extra functions
Reject offer `fn_reject_offer` | book/answer/cancel appointment `fn_request_appointment`, `fn_respond_appointment`, `fn_cancel_appointment` | cancel job (refund) `fn_cancel_job` | failed payment screen `fn_record_failed_payment` | live navigation `fn_update_pro_location` (pro) + select `pro_locations` (customer) | complaint `fn_open_dispute` + `dispute_evidence` | notifications = `notifications` table (the app turns `type` + `data` into TR/EN text) | admin screens `fn_review_document`, `fn_decide_pro_application`, `fn_set_account_status`, `fn_decide_dispute`.

## For Hakan (if the backend sits in between)
Forward the user's login token (JWT) to Supabase so `auth.uid()` works inside the functions. The `service_role` key bypasses the security rules and `auth.uid()` is then empty, so only use it for jobs like a payment-provider webhook. Error codes from the functions: `23514` rule broken (409), `P0002` not found (404), `42501` not allowed (403), `28P01` wrong PIN (400), `23505` duplicate (409).

## Payment and live location notes
- Real card payment is done by the payment provider (e.g. iyzico test mode); the app passes the provider's reference to `fn_accept_offer`. Card numbers are never stored.
- Live location is stored as one last position per professional and only during an active job (KVKK).
- The "Realtime" feature of Supabase can push new messages, offers and locations to the app. Turn it on for `chat_messages`, `offers`, `notifications`, `pro_locations` in Database → Replication.
