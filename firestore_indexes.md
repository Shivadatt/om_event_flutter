# Recommended PostgreSQL Indexes

| Table Name | Column Name | Index Type | Reason |
| :--- | :--- | :--- | :--- |
| admins | uid | UNIQUE B-Tree | Primary lookup key / UNIQUE constraint |
| admins | email | B-Tree | Foreign key lookup optimization |
| admins | phone | B-Tree | Foreign key lookup optimization |
| inquiries | phone | B-Tree | Foreign key lookup optimization |
| notifications | user_id | B-Tree | Foreign key lookup optimization |
| users | phone | B-Tree | Foreign key lookup optimization |
| users | email | UNIQUE B-Tree | Primary lookup key / UNIQUE constraint |
