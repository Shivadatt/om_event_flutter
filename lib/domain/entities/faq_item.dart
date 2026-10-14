class FaqItem {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'GENERAL',
    this.displayOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  FaqItem copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    int? displayOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FaqItem(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory FaqItem.fromJson(Map<String, dynamic> json, [String? fallbackId]) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      try {
        final toDate = (val as dynamic).toDate();
        if (toDate is DateTime) return toDate;
      } catch (_) {}
      return DateTime.now();
    }

    final rawOrder = json['displayOrder'] ??
        json['display_order'] ??
        json['order'] ??
        json['sortOrder'] ??
        0;
    final int parsedOrder = rawOrder is int
        ? rawOrder
        : (int.tryParse(rawOrder.toString()) ?? 0);

    final resolvedId = (json['id'] ?? fallbackId ?? 'faq_${DateTime.now().millisecondsSinceEpoch}').toString();
    final rawCat = json['category'] ?? json['categoryName'] ?? json['cat'] ?? 'GENERAL';

    return FaqItem(
      id: resolvedId,
      question: (json['question'] ?? json['q'] ?? '').toString().trim(),
      answer: (json['answer'] ?? json['a'] ?? '').toString().trim(),
      category: rawCat.toString().trim().toUpperCase(),
      displayOrder: parsedOrder,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category.toUpperCase(),
      'displayOrder': displayOrder,
      'display_order': displayOrder,
      'isActive': isActive,
      'is_active': isActive,
      'createdAt': createdAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
