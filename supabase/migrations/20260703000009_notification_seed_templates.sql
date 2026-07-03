-- =============================================================================
-- Migration: 20260703000009_notification_seed_data.sql
-- Purpose  : Seeds canonical notification templates for all event types used
--            by the Om Events application.  These templates are referenced by
--            template_key at dispatch time.
-- Author   : Om Events – Database Architecture Team
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Push Notification Templates
-- ---------------------------------------------------------------------------

INSERT INTO public.notification_templates (
  template_key, name, description, channel, event_type,
  title_template, body_template, status, locale, tags
) VALUES

-- Booking
('booking_confirmed_push', 'Booking Confirmed – Push', 'Sent to customer when admin confirms booking.', 'push', 'Booking Confirmed',
 'Booking Confirmed! 🎉', 'Your event booking {{booking_number}} has been confirmed. We''re excited to celebrate with you!',
 'active', 'en', ARRAY['customer','booking','push']),

('booking_cancelled_push', 'Booking Cancelled – Push', 'Sent to customer when booking is cancelled.', 'push', 'Booking Cancelled',
 'Booking Update', 'Your booking {{booking_number}} status has been updated to CANCELLED. Contact us for details.',
 'active', 'en', ARRAY['customer','booking','push']),

-- Payment
('payment_approved_push', 'Payment Approved – Push', 'Sent to customer when payment receipt is verified.', 'push', 'Payment Approved',
 'Payment Verified ✅', 'Your payment of ₹{{amount}} has been verified successfully. Thank you!',
 'active', 'en', ARRAY['customer','payment','push']),

-- Quotation
('quotation_approved_push', 'Quotation Approved – Push', 'Sent to customer when quotation is approved.', 'push', 'Quotation Approved',
 'Quotation Approved! 🎊', 'Your quotation {{public_id}} has been approved and booked. Let''s create magic!',
 'active', 'en', ARRAY['customer','quotation','push']),

('quotation_rejected_push', 'Quotation Rejected – Push', 'Sent to customer when quotation is rejected.', 'push', 'Quotation Rejected',
 'Quotation Update', 'Your quotation {{public_id}} was not approved at this time. Please contact us for alternatives.',
 'active', 'en', ARRAY['customer','quotation','push']),

-- Reminder
('event_day_reminder_push', 'Event Day Reminder – Push', 'Sent as event day reminder.', 'push', 'Booking Event Reminder',
 '📅 Event Reminder: {{label}}', 'Your Om Events experience is coming up! Event date: {{event_date}}.',
 'active', 'en', ARRAY['customer','reminder','push']),

-- ---------------------------------------------------------------------------
-- Email Templates
-- ---------------------------------------------------------------------------

('booking_confirmed_email', 'Booking Confirmed – Email', 'Email to customer on booking confirmation.', 'email', 'Booking Confirmed',
 'Your Om Events Booking is Confirmed!', 'Dear {{customer_name}}, your booking {{booking_number}} has been confirmed.',
 'active', 'en', ARRAY['customer','booking','email']),

('payment_approved_email', 'Payment Approved – Email', 'Email to customer on payment verification.', 'email', 'Payment Approved',
 'Payment Verified – Om Events', 'Dear {{customer_name}}, your payment of ₹{{amount}} has been verified.',
 'active', 'en', ARRAY['customer','payment','email']),

('quotation_approved_email', 'Quotation Approved – Email', 'Email to customer on quotation approval.', 'email', 'Quotation Approved',
 'Quotation Approved – Om Events', 'Dear {{customer_name}}, your quotation {{public_id}} has been approved!',
 'active', 'en', ARRAY['customer','quotation','email']),

('event_day_reminder_email', 'Event Day Reminder – Email', 'Reminder email for upcoming event.', 'email', 'Booking Event Reminder',
 '{{label}} – Om Events', 'Dear {{customer_name}}, your event on {{event_date}} is {{days}} days away!',
 'active', 'en', ARRAY['customer','reminder','email']),

-- Admin email alerts
('admin_booking_created_email', 'Admin: New Booking – Email', 'Admin alert when new booking is created.', 'email', 'Booking Created',
 'New Booking Received – Om Events Admin', 'A new booking has been submitted by {{customer_name}}. Please review and confirm.',
 'active', 'en', ARRAY['admin','booking','email']),

('admin_payment_uploaded_email', 'Admin: Payment Uploaded – Email', 'Admin alert when payment receipt is uploaded.', 'email', 'Payment Uploaded',
 'Payment Receipt Uploaded – Om Events Admin', 'A payment receipt of ₹{{amount}} has been uploaded and requires verification.',
 'active', 'en', ARRAY['admin','payment','email']),

-- ---------------------------------------------------------------------------
-- WhatsApp Templates
-- ---------------------------------------------------------------------------

('booking_approved_whatsapp', 'Booking Approved – WhatsApp', 'WhatsApp template for booking approval.', 'whatsapp', 'Booking Confirmed',
 'Booking Approved', 'Your Om Events booking {{booking_number}} has been approved! 🎉 We look forward to celebrating with you.',
 'active', 'en', ARRAY['customer','booking','whatsapp']),

('booking_rejected_whatsapp', 'Booking Rejected – WhatsApp', 'WhatsApp template for booking rejection.', 'whatsapp', 'Booking Cancelled',
 'Booking Update', 'Your Om Events booking {{booking_number}} has been updated to CANCELLED. Contact us for assistance.',
 'active', 'en', ARRAY['customer','booking','whatsapp']),

('payment_approved_whatsapp', 'Payment Approved – WhatsApp', 'WhatsApp template for payment verification.', 'whatsapp', 'Payment Approved',
 'Payment Verified', 'Your payment of ₹{{amount}} has been verified by Om Events. Thank you! 🙏',
 'active', 'en', ARRAY['customer','payment','whatsapp']),

('quotation_approved_whatsapp', 'Quotation Approved – WhatsApp', 'WhatsApp template for quotation approval.', 'whatsapp', 'Quotation Approved',
 'Quotation Approved', 'Your Om Events quotation {{public_id}} has been approved and confirmed. Let''s create magic! ✨',
 'active', 'en', ARRAY['customer','quotation','whatsapp']),

('quotation_rejected_whatsapp', 'Quotation Rejected – WhatsApp', 'WhatsApp template for quotation rejection.', 'whatsapp', 'Quotation Rejected',
 'Quotation Update', 'Your Om Events quotation {{public_id}} was not approved at this time. Please reach out for alternatives.',
 'active', 'en', ARRAY['customer','quotation','whatsapp']),

('admin_alerts_whatsapp', 'Admin Alerts – WhatsApp', 'Generic admin alert WhatsApp template.', 'whatsapp', 'Admin Alert',
 'Om Events Admin Alert', 'Alert: {{event_type}} – {{description}}. Please take necessary action.',
 'active', 'en', ARRAY['admin','whatsapp'])

ON CONFLICT (template_key, channel, locale) DO NOTHING;
