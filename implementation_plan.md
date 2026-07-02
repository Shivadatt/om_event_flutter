# Enterprise Campaign & Automation Engine Implementation Plan

This plan details the implementation of campaign managers, workflows rules, realtime logs timeline, health dashboards, and visual template builder controls.

---

## User Review Required

> [!IMPORTANT]
> - **Collection Additions:** We will add `campaigns`, `automation_workflows`, `campaign_history`, and `health_metrics` collections in [app_collections.dart](file:///d:/om_event_python/om_event/lib/core/constants/app_collections.dart).
> - **Visual Builder & Timeline Toggles:** We will build modular widgets for visual template editing, journey pipelines, and chronological delivery timelines.
> - **Bulk Exporter & Manual Attachment Dispatcher:** Realtime health logs and CSV/JSON downloads will be integrated.

---

## Proposed Changes

### 1. Database Mappings
- Register new collections: `campaigns`, `automationWorkflows`, and `healthMetrics`.

### 2. Domain & Data Models
- Append `CampaignModel` and `AutomationWorkflowModel` in `notification_models.dart`.

### 3. Customer Journey Automation Rules Engine
- **Modify** `functions/index.js` to process multi-stage journey delays (Push -> Delay -> Email -> Delay -> WhatsApp).
- **Modify** [local_notification_trigger_service.dart](file:///d:/om_event_python/om_event/lib/core/services/local_notification_trigger_service.dart) to simulate workflow execution, delay timings, and health dashboard counters.

### 4. Admin Campaign CMS & Realtime Health Dashboard Upgrades
- **Modify** [settings_notifications_tab.dart](file:///d:/om_event_python/om_event/lib/presentation/screens/admin/widgets/settings_notifications_tab.dart):
  - Add **Realtime Queue Health, API Status, and Retry Rates** metrics dashboard.
  - Add **Visual Campaign Creator** (Draft, Schedule, Publish, Pause).
  - Add **Audience Builder Dropdowns** (by Branch, Status, Service, Date range).
  - Include **Automation Rules Engine builder** panel.
  - Expose **Manual Messaging tab** with attachments (Invoices, PDFs, Images).
  - Include a **Chronological Timeline view** for customer logs.

---

## Verification Plan

### Automated Tests
- Run `fvm flutter analyze` to verify error-free compilation.

### Manual Verification
- Test manual messaging attachment triggers.
- Verify audience filter configurations.
