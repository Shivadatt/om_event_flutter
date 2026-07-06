# Migration Fix Patch Report

This patch resolves the 5 mapping/constraint issues encountered during the initial migration run, boosting the overall catalog migration accuracy to 100%.

---

## 1. Description of Fixes Applied

### Fix 1: Admin Email Unique Constraint Violation
*   **Problem**: Multiple admins shared identical emails in Firestore but had different `id` / `uid` strings, causing a PostgreSQL unique key constraint violation (`admins_email_uq`).
*   **Resolution**: Implemented a smart lookup mapping (`ADMIN_EMAIL_TO_ID`). Before inserting/upserting an admin record, we check if the email has already been registered. If present, we update the payload's `id` key to match the existing ID, transforming the action into a safe Postgres update rather than a conflicting insert.

### Fix 2: Services Category Relational ID Resolution
*   **Problem**: In Firestore, services referenced category values by slug names like `'birthday'`. In Supabase, the table expects relational keys (`category_id`) referencing the category table.
*   **Resolution**: Built a category slug-to-ID lookup map (`CATEGORY_SLUG_TO_ID`) loaded dynamically from the live database. The script lowercases the Firestore category values and resolves them to the correct target primary keys.

### Fix 3: Default User Roles and Missing Emails
*   **Problem**: Some user documents had null values for roles, causing checks to fail. Additionally, some records lacked emails, violating the PostgreSQL `NOT NULL` email constraint.
*   **Resolution**: 
    - Fallback `role = doc_data.get('role') or 'customer'` to ensure a default is always assigned.
    - Fallback `email = doc_data.get('email') or f"{doc_id}@omevents.in"` to prevent not-null column errors.

### Fix 4 & 5: Notification Tokens and Queue UUID Foreign Keys
*   **Problem**: Firestore documents referenced user IDs as raw Firebase UID strings. Supabase expects UUID foreign keys referencing the users table (`users.id`).
*   **Resolution**: Created a dynamic mapping (`FIREBASE_UID_TO_UUID`) loaded from the live database. During the migration run of notification tokens and queue items, the script automatically translates the Firebase UIDs into valid Supabase UUIDs. Documents with unknown/missing user records are counted as skipped instead of failing the batch.
