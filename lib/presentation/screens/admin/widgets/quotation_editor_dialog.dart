import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/quotation.dart';
import '../../../../domain/entities/experience.dart';
import '../../../controllers/admin_controller.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_input.dart';
import '../../../controllers/auth_controller.dart';

class QuotationEditorDialog extends StatefulWidget {
  final Quotation quotation;
  final AdminController controller;

  const QuotationEditorDialog({
    super.key,
    required this.quotation,
    required this.controller,
  });

  static void show(BuildContext context, Quotation quotation, AdminController controller) {
    controller.loadQuotationForEditing(quotation);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuotationEditorDialog(quotation: quotation, controller: controller),
    );
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

  // Operational fields controllers
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
    _deliveryController = TextEditingController(text: quote.deliveryCharge.toStringAsFixed(0));
    _travelController = TextEditingController(text: quote.travelCharge.toStringAsFixed(0));
    _gstPercentController = TextEditingController(text: quote.gstPercent.toStringAsFixed(0));

    // Initialize operational field controllers
    _operationalNotesController = TextEditingController(text: quote.operationalNotes ?? '');
    _bookingDetailsController = TextEditingController(text: quote.bookingDetails ?? '');
    _staffAssignmentController = TextEditingController(text: quote.staffAssignment ?? '');
    _logisticsController = TextEditingController(text: quote.logistics ?? '');

    // Listen to changes for recalculation
    _discountController.addListener(_onPricingFieldsChanged);
    _deliveryController.addListener(_onPricingFieldsChanged);
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
    _deliveryController.removeListener(_onPricingFieldsChanged);
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
    widget.controller.editorDelivery.value = double.tryParse(_deliveryController.text) ?? 0.0;
    widget.controller.editorTravel.value = double.tryParse(_travelController.text) ?? 0.0;
    widget.controller.editorGstPercent.value = double.tryParse(_gstPercentController.text) ?? 18.0;
    widget.controller.recalculateEditorTotals();
  }

  void _showExperienceSelector(BuildContext context, AdminController controller) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
        final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;
        final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

        return Dialog(
          backgroundColor: paperColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SELECT DECORATION ITEM",
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAccent,
                    letterSpacing: 1.5,
                  ),
                ),
                const Divider(height: 20),
                Expanded(
                  child: Obx(() {
                    final experiences = controller.rxExperiences;
                    if (experiences.isEmpty) {
                      return const Center(child: Text("No decoration items in catalog."));
                    }
                    return ListView.separated(
                      itemCount: experiences.length,
                      separatorBuilder: (context, index) => Divider(color: lineColor),
                      itemBuilder: (context, index) {
                        final Experience exp = experiences[index];
                        return ListTile(
                          title: Text(
                            exp.name,
                            style: AppTheme.sansBody(fontSize: 14, color: inkColor, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Starting: ${AppFormatters.formatCurrency(exp.price)}",
                            style: AppTheme.sansBody(fontSize: 12, color: inkColor.withValues(alpha: 0.6)),
                          ),
                          trailing: const Icon(Icons.add_circle, color: Color(0xFFC9A77E)),
                          onTap: () {
                            controller.addEditorItem(exp);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _promptRevisionReason(BuildContext context, AdminController controller) {
    final editorNavigator = Navigator.of(context);
    final reasonCtrl = TextEditingController(text: "Updated decorations & price adjustment");
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
        final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;

        return Dialog(
          backgroundColor: paperColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PUBLISH REVISED PROPOSAL",
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAccent,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                CustomInput(
                  label: "Revision Reason (Internal/Client visible)",
                  placeholder: "e.g. Added flower arches",
                  controller: reasonCtrl,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text("Cancel", style: TextStyle(color: inkColor.withValues(alpha: 0.6))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9A77E),
                        foregroundColor: const Color(0xFF091210),
                      ),
                      onPressed: () async {
                        if (reasonCtrl.text.trim().isEmpty) return;
                        Navigator.pop(dialogContext); // Close reason dialog
                        
                        final success = await controller.publishActiveRevision(
                          eventDate: _selectedDate,
                          eventTime: _timeController.text,
                          location: _locController.text,
                          notes: _notesController.text,
                          internalNotes: _internalNotesController.text,
                          adminMessage: _adminMessageController.text,
                          revisionReason: reasonCtrl.text.trim(),
                          operationalNotes: _operationalNotesController.text,
                          bookingDetails: _bookingDetailsController.text,
                          staffAssignment: _staffAssignmentController.text,
                          logistics: _logisticsController.text,
                        );
                        if (success) {
                          editorNavigator.pop(); // Close editor dialog
                        }
                      },
                      child: const Text("Publish"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: paperColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "EDIT PROPOSAL",
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: goldColor,
                              letterSpacing: 2,
                            ),
                          ),
                          if (isPermLocked) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.error),
                              ),
                              child: Text(
                                "PERMANENTLY LOCKED",
                                style: AppTheme.sansBody(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.error),
                              ),
                            ),
                          ] else if (isFinLocked) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.warning),
                              ),
                              child: Text(
                                "FINANCIAL LOCK ACTIVE",
                                style: AppTheme.sansBody(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.warning),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Quotation: ${widget.quotation.publicId.toUpperCase()}",
                        style: AppTheme.serifHeader(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: inkColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (isPermLocked) ...[
                        if (isSuperAdmin)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.lock_open_rounded, size: 16),
                            label: const Text("Unlock"),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (dialogCtx) => AlertDialog(
                                  backgroundColor: paperColor,
                                  title: const Text("Unlock Quotation"),
                                  content: const Text(
                                    "Are you sure you want to unlock this permanently locked quotation? This action will create an audit log and remove all editing restrictions.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogCtx),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                      onPressed: () async {
                                        final navigator = Navigator.of(context);
                                        Navigator.pop(dialogCtx);
                                        await widget.controller.unlockQuotation(
                                          widget.quotation.id,
                                          authController.rxAdminRole.value?.name ?? 'Super Admin',
                                        );
                                        navigator.pop(); // Close editor
                                      },
                                      child: const Text("Confirm Unlock"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        else
                          Tooltip(
                            message: "Only Super Admins can unlock confirmed booking proposals.",
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 14, color: inkColor.withValues(alpha: 0.5)),
                                const SizedBox(width: 4),
                                Text(
                                  "Only Super Admin can unlock",
                                  style: AppTheme.sansBody(fontSize: 11, color: inkColor.withValues(alpha: 0.5)),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 16),
                      ],
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: lineColor),
            
            // Body Content
            Expanded(
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Editor Column
                    Expanded(
                      flex: 7,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.quotation.acceptedAt != null) ...[
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0x0A4CAF50),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0x334CAF50)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.verified_user_rounded, color: Colors.green, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "DIGITAL CONSENT SIGNED",
                                          style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Accepted By: ${widget.quotation.acceptedBy ?? 'Customer'}",
                                      style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, color: inkColor),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Accepted Version: v${widget.quotation.acceptedVersion ?? widget.quotation.version}",
                                      style: AppTheme.sansBody(fontSize: 12, color: inkColor.withValues(alpha: 0.7)),
                                    ),
                                    Text(
                                      "Accepted Amount: ${AppFormatters.formatCurrency(widget.quotation.acceptedAmount ?? widget.quotation.grandTotal)}",
                                      style: AppTheme.sansBody(fontSize: 12, color: inkColor.withValues(alpha: 0.7)),
                                    ),
                                    Text(
                                      "Consent Time: ${AppFormatters.formatShortDate(widget.quotation.acceptedAt!)} ${widget.quotation.acceptedAt!.toLocal().toString().split(' ')[1].substring(0, 5)}",
                                      style: AppTheme.sansBody(fontSize: 12, color: inkColor.withValues(alpha: 0.7)),
                                    ),
                                    Text(
                                      "Device: ${widget.quotation.acceptedDevice ?? 'Unknown'}",
                                      style: AppTheme.sansBody(fontSize: 12, color: inkColor.withValues(alpha: 0.7)),
                                    ),
                                    if (widget.quotation.acceptedIp != null)
                                      Text(
                                        "IP Address: ${widget.quotation.acceptedIp}",
                                        style: AppTheme.sansBody(fontSize: 12, color: inkColor.withValues(alpha: 0.7)),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Consent Text: \"I confirm that I have reviewed this quotation and agree with the pricing, services and terms.\"",
                                      style: AppTheme.sansBody(fontSize: 11, color: inkColor.withValues(alpha: 0.5)).copyWith(fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            Text(
                              "EVENT DETAILS & NOTES",
                              style: AppTheme.sansBody(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: goldColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomInput(
                                    label: "Event Date",
                                    placeholder: "YYYY-MM-DD",
                                    controller: _dateController,
                                    readOnly: true,
                                    onTap: isPermLocked ? null : () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDate,
                                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                        builder: (context, child) => Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.dark(
                                              primary: goldColor,
                                              onPrimary: creamColor,
                                              surface: paperColor,
                                              onSurface: inkColor,
                                            ),
                                          ),
                                          child: child!,
                                        ),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _selectedDate = picked;
                                          _dateController.text = AppFormatters.formatShortDate(picked);
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomInput(
                                    label: "Event Time",
                                    placeholder: "HH:MM",
                                    controller: _timeController,
                                    readOnly: isPermLocked,
                                  ),
                                ),
                              ],
                            ),
                            CustomInput(
                              label: "Venue / Location",
                              placeholder: "Venue name, area and city",
                              controller: _locController,
                              readOnly: isPermLocked,
                            ),
                            const SizedBox(height: 8),
                            CustomInput(
                              label: "Customer Visible Notes",
                              placeholder: "Special requirements / client instructions...",
                              controller: _notesController,
                              maxLines: 2,
                              readOnly: isPermLocked,
                            ),
                            CustomInput(
                              label: "Internal Admin Notes (Private)",
                              placeholder: "Private notes for decoration staff, pricing calculations...",
                              controller: _internalNotesController,
                              maxLines: 2,
                              readOnly: isPermLocked,
                            ),
                            CustomInput(
                              label: "Message to Client",
                              placeholder: "Write a short status overview or greeting for the client portal...",
                              controller: _adminMessageController,
                              maxLines: 2,
                              readOnly: isPermLocked,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "OPERATIONAL & LOGISTICS DETAILS",
                              style: AppTheme.sansBody(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: goldColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomInput(
                              label: "Operational Notes",
                              placeholder: "Preparation details, timing instructions for setup staff...",
                              controller: _operationalNotesController,
                              maxLines: 2,
                              readOnly: isPermLocked,
                            ),
                            CustomInput(
                              label: "Booking Details",
                              placeholder: "Booking confirmation numbers, package selection descriptions...",
                              controller: _bookingDetailsController,
                              maxLines: 2,
                              readOnly: isPermLocked,
                            ),
                            CustomInput(
                              label: "Staff Assignment",
                              placeholder: "Assigned event managers, florist details, designers...",
                              controller: _staffAssignmentController,
                              maxLines: 2,
                              readOnly: isPermLocked,
                            ),
                            CustomInput(
                              label: "Logistics Details",
                              placeholder: "Vehicles numbers, delivery status, transport arrangements...",
                              controller: _logisticsController,
                              maxLines: 2,
                              readOnly: isPermLocked,
                            ),
                            
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "LINE ITEMS",
                                  style: AppTheme.sansBody(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: goldColor,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text("Add Decoration Item"),
                                  style: TextButton.styleFrom(foregroundColor: goldColor),
                                  onPressed: isFinLocked ? null : () => _showExperienceSelector(context, widget.controller),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Items list
                            Obx(() {
                              final items = widget.controller.rxEditorItems;
                              if (items.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: lineColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(child: Text("No items added. Add items from the catalog.")),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  final qtyCtrl = TextEditingController(text: item.quantity.toString());
                                  final priceCtrl = TextEditingController(text: item.unitPrice.toStringAsFixed(0));

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: paperColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: lineColor),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            item.name,
                                            style: AppTheme.sansBody(fontSize: 14, color: inkColor, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Quantity
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            controller: qtyCtrl,
                                            enabled: !isFinLocked,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: "QTY",
                                              labelStyle: AppTheme.sansBody(fontSize: 10, color: goldColor),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            ),
                                            onChanged: (val) {
                                              final qty = int.tryParse(val) ?? 1;
                                              widget.controller.updateItemQuantity(item.experienceId, qty);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Price
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            controller: priceCtrl,
                                            enabled: !isFinLocked,
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            decoration: InputDecoration(
                                              labelText: "PRICE (₹)",
                                              labelStyle: AppTheme.sansBody(fontSize: 10, color: goldColor),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            ),
                                            onChanged: (val) {
                                              final price = double.tryParse(val) ?? 0.0;
                                              widget.controller.updateItemUnitPrice(item.experienceId, price);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Total Price
                                        Text(
                                          AppFormatters.formatCurrency(item.quantity * item.unitPrice),
                                          style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, color: inkColor),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                          onPressed: isFinLocked ? null : () => widget.controller.removeEditorItem(item.experienceId),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    
                    // Right Preview Column
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        color: paperColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "PRICING ADJUSTMENTS",
                              style: AppTheme.sansBody(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: goldColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomInput(
                              label: "Discount (₹)",
                              placeholder: "0",
                              controller: _discountController,
                              keyboardType: TextInputType.number,
                              readOnly: isFinLocked,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomInput(
                                    label: "Delivery (₹)",
                                    placeholder: "0",
                                    controller: _deliveryController,
                                    keyboardType: TextInputType.number,
                                    readOnly: isFinLocked,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomInput(
                                    label: "Travel (₹)",
                                    placeholder: "0",
                                    controller: _travelController,
                                    keyboardType: TextInputType.number,
                                    readOnly: isFinLocked,
                                  ),
                                ),
                              ],
                            ),
                            CustomInput(
                              label: "GST (%)",
                              placeholder: "18",
                              controller: _gstPercentController,
                              keyboardType: TextInputType.number,
                              readOnly: isFinLocked,
                            ),
                            
                            const Divider(height: 32),
                            Text(
                              "LIVE CALCULATION SUMMARY",
                              style: AppTheme.sansBody(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: goldColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow("Subtotal", widget.controller.editorSubtotal, inkColor),
                            _buildSummaryRow("Discount", widget.controller.editorDiscount, Colors.green, isNeg: true),
                            _buildSummaryRow("Delivery Fee", widget.controller.editorDelivery, inkColor),
                            _buildSummaryRow("Travel Fee", widget.controller.editorTravel, inkColor),
                            Obx(() => _buildStaticRow("GST (${widget.controller.editorGstPercent.value.toStringAsFixed(0)}%)", AppFormatters.formatCurrency(widget.controller.editorGstAmount.value), inkColor)),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "GRAND TOTAL",
                                  style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold, color: inkColor),
                                ),
                                Obx(() => Text(
                                  AppFormatters.formatCurrency(widget.controller.editorGrandTotal.value),
                                  style: AppTheme.serifHeader(fontSize: 24, fontWeight: FontWeight.bold, color: goldColor),
                                )),
                              ],
                            ),
                            const Spacer(),
                            
                            // Bottom Action Panel
                            Obx(() {
                              final saving = widget.controller.isSavingDraft.value;
                              final publishing = widget.controller.isPublishingRevision.value;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  CustomButton(
                                    text: "Save Draft Changes",
                                    isLoading: saving,
                                    onPressed: saving || publishing || isPermLocked ? null : () async {
                                      if (_formKey.currentState?.validate() == true) {
                                        await widget.controller.saveActiveDraft(
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
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  CustomButton(
                                    text: "Publish Revised Proposal",
                                    isLoading: publishing,
                                    onPressed: saving || publishing || isPermLocked ? null : () {
                                      if (_formKey.currentState?.validate() == true) {
                                        _promptRevisionReason(context, widget.controller);
                                      }
                                    },
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, RxDouble valueRx, Color color, {bool isNeg = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.sansBody(fontSize: 13, color: Colors.grey)),
          Obx(() => Text(
            "${isNeg ? '-' : ''}${AppFormatters.formatCurrency(valueRx.value)}",
            style: AppTheme.sansBody(fontSize: 13, color: color, fontWeight: FontWeight.bold),
          )),
        ],
      ),
    );
  }

  Widget _buildStaticRow(String title, String valStr, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.sansBody(fontSize: 13, color: Colors.grey)),
          Text(
            valStr,
            style: AppTheme.sansBody(fontSize: 13, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
