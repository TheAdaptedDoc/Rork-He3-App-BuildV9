// stripe-webhook
// Stripe is the source of truth for who paid. This function is the ONLY thing
// that writes entitlement. It verifies Stripe's signature, then writes to the
// profiles table with the service role key (bypassing RLS). The app only ever
// READS entitlement through get_entitlement().
//
// Deploy:  supabase functions deploy stripe-webhook --no-verify-jwt
//   (Stripe calls this with its own signature, not a Supabase JWT)
//
// Secrets to set (supabase secrets set ...):
//   SUPABASE_URL                       (provided by the platform)
//   SUPABASE_SERVICE_ROLE_KEY          (Supabase > Settings > API > service_role)
//   STRIPE_SECRET_KEY                  (Stripe > Developers > API keys)
//   STRIPE_WEBHOOK_SECRET              (Stripe > Developers > Webhooks > your endpoint > signing secret)
//   STRIPE_PRICE_STANDARD              (the Price id for The Standard, optional)
//   STRIPE_PRICE_BROTHERHOOD           (the Price id for The Brotherhood, optional)
//
// Your checkout page must set client_reference_id (or metadata.uid) to the
// Supabase user id, so we know which man to grant. CheckoutLauncher passes
// ?uid=USER_ID to the page for exactly this.

import Stripe from "https://esm.sh/stripe@16?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-06-20",
  httpClient: Stripe.createFetchHttpClient(),
});

const admin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const PRICE_STANDARD = Deno.env.get("STRIPE_PRICE_STANDARD") ?? "";
const PRICE_BROTHERHOOD = Deno.env.get("STRIPE_PRICE_BROTHERHOOD") ?? "";

Deno.serve(async (req) => {
  const sig = req.headers.get("stripe-signature");
  const secret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
  if (!sig || !secret) return new Response("no signature", { status: 400 });

  const raw = await req.text();
  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(raw, sig, secret);
  } catch (e) {
    console.error("bad signature", String(e));
    return new Response("bad signature", { status: 400 });
  }

  try {
    switch (event.type) {
      case "checkout.session.completed": {
        const s = event.data.object as Stripe.Checkout.Session;
        const uid = s.client_reference_id ?? (s.metadata?.uid ?? null);
        const customerId = (s.customer as string) ?? null;
        const email = s.customer_details?.email ?? null;

        // The one time $297 program. Opens a 90 day window.
        if (s.mode === "payment") {
          const now = new Date();
          const end = new Date(now.getTime() + 90 * 24 * 60 * 60 * 1000);
          await grant(uid, customerId, email, {
            program_access: true,
            access_start: now.toISOString(),
            access_end: end.toISOString(),
            stripe_customer_id: customerId,
            referrer_id: s.metadata?.referrer_id ?? null,
            pod_id: s.metadata?.pod_id ?? null,
            standard_bearer_id: s.metadata?.standard_bearer_id ?? null,
          });
        }
        break;
      }

      // Recurring tiers. Status drives the boolean.
      case "customer.subscription.created":
      case "customer.subscription.updated":
      case "customer.subscription.deleted": {
        const sub = event.data.object as Stripe.Subscription;
        const customerId = sub.customer as string;
        const active = sub.status === "active" || sub.status === "trialing";
        const priceId = sub.items.data[0]?.price?.id ?? "";

        const patch: Record<string, unknown> = {};
        if (priceId && priceId === PRICE_STANDARD) patch.standard_active = active;
        if (priceId && priceId === PRICE_BROTHERHOOD) patch.brotherhood_active = active;
        if (Object.keys(patch).length > 0) {
          await admin.from("profiles").update(patch).eq("stripe_customer_id", customerId);
        }
        break;
      }
    }
    return new Response("ok", { status: 200 });
  } catch (e) {
    console.error("handler error", String(e));
    return new Response("handler error", { status: 500 });
  }
});

// Find the man by uid first, then by stripe customer, then by email, and grant.
async function grant(
  uid: string | null,
  customerId: string | null,
  email: string | null,
  patch: Record<string, unknown>,
) {
  if (uid) {
    await admin.from("profiles").update(patch).eq("id", uid);
    return;
  }
  if (customerId) {
    const { data } = await admin.from("profiles").select("id").eq("stripe_customer_id", customerId).maybeSingle();
    if (data?.id) { await admin.from("profiles").update(patch).eq("id", data.id); return; }
  }
  if (email) {
    await admin.from("profiles").update(patch).ilike("email", email);
  }
}
