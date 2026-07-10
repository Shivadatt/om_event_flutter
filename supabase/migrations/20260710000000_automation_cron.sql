-- Enable the pg_cron extension if not enabled
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 1. Hourly check for quotation expiry
SELECT cron.schedule(
  'check-quotation-expiry-hourly',
  '0 * * * *', -- Every hour
  $$
  SELECT net.http_post(
    url := 'https://om-event.supabase.co/functions/v1/check-quotation-expiry',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer service-role-jwt-key"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- 2. Hourly check for expiry reminders
SELECT cron.schedule(
  'send-expiry-reminders-hourly',
  '5 * * * *', -- Every hour at minute 5
  $$
  SELECT net.http_post(
    url := 'https://om-event.supabase.co/functions/v1/send-expiry-reminders',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer service-role-jwt-key"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- 3. Hourly check for viewed followups
SELECT cron.schedule(
  'send-followups-hourly',
  '10 * * * *', -- Every hour at minute 10
  $$
  SELECT net.http_post(
    url := 'https://om-event.supabase.co/functions/v1/send-followups',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer service-role-jwt-key"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- 4. Daily check for booking reminders
SELECT cron.schedule(
  'send-booking-reminders-daily',
  '0 6 * * *', -- Daily at 6:00 AM
  $$
  SELECT net.http_post(
    url := 'https://om-event.supabase.co/functions/v1/send-booking-reminders',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer service-role-jwt-key"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- 5. Hourly check to process the notification outbox queue
SELECT cron.schedule(
  'process-notification-queue-hourly',
  '*/30 * * * *', -- Every 30 minutes
  $$
  SELECT net.http_post(
    url := 'https://om-event.supabase.co/functions/v1/process-notification-queue',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer service-role-jwt-key"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- 6. Daily log cleanup job
SELECT cron.schedule(
  'cleanup-old-automation-logs-daily',
  '0 1 * * *', -- Daily at 1:00 AM
  $$
  SELECT net.http_post(
    url := 'https://om-event.supabase.co/functions/v1/cleanup-old-automation-logs',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer service-role-jwt-key"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- 7. Daily analytics refresh job
SELECT cron.schedule(
  'calculate-analytics-daily',
  '0 2 * * *', -- Daily at 2:00 AM
  $$
  SELECT net.http_post(
    url := 'https://om-event.supabase.co/functions/v1/calculate-analytics',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer service-role-jwt-key"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- 8. Daily morning digest briefing job
SELECT cron.schedule(
  'send-daily-digest-daily',
  '0 9 * * *', -- Daily at 9:00 AM
  $$
  SELECT net.http_post(
    url := 'https://om-event.supabase.co/functions/v1/daily-digest',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer service-role-jwt-key"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);
