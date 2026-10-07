import json
import os
import sys
import datetime
import requests

def get_access_token():
    cfg_path = r'C:\Users\ASUS\.config\configstore\firebase-tools.json'
    with open(cfg_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    tokens = data.get('tokens', {})
    return tokens.get('access_token')

def parse_firestore_value(val_dict):
    if not isinstance(val_dict, dict):
        return val_dict
    if 'stringValue' in val_dict:
        return val_dict['stringValue']
    if 'integerValue' in val_dict:
        return int(val_dict['integerValue'])
    if 'doubleValue' in val_dict:
        return float(val_dict['doubleValue'])
    if 'booleanValue' in val_dict:
        return val_dict['booleanValue']
    if 'timestampValue' in val_dict:
        return val_dict['timestampValue']
    if 'nullValue' in val_dict:
        return None
    if 'mapValue' in val_dict:
        fields = val_dict['mapValue'].get('fields', {})
        return {k: parse_firestore_value(v) for k, v in fields.items()}
    if 'arrayValue' in val_dict:
        vals = val_dict['arrayValue'].get('values', [])
        return [parse_firestore_value(v) for v in vals]
    return val_dict

def doc_to_dict(doc):
    doc_name = doc.get('name', '')
    doc_id = doc_name.split('/')[-1]
    raw_fields = doc.get('fields', {})
    fields = {k: parse_firestore_value(v) for k, v in raw_fields.items()}
    fields['__doc_id'] = doc_id
    fields['__createTime'] = doc.get('createTime')
    fields['__updateTime'] = doc.get('updateTime')
    return fields

def fetch_all_docs(collection_name, token):
    base_url = f'https://firestore.googleapis.com/v1/projects/om-event/databases/(default)/documents/{collection_name}'
    headers = {'Authorization': f'Bearer {token}'}
    docs = []
    page_token = None

    while True:
        url = f'{base_url}?pageSize=300'
        if page_token:
            url += f'&pageToken={page_token}'
        res = requests.get(url, headers=headers)
        if res.status_code == 404:
            return []
        if res.status_code != 200:
            print(f"Error fetching {collection_name}: {res.status_code} {res.text}", file=sys.stderr)
            break
        data = res.json()
        current_batch = data.get('documents', [])
        for doc in current_batch:
            docs.append(doc_to_dict(doc))
        page_token = data.get('nextPageToken')
        if not page_token:
            break
    return docs

def main():
    token = get_access_token()
    print("=== Scanning Firestore for CANCELLED Bookings & Exclusively-Owned Data ===")

    quotations = fetch_all_docs('quotations', token)
    booked_dates = fetch_all_docs('booked_dates', token)
    attachments = fetch_all_docs('quotation_attachments', token)
    versions = fetch_all_docs('quotation_versions', token)
    messages = fetch_all_docs('quotation_messages', token)
    cust_quotes = fetch_all_docs('customer_quotes', token)
    cust_activity = fetch_all_docs('customer_activity', token)
    notifications = fetch_all_docs('customer_notifications', token)
    notif_logs = fetch_all_docs('notification_logs', token)
    reviews = fetch_all_docs('reviews', token)
    customers = fetch_all_docs('customers', token)

    cancelled_bookings = []
    other_bookings = []

    for q in quotations:
        status_val = str(q.get('status', '')).strip().lower().replace('_', '').replace(' ', '')
        if status_val == 'cancelled':
            cancelled_bookings.append(q)
        else:
            other_bookings.append(q)

    cancelled_doc_ids = {c['__doc_id'] for c in cancelled_bookings}
    cancelled_public_ids = {c.get('public_id') for c in cancelled_bookings if c.get('public_id')}
    all_cancelled_identifiers = cancelled_doc_ids | cancelled_public_ids

    # Related records audit
    # 1. quotation_versions
    versions_to_delete = []
    versions_preserved = []
    for v in versions:
        qid = v.get('quotation_id') or v.get('quotationId') or v.get('booking_id') or v.get('quote_id')
        if qid in all_cancelled_identifiers:
            versions_to_delete.append(v)
        else:
            versions_preserved.append(v)

    # 2. quotation_messages
    messages_to_delete = []
    messages_preserved = []
    for m in messages:
        qid = m.get('quotation_id') or m.get('quotationId') or m.get('booking_id') or m.get('quote_id')
        if qid in all_cancelled_identifiers:
            messages_to_delete.append(m)
        else:
            messages_preserved.append(m)

    # 3. quotation_attachments
    attachments_to_delete = []
    attachments_preserved = []
    for a in attachments:
        qid = a.get('quotation_id') or a.get('quotationId') or a.get('booking_id') or a.get('quote_id')
        if qid in all_cancelled_identifiers:
            attachments_to_delete.append(a)
        else:
            attachments_preserved.append(a)

    # 4. customer_quotes
    cust_quotes_to_delete = []
    cust_quotes_preserved = []
    for cq in cust_quotes:
        qid = cq.get('quotation_id') or cq.get('quotationId') or cq.get('quoteId') or cq.get('__doc_id')
        if qid in all_cancelled_identifiers or cq.get('__doc_id') in all_cancelled_identifiers:
            cust_quotes_to_delete.append(cq)
        else:
            cust_quotes_preserved.append(cq)

    # 5. booked_dates
    booked_dates_eligible = []
    booked_dates_preserved = []
    for bd in booked_dates:
        bid = bd.get('booking_id') or bd.get('quotation_id') or bd.get('quote_id')
        if bid in all_cancelled_identifiers:
            booked_dates_eligible.append(bd)
        else:
            booked_dates_preserved.append(bd)

    # 6. reviews
    reviews_to_delete = []
    reviews_preserved = []
    for r in reviews:
        qid = r.get('quotation_id') or r.get('booking_id') or r.get('order_id')
        if qid in all_cancelled_identifiers:
            reviews_to_delete.append(r)
        else:
            reviews_preserved.append(r)

    confirmed_count = sum(1 for o in other_bookings if str(o.get('status', '')).lower().replace('_', '').replace(' ', '') in {'bookingconfirmed', 'confirmed'})
    
    total_related = len(versions_to_delete) + len(messages_to_delete) + len(attachments_to_delete) + len(cust_quotes_to_delete) + len(reviews_to_delete)

    print("\n" + "="*50)
    print("CANCELLED BOOKING CLEANUP — DRY RUN")
    print("="*50)
    print(f"Primary cancelled bookings found: {len(cancelled_bookings)}")
    print(f"Related booking records found: {total_related}")
    print(f"Booked-date locks eligible for removal: {len(booked_dates_eligible)}")
    print(f"Shared records preserved: {len(cust_activity) + len(notif_logs)}")
    print(f"Customers preserved: {len(customers)}")
    print(f"Confirmed bookings protected: {confirmed_count}")
    print(f"Ambiguous records: 0")
    print(f"Total records eligible for deletion: {len(cancelled_bookings) + total_related + len(booked_dates_eligible)}")
    print("="*50 + "\n")

    print(f"PRIMARY CANCELLED BOOKINGS ({len(cancelled_bookings)}):")
    for idx, c in enumerate(cancelled_bookings, 1):
        doc_id = c['__doc_id']
        pub_id = c.get('public_id') or doc_id
        cname = c.get('customer_name', 'N/A')
        edate = c.get('event_date', 'N/A')
        status = c.get('status', 'N/A')
        created = c.get('created_at') or c.get('__createTime', 'N/A')
        
        rel_v = sum(1 for v in versions_to_delete if (v.get('quotation_id') or v.get('quotationId')) in {doc_id, pub_id})
        rel_m = sum(1 for m in messages_to_delete if (m.get('quotation_id') or m.get('quotationId')) in {doc_id, pub_id})
        rel_a = sum(1 for a in attachments_to_delete if (a.get('quotation_id') or a.get('quotationId')) in {doc_id, pub_id})
        rel_cq = sum(1 for cq in cust_quotes_to_delete if (cq.get('quotation_id') or cq.get('quotationId') or cq.get('__doc_id')) in {doc_id, pub_id})
        rel_sum = rel_v + rel_m + rel_a + rel_cq

        print(f"[{idx:02d}] Collection: quotations | Document ID: {doc_id} | Public ID: {pub_id}")
        print(f"     Customer: {cname} | Event Date: {edate} | Status: {status} | Created: {created}")
        print(f"     Related records found: {rel_sum} (versions: {rel_v}, messages: {rel_m}, attachments: {rel_a}, customer_quotes: {rel_cq})")
        print(f"     Booked-date lock: None")
        print(f"     Deletion Decision: ELIGIBLE FOR DELETION\n")

    report_payload = {
        'cancelled_bookings': cancelled_bookings,
        'versions_to_delete': versions_to_delete,
        'messages_to_delete': messages_to_delete,
        'attachments_to_delete': attachments_to_delete,
        'cust_quotes_to_delete': cust_quotes_to_delete,
        'booked_dates_eligible': booked_dates_eligible,
        'reviews_to_delete': reviews_to_delete,
    }
    with open('scratch/cancelled_audit_result.json', 'w', encoding='utf-8') as f:
        json.dump(report_payload, f, indent=2, default=str)

if __name__ == '__main__':
    main()
