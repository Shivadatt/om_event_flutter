-- Migration: 20260706000006_native_crm_triggers
-- Purpose  : Replaces Firebase Cloud Function triggers with native Supabase PostgreSQL database triggers 
--            for CRM events, automatically pushing notifications to notification_queue.

CREATE OR REPLACE FUNCTION public.fn_crm_notification_trigger()
RETURNS TRIGGER AS $$
BEGIN
  -- 1. Leads Table trigger (Inquiries creation)
  IF TG_TABLE_NAME = 'leads' AND TG_OP = 'INSERT' THEN
    INSERT INTO public.notification_queue (
      recipient, recipient_id, notification_type, title, body, channel, status, priority
    ) VALUES (
      'admin@omevents.com', 'admin_main', 'Lead Created', 'New CRM Lead Inquiry',
      'Name: ' || COALESCE(NEW.customer_name, 'Unknown') || ' | Phone: ' || COALESCE(NEW.customer_phone, 'None'),
      'email', 'pending', 'normal'
    );
  END IF;

  -- 2. Bookings Table trigger (Reserving decorators)
  IF TG_TABLE_NAME = 'bookings' THEN
    IF TG_OP = 'INSERT' THEN
      INSERT INTO public.notification_queue (
        recipient, recipient_id, notification_type, title, body, channel, status, priority
      ) VALUES (
        'admin@omevents.com', 'admin_main', 'Booking Created', 'New Booking Request',
        'Submitted by ' || COALESCE(NEW.customer_email, 'Customer'),
        'email', 'pending', 'normal'
      );
    ELSIF TG_OP = 'UPDATE' THEN
      IF OLD.status IS DISTINCT FROM NEW.status THEN
        IF NEW.status IN ('confirmed', 'approved') THEN
          INSERT INTO public.notification_queue (
            recipient, recipient_id, notification_type, title, body, channel, status, priority
          ) VALUES (
            COALESCE(NEW.customer_email, 'customer@gmail.com'),
            COALESCE(NEW.customer_id, 'customer'),
            'Booking Approved', 'Booking Accepted!',
            'Your event has been approved by Om Events.',
            'email', 'pending', 'normal'
          );
        ELSIF NEW.status IN ('cancelled', 'rejected') THEN
          INSERT INTO public.notification_queue (
            recipient, recipient_id, notification_type, title, body, channel, status, priority
          ) VALUES (
            COALESCE(NEW.customer_email, 'customer@gmail.com'),
            COALESCE(NEW.customer_id, 'customer'),
            'Booking Rejected', 'Booking Update',
            'Your booking request was cancelled.',
            'email', 'pending', 'normal'
          );
        END IF;
      END IF;
    END IF;
  END IF;

  -- 3. Quotations Table trigger (Price estimates)
  IF TG_TABLE_NAME = 'quotations' THEN
    IF TG_OP = 'INSERT' THEN
      IF NEW.customer_phone IS NOT NULL AND NEW.customer_phone <> '' THEN
        INSERT INTO public.notification_queue (
          recipient, recipient_id, notification_type, title, body, channel, status, priority, variables
        ) VALUES (
          NEW.customer_phone,
          COALESCE(NEW.customer_id, 'customer'),
          'Quotation Ready', 'WhatsApp Alert', 'Quotation ready',
          'whatsapp', 'pending', 'normal',
          jsonb_build_object('templateName', 'quotation_ready', 'parameters', jsonb_build_array(COALESCE(NEW.public_id, '')))
        );
      END IF;
    ELSIF TG_OP = 'UPDATE' THEN
      IF OLD.status IS DISTINCT FROM NEW.status THEN
        IF NEW.status IN ('approved', 'accepted', 'booked') THEN
          INSERT INTO public.notification_queue (
            recipient, recipient_id, notification_type, title, body, channel, status, priority
          ) VALUES (
            'admin@omevents.com', 'admin_main', 'Quotation Approved',
            'Quotation Approved: ' || COALESCE(NEW.public_id, NEW.id),
            'Quotation ' || COALESCE(NEW.public_id, NEW.id) || ' has been approved/booked by customer ' || COALESCE(NEW.customer_name, 'Customer') || '.',
            'email', 'pending', 'normal'
          );
        END IF;
      END IF;
    END IF;
  END IF;

  -- 4. Payments Table trigger (Payment logging)
  IF TG_TABLE_NAME = 'customer_payments' AND TG_OP = 'INSERT' THEN
    INSERT INTO public.notification_queue (
      recipient, recipient_id, notification_type, title, body, channel, status, priority
    ) VALUES (
      'admin@omevents.com', 'admin_main', 'Payment Created', 'Verify Payment Receipt',
      'Amount: ₹' || COALESCE(NEW.amount::text, '0'),
      'email', 'pending', 'normal'
    );
  END IF;

  -- 5. Reviews Table trigger (Feedback logs)
  IF TG_TABLE_NAME = 'reviews' AND TG_OP = 'INSERT' THEN
    INSERT INTO public.notification_queue (
      recipient, recipient_id, notification_type, title, body, channel, status, priority
    ) VALUES (
      'admin@omevents.com', 'admin_main', 'Review Created', 'New Customer Review',
      'Rating: ' || COALESCE(NEW.rating::text, '5') || ' stars | Comment: ' || COALESCE(NEW.comment, ''),
      'email', 'pending', 'normal'
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach triggers
DROP TRIGGER IF EXISTS trg_leads_notification ON public.leads;
CREATE TRIGGER trg_leads_notification
  AFTER INSERT ON public.leads
  FOR EACH ROW EXECUTE FUNCTION public.fn_crm_notification_trigger();

DROP TRIGGER IF EXISTS trg_bookings_notification ON public.bookings;
CREATE TRIGGER trg_bookings_notification
  AFTER INSERT OR UPDATE ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION public.fn_crm_notification_trigger();

DROP TRIGGER IF EXISTS trg_quotations_notification ON public.quotations;
CREATE TRIGGER trg_quotations_notification
  AFTER INSERT OR UPDATE ON public.quotations
  FOR EACH ROW EXECUTE FUNCTION public.fn_crm_notification_trigger();

DROP TRIGGER IF EXISTS trg_payments_notification ON public.customer_payments;
CREATE TRIGGER trg_payments_notification
  AFTER INSERT ON public.customer_payments
  FOR EACH ROW EXECUTE FUNCTION public.fn_crm_notification_trigger();

DROP TRIGGER IF EXISTS trg_reviews_notification ON public.reviews;
CREATE TRIGGER trg_reviews_notification
  AFTER INSERT ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION public.fn_crm_notification_trigger();
