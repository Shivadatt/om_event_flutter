import json
import os
import sys
import requests
from audit_cancelled import get_access_token, parse_firestore_value, doc_to_dict, fetch_all_docs

def delete_doc(collection_name, doc_id, token):
    url = f"https://firestore.googleapis.com/v1/projects/om-event/databases/(default)/documents/{collection_name}/{doc_id}"
    headers = {"Authorization": f"Bearer {token}"}
    res = requests.delete(url, headers=headers)
    if res.status_code in (200, 204):
        return True, "Deleted"
    elif res.status_code == 404:
        return True, "Already deleted / Not found"
    else:
        return False, f"HTTP {res.status_code}: {res.text}"

def main():
    token = get_access_token()
    print("==================================================")
    print("CANONICAL COLLECTION: quotations")
    print("CANONICAL CANCELLED STATUS: cancelled")
    print("==================================================")

    # 1. Fetch current quotations
    quotations = fetch_all_docs('quotations', token)
    cancelled_quotations = []
    other_quotations = []

    for q in quotations:
        status_norm = str(q.get('status', '')).strip().lower().replace('_', '').replace(' ', '')
        if status_norm == 'cancelled':
            cancelled_quotations.append(q)
        else:
            other_quotations.append(q)

    print(f"TOTAL CANCELLED RECORDS FOUND: {len(cancelled_quotations)}")
    print(f"TOTAL OTHER RECORDS PRESERVED: {len(other_quotations)}")

    cancelled_doc_ids = {c['__doc_id'] for c in cancelled_quotations}
    cancelled_public_ids = {c.get('public_id') for c in cancelled_quotations if c.get('public_id')}
    all_cancelled_ids = cancelled_doc_ids | cancelled_public_ids

    # 2. Fetch exclusively owned related records
    versions = fetch_all_docs('quotation_versions', token)
    messages = fetch_all_docs('quotation_messages', token)
    attachments = fetch_all_docs('quotation_attachments', token)
    cust_quotes = fetch_all_docs('customer_quotes', token)
    booked_dates = fetch_all_docs('booked_dates', token)

    versions_to_delete = [v for v in versions if (v.get('quotation_id') or v.get('quotationId') or v.get('booking_id')) in all_cancelled_ids]
    messages_to_delete = [m for m in messages if (m.get('quotation_id') or m.get('quotationId') or m.get('booking_id')) in all_cancelled_ids]
    attachments_to_delete = [a for a in attachments if (a.get('quotation_id') or a.get('quotationId') or a.get('booking_id')) in all_cancelled_ids]
    cust_quotes_to_delete = [cq for cq in cust_quotes if (cq.get('quotation_id') or cq.get('quotationId') or cq.get('__doc_id')) in all_cancelled_ids]
    booked_dates_to_delete = [bd for bd in booked_dates if (bd.get('booking_id') or bd.get('quotation_id')) in all_cancelled_ids]

    print(f"\nExclusively owned related records to delete:")
    print(f"- quotation_versions: {len(versions_to_delete)}")
    print(f"- quotation_messages: {len(messages_to_delete)}")
    print(f"- quotation_attachments: {len(attachments_to_delete)}")
    print(f"- customer_quotes: {len(cust_quotes_to_delete)}")
    print(f"- booked_dates: {len(booked_dates_to_delete)}")

    deleted_counts = {
        'quotations': 0,
        'quotation_versions': 0,
        'quotation_messages': 0,
        'quotation_attachments': 0,
        'customer_quotes': 0,
        'booked_dates': 0,
    }
    failures = []

    # 3. Delete exclusively-owned child/related records first
    print("\n--- Deleting quotation_versions ---")
    for v in versions_to_delete:
        ok, msg = delete_doc('quotation_versions', v['__doc_id'], token)
        if ok:
            deleted_counts['quotation_versions'] += 1
        else:
            failures.append(('quotation_versions', v['__doc_id'], msg))

    print("--- Deleting quotation_messages ---")
    for m in messages_to_delete:
        ok, msg = delete_doc('quotation_messages', m['__doc_id'], token)
        if ok:
            deleted_counts['quotation_messages'] += 1
        else:
            failures.append(('quotation_messages', m['__doc_id'], msg))

    print("--- Deleting quotation_attachments ---")
    for a in attachments_to_delete:
        ok, msg = delete_doc('quotation_attachments', a['__doc_id'], token)
        if ok:
            deleted_counts['quotation_attachments'] += 1
        else:
            failures.append(('quotation_attachments', a['__doc_id'], msg))

    print("--- Deleting customer_quotes ---")
    for cq in cust_quotes_to_delete:
        ok, msg = delete_doc('customer_quotes', cq['__doc_id'], token)
        if ok:
            deleted_counts['customer_quotes'] += 1
        else:
            failures.append(('customer_quotes', cq['__doc_id'], msg))

    print("--- Deleting obsolete booked_dates ---")
    for bd in booked_dates_to_delete:
        ok, msg = delete_doc('booked_dates', bd['__doc_id'], token)
        if ok:
            deleted_counts['booked_dates'] += 1
        else:
            failures.append(('booked_dates', bd['__doc_id'], msg))

    # 4. Delete primary cancelled quotation documents
    print("\n--- Deleting primary cancelled quotations ---")
    for q in cancelled_quotations:
        doc_id = q['__doc_id']
        ok, msg = delete_doc('quotations', doc_id, token)
        if ok:
            deleted_counts['quotations'] += 1
            print(f"DELETED quotations/{doc_id} (PublicID: {q.get('public_id')})")
        else:
            failures.append(('quotations', doc_id, msg))
            print(f"FAILED quotations/{doc_id}: {msg}", file=sys.stderr)

    # 5. Direct verification query
    print("\n==================================================")
    print("VERIFYING FIREBASE DIRECTLY...")
    print("==================================================")
    remaining_quotes = fetch_all_docs('quotations', token)
    remaining_cancelled = [q for q in remaining_quotes if str(q.get('status', '')).strip().lower().replace('_', '').replace(' ', '') == 'cancelled']
    remaining_confirmed = [q for q in remaining_quotes if str(q.get('status', '')).strip().lower().replace('_', '').replace(' ', '') in {'bookingconfirmed', 'confirmed'}]

    print(f"Total quotations remaining: {len(remaining_quotes)}")
    print(f"Cancelled records remaining in Firebase: {len(remaining_cancelled)}")
    print(f"Confirmed bookings remaining: {len(remaining_confirmed)}")
    print(f"Deleted counts: {deleted_counts}")
    print(f"Failures: {failures}")

    summary = {
        'deleted_counts': deleted_counts,
        'remaining_total': len(remaining_quotes),
        'remaining_cancelled': len(remaining_cancelled),
        'remaining_confirmed': len(remaining_confirmed),
        'deleted_quotation_ids': [q['__doc_id'] for q in cancelled_quotations],
        'deleted_public_ids': [q.get('public_id') for q in cancelled_quotations if q.get('public_id')],
        'failures': failures,
    }
    with open('scratch/cleanup_execution_summary.json', 'w', encoding='utf-8') as f:
        json.dump(summary, f, indent=2)

    if len(remaining_cancelled) == 0:
        print("\nSUCCESS: ALL CANCELLED RECORDS PERMANENTLY REMOVED FROM FIREBASE (REMAINING = 0)!")
    else:
        print(f"\nWARNING: {len(remaining_cancelled)} cancelled records still remain in Firebase!", file=sys.stderr)

if __name__ == '__main__':
    main()
