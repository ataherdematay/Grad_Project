# BiTadilat prototype: language and navigation fixes

Branch: `fix/language-and-navigation` (prepared by Alaa with Claude). Applies to `preview/` only. The Flutter app in `mobile/` is NOT changed.

## What was wrong
1. **TR/EN only half worked.** The translator replaced pieces of sentences, so English was glued onto Turkish suffixes, and the dictionary had only 177 entries. In EN mode about 1,200 of ~2,580 texts stayed Turkish.
2. **Buttons stopped working in EN mode.** The saved language was applied before the click handlers were attached. The handlers find buttons by Turkish words (for example "gönder", "karşılaştır"), so after translation they no longer matched.
3. **Invalid CSS selectors (`:has(...:contains(...))`)** in 5 screens threw a script error and stopped the handlers from being attached (offer preparation, messaging, rating, admin document review, pro pending).
4. **Screens with no way in** from the normal flow: Compare Offers, Cost Items modal, Job Approval, Rating, the 4 Admin screens and the landing page.

## What changed
- `preview/screens/*.html` (all 48): new dictionary (about 1,440 phrases) and a whole-phrase translator. It never mixes languages; text it does not know stays as it was. Language is now applied after the handlers are attached. The 5 broken selectors are fixed.
- New links: "Compare Offers" button on the offers list; "Edit Cost Items" button on offer preparation; the "Approval" step on Job Workspace and Job Progress opens Job Approval (then Rating); "View Website" link on the Welcome screen; "Admin Portal" link in the landing footer. The admin screens already link to each other.
- `preview/nav_map.json` regenerated from the real links in the screens.
- TR/EN toggle stays on the main screens only (as agreed).

## Left for later (not touched)
Payment / 3D Secure / live-navigation screens and flow, the simulator side panel (still Turkish), the Flutter localization (`mobile/` has no ARB files yet), and names/districts (Kadıköy, Mehmet Usta...) which stay as proper nouns.

## Test results
- All 48 screens reachable by clicking from the Welcome screen, in both TR and EN.
- EN mode: about 100 strings stay Turkish, all of them names or districts.
- Not run: the Flutter app (no SDK in the sandbox); please run `flutter analyze` and `flutter test`.

## How to check
Open `preview/index.html`, press EN in the top bar, click through Welcome → role → phone → SMS → Home → create request → offers → Compare Offers.
