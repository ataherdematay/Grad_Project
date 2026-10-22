# Design System: BiTadilat

## 1. Product purpose

BiTadilat is a trustworthy, Turkish-first marketplace for home repair and renovation. Customers describe an urgent repair or a planned renovation, receive structured offers from verified local professionals, compare them fairly, schedule a visit, communicate in-app, track work milestones, and leave a review. Service professionals discover relevant work, send transparent offers, manage availability, and complete work through clear milestones.

The customer and service-professional experiences are native mobile applications. The administrator experience is a responsive desktop web portal. The promotional website is a separate responsive web experience. Do not force desktop administration tables into the mobile app.

## 2. Visual theme and atmosphere

Create a calm, credible, practical service experience: modern Turkish urban home-care, not a generic gig marketplace. The UI should feel dependable during an urgent problem and informative during a considered renovation. Use generous white space, clear hierarchy, softly rounded surfaces, precise iconography, and restrained motion. The product must feel original; do not imitate Bitaksi branding, purple palette, taxi visuals, or its logo.

## 3. Platforms and layout

- Mobile baseline: native iOS and Android, 390 by 844 portrait viewport, safe areas respected.
- Use a fixed bottom navigation only on signed-in customer and professional home-level screens; hide it during authentication, forms, modal confirmations, and active work flows.
- Touch targets are at least 44 by 44 points. Keep primary actions pinned above the safe-area when a long form scrolls.
- Use 16 point side padding, 12 point spacing within groups, 24 point spacing between major groups, and 8 point spacing for compact related controls.
- Prefer bottom sheets for contextual choices, confirmation dialogs for irreversible actions, and inline validation beneath the field that needs correction.

## 4. Color palette and semantic roles

- Deep service teal: #0F4C5C. Primary brand, active navigation, high-emphasis actions.
- Dark teal: #0A3945. Pressed states and dark headers.
- Warm repair orange: #E87525. Urgency, time-sensitive repair labels, and a single secondary call to action; never use it for destructive actions.
- Trust green: #107A5B. Verified professional badges, success states, completed milestones.
- Alert red: #B9382C. Errors, destructive actions, unresolved complaint states.
- Information blue: #247BA0. Informative notices and links.
- Canvas: #F7F8F6. Primary page background.
- Surface: #FFFFFF. Cards, sheets, inputs, and raised content.
- Primary text: #102A34. Headings and essential data.
- Secondary text: #5F6F73. Labels, hints, and supporting copy.
- Border: #D9E1DD. Low-emphasis dividers and input outlines.
- Disabled surface: #E9EEEB. Disabled fields and buttons.

Never encode a status with color alone. Pair status colors with an icon and explicit Turkish text.

## 5. Typography

- Use Manrope for the full interface, with Turkish characters rendered correctly.
- Screen title: 28 px, semibold, tight line height.
- Section heading: 20 px, semibold.
- Card title and primary button label: 16 px, semibold.
- Body: 16 px, regular, 1.45 line height.
- Supporting metadata and field labels: 14 px, medium.
- Use sentence case in Turkish. Avoid all-caps labels except short status tags.

## 6. Component rules

- Buttons: primary buttons use deep service teal with white text, 14 px corner radius, 52 px height. Use one primary action per viewport. Secondary buttons are white with teal outline; tertiary actions are text-only.
- Cards: white surface, 16 px radius, 1 px #D9E1DD outline, no heavy shadow. Use a subtle 0 4 16 rgba(16,42,52,0.08) shadow only when a card floats over a map or another surface.
- Inputs: visible label above the field, useful Turkish placeholder, 52 px height, 12 px radius. Error state shows red outline and a concise error sentence below.
- Status chips: compact, icon plus label. Examples: "Doğrulandı", "Yanıt bekliyor", "Ziyaret planlandı", "İş sürüyor", "Tamamlandı".
- Professional cards always show: real-looking Turkish name, trade, neighborhood/service area, verified state, rating with review count, earliest availability, and an explicit action.
- Price presentation always distinguishes labor, materials, total, and validity / estimated arrival time. Never display a misleading single price.
- Use line icons with a 2 px stroke and simple home-repair metaphors: wrench, droplet, plug, paint roller, calendar, shield-check, chat bubble, star.

## 7. Accessibility and trust

- Meet WCAG AA contrast for text and controls.
- Make errors actionable: explain what happened and what the user can do next.
- Display only the minimum contact and location detail needed for an active job. Use partial contact data before a job is accepted.
- Make verification and safety visible: badge, what it means, and a path to report an issue.
- Give every destructive action a confirmation state and explain its consequence. Cancellation must show any applicable policy before confirmation.
- Turkish is the default language. Include a clear TR / EN control in authentication and settings, but do not duplicate both languages in every label.

## 8. Image and map direction

- Use authentic but non-identifying home-repair photography only where it improves confidence: a softly lit bathroom plumbing repair, clean renovation materials, or a professional at work. Avoid stock-photo collages and visual clutter.
- Service request photos are user-content placeholders shown as small rounded thumbnails with add and remove affordances.
- A map is optional and contextual: use it for precise address confirmation or appointment location, not as the main home screen. Do not copy ride-hailing map-first layouts.

## 9. Screen families and navigation

- Customer: authentication, customer home / requests, new request, matching professionals, structured offer comparison, professional profile, visit scheduling, chat and active job workspace, job milestones, cancellation, completion sign-off, review, complaint and complaint status.
- Professional: authentication / role-aware entry, matched requests feed, request detail, structured offer builder, sent offer status, profile and availability, active job milestones, chat, issue reporting.
- Admin web: profile verification, dispute centre, account directory. Use desktop data tables and detail drawers, not mobile layouts.
- Promotional web: marketing site, app download, feature explanation, FAQ, professional acquisition.

## 10. Prompt-ready design system block

Use this exact summary in every Stitch screen prompt:

"BiTadilat design system: a Turkish-first native mobile home repair and renovation marketplace, 390x844 portrait viewport, light canvas #F7F8F6, white surfaces, deep service teal #0F4C5C primary actions, warm repair orange #E87525 for urgent labels only, trust green #107A5B for verified and completed states, Manrope typography, 16 px side padding, soft 12-16 px corners, crisp line icons, WCAG AA contrast, calm trustworthy practical tone. Keep all copy in Turkish. Do not use Bitaksi branding, purple, taxi imagery, or a ride-hailing map-first layout."

## 11. Non-negotiable content rules

- Use believable Turkish examples, such as Kadıköy, Üsküdar, Ataşehir, plumbing, electrical repair, painting, or bathroom renovation.
- Never claim instant matching is guaranteed. Show matching reasons and availability transparently.
- Do not invent payment flows unless they are included in the approved product scope.
- Do not reduce a service request to only a category: include urgency, district, written scope, and optional photos.
- Preserve the distinction between urgent repair and planned renovation throughout the flow.
