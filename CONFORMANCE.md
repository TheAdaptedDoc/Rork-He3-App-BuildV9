# HE3 app · conformance to canon

This pass restructured the app to match your uploaded specs. Status of each.

## App Build Spec (Rork) · Auth, Payment, Entitlement

Done
- The one rule: the app never processes payment. The in app credit card form and the fake "complete purchase" were removed. The purchase trio (PurchaseView, PaymentMethodView, PurchaseFlowWrapper) now route only to web checkout.
- Auth: real Supabase Auth. AuthManager signs in with Apple (native button plus nonce) and Google (Supabase OAuth). The nil stub is gone.
- Entitlement: the app reads get_entitlement on launch and on foreground and gates on the result.
- Three gating states: full program, daily practice only (The Standard active), and Locked.
- Locked screen: a single Unlock the Program button that opens the system browser to https://checkout.theintegratedman.com?uid=USER_ID.
- Security: the app holds only the Supabase anon key and the checkout URL. No Stripe key. Entitlement is computed server side and only read.

By hand (platform config, per the spec's own Rork vs by hand split)
- Apple capability "Sign in with Apple" on the target, and the Apple provider enabled in Supabase Auth.
- Google provider keys in Supabase, and a he3:// URL scheme in Info.plist for the OAuth redirect. Verify the exact signInWithOAuth call against your installed supabase-swift version.
- The Stripe products, the web checkout page, and the webhook Edge Function. The schema lists the exact webhook writes.

## Backend Architecture Map

Done
- profiles model matches: program_access, access_start, access_end, standard_active, brotherhood_active, stripe_customer_id, referrer_id, pod_id, standard_bearer_id.
- The Brotherhood is not gated by the app. brotherhood_active is read for status only.
- The Standard link out exists (CheckoutLauncher.openStandard).

## Supabase Schema (your canonical file)

Done
- Your HE3_Supabase_Schema.sql is now migration 0001 verbatim (profiles, RLS, handle_new_user, touch_updated_at, get_entitlement returning a table).
- The app and the edge function were adapted to the table shaped get_entitlement.
- Lessons were added as 0002 (additive), with RLS that honors the same 90 day window.

## Filming Architecture v5 · the 31 video manifest

Done
- The lesson catalog seed (0003) now follows the manifest: Day 0 orientation, one pillar per week, the practices, the two keystones, and the connective beats (Reading Your Voice Profile, The Dip, Day 31).
- Core lesson slugs equal the in app section ids, so each section streams its own video.
- The streaming player is gated by the same entitlement, through a signed Mux token.

To finish
- Upload each video to Mux (signed policy) and paste its playback id into the matching lessons row.

## Canon Amendments V8.3

Done
- Midday Reset renamed to The Midday Truth Tap, with the affect labeling mechanism in the practice copy.
- Ember accent (#8B4513) is the Innate color in the theme; crimson stays Ego and plain emphasis; Self stays obsidian.
- The app is the paid program, so it carries the full practices, which honors the public step one rule (the app over delivers on every public claim).

## System Additions v1

Done
- The Council added as a keystone section in Pillar Three, after Alignment in Action.
- The Re Calibration added as a keystone section in Pillar Four, with the assessment retake instruction.

Noted for a follow up pass
- When You Fracture and Bringing Your People are written as in take video segments, not separate app sections. They live inside the Embodied Freedom and Relational Mastery lessons. No app structure change needed, they ride with those videos.
- The Re Calibration asks the man to retake the assessment and compare day 0 to day 30. The retake entry point and the side by side compare view are a small follow up (the content and instruction are in place now).

## Core Manuscript V8.5

Aligned
- Container language matches: 90 day window, 30 day sprint, one pillar per week, access closes, no lifetime access. The Locked and Purchase copy now say this in brand voice with no hyphens.

## Brand writing rule (no hyphens or em dashes) (DONE)

- Full sweep complete across the app. Removed 30 em dashes from on screen copy: the day and week notification titles now use colons, and the onboarding and program content use commas, periods, or colons as the line reads best.
- Removed the hyphens from copy: self trust, second guess, one sentence, coexist, micro moments, stream of consciousness, and the earlier store and skip button copy.
- Deliberately preserved: the Commitment Oath keeps its original em dash, since it is a locked verbatim passage. Em dashes inside source code comments were left alone, as they are not copy.
- Verified: zero em dashes and zero hyphens remain in any user facing string. The only hyphens left in string literals are date formats, font names, and URL identifiers.

## Two things to action before submission (RESOLVED)

1. Target membership. The project uses Xcode 16 synchronized folders (objectVersion 77, PBXFileSystemSynchronizedRootGroup, the HE3 target syncs the HE3 folder with no exception sets). Every Swift file under HE3 is compiled into the target automatically, so all new files are already in the build. No pbxproj edits were needed. Confirmed all 15 new files sit under the synced root and none are stray.
2. God Mode is now locked to DEBUG. In release builds godMode is a constant false with a no op setter at the source, so no path can enable it, and the review code that switched it on is wrapped in DEBUG so the affordance does not ship. The entitlement gate is the only way into the program in release.

## Open canon question

The in app assessment is 27 questions. Your Voice Profile canon is 34 items. Confirm which is authoritative and I will align the question set and the Reading Your Voice Profile readback.

## Assessment v2 (RESOLVED, locked to assessment.html)

Done
- 34 statements, four subscales (Ego 9, Self 9, Innate 9, Integration 7), verbatim from the live page, shuffled.
- Seven reverse items (8, 9, 17, 18, 26, 27, 34), scored as 6 minus raw.
- Recalibrated bands. Voice: Suppressed 9 to 20, Balanced 21 to 29, Loud 30 to 37, Dominant 38 to 45. Integration: Fragmented 7 to 15, Partial 16 to 22, Strong 23 to 29, High 30 to 35.
- Four metrics: Dominant Voice, Suppressed Voice (Floor), Voice Spread, and a directly measured Integration Index. The old engine's spread bug is gone.
- The deterministic five archetype chain, exact tie breaks (Ego over Self over Innate for highest, Innate over Self over Ego for lowest), verified against the handoff worked example and all five branches.
- Verbatim archetype result copy for all five profiles, already hyphen free.
- Results screen shows the profile, the four metrics, the voice and integration bars with bands, the full longform read as a one open accordion, the four week bridge, and the CTA.
- Re Calibration: the day 0 baseline is captured on first take and persisted. Each take writes to Supabase tagged day0 or day30 (migration 0003) so spread falling and integration climbing can be plotted.
- Intro copy updated to 34 questions and 7 minutes.

To finish
- A small in app entry point and a side by side day 0 versus day 30 compare screen for the Re Calibration (data and storage are in place).

## Re Calibration compare screen (DONE)

- RecalibrationView lays day 0 next to day 30: Integration Index with its band, Voice Spread, and each voice subscale, with direction labels (climbing, falling, holding). Ember marks good movement, crimson marks the wrong direction.
- It calls out the buried voice climbing out of Suppressed, and shows the archetype shift when the pattern moves.
- Three states: no baseline, baseline set and awaiting the day 30 retake (shows the day 0 snapshot), and the full compare after a retake.
- Retake runs the same 34 item assessment in place. The baseline holds, the new take becomes day 30, and both persist locally and to Supabase.
- Entry point: a Re Calibration card on the dashboard, shown once the assessment is taken.

## Reading Your Voice Profile readback (DONE)

- The Day 0 connective lesson now plays alongside the man's stored result. VoiceProfileReadbackView streams the c_reading_profile lesson (same entitlement gate) and reads back his day 0 baseline underneath it: the archetype, the four metrics with bands, the voice and integration bars, and the full longform read.
- It always reads the day 0 baseline, even after a day 30 retake, and points the man to the Re Calibration when a retake exists.
- The result rendering was extracted into a shared ProfileReadout, so the post assessment screen and the readback never diverge.
- Entry point: a Reading Your Voice Profile card on the dashboard, shown once the assessment is taken, beside the Re Calibration card.
- New files to add to the target: ProfileReadout.swift, VoiceProfileReadbackView.swift.

## Daily practice only sub gating (DONE)

- The three states now render distinctly. In daily practice only (The Standard active, program window closed): the dashboard keeps the practices, the streak, the night Courage Ritual, and the Re Calibration, and shows a daily practice banner plus a locked full program card that opens web checkout.
- The Pillars tab locks every pillar in that state and shows a renewal banner that links to checkout. Journal and Rituals stay open.
- Full program and God Mode render the complete dashboard and unlocked pillars as before.
