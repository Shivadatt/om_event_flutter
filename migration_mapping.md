# Firestore to Supabase Migration Mapping

| Firestore Collection | Supabase Table | Primary Key | Key Field Mappings |
| :--- | :--- | :--- | :--- |
| `admins` | `public.admins` | `id` | `createdBy` &rarr; `created_by`, `createdAt` &rarr; `created_at` |
| `bookings` | `public.bookings` | `id` | Direct Match |
| `chat_rooms` | `public.chat_rooms` | `id` | Direct Match |
| `device_tokens` | `public.device_tokens` | `id` | Direct Match |
| `gallery` | `public.gallery` | `id` | Direct Match |
| `inquiries` | `public.inquiries` | `id` | Direct Match |
| `notifications` | `public.notifications` | `id` | Direct Match |
| `permissions` | `public.permissions` | `id` | Direct Match |
| `reviews` | `public.reviews` | `id` | Direct Match |
| `roles` | `public.roles` | `id` | Direct Match |
| `service_categories` | `public.service_categories` | `id` | Direct Match |
| `services` | `public.services` | `id` | Direct Match |
| `settings` | `public.settings` | `id` | Direct Match |
| `users` | `public.users` | `id` | `createdAt` &rarr; `created_at`, `fcmToken` &rarr; `fcm_token`, `updatedAt` &rarr; `updated_at`, `profileImage` &rarr; `profile_image`, `isActive` &rarr; `is_active` |
