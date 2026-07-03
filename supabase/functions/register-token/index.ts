// @ts-nocheck
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { createRemoteJWKSet, jwtVerify } from "https://deno.land/x/jose@v5.2.2/index.ts"

declare const Deno: any;

const FIREBASE_PROJECT_ID = "om-event"
const JWKS_URL = "https://www.googleapis.com/robot/v1/metadata/jwk/securetoken@system.gserviceaccount.com"
const JWKS = createRemoteJWKSet(new URL(JWKS_URL))

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get("Authorization")
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(JSON.stringify({ error: "Missing or invalid authorization header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    const jwt = authHeader.split("Bearer ")[1]

    // Verify Firebase JWT
    const { payload } = await jwtVerify(jwt, JWKS, {
      issuer: `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`,
      audience: FIREBASE_PROJECT_ID,
    })

    const firebaseUid = payload.sub
    if (!firebaseUid) {
      throw new Error("Firebase UID (sub claim) is missing from token")
    }

    // Initialize Supabase Client with Service Role Key
    const supabaseUrl = Deno.env.get("SUPABASE_URL") || ""
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || ""
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { persistSession: false },
    })

    const body = await req.json()
    const action = body.action || "upsert"
    const deviceId = body.device_id || "unknown"

    if (action === "delete") {
      const { error: deleteError } = await supabase
        .from("notification_tokens")
        .delete()
        .eq("user_id", firebaseUid)
        .eq("device_id", deviceId)

      if (deleteError) throw deleteError

      return new Response(JSON.stringify({ success: true, message: "Token deleted successfully." }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    } else {
      const token = body.token
      const platform = body.platform || "unknown"
      const role = body.role || "customer"

      if (!token) {
        return new Response(JSON.stringify({ error: "Missing token parameter" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        })
      }

      // Check if row already exists
      const { data: existing, error: fetchError } = await supabase
        .from("notification_tokens")
        .select("id")
        .eq("user_id", firebaseUid)
        .eq("device_id", deviceId)
        .maybeSingle()

      if (fetchError) throw fetchError

      if (existing) {
        // Update (PATCH)
        const { error: updateError } = await supabase
          .from("notification_tokens")
          .update({
            token: token,
            role: role,
            platform: platform,
            updated_at: new Date().toISOString()
          })
          .eq("id", existing.id)

        if (updateError) throw updateError
      } else {
        // Insert (POST)
        const { error: insertError } = await supabase
          .from("notification_tokens")
          .insert({
            user_id: firebaseUid,
            role: role,
            device_id: deviceId,
            platform: platform,
            token: token,
            updated_at: new Date().toISOString()
          })

        if (insertError) throw insertError
      }

      return new Response(JSON.stringify({ success: true, message: "Token registered successfully." }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})
