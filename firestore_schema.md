# Firestore Catalog Schema Specification

## Collection: `admins`
- **Document Count**: 4

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `uid` | STRING | False | True | `Adu3Mo47s3hx0VuWU0vh4nVKnqz2` |
| `name` | STRING | False | True | `Om Super Admin` |
| `email` | STRING | False | True | `omeventsanddecorators@gmail.com` |
| `permissions` | ARRAY | False | True | `['all']` |
| `role` | STRING | False | True | `super_admin` |
| `createdBy` | STRING | False | True | `system` |
| `phone` | STRING | False | True | `9512149944` |
| `createdAt` | TIMESTAMP | False | True | `2026-06-25T05:41:41.093000+00:00` |

## Collection: `bookings`
- **Document Count**: 1

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `service_name` | STRING | False | True | `Royal Stage Decoration` |
| `remaining_amount` | NUMBER | False | True | `50000.0` |
| `status` | STRING | False | True | `pending` |
| `event_date` | STRING | False | True | `2026-07-05T11:11:40.450371` |
| `advance_amount` | NUMBER | False | True | `25000.0` |
| `event_time` | STRING | False | True | `Evening` |
| `venue` | STRING | False | True | `Royal Palace Hall, Kadi` |
| `budget` | NUMBER | False | True | `75000.0` |
| `mobile` | STRING | False | True | `9876543210` |
| `created_at` | TIMESTAMP | False | True | `2026-06-25T05:41:41.282000+00:00` |
| `payment_status` | STRING | False | True | `partial` |

## Collection: `chat_rooms`
- **Document Count**: 1

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `title` | STRING | False | True | `Support Chat` |
| `updated_at` | TIMESTAMP | False | True | `2026-06-25T05:41:43.043000+00:00` |
| `created_at` | TIMESTAMP | False | True | `2026-06-25T05:41:43.043000+00:00` |

## Collection: `device_tokens`
- **Document Count**: 1

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `platform` | STRING | False | True | `android` |
| `token` | STRING | False | True | `fcm_sample_token_123456abcdefg` |
| `created_at` | TIMESTAMP | False | True | `2026-06-25T05:41:43.342000+00:00` |

## Collection: `gallery`
- **Document Count**: 430

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `category` | STRING | False | True | `Birthday` |
| `title` | STRING | False | True | `Butterfly Theme Gallery 2` |
| `variation_id` | STRING | False | True | `` |
| `service_id` | NUMBER | False | True | `7` |
| `created_at` | TIMESTAMP | False | True | `2026-06-25T06:11:04.147000+00:00` |
| `image_url` | STRING | False | True | `https://gkfcfebywgmqqhartrhv.supabase.co/storage/v1/objec...` |

### Possible Foreign Keys
- `service_id` &rarr; `services.id`

## Collection: `inquiries`
- **Document Count**: 1

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `event_type` | STRING | False | True | `Reception` |
| `name` | STRING | False | True | `Rahul Sharma` |
| `event_date` | STRING | False | True | `2026-07-10T11:11:41.798779` |
| `venue` | STRING | False | True | `Open Lawn, Mehsana` |
| `notes` | STRING | False | True | `Looking for a premium setup with lightings.` |
| `phone` | STRING | False | True | `9988776655` |
| `created_at` | TIMESTAMP | False | True | `2026-06-25T05:41:42.602000+00:00` |
| `status` | STRING | False | True | `new` |

## Collection: `notifications`
- **Document Count**: 3

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `is_read` | BOOLEAN | False | True | `False` |
| `title` | STRING | False | True | `New Booking Alert 🔔` |
| `message` | STRING | False | True | `A new booking inquiry has been submitted.` |
| `type` | STRING | False | True | `alert` |
| `user_id` | STRING | False | True | `admin` |
| `created_at` | TIMESTAMP | False | True | `2026-06-25T05:41:41.680000+00:00` |

### Possible Foreign Keys
- `user_id` &rarr; `users.id`

## Collection: `permissions`
- **Document Count**: 19

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `created_at` | TIMESTAMP | False | True | `2026-06-25T05:41:30.626000+00:00` |
| `name` | STRING | False | True | `Admin Management` |

## Collection: `reviews`
- **Document Count**: 1

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `created_at` | TIMESTAMP | False | True | `2026-06-25T05:41:42.837000+00:00` |
| `is_approved` | BOOLEAN | False | True | `True` |
| `comment` | STRING | False | True | `Outstanding decoration! Very professional service.` |
| `customer_name` | STRING | False | True | `Karan Patel` |
| `rating` | NUMBER | False | True | `5.0` |

## Collection: `roles`
- **Document Count**: 3

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `created_at` | TIMESTAMP | False | True | `2026-06-25T05:41:15.991000+00:00` |
| `name` | STRING | False | True | `Admin` |

## Collection: `service_categories`
- **Document Count**: 11

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `name` | STRING | False | True | `Birthday` |
| `is_active` | BOOLEAN | False | True | `True` |
| `created_at` | TIMESTAMP | False | True | `2026-06-25T06:10:44.768000+00:00` |
| `image_url` | STRING | False | True | `https://picsum.photos/seed/cat-bday/300/200` |

## Collection: `services`
- **Document Count**: 43

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `variations_count` | NUMBER | False | True | `0` |
| `short_description` | STRING | False | True | `Birthday Setup` |
| `what_included` | ARRAY | False | True | `[]` |
| `image_url` | STRING | False | True | `https://gkfcfebywgmqqhartrhv.supabase.co/storage/v1/objec...` |
| `luxury_price` | NUMBER | False | True | `10000.0` |
| `premium_price` | NUMBER | False | True | `5000.0` |
| `setup_duration` | NULL | True | True | `null` |
| `created_at` | TIMESTAMP | False | True | `2026-06-25T06:10:51.106000+00:00` |
| `service_name` | STRING | False | True | `Basic Birthday Decoration` |
| `basic_price` | NUMBER | False | True | `2500.0` |
| `review_count` | NUMBER | False | True | `0` |
| `is_active` | BOOLEAN | False | True | `True` |
| `description` | STRING | False | True | `Basic Birthday Decoration` |
| `category` | STRING | False | True | `Birthday` |
| `starting_price` | NUMBER | False | True | `2500.0` |
| `min_starting_price` | NULL | True | True | `null` |
| `theme_options` | ARRAY | False | True | `[]` |
| `rating` | NUMBER | False | True | `0.0` |

## Collection: `settings`
- **Document Count**: 12

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `value` | STRING | False | True | `1.0.0` |
| `updated_at` | TIMESTAMP | False | True | `2026-06-25T05:41:33.273000+00:00` |
| `created_at` | TIMESTAMP | False | True | `2026-06-25T05:41:33.273000+00:00` |

## Collection: `users`
- **Document Count**: 8

### Fields Union
| Field Name | Type | Nullable | Required | Example Value |
| :--- | :--- | :--- | :--- |
| `uid` | STRING | False | False | `Adu3Mo47s3hx0VuWU0vh4nVKnqz2` |
| `name` | STRING | False | True | `Om Super Admin` |
| `createdAt` | TIMESTAMP | False | False | `2026-06-25T05:41:41.002000+00:00` |
| `role` | STRING | False | False | `super_admin` |
| `fcmToken` | STRING | False | False | `dQQk4vDWRYKXW3WGM38Vpd:APA91bHDL_iw57hVYqTNEgazScG2_U1gAj...` |
| `updatedAt` | TIMESTAMP | False | True | `2026-06-25T06:01:09.440000+00:00` |
| `phone` | STRING | False | True | `9512149944` |
| `profileImage` | STRING | False | False | `` |
| `isActive` | BOOLEAN | False | False | `True` |
| `email` | STRING | False | True | `omeventanddecorators@gmail.com` |
| `saved_addresses` | ARRAY | False | False | `[]` |
| `avatar_url` | STRING | False | False | `https://gkfcfebywgmqqhartrhv.supabase.co/storage/v1/objec...` |
| `notification_preferences` | MAP | False | False | `{'push': True, 'email': True}` |

