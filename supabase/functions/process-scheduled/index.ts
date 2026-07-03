import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

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
    const supabaseUrl = Deno.env.get("SUPABASE_URL") || ""
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || ""
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { persistSession: false },
    })

    // Fetch pending scheduled notifications that are due
    const { data: dueSchedules, error: fetchError } = await supabase
      .from("scheduled_notifications")
      .select("*")
      .eq("status", "pending")
      .lte("trigger_at", new Date().toISOString())
      .limit(50)

    if (fetchError) {
      throw fetchError
    }

    if (!dueSchedules || dueSchedules.length === 0) {
      return new Response(JSON.stringify({ message: "No due scheduled notifications." }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    let promotedCount = 0

    for (const schedule of dueSchedules) {
      const scheduleId = schedule.id

      // 1. Insert into notification_queue
      const { data: newQueueTask, error: insertError } = await supabase
        .from("notification_queue")
        .insert({
          recipient: schedule.recipient,
          recipient_id: schedule.recipient_id,
          notification_type: schedule.event_type || "Scheduled Reminder",
          title: schedule.title,
          body: schedule.body,
          channel: schedule.channel,
          priority: schedule.priority || "normal",
          status: "pending",
          retry_count: 0,
          variables: schedule.variables || {},
          metadata: { ...schedule.metadata, scheduled_id: scheduleId },
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })
        .select()
        .single()

      if (insertError) {
        console.error(`Failed to promote schedule ${scheduleId}:`, insertError)
        // Mark schedule as failed
        await supabase
          .from("scheduled_notifications")
          .update({
            status: "failed",
            updated_at: new Date().toISOString()
          })
          .eq("id", scheduleId)
        continue
      }

      // 2. Update scheduled_notifications status to queued and record queue_id
      await supabase
        .from("scheduled_notifications")
        .update({
          status: "queued",
          queue_id: newQueueTask.id,
          fired_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })
        .eq("id", scheduleId)

      promotedCount++
    }

    return new Response(JSON.stringify({ success: true, message: `Successfully promoted ${promotedCount} scheduled notifications.` }), {
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
