# HE3 — connection checklist, service by service

You have accounts already. This is the wiring: what to set in each account so the
code I built actually talks to it. The code side (database, edge functions, the
app) is done. What is left is account config: keys, secrets, providers, products,
webhooks. Do these in order, top to bottom, because later steps depend on earlier ones.

Secret names below are exact. Set Supabase secrets with:
`supabase secrets set NAME=value` (or in the dashboard under Edge Functions > Secrets).

---

## 1. SUPABASE  (the foundation, do this first)

Database
- [ ] Open the SQL editor and run these in order:
      0001_core_schema.sql
      0002_lessons.sql
      0003_assessment.sql
      0004_reflections.sql
      then the seed: supabase/seed/0003_lessons_seed.sql
- [ ] Confirm the tables exist: profiles, lessons, assessment_results, reflections.

Edge functions (deploy all three)
- [ ] `supabase functions deploy mint-playback-token --no-verify-jwt`
- [ ] `supabase functions deploy ai-reflection --no-verify-jwt`
- [ ] `supabase functions deploy stripe-webhook --no-verify-jwt`

Secrets the platform already gives you (confirm they resolve)
- [ ] SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY
      (Settings > API. The service role key is secret, never put it in the app.)

Check
- [ ] In the app, a signed in but unpaid man hits the Locked screen. That proves
      get_entitlement() is wired.

---

## 2. APPLE  (Sign in with Apple)

- [ ] In the Apple Developer portal, your App ID has the Sign in with Apple capability on.
- [ ] In Xcode or Rork, the target has the Sign in with Apple capability added.
- [ ] In Supabase > Authentication > Providers > Apple: turn it on, paste the
      Services ID, Team ID, Key ID, and the private key.
- [ ] Add your redirect URL to Apple: the Supabase callback shown on that provider page.

Check
- [ ] Tap Sign in with Apple in the app, complete it, land back signed in.

---

## 3. GOOGLE  (Sign in with Google)

- [ ] In Google Cloud Console, create an OAuth client (iOS plus Web).
- [ ] In Supabase > Authentication > Providers > Google: turn it on, paste the
      client ID and secret.
- [ ] Add the Supabase callback URL to the Google client's authorized redirect URIs.
- [ ] Confirm the app's URL scheme he3:// is registered so Google can return to the app.

Check
- [ ] Tap Sign in with Google, complete it, land back signed in.

---

## 4. STRIPE  (payments, then access)

Products and prices
- [ ] Create the program product, one time, $297. Note its Price id.
- [ ] Create The Standard, recurring $19 per month. Note its Price id.
- [ ] Create The Brotherhood, recurring $147 per month. Note its Price id.

Checkout page (your Netlify checkout)
- [ ] The page reads ?uid=USER_ID and sets it as client_reference_id on the Stripe
      Checkout Session. This is how the webhook knows which man to grant. Without it,
      a payment cannot be matched to an account.
- [ ] On success, redirect to your thank you page.

Webhook
- [ ] Stripe > Developers > Webhooks > Add endpoint. Point it at your deployed
      function URL: https://<your-project>.functions.supabase.co/stripe-webhook
- [ ] Subscribe it to: checkout.session.completed, customer.subscription.created,
      customer.subscription.updated, customer.subscription.deleted.
- [ ] Copy the endpoint's signing secret.

Secrets (set in Supabase)
- [ ] STRIPE_SECRET_KEY        (Developers > API keys)
- [ ] STRIPE_WEBHOOK_SECRET    (the signing secret from the step above)
- [ ] STRIPE_PRICE_STANDARD    (the Standard Price id)
- [ ] STRIPE_PRICE_BROTHERHOOD (the Brotherhood Price id)

Check
- [ ] Use a Stripe test card to buy the program. Within a few seconds the man's
      profile flips program_access true, and the app shows the program on next refresh.

---

## 5. MUX  (the lesson video)

- [ ] Mux > Settings > Signing Keys: create a signing key. Note the Key ID and the
      base64 private key.
- [ ] Set your default playback policy to SIGNED (not public).
- [ ] Upload each lesson. For each asset, copy its signed Playback ID.
- [ ] In Supabase, paste each Playback ID into the matching row of the lessons table
      (mux_playback_id), and set is_published true.

Secrets (set in Supabase)
- [ ] MUX_SIGNING_KEY_ID
- [ ] MUX_SIGNING_PRIVATE_KEY   (the base64 private key)

Check
- [ ] As a paid man, open a lesson with a Playback ID set. It streams. Owner preview
      still shows the Coming Soon card by design.

---

## 6. ANTHROPIC  (The Council, the AI reflection)

- [ ] console.anthropic.com > API keys: create a key for this project.
- [ ] Add a little prepaid credit, or set a monthly cap, so spend is bounded.

Secrets (set in Supabase)
- [ ] ANTHROPIC_API_KEY
- [ ] ANTHROPIC_MODEL   (optional. Defaults to claude-haiku-4-5. Set to
      claude-sonnet-4-6 if you want richer, longer reflections at higher cost.)

Check
- [ ] As a paid man, open The Council, bring a decision, convene. Three voices plus a
      synthesis come back, and a row lands in the reflections table. Owner preview
      shows the built in sample without spending anything.

---

## 7. CIRCLE  (the Brotherhood community)

- [ ] Create the space and the member tiers.
- [ ] Set up single sign on or a deep link so a member moves from the app into Circle
      without a second login.
- [ ] Brotherhood access is enforced in Circle and mirrored in Supabase via the
      subscription webhook above.

---

## 8. KIT  (email)

- [ ] Connect your waitlist form and your checkout to Kit so buyers and leads flow in.
- [ ] Build the welcome and nurture sequences.

---

## 9. REWARDFUL  (affiliates, King Axis)

- [ ] Connect Rewardful to your Stripe account.
- [ ] Create affiliate links. Rewardful tags the Stripe checkout, and the referrer
      flows through to the profile via checkout metadata.

---

## 10. NETLIFY  (the public pages)

- [ ] Deploy the landing, checkout, and thank you pages.
- [ ] Point your domain at them.
- [ ] Confirm the checkout page passes uid through to Stripe as in step 4.

---

## FINAL END TO END SMOKE TEST

Run this once, in order, on a real device or TestFlight:
1. [ ] Fresh install. You land on the home screen, fonts and tri color marks correct.
2. [ ] Take the Voice Dynamic, 34 questions, auto advancing, blind. You get your archetype read.
3. [ ] Sign in with Apple or Google. You land on the Locked screen.
4. [ ] Buy the program with a Stripe test card. The app flips to the full program.
5. [ ] Open a lesson with a Mux Playback ID set. It streams.
6. [ ] Open The Council, convene, get a reflection.
7. [ ] Set AppConfig.ownerPreviewEnabled to false, rebuild, confirm the owner doors are gone.
8. [ ] Submit to TestFlight, then the App Store.

When all eight pass, you are fully connected and ready to launch.
