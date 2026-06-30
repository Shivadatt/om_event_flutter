import sqlite3
import os
import sys
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore

# Path to the Django SQLite database
DB_PATH = os.path.abspath(os.path.join(
    os.path.dirname(__file__), 
    '../../Om event website/Om event website/instance/events.sqlite3'
))

# Path to Firebase admin certificate
CERT_PATH = os.path.abspath(os.path.join(
    os.path.dirname(__file__), 
    '../serviceAccountKey.json'
))

def main():
    if not os.path.exists(DB_PATH):
        print(f"Error: SQLite database not found at: {DB_PATH}")
        sys.exit(1)

    if not os.path.exists(CERT_PATH):
        print(f"Error: Firebase service account certificate not found at: {CERT_PATH}")
        print("Please place your Firebase 'serviceAccountKey.json' in the om_event root directory.")
        sys.exit(1)

    print("Initializing Firebase Admin SDK...")
    cred = credentials.Certificate(CERT_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("Firebase connected successfully.")

    print("Opening SQLite connection...")
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # 1. Migrate Users (auth_user)
    print("\nMigrating Users...")
    cursor.execute("SELECT * FROM auth_user")
    users = cursor.fetchall()
    for u in users:
        user_id = str(u['id'])
        user_data = {
            'name': u['first_name'] + ' ' + u['last_name'] if (u['first_name'] or u['last_name']) else u['username'],
            'email': u['email'],
            'role': 'admin' if u['is_superuser'] else ('staff' if u['is_staff'] else 'customer'),
            'isActive': bool(u['is_active']),
            'createdAt': u['date_joined']
        }
        db.collection('users').document(user_id).set(user_data)
        print(f" Migrated User: {user_data['name']} (ID: {user_id})")

    # 2. Migrate Categories (events_category)
    print("\nMigrating Categories...")
    cursor.execute("SELECT * FROM events_category")
    categories = cursor.fetchall()
    for cat in categories:
        cat_id = str(cat['id'])
        cat_data = {
            'name': cat['name'],
            'slug': cat['slug'],
            'description': cat['description'] or '',
            'icon': cat['icon'] or '🎈',
            'color': cat['color'] or '#c79b61',
            'imageUrl': cat['image_url'] or '',
            'sortOrder': int(cat['sort_order'] or 0),
            'isActive': bool(cat['is_active'])
        }
        db.collection('categories').document(cat_id).set(cat_data)
        print(f" Migrated Category: {cat_data['name']} (ID: {cat_id})")

    # 3. Migrate Experiences (events_decorationitem)
    print("\nMigrating Decoration Items...")
    cursor.execute("SELECT * FROM events_decorationitem")
    items = cursor.fetchall()
    for item in items:
        item_id = str(item['id'])
        
        # Fetch associated gallery images
        cursor.execute("SELECT url FROM events_itemimage WHERE decoration_item_id = ?", (item['id'],))
        gallery_images = [row['url'] for row in cursor.fetchall()]

        # Parse tags, colors, themes into Lists
        tags = [t.strip() for t in (item['tags'] or '').split(',') if t.strip()]
        colors = [c.strip() for c in (item['colors'] or '').split(',') if c.strip()]
        themes = [th.strip() for th in (item['themes'] or '').split(',') if th.strip()]

        item_data = {
            'categoryId': str(item['category_id']),
            'categoryName': 'Event Package', # Default placeholder resolved on client
            'categorySlug': 'package',
            'name': item['name'],
            'slug': item['slug'],
            'description': item['description'],
            'price': float(item['price']),
            'offerPrice': float(item['offer_price']) if item['offer_price'] else None,
            'durationHours': float(item['duration_hours'] or 3.0),
            'popularity': int(item['popularity'] or 0),
            'rating': float(item['rating'] or 5.0),
            'reviewCount': int(item['review_count'] or 0),
            'availability': item['availability'] or 'available',
            'tags': tags,
            'colors': colors,
            'themes': themes,
            'imageUrl': item['image_url'] or '',
            'videoUrl': item['video_url'] or '',
            'galleryImages': gallery_images,
            'isFeatured': bool(item['is_featured']),
            'isActive': bool(item['is_active']),
            'createdAt': item['created_at']
        }
        
        db.collection('items').document(item_id).set(item_data)
        print(f" Migrated Decoration: {item_data['name']} (ID: {item_id})")

    # 4. Migrate Customers (events_customer)
    print("\nMigrating Customers...")
    cursor.execute("SELECT * FROM events_customer")
    customers = cursor.fetchall()
    for c in customers:
        cust_id = str(c['id'])
        cust_data = {
            'name': c['name'],
            'phone': c['phone'],
            'email': c['email'] or '',
            'address': c['address'] or '',
            'city': c['city'] or '',
            'mapLocation': c['map_location'] or ''
        }
        db.collection('customers').document(cust_id).set(cust_data)
        print(f" Migrated Customer: {cust_data['name']} (ID: {cust_id})")

    # 5. Migrate Leads (events_lead)
    print("\nMigrating Leads...")
    cursor.execute("SELECT * FROM events_lead")
    leads = cursor.fetchall()
    for lead in leads:
        lead_id = str(lead['id'])
        lead_data = {
            'name': lead['name'],
            'phone': lead['phone'],
            'email': lead['email'] or '',
            'requestType': lead['request_type'] or 'callback',
            'eventDate': lead['event_date'],
            'budget': float(lead['budget']) if lead['budget'] else None,
            'requirements': lead['requirements'] or '',
            'status': lead['status'] or 'new',
            'assignedStaffId': str(lead['assigned_user_id']) if lead['assigned_user_id'] else None,
            'createdAt': lead['created_at'],
            'updatedAt': lead['updated_at']
        }
        db.collection('leads').document(lead_id).set(lead_data)
        print(f" Migrated Lead from: {lead_data['name']} (ID: {lead_id})")

    # 6. Migrate Quotations (events_quotation + events_quotationitem)
    print("\nMigrating Quotations...")
    cursor.execute("SELECT * FROM events_quotation")
    quotes = cursor.fetchall()
    for q in quotes:
        quote_id = str(q['id'])
        
        # Load quotation line items
        cursor.execute("SELECT * FROM events_quotationitem WHERE quotation_id = ?", (q['id'],))
        items_rows = cursor.fetchall()
        quote_items = []
        for row in items_rows:
            quote_items.append({
                'experienceId': str(row['decoration_item_id']),
                'name': row['name'],
                'quantity': int(row['quantity']),
                'unitPrice': float(row['unit_price']),
                'color': row['color'] or '',
                'theme': row['theme'] or '',
                'notes': row['notes'] or ''
            })

        quote_data = {
            'publicId': q['public_id'],
            'customerPhone': '', # Filled via join or client lookup
            'customerName': '',
            'eventDate': q['event_date'],
            'eventTime': q['event_time'] or '',
            'location': q['location'],
            'notes': q['notes'] or '',
            'subtotal': float(q['subtotal']),
            'discount': float(q['discount'] or 0.0),
            'deliveryCharge': float(q['delivery_charge'] or 0.0),
            'travelCharge': float(q['travel_charge'] or 0.0),
            'gstPercent': float(q['gst_percent'] or 18.0),
            'gstAmount': float(q['gst_amount'] or 0.0),
            'grandTotal': float(q['grand_total']),
            'pdfUrl': q['pdf_url'] or '',
            'status': q['status'] or 'pending',
            'items': quote_items,
            'createdAt': q['created_at'],
            'updatedAt': q['updated_at']
        }
        
        db.collection('quotations').document(quote_id).set(quote_data)
        print(f" Migrated Quotation: {quote_data['publicId']} (ID: {quote_id})")

    # 7. Migrate Bookings (events_booking)
    print("\nMigrating Bookings...")
    cursor.execute("SELECT * FROM events_booking")
    bookings = cursor.fetchall()
    for b in bookings:
        b_id = str(b['id'])
        b_data = {
            'bookingNumber': b['booking_number'],
            'quotationId': str(b['quotation_id']),
            'advanceAmount': float(b['advance_amount'] or 0.0),
            'paymentStatus': b['payment_status'] or 'pending',
            'status': b['status'] or 'pending',
            'createdAt': b['created_at'],
            'updatedAt': b['updated_at']
        }
        db.collection('bookings').document(b_id).set(b_data)
        print(f" Migrated Booking: {b_data['bookingNumber']} (ID: {b_id})")

    # 8. Migrate Reviews (events_review)
    print("\nMigrating Reviews...")
    cursor.execute("SELECT * FROM events_review")
    reviews = cursor.fetchall()
    for r in reviews:
        r_id = str(r['id'])
        r_data = {
            'customerName': r['customer_name'],
            'eventName': r['event_name'],
            'rating': int(r['rating']),
            'comment': r['comment'],
            'imageUrl': r['image_url'] or '',
            'isVerified': bool(r['is_verified']),
            'isPublished': bool(r['is_published']),
            'createdAt': r['created_at']
        }
        db.collection('reviews').document(r_id).set(r_data)
        print(f" Migrated Review from: {r_data['customerName']} (ID: {r_id})")

    # 9. Migrate Activity Logs (events_activitylog)
    print("\nMigrating Activity Logs...")
    cursor.execute("SELECT * FROM events_activitylog")
    logs = cursor.fetchall()
    for log in logs:
        log_id = str(log['id'])
        log_data = {
            'userId': str(log['user_id']) if log['user_id'] else None,
            'action': log['action'],
            'entityType': log['entity_type'] or '',
            'entityId': str(log['entity_id']) if log['entity_id'] else '',
            'ipAddress': log['ip_address'] or '',
            'createdAt': log['created_at']
        }
        db.collection('activity_logs').document(log_id).set(log_data)
        print(f" Migrated Activity Log: {log_data['action']} (ID: {log_id})")

    print("\nMigration Completed Successfully!")
    conn.close()

if __name__ == '__main__':
    main()
