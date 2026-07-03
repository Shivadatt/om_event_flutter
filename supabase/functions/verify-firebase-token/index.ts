import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { createRemoteJWKSet, jwtVerify } from "https://deno.land/x/jose@v5.2.2/index.ts"

const FIREBASE_PROJECT_ID = "om-event"
const JWKS_URL = "https://www.googleapis.com/robot/v1/metadata/jwk/securetoken@system.gserviceaccount.com"

const JWKS = createRemoteJWKSet(new URL(JWKS_URL))

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
}

serve(async (req) => {
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

    const token = authHeader.split("Bearer ")[1]

    // Verify Firebase JWT
    const { payload } = await jwtVerify(token, JWKS, {
      issuer: `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`,
      audience: FIREBASE_PROJECT_ID,
    })

    const firebaseUid = payload.sub
    if (!firebaseUid) {
      throw new Error("Firebase UID (sub claim) is missing from token")
    }

    const email = (payload.email as string || "").trim()
    const name = (payload.name as string || email.split("@")[0] || "User").trim()

    // Initialize Supabase Client with Service Role Key
    const supabaseUrl = Deno.env.get("SUPABASE_URL") || ""
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || ""
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { persistSession: false },
    })

    // Search users table
    const { data: user, error: fetchError } = await supabase
      .from("users")
      .select("*")
      .eq("firebase_uid", firebaseUid)
      .maybeSingle()

    if (fetchError) {
      throw fetchError
    }

    if (!user) {
      // If user does not exist, auto-create one as customer (or super_admin if matching business email)
      const isSuper = email.toLowerCase() === "omeventsanddecorators@gmail.com"
      const role = isSuper ? "super_admin" : "customer"

      const { data: newUser, error: insertError } = await supabase
        .from("users")
        .insert({
          firebase_uid: firebaseUid,
          email: email,
          name: name,
          role: role,
          branch: "Ahmedabad",
          is_active: true,
        })
        .select()
        .single()

      if (insertError) {
        throw insertError
      }

      return new Response(JSON.stringify({ user: newUser }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    return new Response(JSON.stringify({ user }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })

  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})
