import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../domain/entities/lead.dart';
import '../../controllers/admin_controller.dart';
import '../customer/helpers/customer_dialog_helper.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import 'widgets/inquiry_details_dialog.dart';
import 'widgets/inquiry_filter_chips.dart';
import 'widgets/inquiry_grid.dart';
import 'widgets/inquiry_search_toolbar.dart';
import 'widgets/inquiry_showcase_header.dart';
import 'widgets/inquiry_showcase_helper.dart';

typedef InquiryShowcaseScreen = ManageLeadsScreen;

class ManageLeadsScreen extends StatefulWidget {
  const ManageLeadsScreen({super.key});

  @override
  State<ManageLeadsScreen> createState() => _ManageLeadsScreenState();
}

class _ManageLeadsScreenState extends State<ManageLeadsScreen> {
  final AdminController controller = Get.find<AdminController>();
  final TextEditingController _searchCtrl = TextEditingController();

  String _selectedStatusFilter = 'all';
  bool _isGridView = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAddInquiryDialog(BuildContext context) {
    CustomerDialogHelper.openLeadDialog(context);
  }

  void _showInquiryDetailsDialog(
    BuildContext context,
    Lead lead,
    String coverUrl,
    String cleanType,
  ) {
    InquiryDetailsDialog.show(
      context,
      lead: lead,
      coverUrl: coverUrl,
      cleanType: cleanType,
      onStatusChanged: (newStatus) => controller.updateLead(lead.id, newStatus),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isInsideDrawer = AdminLayoutScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: isInsideDrawer ? null : const AdminBackButton(),
        automaticallyImplyLeading: !isInsideDrawer,
        title: Text(
          "INQUIRY SHOWCASE",
          style: AppTheme.sansBody(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white70,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: isInsideDrawer ? 0 : kToolbarHeight,
      ),
      backgroundColor: Colors.transparent,
      body: Obx(() {
        final allLeads = controller.rxLeads;

        final int allCount = allLeads.length;
        final int newCount =
            allLeads.where((l) => l.status.toLowerCase() == 'new').length;
        final int contactedCount =
            allLeads.where((l) => l.status.toLowerCase() == 'contacted').length;
        final int closedCount = allLeads
            .where((l) =>
                l.status.toLowerCase() == 'closed' ||
                l.status.toLowerCase() == 'won')
            .length;

        final filteredLeads = InquiryShowcaseHelper.filterLeads(
          allLeads: allLeads,
          selectedStatusFilter: _selectedStatusFilter,
          searchQuery: _searchCtrl.text,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            final bool isMobile = maxWidth < 650;
            final bool isNarrow = maxWidth < 850;
            final int crossAxisCount =
                InquiryShowcaseHelper.getCrossAxisCount(maxWidth);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 14 : 20,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InquiryShowcaseHeader(
                        isMobile: isMobile,
                        onAddInquiry: () => _openAddInquiryDialog(context),
                      ),
                      const SizedBox(height: 14),
                      if (isNarrow) ...[
                        InquiryFilterChips(
                          selectedFilter: _selectedStatusFilter,
                          allCount: allCount,
                          newCount: newCount,
                          contactedCount: contactedCount,
                          closedCount: closedCount,
                          onFilterSelected: (val) =>
                              setState(() => _selectedStatusFilter = val),
                          isMobile: isMobile,
                        ),
                        const SizedBox(height: 12),
                        InquirySearchToolbar(
                          searchCtrl: _searchCtrl,
                          isGridView: _isGridView,
                          onSearchChanged: (_) => setState(() {}),
                          onViewModeChanged: (val) =>
                              setState(() => _isGridView = val),
                          isMobile: true,
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InquiryFilterChips(
                              selectedFilter: _selectedStatusFilter,
                              allCount: allCount,
                              newCount: newCount,
                              contactedCount: contactedCount,
                              closedCount: closedCount,
                              onFilterSelected: (val) =>
                                  setState(() => _selectedStatusFilter = val),
                              isMobile: false,
                            ),
                            InquirySearchToolbar(
                              searchCtrl: _searchCtrl,
                              isGridView: _isGridView,
                              onSearchChanged: (_) => setState(() {}),
                              onViewModeChanged: (val) =>
                                  setState(() => _isGridView = val),
                              isMobile: false,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      InquiryGrid(
                        leads: filteredLeads,
                        isGridView: _isGridView,
                        crossAxisCount: crossAxisCount,
                        isMobile: isMobile,
                        onStatusChanged: (lead, newStatus) =>
                            controller.updateLead(lead.id, newStatus),
                        onOpenDetails: (lead, coverUrl, cleanType) =>
                            _showInquiryDetailsDialog(
                                context, lead, coverUrl, cleanType),
                        onResetFilters: () {
                          _searchCtrl.clear();
                          setState(() => _selectedStatusFilter = 'all');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
