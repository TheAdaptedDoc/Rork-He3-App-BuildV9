// ai-reflection  (The Council)
// A signed in, entitled man brings a decision or a knot. We pass his Voice Profile
// and his situation to Claude, which answers AS his three voices, Ego, Self, Innate,
// then gives one integrated read. The Anthropic key never leaves the server.
//
// Deploy:  supabase functions deploy ai-reflection --no-verify-jwt
//   (we verify the JWT ourselves so we can return a clean 401)
//
// Secrets to set (supabase secrets set ...):
//   SUPABASE_URL, SUPABASE_ANON_KEY     (provided by the platform)
//   ANTHROPIC_API_KEY                   (console.anthropic.com > API keys)
//   ANTHROPIC_MODEL                     (optional, defaults to claude-haiku-4-5)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const SYSTEM = `You are The Council inside HE3, The Integrated Man, a program by Dr. David Hausmann.

A man runs on three inner voices. You answer AS each of them, in the first person, speaking to him as "you".

EGO, the bodyguard and the driver. Built to protect, push, and win. Reads the situation for threat, status, and momentum. Direct, a little hard, never cruel. It wants him to act and to guard what matters.
SELF, the witness. Sees clean, tells the plain truth, holds the line on his integrity. Measured and honest. It names what he is avoiding and what is actually true.
INNATE, the signal. Knows before it can explain. Quiet, instinctive, close to the body. It speaks to what he already senses underneath the noise.

Then give ONE integrated read called the synthesis: not a vote count, but the move a man makes when all three are aligned. Decisive and kind.

VOICE RULES, follow exactly:
- Sound like David: direct, masculine, grounded, dark humor only if it lands, quick to genuine warmth. Not a therapist, not a guru, not a life coach. No clichments, no affirmations, no "I hear you".
- No hyphens and no em dashes anywhere. Use commas, periods, or shorter sentences.
- Each voice is 2 to 4 sentences. The synthesis is 2 to 4 sentences. Tight, not flowery.
- Speak to his actual situation and his profile. If his Innate is suppressed, let Innate sound faint or rusty but real. If his Ego is dominant, let Ego be loud and sure.
- Never diagnose, never give medical or legal advice. If he describes self harm or crisis, drop the format and tell him plainly to reach a person or a crisis line today, in the synthesis.

Return ONLY a JSON object, no preamble, no markdown:
{"ego": "...", "self": "...", "innate": "...", "synthesis": "..."}`;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader.startsWith("Bearer ")) return json({ error: "not signed in" }, 401);

    const body = await req.json().catch(() => ({}));
    const situation = String(body.situation ?? "").slice(0, 2000).trim();
    const profile = body.profile ?? {};
    const pillar = String(body.pillar ?? "").slice(0, 80);
    if (!situation) return json({ error: "missing situation" }, 400);

    // Run as the caller so auth.uid() and RLS resolve to THIS man.
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: userData, error: userErr } = await supabase.auth.getUser();
    if (userErr || !userData?.user) return json({ error: "not signed in" }, 401);
    const userId = userData.user.id;

    // The same entitlement the sprint reads. The Council is a full program feature.
    const { data: ent, error: entErr } = await supabase.rpc("get_entitlement");
    if (entErr) return json({ error: "entitlement check failed" }, 500);
    const row = Array.isArray(ent) ? ent[0] : ent;
    if (row?.program_access !== true) return json({ error: "not entitled", locked: true }, 403);

    const userMessage =
      `His Voice Profile:\n` +
      `Dominant voice: ${profile.dominant ?? "unknown"}\n` +
      `Suppressed voice (his floor): ${profile.suppressed ?? "unknown"}\n` +
      `Archetype: ${profile.archetype ?? "unknown"}\n` +
      `Scores out of 45: Ego ${profile.ego ?? "?"}, Self ${profile.self ?? "?"}, Innate ${profile.innate ?? "?"}. Integration ${profile.integration ?? "?"} out of 35.\n` +
      (pillar ? `Current pillar: ${pillar}\n` : "") +
      `\nWhat he brought to the Council:\n${situation}`;

    const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!apiKey) return json({ error: "ai not configured" }, 500);
    const model = Deno.env.get("ANTHROPIC_MODEL") ?? "claude-haiku-4-5";

    const aiRes = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model,
        max_tokens: 900,
        system: SYSTEM,
        messages: [{ role: "user", content: userMessage }],
      }),
    });

    if (!aiRes.ok) {
      const detail = await aiRes.text().catch(() => "");
      console.error("anthropic error", aiRes.status, detail);
      return json({ error: "reflection failed" }, 502);
    }

    const data = await aiRes.json();
    const text = (data?.content ?? [])
      .filter((b: { type: string }) => b.type === "text")
      .map((b: { text: string }) => b.text)
      .join("\n")
      .trim();

    const reflection = safeParse(text);
    if (!reflection) return json({ error: "reflection unreadable" }, 502);

    // Best effort log so a man can revisit his Council. Ignore if the table is absent.
    try {
      await supabase.from("reflections").insert({
        user_id: userId,
        pillar: pillar || null,
        situation,
        ego: reflection.ego,
        self_voice: reflection.self,
        innate: reflection.innate,
        synthesis: reflection.synthesis,
      });
    } catch (_) { /* logging is optional */ }

    return json(reflection);
  } catch (_e) {
    return json({ error: "unexpected error" }, 500);
  }
});

// The model is told to return only JSON, but strip stray fences just in case.
function safeParse(text: string) {
  const cleaned = text.replace(/```json/gi, "").replace(/```/g, "").trim();
  try {
    const o = JSON.parse(cleaned);
    if (o && o.ego && o.self && o.innate && o.synthesis) return o;
  } catch (_) { /* fall through */ }
  return null;
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
