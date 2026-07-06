# Recommended PostgreSQL Foreign Keys

| Parent Table | Child Table | Parent Column | Child Column | ON DELETE | ON UPDATE |
| :--- | :--- | :--- | :--- | :--- | :--- |
| service_categories | gallery | id | service_id | CASCADE | CASCADE |
| users | notifications | id | user_id | CASCADE | CASCADE |
