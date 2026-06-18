# HE3 video and entitlement wiring

This adds gated lesson streaming to the app. Videos play only for a man whose
Supabase entitlement is active, the same entitlement that unlocks the 30 day
sprint. No entitlement, no token, no stream.

## What got added

iOS
- Models/Lesson.swift            lesson row model
- Services/EntitlementService.swift   reads get_entitlement on launch and foreground
- Services/VideoService.swift     loads the catalog, mints signed stream URLs
- Views/LessonPlayerView.swift    real AVKit player with locked and coming soon states
- PillarDetailView.swift          placeholder swapped for LessonPlayerView
- ContentView.swift               refreshes entitlement, preloads catalog

Supabase
- migrations/0001_entitlement_and_lessons.sql   entitlement columns, lessons table, RLS, get_entitlement()
- seed/0002_lessons_seed.sql                     31 lesson rows, slugs match section ids
- functions/mint-playback-token/index.ts         verifies entitlement, signs a Mux token

## One time setup

1. Run the migration, then the seed, in the Supabase SQL editor.

2. Upload each lesson to Mux with a SIGNED playback policy. Copy each signed
   playback id into the matching row in the lessons table. Core lesson slugs
   already match the in app section ids, so the player finds them automatically.

3. Create a Mux signing key. Set the function secrets:
       supabase secrets set MUX_SIGNING_KEY_ID=...
       supabase secrets set MUX_SIGNING_PRIVATE_KEY=...   (the base64 key from Mux)

4. Deploy the function:
       supabase functions deploy mint-playback-token

That is the whole video path. Open a pillar section and the lesson streams.

## The one prerequisite

The stream gate calls get_entitlement, which needs a signed in user. Auth is
still a stub (AuthManager.getAccessToken returns nil). Until Rork Auth is wired,
the server returns the locked state and the player shows the locked panel, which
is the correct safe default.

Once Apple and Google sign in are live through Supabase Auth, flip the app gate
from the local hasPurchased flag to EntitlementService.shared.hasProgramAccess.
At that point the sprint and the videos unlock from the same server truth, and
the local purchase boolean can be retired.

## Cloudflare Stream instead of Mux

Keep everything. Only swap the signMuxToken block in the edge function for a
call to Cloudflare's signed token endpoint, and return the signed URL. The
entitlement check above it does not change.
