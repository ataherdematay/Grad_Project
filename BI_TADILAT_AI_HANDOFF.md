# BiTadilat — UI/UX Design Handoff for a New AI

> Copy this entire file into the new AI conversation before continuing the BiTadilat work. It is written so that the new AI can continue the Stitch design process without rediscovering product decisions or changing completed work arbitrarily.

## 1) Role and objective

You are continuing UI/UX work for **BiTadilat**, a Turkish-first marketplace for home repair and renovation. The end goal is a production-oriented, user-friendly mobile experience for customers and service professionals, plus a separate responsive web experience for administrators.

The current work is being made in **Google Stitch**, screen by screen. Do **not** produce one giant mega-prompt. Review each generated screen, call out concrete inconsistencies, and give one small, precise next prompt at a time. Preserve the existing visual system and terminology.

The user is a student/designer who will paste your prompts into Stitch and send screenshots back. They want practical prompts in Turkish/English as needed, clear explanations, and a professional product that can later be implemented as a frontend.

## 2) Product scope

### What BiTadilat does

Customers can:

1. Register using a phone number and OTP verification.
2. Choose customer or service-professional role.
3. Create a repair/renovation request.
4. Provide category, urgency, district, written scope, optional photos, and optional context.
5. Receive offers from verified service professionals.
6. Compare structured offers (labour, materials, total price, availability, warranty, ratings).
7. Inspect professional profiles, then accept an offer.
8. Request and confirm an appointment.
9. Communicate in-app, track job milestones, complete/cancel a job, review a professional, or open a complaint.

Service professionals can:

1. Browse matched requests.
2. Build structured offers.
3. Manage sent offers, profile, territory, and availability.
4. Confirm appointments, chat, and update job milestones.

Administrators use a **separate responsive web portal** to verify professionals, manage disputes/complaints, and manage accounts. Do not put admin screens in the mobile app.

Marketing/promotion is also a separate web experience.

### Business facts that must remain true in UI

- A customer request requires a category, urgency, district/location, and written scope.
- A request may include **up to five optional photos**.
- Urgency is either `Acil onarım` or `Planlı yenileme`.
- Professional matching is based on relevant territory and availability.
- Offers must display a clear structured breakdown: labour, materials, total, and timing/availability.
- Offers are comparable; do not force or manipulate customer choice.
- Appointment selection happens **after** a customer accepts an offer.
- In-app messaging and milestones happen after the selection/appointment flow.
- Exact street/building address must not appear early in the flow. It is shared safely once appointment/selection is confirmed.

## 3) Visual direction and design system

The existing Stitch project imported a `DESIGN.md` design system. Preserve it.

### Tone

- Calm, credible, modern Turkish urban home-care service.
- Practical and reliable—not a generic gig marketplace.
- Clear hierarchy, generous white space, soft cards, simple line icons, restrained motion.
- Original BiTadilat identity. Take only interaction inspiration from taxi apps (short phone signup, decisive CTA, transparent states); do **not** imitate Bitaksi’s purple branding, logo, wording, or map-first layout.

### Platform and layout

- Mobile baseline: native iOS/Android, `390 × 844` portrait viewport, safe areas respected.
- Manrope font, Turkish characters rendered correctly.
- 16 px side padding; 12 px in-group spacing; 24 px between major groups; 8 px compact spacing.
- Minimum touch target: 44 × 44 px.
- Fixed bottom navigation belongs only on signed-in customer/professional home-level screens. Do not use it during onboarding, forms, confirmations, or active flows.
- Use fixed bottom primary actions on long forms when needed.

### Colour system

- Primary service teal: `#0F4C5C`
- Dark teal / pressed: `#0A3945`
- Urgency orange: `#E87525` (only time-sensitive repair/urgency)
- Trust/verified green: `#107A5B`
- Alert red: `#B9382C`
- Information blue: `#247BA0`
- Canvas: `#F7F8F6`
- Surface: `#FFFFFF`
- Primary text: `#102A34`
- Secondary text: `#5F6F73`
- Border: `#D9E1DD`
- Disabled: `#E9EEEB`

### Component rules

- One clear primary action per screen.
- Disabled button state must be visibly muted, not merely lower contrast text.
- Use status colour together with an icon and explicit Turkish text; never colour alone.
- Use bottom sheets for contextual confirmation of meaningful actions such as accepting an offer.
- Do not add artificial countdowns, guaranteed response times, fictitious availability, fake provider rankings, or high-pressure language.
- Mock-up names, avatars, dates, prices, ratings, and offers are **sample data only**. Production values must be backend-driven.
- Dates and availability must be dynamic when implemented; mock-up dates are illustrative.

## 4) Terminology and hard consistency rules

- Use the product-wide category `Tesisat`. Do not change the selected category to `Sıhhi Tesisat` midway through a flow.
  - A provider/company may have `Sıhhi Tesisat` in its business name or specialty; that is acceptable.
- Correct price phrase: `Toplam tutar (KDV dahil)`.
  - Never combine `Net toplam` with `KDV dahil`.
- Never show a fake final appointment before a professional confirms it.
  - Before confirmation: `Randevu talebi gönder` / `Ustanın onayı bekleniyor`.
  - After confirmation: `Randevun onaylandı`.
- Do not display `Ortalama 15 dk`, a resend button before its timer ends, or a countdown that pressures users.
- Generic text must not hard-code a sample neighborhood such as Kadıköy. It may appear only as sample request data or an actual coverage location.
- No personal phone number, direct calling, payment collection, exact home address, or map tracking in the current customer screens unless a later requirement explicitly calls for it.

## 5) Completed customer screens in Stitch

The following have been designed. Do not recreate them from scratch unless the user asks.

### A. Onboarding and authentication

1. **Welcome / role selection**
   - Customer role: `Ev sahibi / Müşteri`.
   - Professional role: `Hizmet profesyoneli`.
   - No default selection; phone continuation disabled until role is chosen.
2. **Phone-number verification**
   - Turkish country code and valid mobile input.
3. **OTP verification**
   - Six digits required before `Doğrula` activates.
   - Initial resend state must be disabled timer text: `00:42 sonra tekrar gönder`.

### B. Customer home

4. **Customer home / empty state**
   - Main CTA: `Talep oluşturmaya başla`.
   - Bottom tabs: Ana sayfa, Taleplerim, Mesajlar, Profil.
   - Trust/standards cards and no active-request state.

### C. Request creation, 4-step flow

5. **Step 1/4 — service and urgency**
   - Category grid: Tesisat, Elektrik, Boya & Badana, Klima, Banyo yenileme, Mutfak yenileme, Marangozluk, Diğer.
   - Urgency cards: Acil onarım and Planlı yenileme.
   - Continue is disabled until both category and urgency are selected.
6. **Step 2/4 — location and description**
   - City, district, use-current-location action, written scope (at least 20 characters), optional prompt chips.
   - Generic privacy guidance; exact address protected.
7. **Step 3/4 — photos and extra information**
   - Empty default state: `0 / 5 fotoğraf eklendi`, one add-photo tile, empty placeholders, no thumbnail.
   - Photo and extra information are optional; Continue is therefore active in initial valid state.
8. **Step 4/4 — review and publish**
   - Editable summary cards for service/urgency, broad location, description, photos/extra information.
   - Exactly one fixed primary action: `Talebi yayınla`.

### D. Request matching and offers

9. **Request published / waiting for offers**
   - Request summary, timeline, status `Teklif bekleniyor`, no fake offers or countdown.
10. **Offers list**
   - Heading `3 teklif geldi`.
   - Verified professional, rating/review count, total, labour/material breakdown, availability estimate, and `Teklifi incele`.
   - Sort control may exist but must not label a provider “best” or preselect an offer.
11. **Offer comparison**
   - Two selected offers shown side by side with identical criteria: total including VAT, labour, materials, extra cost, warranty, availability, ratings, and scope.
   - The customer remains in control; no winner/recommended badge.
12. **Offer detail**
   - Provider profile summary, scope, transparent price breakdown, warranty, availability, and `Ustaya soru sor`.
   - CTA `Teklifi kabul et`.
13. **Offer acceptance confirmation**
   - Bottom sheet over dimmed offer-detail screen.
   - Confirm or cancel; acceptance does not yet create a confirmed appointment.

### E. Appointment

14. **Appointment time selection**
   - Date cards + available time slots; one muted `Dolu` slot.
   - `Randevu talebi gönder` remains disabled until a date and available time slot are selected.
15. **Appointment request sent / waiting for professional approval**
   - Status `Ustanın onayı bekleniyor`.
   - Timeline: offer accepted → request sent → professional confirmation pending → job start pending.
   - No response duration/guarantee, no fake confirmation.

### F. Professional profile

16. **Professional profile**
   - Generic avatar, verified badge, rating, completed jobs, time on platform.
   - Expertise, service regions, about text, three verification checks, two review cards.
   - CTA `Teklife dön`, secondary action `Ustaya soru sor`.

## 6) Current next screen — paste this into Stitch

The immediate next design is the customer workspace after the professional confirms the appointment.

```text
Create one new mobile screen for BiTadilat: “İş Alanı — Randevu Onaylandı”.

This is the customer’s active workspace after Mavi Hat Tesisat confirms the requested appointment. Use the existing BiTadilat design system exactly: Manrope, warm off-white background, white cards, deep service teal #0F4C5C, trust green for confirmed states, and Turkish copy.

Header: back arrow, centered “İş alanı”, overflow menu icon.

At the top, show a prominent confirmation card:
- Green check icon
- Title: “Randevun onaylandı”
- Subtitle: “Mavi Hat Tesisat seçtiğin zaman aralığında hizmet verecek.”
- Status chip: “Yaklaşan randevu”

Show a compact appointment card:
- “Mavi Hat Tesisat”
- Green “Doğrulanmış uzman” badge
- “Tesisat • Acil onarım”
- “Randevu” — “Yarın · 14:00 – 16:00”
- “Hizmet bölgesi” — “İstanbul, Kadıköy”
- “Teklif toplamı” — “₺2.450 (KDV dahil)”

Add a small privacy row:
“Kesin adresin, randevu onayıyla uzmanla güvenli biçimde paylaşıldı.”

Section title: “İş durumu”
Show a four-step timeline:
1. “Teklif kabul edildi” — completed, green check
2. “Randevu onaylandı” — completed, green check
3. “İş başlangıcı” — active upcoming state in teal, subtitle “Randevu saatinde güncellenecek”
4. “İş tamamlandı” — muted pending state

Section title: “İletişim ve takip”
Show two large action cards:
- “Mesajlar” — subtitle “Mavi Hat Tesisat ile uygulama içinden iletişim kur”
- “İş ilerlemesi” — subtitle “Henüz başlamadı”

Add a text-only action:
“Randevuyu değiştir veya iptal et”

Fixed bottom primary button:
“Ustaya mesaj gönder”

Do not show direct phone calling, personal contact information, payment collection, map tracking, a fabricated arrival time, or an already completed job.
```

## 7) Remaining screen order

Continue in this sequence, reviewing each generated screen before requesting the next:

1. **Confirmed appointment / active job workspace** — prompt supplied above.
2. **In-app message thread** with the selected professional.
   - Must support neutral customer/professional messages and optional attachment action.
   - No phone number/call button.
3. **Job milestones / progress tracking**.
   - Statuses should be explicit: scheduled, started, in progress, awaiting customer confirmation, completed.
   - Do not call it live map tracking.
4. **Reschedule/cancellation flow**.
   - User chooses reason; confirmation dialog for cancellation; clear status afterward.
5. **Completion confirmation**.
   - Customer sees completed scope/price summary, can confirm completion or report an issue.
6. **Rating and review**.
   - Rating input and optional written review, then submitted state.
7. **Complaint submission and complaint status tracking**.
   - Clearly separate from a normal review; request evidence/details, show case status.
8. **Professional mobile flow**.
   - Matched request feed, structured offer builder, sent-offer status, profile/availability, job execution/milestones.
9. **Administrator web portal**.
   - Professional verification, disputes/complaints, account management.
10. **Marketing web**.
    - Separate responsive promotional experience.

## 8) How to review screenshots

When the user shares a Stitch screenshot:

1. Start with the outcome: say whether the screen is accepted, needs a small correction, or is structurally wrong.
2. Check terminology, data flow, action state, privacy, and design-system consistency.
3. Do not nitpick harmless sample names or dates.
4. Flag concrete problems, for example:
   - active CTA before mandatory fields are complete;
   - duplicate primary buttons;
   - `Net` plus `KDV dahil` price conflict;
   - category name changes in the same request;
   - a payment/confirmation/countdown claim outside supported scope;
   - a large blank canvas instead of a realistic 390 × 844 mobile layout.
5. If changes are needed, give a narrowly scoped Stitch edit prompt: `Edit only ... Do not change ...`.
6. If accepted, give exactly one next-screen prompt. Do not jump ahead with a mega-prompt.

## 9) Frontend implementation handoff rules

When implementation begins, convert the visual flow into reusable components and explicit states:

- `AppHeader`, `ProgressIndicator`, `SelectionCard`, `StatusChip`, `InfoCard`, `OfferCard`, `Timeline`, `BottomSheet`, `FixedActionBar`, `EmptyState`.
- Form states: empty, invalid, valid, selected, loading, submitted, pending, confirmed, started, in-progress, completed, cancelled, error.
- Backend-driven entities: request, category, urgency, district, attachments, offer, provider profile, availability slot, appointment, message, milestone, review, complaint.
- Keep all mock data clearly separable from API data.
- Design for accessibility: contrast, visible focus, readable Turkish text, 44px touch targets, icon + label status communication.

## 10) Reference files

- Existing product design system: `DESIGN.md`
- Existing progress/implementation note: `UI_UX_PROGRESS.md`
- This complete AI handoff: `BI_TADILAT_AI_HANDOFF.md`

If a requirements-analysis document is available, use it as the product source of truth. Do not silently invent business rules that conflict with it.
