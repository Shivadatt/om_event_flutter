import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/quotation.dart';
import '../../../controllers/admin_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../../core/utils/app_logger.dart';
import 'editor/experience_selector_dialog.dart';
import 'editor/publish_revision_dialog.dart';
import 'editor/editor_event_details_section.dart';
import 'editor/editor_items_list_section.dart';
import 'editor/editor_right_panel.dart';
import 'editor/editor_header_bar.dart';

class QuotationEditorDialog extends StatefulWidget {
  final Quotation quotation;
  final AdminController controller;

  const QuotationEditorDialog({
    super.key,
    required this.quotation,
    required this.controller,
  });

  static void show(BuildContext context, Quotation quotation, AdminController controller) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryAccent),
      ),
    );

    try {
      AppLogger.info("Loading quotation ${quotation.publicId} for editor", layer: LogLayer.ui, className: "QuotationEditorDialog", methodName: "show");
      await controller.loadQuotationForEditing(quotation);
      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => QuotationEditorDialog(quotation: quotation, controller: controller),
        );
      }
    } catch (e, stack) {
      AppLogger.errorDetailed("Error loading quotation", layer: LogLayer.ui, className: "QuotationEditorDialog", methodName: "show", error: e, stack: stack);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  State<QuotationEditorDialog> createState() => _QuotationEditorDialogState();
}

class _QuotationEditorDialogState extends State<QuotationEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _locController;
  late TextEditingController _notesController;
  late TextEditingController _internalNotesController;
  late TextEditingController _adminMessageController;

  late TextEditingController _discountController;
  late TextEditingController _deliveryController;
  late TextEditingController _travelController;
  late TextEditingController _gstPercentController;

  late TextEditingController _operationalNotesController;
  late TextEditingController _bookingDetailsController;
  late TextEditingController _staffAssignmentController;
  late TextEditingController _logisticsController;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final quote = widget.quotation;
    _selectedDate = quote.eventDate;

    _dateController = TextEditingController(text: AppFormatters.formatShortDate(quote.eventDate));
    _timeController = TextEditingController(text: quote.eventTime);
    _locController = TextEditingController(text: quote.location);
    _notesController = TextEditingController(text: quote.notes);
    _internalNotesController = TextEditingController(text: quote.internalNotes ?? '');
    _adminMessageController = TextEditingController(text: quote.adminMessage ?? '');

    _discountController = TextEditingController(text: quote.discount.toStringAsFixed(0));
    _deliveryController = TextEditingController(text: "0");
    _travelController = TextEditingController(text: quote.travelCharge.toStringAsFixed(0));
    _gstPercentController = TextEditingController(text: quote.gstPercent.toStringAsFixed(0));

    _operationalNotesController = TextEditingController(text: quote.operationalNotes ?? '');
    _bookingDetailsController = TextEditingController(text: quote.bookingDetails ?? '');
    _staffAssignmentController = TextEditingController(text: quote.staffAssignment ?? '');
    _logisticsController = TextEditingController(text: quote.logistics ?? '');

    _discountController.addListener(_onPricingFieldsChanged);
    _travelController.addListener(_onPricingFieldsChanged);
    _gstPercentController.addListener(_onPricingFieldsChanged);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _locController.dispose();
    _notesController.dispose();
    _internalNotesController.dispose();
    _adminMessageController.dispose();
    _operationalNotesController.dispose();
    _bookingDetailsController.dispose();
    _staffAssignmentController.dispose();
    _logisticsController.dispose();

    _discountController.removeListener(_onPricingFieldsChanged);
    _travelController.removeListener(_onPricingFieldsChanged);
    _gstPercentController.removeListener(_onPricingFieldsChanged);

    _discountController.dispose();
    _deliveryController.dispose();
    _travelController.dispose();
    _gstPercentController.dispose();
    super.dispose();
  }

  void _onPricingFieldsChanged() {
    widget.controller.editorDiscount.value = double.tryParse(_discountController.text) ?? 0.0;
    widget.controller.editorDelivery.value = 0.0;
    widget.controller.editorTravel.value = double.tryParse(_travelController.text) ?? 0.0;
    widget.controller.editorGstPercent.value = double.tryParse(_gstPercentController.text) ?? 18.0;
    widget.controller.recalculateEditorTotals();
  }

  void _showExperienceSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExperienceSelectorDialog(controller: widget.controller),
    );
  }

  void _promptRevisionReason(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PublishRevisionDialog(
        controller: widget.controller,
        selectedDate: _selectedDate,
        timeController: _timeController,
        locController: _locController,
        notesController: _notesController,
        internalNotesController: _internalNotesController,
        adminMessageController: _adminMessageController,
        operationalNotesController: _operationalNotesController,
        bookingDetailsController: _bookingDetailsController,
        staffAssignmentController: _staffAssignmentController,
        logisticsController: _logisticsController,
        editorNavigator: Navigator.of(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final creamColor = isDark ? AppColors.darkCream : AppColors.lightCream;
    final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final goldColor = isDark ? AppColors.darkGold : AppColors.lightGold;

    final isFinLocked = widget.quotation.isFinancialLocked || 
                        widget.quotation.status == QuotationStatus.acceptedByClient || 
                        widget.quotation.status == QuotationStatus.bookingConfirmed;
    final isPermLocked = widget.quotation.isPermanentlyLocked || 
                         widget.quotation.status == QuotationStatus.bookingConfirmed;

    final authController = Get.find<AuthController>();
    final userRole = authController.rxAdminRole.value?.roleType ?? authController.rxUserRole.value;
    final isSuperAdmin = userRole == 'super_admin';

    final Widget leftEditorWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorEventDetailsSection(
          quotation: widget.quotation,
          dateController: _dateController,
          timeController: _timeController,
          locController: _locController,
          notesController: _notesController,
          internalNotesController: _internalNotesController,
          adminMessageController: _adminMessageController,
          operationalNotesController: _operationalNotesController,
          bookingDetailsController: _bookingDetailsController,
          staffAssignmentController: _staffAssignmentController,
          logisticsController: _logisticsController,
          selectedDate: _selectedDate,
          onDateChanged: (picked) {
            setState(() {
              _selectedDate = picked;
              _dateController.text = AppFormatters.formatShortDate(picked);
            });
          },
          isPermLocked: isPermLocked,
        ),
        const SizedBox(height: 32),
        EditorItemsListSection(
          controller: widget.controller,
          isFinLocked: isFinLocked,
          onAddButtonPressed: () => _showExperienceSelector(context),
        ),
      ],
    );

    final Widget rightPreviewWidget = EditorRightPanel(
      controller: widget.controller,
      discountController: _discountController,
      travelController: _travelController,
      gstPercentController: _gstPercentController,
      isFinLocked: isFinLocked,
      isPermLocked: isPermLocked,
      onSaveDraftPressed: () async {
        if (_formKey.currentState?.validate() == true) {
          final navigator = Navigator.of(context);
          final success = await widget.controller.saveActiveDraft(
            eventDate: _selectedDate,
            eventTime: _timeController.text,
            location: _locController.text,
            notes: _notesController.text,
            internalNotes: _internalNotesController.text,
            adminMessage: _adminMessageController.text,
            operationalNotes: _operationalNotesController.text,
            bookingDetails: _bookingDetailsController.text,
            staffAssignment: _staffAssignmentController.text,
            logistics: _logisticsController.text,
          );
          if (success && context.mounted) {
            navigator.pop();
          }
        }
      },
      onPublishPressed: () {
        if (_formKey.currentState?.validate() == true) {
          _promptRevisionReason(context);
        }
      },
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: creamColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            EditorHeaderBar(
              quotation: widget.quotation,
              controller: widget.controller,
              authController: authController,
              isPermLocked: isPermLocked,
              isFinLocked: isFinLocked,
              isSuperAdmin: isSuperAdmin,
              paperColor: paperColor,
              inkColor: inkColor,
              lineColor: lineColor,
              goldColor: goldColor,
            ),
            Divider(height: 1, color: lineColor),
            Expanded(
              child: Form(
                key: _formKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final bool isDesktop = width >= 850;

                    return isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 7,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: leftEditorWidget,
                                ),
                              ),
                              VerticalDivider(width: 1, color: lineColor),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  color: paperColor,
                                  child: SingleChildScrollView(
                                    child: rightPreviewWidget,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: leftEditorWidget,
                                ),
                                Divider(height: 1, color: lineColor),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  color: paperColor,
                                  child: rightPreviewWidget,
                                ),
                              ],
                            ),
                          );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
