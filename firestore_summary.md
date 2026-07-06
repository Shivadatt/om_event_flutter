# Firestore Catalog Schema Discovery & Audit Summary

This report presents a complete structural and statistical analysis of the live Firestore database collections, field-level data schemas, and relations.

---

## 1. Catalog Metrics Overview

*   **Firestore Collections Count**: 14
*   **Total Document Count**: 538
*   **Total Field Attributes Discovered**: 84
*   **Missing Primary Keys**: None (all tables map Firestore Document IDs to PostgreSQL primary key column `id`).

| Collection Name | Document Count | Average Fields | Key Data Types Discovered |
| :--- | :--- | :--- | :--- |
| `admins` | 4 | 8 | `STRING`, `ARRAY`, `TIMESTAMP` |
| `bookings` | 1 | 11 | `STRING`, `NUMBER`, `TIMESTAMP` |
| `chat_rooms` | 1 | 3 | `STRING`, `TIMESTAMP` |
| `device_tokens` | 1 | 3 | `STRING`, `TIMESTAMP` |
| `gallery` | 430 | 6 | `STRING`, `NUMBER`, `TIMESTAMP` |
| `inquiries` | 1 | 8 | `STRING`, `TIMESTAMP` |
| `notifications` | 3 | 6 | `BOOLEAN`, `STRING`, `TIMESTAMP` |
| `permissions` | 19 | 2 | `STRING`, `TIMESTAMP` |
| `reviews` | 1 | 5 | `BOOLEAN`, `STRING`, `NUMBER`, `TIMESTAMP` |
| `roles` | 3 | 2 | `STRING`, `TIMESTAMP` |
| `service_categories` | 11 | 4 | `STRING`, `BOOLEAN`, `TIMESTAMP` |
| `services` | 43 | 18 | `STRING`, `NUMBER`, `ARRAY`, `TIMESTAMP` |
| `settings` | 12 | 3 | `STRING`, `TIMESTAMP` |
| `users` | 8 | 14 | `STRING`, `BOOLEAN`, `MAP`, `ARRAY`, `TIMESTAMP` |

---

## 2. Inferred Relationships (Foreign Keys)

*   `services.category_id` &rarr; `service_categories.id`
*   `gallery.service_id` &rarr; `services.id`
*   `gallery.booking_id` &rarr; `bookings.id`
*   `notifications.user_id` &rarr; `users.id`
*   `chat_messages.room_id` &rarr; `chat_rooms.id`
*   `admins.role_id` &rarr; `roles.id`
*   `role_permissions.role_id` &rarr; `roles.id`
*   `role_permissions.permission_id` &rarr; `permissions.id`

---

## 3. Nested Structures & JSON Targets

*   **`users.notification_preferences`**: A `MAP` type storing settings like `{'push': True, 'email': True}`. Target column: `notification_preferences JSONB`.
*   **`users.saved_addresses`**: An `ARRAY` type containing location detail objects. Target column: `saved_addresses JSONB`.
*   **`services.theme_options`**: An `ARRAY` of strings representing decoration themes. Target column: `theme_options TEXT[]`.
*   **`services.what_included`**: An `ARRAY` of strings detailing catalog items. Target column: `what_included TEXT[]`.

---

## 4. Migration Complexity, Risks & Estimates

### Complexity: **Medium**
*   **Rationale**: The database schema is mostly flat with the exception of JSONB configurations for user preferences/addresses, and standard string array representations for catalog metadata. Table keys are standard strings that map cleanly to document paths.

### Risks:
1.  **Orphaned Foreign Keys**: If Firestore contains reference references (e.g. `service_id = 7`) that do not exist in the primary keys of the catalog services, insertion will fail.
2.  **Date Representation**: Firestore timestamps are parsed as UTC timezone objects; mapping to `TIMESTAMPTZ` in Supabase is necessary to avoid timezone offsets.
3.  **Active Connections**: Read streams and updates might take place during migration; running the migration using upsert prevents data duplication.

### Estimates:
*   **Schema Creation**: 5 minutes (Phase 1 SQL execution).
*   **Data Streaming & Sync**: 2 minutes (Python mapping runner execution).
*   **Total Validation & Deploy**: 15 minutes.
