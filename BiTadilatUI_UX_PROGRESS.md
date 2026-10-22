# BiTadilat UI/UX Progress Notes

This file is the working source of truth for the product-design flow. It records what has been designed in Stitch, the intended interaction rules, and the remaining screens required before frontend implementation.

## Product principles

- Turkish-first home repair and renovation marketplace.
- Customer and service-professional experiences are mobile applications.
- Administrator experience is a separate responsive web portal; do not force it into the mobile flow.
- The design system uses Manrope, a warm off-white canvas, white surfaces, deep service teal `#0F4C5C`, verification green, and urgency orange.
- Make information explicit: no fabricated countdowns, availability promises, professional rankings, payments, or appointment confirmations.
- Keep one clear primary action per screen. Disabled actions must be visibly disabled until their required inputs are complete.

## Designed customer flow

### 1. Entry and authentication

1. Welcome / role selection
   - Roles: **Ev sahibi / Müşteri** and **Hizmet profesyoneli**.
   - No role is selected by default.
   - Phone continuation is disabled until one role is selected.
2. Phone-number verification
   - Customer enters a Turkish mobile number.
   - Continue may be active only with a valid populated number.
3. OTP verification
   - Verify action is disabled until all six code digits are entered.
   - Resend must initially read `00:42 sonra tekrar gönder` in a disabled state; it must not be an immediately active resend control.

### 2. Customer request creation

4. Request step 1/4 — service and urgency
   - Select one category and one urgency: **Acil onarım** or **Planlı yenileme**.
   - Categories include Tesisat, Elektrik, Boya & Badana, Klima, Banyo yenileme, Mutfak yenileme, Marangozluk, Diğer.
   - Continue is disabled until both selections are made.
5. Request step 2/4 — location and description
   - City, district, description (minimum 20 characters).
   - Exact street/building address remains private until the relevant professional is selected / appointment is confirmed.
   - Use the product-wide category name **Tesisat**, not the inconsistent alternate label `Sıhhi Tesisat`.
   - Do not hard-code Kadıköy in generic explanatory text.
6. Request step 3/4 — photos and extra information
   - Photos are optional, maximum five.
   - Default state shows `0 / 5 fotoğraf eklendi`, no photo thumbnail, and an active Continue action.
   - Optional extra note: maximum 250 characters.
7. Request step 4/4 — review and publish
   - Review service/urgency, approximate location, description, photos/extra information.
   - A single fixed primary action: **Talebi yayınla**.

### 3. Matching, offers, and acceptance

8. Request published / waiting for offers
   - Show request status and a neutral matching timeline.
   - No artificial countdown, fake provider, price, map, or real-time tracking.
9. Offer list
   - Show transparent offer cards: verified provider, rating and review count, labour, materials, total, availability estimate, and open-details action.
   - The user remains in control; no offer is preselected or labelled "best".
10. Offer detail
   - Show scope, itemized labour/materials/extra costs, total **including VAT**, provider note, warranty, availability estimate, and message action.
   - Price wording: `Toplam tutar (KDV dahil)`; never combine `Net` with `KDV dahil`.
11. Offer comparison
   - Customer can compare two selected offers side by side using the same attributes: total, labour, materials, extra cost, warranty, availability, rating, and scope.
   - Do not visually declare a winner or preselect a provider.
12. Offer acceptance confirmation
   - Bottom sheet over a dimmed offer-detail screen.
   - Acceptance confirms the offer, but it does not select or confirm an appointment yet.

### 4. Appointment

13. Appointment selection
   - Customer selects a day and available time range.
   - CTA remains disabled until both are selected.
   - Action is **Randevu talebi gönder**, not a claim of instant confirmation.
14. Appointment-request waiting state
   - Status: **Ustanın onayı bekleniyor**.
   - Timeline: offer accepted, appointment request sent, professional confirmation pending, job start pending.
   - No promised response duration or countdown.
   - Use category label `Tesisat` consistently.

## Current correction queue

Completed on 2026-10-21 (reported by the designer):

1. OTP resend timer is initially disabled.
2. The generic pricing guidance no longer hard-codes `Kadıköy`.
3. Appointment-request waiting state uses `Tesisat` and no longer promises `Ortalama 15 dk`.

## Remaining customer screens

1. Confirmed appointment and active job workspace.
2. In-app messaging for the selected professional.
3. Job milestones / progress tracking.
4. Customer cancellation flow.
5. Job completion confirmation.
6. Customer review and rating.
7. Complaint submission and complaint-status tracking.

## Remaining professional and web screens

- Professional request feed, structured offer builder, sent-offer status, profile/availability, and job execution milestones.
- Administrator web portal: professional verification, disputes, and account management.
- Marketing / promotion web experience.

## Frontend implementation notes

- Model each form state explicitly: empty, invalid, valid, selected, loading, submitted, pending, confirmed, completed, cancelled, and error.
- Build reusable components: app header, progress indicator, selection card, status chip, fixed bottom action bar, information card, offer card, timeline, and bottom sheet.
- Do not rely on colour alone for urgency, verification, disabled states, or status. Pair colour with icon and Turkish text.
- Treat displayed provider names, prices, dates, ratings, and avatars in mock-ups as sample data only. Production data must come from backend services.
- Dates and availability must be dynamic in the product; mock-up date labels are illustrative only.
