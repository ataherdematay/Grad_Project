# Live payment demo (10-15 minutes)

[Türkçe sürüm](PAYMENT_DEMO.md)

This is a step-by-step script for showing the BiTadilat payment system live to the supervisor. Payments go through the **real Craftgate sandbox**: the card form, the bank's 3D Secure (SMS) page, the Craftgate payment id and the refund are real sandbox calls. No real money moves.

What the demo shows:

- the customer's **Money journey** timeline,
- the **Receipt**,
- **My payments**,
- the pro's timeline (no card data; service fee and net earning shown),
- the admin **secure hold summary** and **payment timeline**,
- the **demo clock** (fast-forward), which runs the 48-hour automatic payout in seconds.

This script was run end to end on 26 November 2026 on an iPhone 18 Pro simulator and the admin web build. The screenshots come from that run ([img/](img/)). The app was in Turkish; English labels are given in brackets where they help.

For the concepts, see the presentation pages:

- [docs/sunum/en/1-payment-flow.html](../sunum/en/1-payment-flow.html): flow table and fraud safeguards.
- [docs/sunum/en/2-money-map.html](../sunum/en/2-money-map.html): interactive money map. Good for a one-minute opening.
- [docs/sunum/en/3-payment-animation.html](../sunum/en/3-payment-animation.html): 11-scene animation.

## Timeline

| Minute | Step | Where the money is |
|---|---|---|
| 0-1 | Opening with the money map page | - |
| 1-6 | **A. Happy path:** accept offer, real 3DS payment, receipt, delivery, customer approval | Card, then secure hold, then pro |
| 6-9 | **B. 48 hours:** second payment, delivery, customer does not approve, demo clock | Secure hold, then automatically the pro |
| 9-12 | **C. Cancel and refund:** third payment, cancellation, real Craftgate refund | Secure hold, then the customer's card |
| 12-15 | **D. Admin panel:** summary cards, payment timeline, questions | - |

## 1. Preparation (before class, about 15 minutes)

### 1.1 Backend

PostgreSQL must be running. See [docs/RUNNING.md](../RUNNING.md) for setup and other options.

```bash
cd backend
export CRAFTGATE_API_KEY=<sandbox API key>          # never write the value into docs or the repo
export CRAFTGATE_SECRET_KEY=<sandbox secret key>
./mvnw spring-boot:run                              # dev profile, http://127.0.0.1:8090
```

- The log should show `Started BitadilatApplication`.
- The warning `CRAFTGATE_CALLBACK_KEY tanımlı değil` is normal in dev. The payment result is still verified against the Craftgate API.
- A key starting with `sandbox-demo` switches to a fake in-memory gateway that never calls Craftgate. Use real sandbox keys for this demo; the timeline then shows provider `CRAFTGATE`.

### 1.2 Reset the demo data

```bash
curl -X POST http://localhost:8090/api/v1/dev/reset     # returns 204
```

### 1.3 Accounts

All demo passwords are `Demo1234!` (dev seed only, [docs/spec/SEED_DATA.md](../spec/SEED_DATA.md)).

| Role | Email | Where |
|---|---|---|
| Customer | `ali@bitadilat.test` | iOS simulator |
| Pro (Mavi Hat Tesisat) | `mehmet@bitadilat.test` | Simulator or terminal |
| Admin | `admin@bitadilat.test` | Web panel only |

### 1.4 Mobile app (iOS simulator)

```bash
cd apps/mobile
flutter build ios --simulator --debug --dart-define=API_BASE_URL=http://localhost:8090
xcrun simctl boot "iPhone 18 Pro"          # if not booted
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
xcrun simctl launch booted com.bitadilat.app
```

- On the welcome screen pick **Türkçe** (or English) and sign in as Ali.
- If iOS asks "Save Password?", choose **Not Now**.

### 1.5 Admin panel

```bash
cd apps/admin
flutter build web --dart-define=API_BASE_URL=http://localhost:8090
python3 -m http.server 8093 --bind 127.0.0.1 --directory build/web
```

Open `http://127.0.0.1:8093` and sign in as admin. Do not use port 3000; another project uses it.

### 1.6 Prepare the offers (terminal helpers)

The request wizard and the pro's offer screen take too long in class. Open the three requests and offers through the API beforehand. Paste this block into one terminal once:

```bash
B=http://localhost:8090/api/v1
tok(){ curl -s $B/auth/login -H 'content-type: application/json' \
  -d "{\"identifier\":\"$1@bitadilat.test\",\"password\":\"Demo1234!\"}" | python3 -c 'import sys,json;print(json.load(sys.stdin)["accessToken"])'; }
api(){ local t=$1 m=$2 p=$3; shift 3; curl -s -X $m "$B$p" -H "authorization: Bearer $t" -H 'content-type: application/json' "$@"; }
# teklif <title> <labour> <materials>: Ali opens a request, Mehmet makes an offer
teklif(){ local A=$(tok ali) M=$(tok mehmet)
  local addr=$(api $A GET /me/addresses | python3 -c 'import sys,json;print(json.load(sys.stdin)[0]["id"])')
  local req=$(api $A POST /requests -d "{\"categoryId\":\"plumbing\",\"urgency\":\"URGENT\",\"title\":\"$1\",\"description\":\"Lavabonun altindan surekli su damliyor, dolap islandi.\",\"addressId\":\"$addr\",\"photoIds\":[],\"answers\":[]}" | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')
  local f=$(python3 -c 'import datetime as d;print((d.datetime.now(d.timezone.utc)+d.timedelta(hours=3)).strftime("%Y-%m-%dT%H:00:00Z"))')
  local t=$(python3 -c 'import datetime as d;print((d.datetime.now(d.timezone.utc)+d.timedelta(hours=6)).strftime("%Y-%m-%dT%H:00:00Z"))')
  api $M POST /pro/requests/$req/offers -d "{\"laborAmount\":$2,\"materialsAmount\":$3,\"arrivalFrom\":\"$f\",\"arrivalTo\":\"$t\",\"warrantyMonths\":6,\"note\":\"Sifon ve conta degisimi.\",\"items\":[]}" >/dev/null
  echo "request $req ready"; }
# isler: Ali's active jobs (id, code, title, status)
isler(){ api $(tok ali) GET "/jobs?as=CUSTOMER&scope=active" | python3 -c 'import sys,json;[print(j["id"],j["publicCode"],j["title"],j["status"]) for j in json.load(sys.stdin)["items"]]'; }
# usta_bitir <jobId>: the pro accepts the appointment, arrives, starts, finishes
usta_bitir(){ local M=$(tok mehmet)
  local p=$(api $M GET /jobs/$1 | python3 -c 'import sys,json;print(json.load(sys.stdin)["appointment"]["pendingProposal"]["id"])')
  api $M POST /jobs/$1/appointment/proposals/$p/accept >/dev/null; api $M POST /jobs/$1/arrived >/dev/null; api $M POST /jobs/$1/start >/dev/null
  api $M POST /jobs/$1/finish -d '{"note":"Sifon ve conta degistirildi, kacak giderildi.","photoIds":[]}' | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d["status"],"auto-approve at:",d["autoCompleteAt"])'; }
# hizlandir <jobId>: runs the 48-hour payout now (dev profile and 127.0.0.1 only)
hizlandir(){ api $(tok ali) POST /dev/jobs/$1/payment/fast-forward; echo; }
```

Then:

```bash
teklif "Mutfak lavabosu su kacagi" 900 300        # A: TRY 1,200
teklif "Banyo bataryasi damlatiyor" 650 150       # B: TRY 800
teklif "Klozet rezervuari su kaciriyor" 400 100   # C: TRY 500
```

### 1.7 Checklist

- [ ] `dev/reset` returned 204, then the offers were created.
- [ ] Ali's home screen shows three open requests, each with "1 teklif geldi" (1 offer).
- [ ] The admin **Ödemeler** (Payments) page opens.
- [ ] The machine is online (Craftgate sandbox and the 3DS page are external).

**Starting values after a reset (admin summary):** in secure hold ₺3,400, paid to pros ₺7,785, refunded to customers ₺0, service fee earned ₺865, total payments 13, seed 13. These are seed payments (provider `SEED`, no Craftgate call).

## 2. Scenario A: happy path (5-6 minutes)

| # | Tap | What you see | Where the money is |
|---|---|---|---|
| A1 | Home, card "Mutfak lavabosu su kacagi", **Teklifleri gör (1)** (See offers), then the Mavi Hat Tesisat offer | Offer breakdown: labour ₺900, materials ₺300, total ₺1,200 | Customer's card |
| A2 | **Teklifi kabul et** (Accept offer) | "Your payment is held in secure hold" text and the cancellation policy ([img/01](img/01-teklif-kabul.png)) | Card |
| A3 | **Ödemeye geç** (Go to payment), then **Test kartını doldur** (Fill test card, debug builds only) | Card `5258 6400 0000 0001`, `07/44`, CVC `000` ([img/02](img/02-kart-formu.png)) | Card |
| A4 | **₺1.200 öde** (Pay) | Craftgate's sandbox SMS page; the code is printed in brackets on the page ([img/03](img/03-3ds-banka.png)) | Bank is verifying |
| A5 | Type the 6-digit code (submits itself on the 6th digit) | The app moves to the **Randevu** (Appointment) screen; tap **Randevu iste** | **Secure hold** |
| A6 | Scroll the job detail, tap the **Paranın yolculuğu** (Money journey) card | "Money right now: in secure hold", three nodes (Card ✓, Secure hold, Pro), events: payment started, bank verification started, amount placed in secure hold ([img/04](img/04-yolculuk-havuzda.png)) | Secure hold |
| A7 | **Makbuzu gör** (View receipt) | Sandbox notice, receipt no `BT-yyyyMMdd-XXXXXX`, line items, `Mastercard •••• 0001`, money right now ([img/09](img/09-makbuz.png)) | Secure hold |
| A8 | Terminal: `isler`, then `usta_bitir <A's jobId>` | Pull to refresh the job: "Onayın bekleniyor" (Waiting for your approval) and the auto-approval date. The journey shows **time left until automatic payout: 48 h 0 min** ([img/05](img/05-geri-sayim.png)) | Secure hold |
| A9 | **Teslimi onayla**, **Onayla**, **Onayla ve aktar** (Approve and pay out) ([img/06](img/06-teslim-onayi.png)). On the rating screen tap **Şimdi değil** (Not now) | Job "Tamamlandı" (Completed) | **With the pro** |
| A10 | Profile, **Ödemelerim** (My payments), "Mutfak lavabosu" | "Money right now: with the pro"; the last events are "you approved" and "amount paid out to the pro" ([img/07](img/07-yolculuk-ustada.png), [img/08](img/08-hareketler.png), [img/10](img/10-odemelerim.png)) | With the pro |

Talking points:

- The server takes the amount from the offer; the app never sends an amount. The card number is not stored, only the brand and last 4 digits.
- The customer never sees the service fee or the pro's share (GLOSSARY rule). The receipt has no fee breakdown.
- Before paying the pro, the server asks Craftgate whether the payment has any refund. If it has one, no money leaves and the payment goes to review.

**Pro side (optional, about 1 minute):** Profile, Settings, **Çıkış yap** (Sign out); sign in as Mehmet; İşlerim (My jobs), Geçmiş (Past), "Mutfak lavabosu", Money journey.

- "Money right now: **with you**". Nodes: Customer, Secure hold, You.
- Amounts: total ₺1,200, **service fee (10%) ₺120**, **your net earning ₺1,080**.
- **No card row and no receipt button** ([img/14](img/14-usta-yolculuk.png), [img/15](img/15-usta-hareketler.png)).
- The receipt endpoint returns `403 FORBIDDEN` to the pro.

In the admin panel, click this payment's row: provider **Craftgate**, the **Craftgate payment id** (for example `3302829`) and the masked card appear ([img/17](img/17-admin-zaman-cizelgesi.png)).

## 3. Scenario B: the customer does not approve, 48 hours (3 minutes)

| # | Action | What you see | Where the money is |
|---|---|---|---|
| B1 | As Ali, pay the "Banyo bataryasi damlatiyor" offer like A1-A5 (₺800) and request an appointment | Appointment screen | Secure hold |
| B2 | Terminal: `isler`, then `usta_bitir <B's jobId>` | `WORK_FINISHED auto-approve at: <48 hours later>` | Secure hold |
| B3 | Show the journey screen | "Time left until automatic payout 48 h 0 min" | Secure hold |
| B4 | Terminal: `hizlandir <B's jobId>` | `{"jobStatus":"COMPLETED","escrowStatus":"RELEASED_TO_PRO","moneyLocation":"PRO","released":true,...}` | **With the pro** |
| B5 | Pull to refresh the journey | The last events are **48 hours passed, the system approved** and **amount paid out to the pro** ([img/11](img/11-otomatik-aktarim.png)) | With the pro |

Talking points:

- The demo clock only moves this job's auto-approval time to now and runs the real 48-hour scheduler path (`JobScheduler`, `releaseChecked`). The Craftgate refund check is not skipped.
- The endpoint exists only in the `dev` profile and only answers 127.0.0.1. In prod it does not exist (404).
- A second call returns `409 ILLEGAL_STATE`; money is never paid out twice.

## 4. Scenario C: cancellation and a real Craftgate refund (3 minutes)

| # | Action | What you see | Where the money is |
|---|---|---|---|
| C1 | Pay the "Klozet rezervuari su kaciriyor" offer (₺500). Go back from the appointment screen | Job "Randevu bekleniyor" (Waiting for appointment) | Secure hold |
| C2 | At the bottom of the job detail tap **İşi iptal et** (Cancel job), pick a reason, confirm | Job "İptal edildi" (Cancelled) | **Refunded to your card** |
| C3 | Money journey | "Money right now: refunded to you". Amounts: total ₺500, **refunded ₺500**. Events: refund requested ₺500, amount refunded to your card ₺500 ([img/12](img/12-iade.png), [img/13](img/13-iade-hareketleri.png)) | Customer's card |
| C4 | My payments | The row says "Kartına iade edildi" (refunded to your card), "refunded: ₺500" | Card |

To cancel from the terminal instead:

```bash
api $(tok ali) POST /jobs/<jobId>/cancel -d '{"reason":"PLANS_CHANGED"}'
```

The backend log shows the real refund:

```
Tam iade yapıldı. paymentId=... refundId=... type=CANCEL status=SUCCESS amount=500.00
```

Talking points:

- The cancellation and the refund intent are saved in one transaction. The Craftgate refund call runs only after that transaction commits (outbox).
- If Craftgate does not answer, the refund is retried in the background (backoff from 5 minutes up to 6 hours). Every attempt first asks how much is already refunded, so the customer is never refunded twice.

## 5. Scenario D: admin panel (2-3 minutes)

The **Ödemeler** (Payments) page starts with the **secure hold summary** ([img/16](img/16-admin-ozet.png)). Expected values after A, B and C:

| Card | Calculation | Expected |
|---|---|---|
| Waiting in secure hold | Seed LOCKED ₺1,200 + seed DISPUTED ₺2,200 | **₺3,400** (locked + disputed: 1 + 1) |
| Paid to pros | Seed ₺7,785 + A ₺1,080 + B ₺720 | **₺9,585** |
| Refunded to customers | C ₺500 | **₺500** |
| Service fee earned | Seed ₺865 + A ₺120 + B ₺80 | **₺1,065** |
| Chips | | Total 16, in hold 2, paid out 13, refunded 1, failed 0, seed 13 |

- If a 3DS attempt was abandoned or a wrong SMS code was typed, the "failed" chip goes up by 1. That is expected; the totals do not change.
- Clicking a row opens the **payment timeline** side panel: where the money is now, gross, service fee, pro net, refund, Craftgate payment id, masked card and every event (which role, when, how much). Refund example: [img/18](img/18-admin-iade.png).
- Picking a status filter (for example "paid out to the pro") also shows the ledger totals for that status.

## 6. Where the money is, at a glance

| `status` | `moneyLocation` | Customer sees | Pro sees |
|---|---|---|---|
| Before payment | `CUSTOMER_CARD` | On your card | On the customer's card |
| `LOCKED` | `BITADILAT_VAULT` | In secure hold | In secure hold |
| `DISPUTED` (complaint) | `BITADILAT_VAULT` | In secure hold (held during the complaint) | Same |
| `RELEASED_TO_PRO` | `PRO` | With the pro | With you |
| `REFUNDED_TO_CUSTOMER` | `CUSTOMER_REFUNDED` | Refunded to you | Refunded to the customer |
| `SPLIT_SETTLED` (admin 50/50 decision) | `SPLIT` | Split | Split |

## 7. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Backend does not start, "CRAFTGATE_API_KEY" error | Key environment variables missing | `export` both keys in the terminal. Never write the values into docs |
| Error after **Pay**, `GATEWAY_ERROR` | Offline or Craftgate sandbox unreachable | Check the connection and retry |
| `PAYMENT_IN_PROGRESS` (409) | An unfinished 3DS attempt exists for this request | A new attempt is accepted after 10 minutes, or create a new request with `teklif` |
| Payment failed, `PAYMENT_DECLINED` | Wrong SMS code or the bank page was closed | Pay the same offer again; the request stays open |
| SMS page blank or does not return | The WebView cannot reach the internet | Check the simulator's network; try `https://sandbox-api.craftgate.io` in Safari |
| Taps or typing lag in the simulator | Simulator input is delayed | Wait 1-2 seconds between steps, type into one field at a time |
| A screen shows an old state | Cached data | Pull down to refresh |
| `hizlandir` returns `409 ILLEGAL_STATE` | Job not `WORK_FINISHED`, called twice, or a complaint is open | Run `usta_bitir` first; call it once per job |
| `hizlandir` returns `404` | Wrong jobId, or the backend is not in the dev profile | Get the id with `isler`; start the backend with `./mvnw spring-boot:run` (dev) |
| `usta_bitir` fails on "pendingProposal" | The customer did not request an appointment | Tap **Randevu iste** on the appointment screen |
| Admin login does not work | The admin account works only in the web panel; CORS allows only localhost/127.0.0.1 | Open it at `http://127.0.0.1:8093` |
| Timeline shows provider `DEMO` | Backend started with a `sandbox-demo...` key | Restart with real sandbox keys. In demo mode a restart breaks refunds |
| Summary cards differ from the table | Other payments were made after the reset | Repeat `dev/reset` and the `teklif` steps |

## 8. Technical notes

- Endpoints: `GET /jobs/{id}/payment/timeline`, `GET /jobs/{id}/payment/receipt`, `GET /me/payments`, `GET /admin/payments/summary`, `GET /admin/payments/{ref}/timeline`, `POST /dev/jobs/{id}/payment/fast-forward`. Contract: [docs/spec/API_V1.md](../spec/API_V1.md), "payment demo" section.
- The receipt number is `BT-<day>-<first 6 hex of the payment ref>`. The day is in Istanbul time, so it matches the date printed on the receipt.
- Role visibility:
  - the customer never sees the service fee or the pro's share,
  - the pro never sees card data or the receipt,
  - the admin sees everything.
