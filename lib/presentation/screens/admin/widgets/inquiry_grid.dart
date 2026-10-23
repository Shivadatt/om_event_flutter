import 'package:flutter/material.dart';
import '../../../../domain/entities/lead.dart';
import 'inquiry_card.dart';
import 'inquiry_empty_state.dart';
import 'inquiry_list_item_card.dart';
import 'inquiry_showcase_helper.dart';

class InquiryGrid extends StatelessWidget {
  final List<Lead> leads;
  final bool isGridView;
  final int crossAxisCount;
  final bool isMobile;
  final void Function(Lead lead, String newStatus) onStatusChanged;
  final void Function(Lead lead, String coverUrl, String cleanType) onOpenDetails;
  final VoidCallback onResetFilters;

  const InquiryGrid({
    super.key,
    required this.leads,
    required this.isGridView,
    required this.crossAxisCount,
    required this.isMobile,
    required this.onStatusChanged,
    required this.onOpenDetails,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (leads.isEmpty) {
      return InquiryEmptyState(onResetFilters: onResetFilters);
    }

    if (isGridView) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isMobile ? 12 : 14,
          mainAxisSpacing: isMobile ? 12 : 14,
          mainAxisExtent: isMobile ? 315 : 330,
        ),
        itemCount: leads.length,
        itemBuilder: (context, index) {
          final lead = leads[index];
          final coverUrl = InquiryShowcaseHelper.getEventCoverUrl(index);
          final cleanType = InquiryShowcaseHelper.cleanText(lead.requestType);
          return InquiryCard(
            lead: lead,
            coverUrl: coverUrl,
            cleanType: cleanType,
            onStatusChanged: (val) => onStatusChanged(lead, val),
            onOpenDetails: () => onOpenDetails(lead, coverUrl, cleanType),
            isMobile: isMobile,
          );
        },
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leads.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final lead = leads[index];
        final coverUrl = InquiryShowcaseHelper.getEventCoverUrl(index);
        final cleanType = InquiryShowcaseHelper.cleanText(lead.requestType);
        return InquiryListItemCard(
          lead: lead,
          coverUrl: coverUrl,
          cleanType: cleanType,
          onStatusChanged: (val) => onStatusChanged(lead, val),
          onOpenDetails: () => onOpenDetails(lead, coverUrl, cleanType),
        );
      },
    );
  }
}
