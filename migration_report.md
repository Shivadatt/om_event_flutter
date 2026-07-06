# Enterprise Firestore to Supabase Migration Report

## Execution Summary
- **Timestamp**: 2026-07-06T16:55:05.550337 UTC
- **Firestore Documents Scanned**: 538
- **Supabase Rows Upserted**: 534
- **Failed Records**: 0
- **Skipped Records**: 4
- **Accuracy**: 100.00%

## Collection Level Metrics
| Collection | Target Table | Discovered Docs | Migrated Rows | Skipped | Failed |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `roles` | `public.roles` | 3 | 3 | 0 | 0 |
| `permissions` | `public.permissions` | 19 | 19 | 0 | 0 |
| `admins` | `public.admins` | 4 | 4 | 0 | 0 |
| `service_categories` | `public.categories` | 11 | 11 | 0 | 0 |
| `services` | `public.experiences` | 43 | 43 | 0 | 0 |
| `users` | `public.users` | 8 | 8 | 0 | 0 |
| `bookings` | `public.bookings` | 1 | 1 | 0 | 0 |
| `gallery` | `public.gallery` | 430 | 430 | 0 | 0 |
| `chat_rooms` | `public.chat_rooms` | 1 | 1 | 0 | 0 |
| `device_tokens` | `public.notification_tokens` | 1 | 0 | 1 | 0 |
| `inquiries` | `public.leads` | 1 | 1 | 0 | 0 |
| `notifications` | `public.notification_queue` | 3 | 0 | 3 | 0 |
| `reviews` | `public.reviews` | 1 | 1 | 0 | 0 |
| `settings` | `public.settings` | 12 | 12 | 0 | 0 |
