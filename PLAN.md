# HE³: The Integrated Man System — iOS App


## Features

- **Commitment Oath onboarding** — Full-screen immersive experience on first launch where the user reads and accepts the HE³ oath before entering the app
- **Three-Voices Assessment** — Interactive quiz to identify which voice (Ego, Self, Innate) is dominant and which is suppressed, with a visual results breakdown
- **4-Pillar Journey with locked progression** — Weekly-gated modules (Suppressed Man → Awakening → Integration → Rising) that unlock one per week, preventing binge consumption
- **Core video lessons** — Placeholder cards for each pillar's video content, ready for real video URLs to be added later
- **AI-supported reflection prompts** — Guided journaling with structured prompts tied to each pillar's exercises (Mirror Exercise, Shadow Work, Decision Journal, etc.)
- **Daily practices tracker** — Track completion of Ego, Self, and Innate practices (cold exposure, posture discipline, midday reset, quiet bridge, etc.)
- **Night Practice (Courage Ritual)** — Camera-based selfie video recording for the nightly courage ritual with the three reflection questions
- **Rituals library** — Dedicated tab listing every recorded Courage Ritual video, sortable by newest/oldest, with optional export to the device's native Photos library
- **90-day countdown dashboard** — Live countdown showing days remaining, current pillar progress, streak tracking, and completion percentage
- **In-app purchase ($297)** — One-time purchase to unlock the full 90-day program via RevenueCat
- **Paid reactivation ($147)** — Second-chance 45-day access if the original window expires
- **User accounts** — Sign-up and login to persist progress across devices
- **Restore purchases** — Standard App Store restore functionality
- **Digital manifesto template** — Guided writing experience for the final Rising Man manifesto in Pillar 4

---

## Design — Brand System v2.2 (editorial)

- **Bone paper theme** — BONE (#F2EFE8) backgrounds, OBSIDIAN (#0C0C0E) structural type/fills, ASH (#3C3A3C) body text. No dark mode, no gold.
- **Crimson is the single loud accent** — CRIMSON (#A81C1C) for CTAs, focus/active, EGO. EMBER (#8B4513) is a quiet depth tone (INNATE, secondary marks) — never a competing headline color.
- **Flat and structural** — borderRadius 0 on everything, no drop shadows, no elevation. Hairline PAPER DARK (#DCD8D0) dividers and inactive tracks.
- **Typography** — Oswald 700 for the HE³ wordmark only · Bebas Neue (wide tracking, uppercase) for titles/buttons/results · Cormorant Garamond for questions/body · Playfair Display Italic for taglines/emotional anchors · DM Mono (uppercase, wide letterSpacing) for labels/counters/metadata.
- **Three voices icon system** — EGO = crimson lightning bolt · SELF = obsidian concentric ring + center dot · INNATE = ember sine wave. Three crimson vertical marks ▮▮▮ as the series signature.
- **Left-aligned by default** — center only ceremonial moments (assessment question, result hero, taglines).
- **Quiet motion** — short opacity fades, never spring/bounce.
- **Buttons** — full-width rectangles. Primary = obsidian fill / bone text. Conversion CTA = crimson fill / bone text. Tertiary = 2px obsidian border.

---

## Screens

1. **Commitment Oath** — Full-screen dark onboarding with the oath text, "I commit" button with haptic confirmation. Shown once on first launch
2. **Assessment** — Multi-step quiz flow identifying your dominant and suppressed voice (Ego, Self, Innate) with a results summary card
3. **Dashboard (Home)** — 90-day countdown timer, current pillar card, daily practice checklist, streak counter, and quick access to Night Practice
4. **Pillar Detail** — Deep dive into each pillar with video placeholder, written content, reflection prompts, exercises, and practice instructions. Locked pillars show a "Coming in Week X" overlay
5. **Journal** — List of past journal entries organized by pillar, with the ability to write new reflections tied to specific exercises
6. **Night Practice** — Camera view for recording the Courage Ritual video with the three guiding questions displayed on screen
7. **Manifesto** — Writing space for the final personal manifesto (unlocks in Pillar 4)
8. **Paywall** — Premium purchase screen with program value proposition, $297 one-time purchase, and restore button
9. **Rituals** — Tab listing all saved Courage Ritual videos with date stamps, sort controls, in-app playback, note editing, and Save to Photos
10. **Settings** — Account info, restore purchases, about HE³, and support link

---

## App Icon

- Bone (#F2EFE8) background, flat — no gradients or glow
- HE³ wordmark in Oswald 700 obsidian with a crimson, skewed superscript "3"
- Minimal, bold, editorial — no busy details
