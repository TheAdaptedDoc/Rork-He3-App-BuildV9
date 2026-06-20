# HE3 — what to buy and program to go fully live

A plain map of the AI prompt layer and every third party service the app leans on,
what each one is for, what it costs, and what has to be programmed. Prices move, so
confirm the live number at signup. Verified ones are dated.

---

## PART A. The AI prompts

### What exists today
The reflection and journal prompts in the app are static. They are written into the
program, one set per pillar and section, and they show with no network and no cost.
There is no AI call wired in right now. So "AI prompts" today means curated prompts,
not generated ones.

### What turning on real AI would add
Dynamic, personal prompts instead of fixed ones. Examples:
- A daily prompt tuned to the man's dominant and suppressed voice from his Voice Dynamic result.
- A Council style reflection that actually responds to what he just journaled.
- A day 30 read that speaks to how his numbers moved.

### The only safe way to build it
The app must never hold the AI key. The pattern matches the video layer already in place:
1. A Supabase Edge Function holds the Anthropic API key as a server secret.
2. The app sends context (voice profile, current pillar, recent journal) to that function.
3. The function calls Claude, returns the prompt or reflection, and the app shows it.
4. The function checks entitlement first, same gate as the video.

### Model and cost
Claude Haiku 4.5 is plenty for prompt generation and is the cheapest current model at
$1 per million input tokens and $5 per million output tokens (verified June 2026). A
single generation is roughly one to two thousand tokens in and a few hundred out, which
is a fraction of a cent. Even heavy early use lands in low single digit dollars per month.
It is pay as you go with no subscription. Sonnet 4.6 ($3 / $15) is the step up if you
want richer, longer reflections.

### My recommendation
Launch on the curated static prompts. They are tighter, free, and on brand. Add an AI
reflection or Council layer afterward as a premium touch, once the core funnel is earning.
Decision needed from you: AI generated, or keep curated. I can wire either.

---

## PART B. Third party services, the buy and program checklist

### 1. Apple Developer Program
- For: shipping on the App Store, Sign in with Apple, TestFlight.
- Cost: $99 per year.
- Program: enable the Sign in with Apple capability, create the App ID, handle provisioning. The app code already expects this.

### 2. Google Cloud, Sign in with Google
- For: the Google login button.
- Cost: free.
- Program: create an OAuth client, add it to Supabase Auth, register the he3 redirect scheme.

### 3. Supabase (the backbone)
- For: login, the database (entitlements, lessons, assessment results, journal), and the Edge Functions (the video token, the Stripe webhook, and the AI function if you add it).
- Cost: free to start, Pro is $25 per month when you outgrow the free tier.
- Program: run the four SQL files in order, turn on the Apple and Google providers, deploy the edge functions and set their secrets.

### 4. Stripe (the money)
- For: taking payment on the web, then telling the app the man is paid.
- Cost: no monthly fee, about 2.9% plus 30 cents per US card charge.
- Program: create the products and prices ($297 program, The Standard, The Brotherhood), build the small web checkout page, deploy the webhook function that flips entitlement in Supabase. This is what keeps payment out of the app and avoids Apple's 15 to 30 percent cut.

### 5. Mux (the video)
- For: hosting each lesson and streaming it with a signed, expiring link so only paid men can watch.
- Cost: pay as you go with a $20 per month usage credit. Encoding about $0.07 per minute, delivery about $0.025 per minute, storage about $1 per 1000 minutes per month at basic quality (verified June 2026). For a short course watched by a small first room, the monthly credit likely covers most of it.
- Program: upload each lesson with a signed playback policy, paste each playback ID into the lessons table, set the Mux signing key as a secret in the mint-playback-token function.

### 6. Circle (the Brotherhood community)
- For: the members community the app points to.
- Cost: tiers roughly $49 to $89 and up per month, confirm current.
- Program: create the space, single sign on or deep link from the app.

### 7. Kit, formerly ConvertKit (email)
- For: the waitlist and member email.
- Cost: free up to a few thousand subscribers, then paid.
- Program: connect the waitlist and checkout to Kit, build the sequences.

### 8. Rewardful (affiliates)
- For: tracking affiliate sales on top of Stripe, the King Axis side.
- Cost: roughly $49 per month, confirm current.
- Program: connect Stripe, create the affiliate links.

### 9. Netlify (landing and checkout hosting)
- For: hosting the public landing and the Stripe checkout and thank you pages.
- Cost: free tier is fine to start.
- Program: deploy the three pages.

---

## PART C. The minimum to be fully functional

To take a payment and stream a video, you only need four:
1. Apple Developer, $99 per year.
2. Supabase, free to start.
3. Stripe, per transaction.
4. Mux, pay as you go.

Everything else, Circle, Kit, Rewardful, and the AI layer, is additive and can come after launch.

---

## PART D. Rough monthly cost

At launch, small scale, payments plus video working:
- Apple, about $8 per month amortized.
- Supabase, $0 on the free tier.
- Stripe, only on actual sales, about 3% plus 30 cents.
- Mux, often inside the $20 monthly credit early on.
- AI, a few dollars per month only if you turn it on.

So roughly $30 to $50 per month to be live with payments and video, before community and affiliates.
Add Circle and Rewardful and you are roughly $130 to $200 per month with the full stack.

Numbers are guides. Confirm each at signup, since plans change.
