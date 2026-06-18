// mint-playback-token
// The real stream gate. A signed in man asks for a lesson by playback id.
// We verify HIS entitlement server side (the same get_entitlement the sprint reads),
// and only then sign a short lived Mux playback token. No entitlement, no token,
// no stream. The playback id alone is useless because the Mux asset uses a SIGNED
// playback policy.
//
// Deploy:  supabase functions deploy mint-playback-token --no-verify-jwt
//   (we verify the JWT ourselves below so we can return a clean 401)
//
// Secrets to set (supabase secrets set ...):
//   SUPABASE_URL, SUPABASE_ANON_KEY            (provided by the platform)
//   MUX_SIGNING_KEY_ID                         (Mux > Settings > Signing Keys)
//   MUX_SIGNING_PRIVATE_KEY                    (the base64 private key Mux gives you)
//
// Cloudflare Stream alternative: swap the signMuxToken block for a call to
// Cloudflare's /stream/{uid}/token endpoint with your account token, and return
// the signed URL instead. The entitlement check above stays identical.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import jwt from "npm:jsonwebtoken@9";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") {
    return json({ error: "method not allowed" }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader.startsWith("Bearer ")) {
      return json({ error: "not signed in" }, 401);
    }

    const { playbackId } = await req.json().catch(() => ({}));
    if (!playbackId || typeof playbackId !== "string") {
      return json({ error: "missing playbackId" }, 400);
    }

    // Run as the caller so RLS and auth.uid() resolve to THIS man.
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: userData, error: userErr } = await supabase.auth.getUser();
    if (userErr || !userData?.user) {
      return json({ error: "not signed in" }, 401);
    }

    // The same entitlement the sprint reads. Source of truth is the DB, mirrored
    // from Stripe by the webhook. We never trust a client claim.
    const { data: ent, error: entErr } = await supabase.rpc("get_entitlement");
    if (entErr) return json({ error: "entitlement check failed" }, 500);

    // get_entitlement() returns a single row table, so read the first row.
    const row = Array.isArray(ent) ? ent[0] : ent;
    const programAccess = row?.program_access === true;
    if (!programAccess) {
      return json({ error: "not entitled", locked: true }, 403);
    }

    // Confirm the lesson exists and is published before signing anything.
    const { data: lesson } = await supabase
      .from("lessons")
      .select("mux_playback_id, is_published")
      .eq("mux_playback_id", playbackId)
      .maybeSingle();

    if (!lesson || lesson.is_published !== true) {
      return json({ error: "lesson not available" }, 404);
    }

    const token = signMuxToken(playbackId);
    // Short lived. The app refetches a token each time a lesson opens.
    return json({ token, url: `https://stream.mux.com/${playbackId}.m3u8?token=${token}`, expiresIn: 3600 });
  } catch (_e) {
    return json({ error: "unexpected error" }, 500);
  }
});

function signMuxToken(playbackId: string): string {
  const keyId = Deno.env.get("MUX_SIGNING_KEY_ID")!;
  // Mux gives the private key base64 encoded. Decode it to PEM for signing.
  const privateKey = atob(Deno.env.get("MUX_SIGNING_PRIVATE_KEY")!);
  return jwt.sign(
    { sub: playbackId, aud: "v", exp: Math.floor(Date.now() / 1000) + 3600 },
    privateKey,
    { algorithm: "RS256", keyid: keyId },
  );
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
