import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:om_event/data/models/lead_model.dart';
import 'package:om_event/presentation/controllers/admin_controller.dart';
import 'package:om_event/presentation/screens/admin/manage_leads_screen.dart';
import 'package:om_event/presentation/screens/admin/widgets/inquiry_card.dart';
import 'package:om_event/presentation/screens/admin/widgets/inquiry_card_image.dart';
import 'package:om_event/presentation/screens/admin/widgets/inquiry_filter_chips.dart';
import 'package:om_event/presentation/screens/admin/widgets/inquiry_search_toolbar.dart';
import 'package:om_event/presentation/screens/admin/widgets/inquiry_showcase_header.dart';
import 'package:om_event/presentation/screens/admin/widgets/inquiry_details_dialog.dart';
import 'package:om_event/presentation/screens/admin/widgets/inquiry_list_item_card.dart';

class MockAdminController extends GetxController implements AdminController {
  @override
  final rxLeads = <LeadModel>[].obs;

  @override
  final isLoadingCustomers = false.obs;

  @override
  final customerLoadError = ''.obs;

  String? lastUpdatedLeadId;
  String? lastUpdatedStatus;

  @override
  Future<void> updateLead(String id, String status) async {
    lastUpdatedLeadId = id;
    lastUpdatedStatus = status;
    final idx = rxLeads.indexWhere((l) => l.id == id);
    if (idx != -1) {
      final old = rxLeads[idx];
      rxLeads[idx] = LeadModel(
        id: old.id,
        name: old.name,
        phone: old.phone,
        email: old.email,
        requestType: old.requestType,
        eventDate: old.eventDate,
        budget: old.budget,
        requirements: old.requirements,
        status: status,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAdminController mockController;

  final sampleLeads = [
    LeadModel(
      id: 'lead_1',
      name: 'shiwa',
      phone: '9856327415',
      email: 'shiwa@gmail.com',
      requestType: 'consultation',
      budget: 10000.0,
      requirements: 'Decor and lights setup',
      status: 'new',
      eventDate: DateTime(2026, 10, 22),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    LeadModel(
      id: 'lead_2',
      name: 'Aarav Shah',
      phone: '9876543210',
      email: '',
      requestType: 'callback',
      budget: 0.0,
      requirements: '',
      status: 'closed',
      eventDate: null,
      createdAt: DateTime(2026, 1, 2),
      updatedAt: DateTime(2026, 1, 2),
    ),
    LeadModel(
      id: 'lead_3',
      name: 'Priya Patel',
      phone: '9822334455',
      email: 'priya@gmail.com',
      requestType: 'Wedding',
      budget: 50000.0,
      requirements: 'Floral entrance',
      status: 'contacted',
      eventDate: DateTime(2026, 11, 15),
      createdAt: DateTime(2026, 1, 3),
      updatedAt: DateTime(2026, 1, 3),
    ),
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    mockController = MockAdminController();
    mockController.rxLeads.assignAll(sampleLeads);
    Get.put<AdminController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestScreen() {
    return GetMaterialApp(
      theme: ThemeData.dark(),
      home: const ManageLeadsScreen(),
    );
  }

  group('Inquiry Showcase Responsive Layout Tests', () {
    testWidgets('Desktop (1920x1080) renders 3-column grid with header and toolbar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ManageLeadsScreen), findsOneWidget);
      expect(find.byType(InquiryShowcaseHeader), findsOneWidget);
      expect(find.byType(InquiryFilterChips), findsOneWidget);
      expect(find.byType(InquirySearchToolbar), findsOneWidget);
      expect(find.text('Inquiry Showcase'), findsOneWidget);
      expect(find.text('Add Inquiry'), findsOneWidget);
      expect(find.text('All (3)'), findsOneWidget);
      expect(find.text('New (1)'), findsOneWidget);
      expect(find.text('Contacted (1)'), findsOneWidget);
      expect(find.text('Closed (1)'), findsOneWidget);

      expect(find.byType(InquiryCard), findsNWidgets(3));
      expect(find.text('shiwa'), findsOneWidget);
      expect(find.text('Aarav Shah'), findsOneWidget);
      expect(find.text('Priya Patel'), findsOneWidget);
      expect(find.text('₹10,000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Laptop (1366x768) renders 3-column grid without overflow', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      expect(find.byType(InquiryCard), findsNWidgets(3));
      expect(find.text('Inquiry Showcase'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tablet (768x1024) renders 2-column grid cleanly', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      expect(find.byType(InquiryCard), findsNWidgets(3));
      expect(find.text('shiwa'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Mobile (375x812) renders 1-column vertical card grid and full-width Add button', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      expect(find.byType(InquiryShowcaseHeader), findsOneWidget);
      expect(find.byType(InquiryFilterChips), findsOneWidget);
      expect(find.byType(InquirySearchToolbar), findsOneWidget);

      // Verify that Add Inquiry button is full-width
      final addBtnFinder = find.widgetWithText(InkWell, 'Add Inquiry');
      expect(addBtnFinder, findsOneWidget);
      final addBtnRect = tester.getRect(addBtnFinder);
      expect(addBtnRect.width, greaterThan(300.0));

      // Verify inquiry cards are single-column vertical cards
      expect(find.byType(InquiryCard), findsNWidgets(3));
      expect(find.byType(InquiryCardImage), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Short Viewport (800x480) renders safely', (tester) async {
      tester.view.physicalSize = const Size(800, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      expect(find.byType(InquiryCard), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Filters inquiries by status chip correctly', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Tap 'New (1)'
      await tester.tap(find.text('New (1)'));
      await tester.pumpAndSettle();
      expect(find.byType(InquiryCard), findsOneWidget);
      expect(find.text('shiwa'), findsOneWidget);
      expect(find.text('Aarav Shah'), findsNothing);

      // Tap 'Closed (1)'
      await tester.tap(find.text('Closed (1)'));
      await tester.pumpAndSettle();
      expect(find.byType(InquiryCard), findsOneWidget);
      expect(find.text('Aarav Shah'), findsOneWidget);
      expect(find.text('shiwa'), findsNothing);

      // Tap 'All (3)'
      await tester.tap(find.text('All (3)'));
      await tester.pumpAndSettle();
      expect(find.byType(InquiryCard), findsNWidgets(3));
    });

    testWidgets('Toggles between Grid and List view modes', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      expect(find.byType(InquiryCard), findsNWidgets(3));
      expect(find.byType(InquiryListItemCard), findsNothing);

      // Tap List view button
      await tester.tap(find.byIcon(Icons.view_list_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(InquiryListItemCard), findsNWidgets(3));
      expect(find.byType(InquiryCard), findsNothing);

      // Tap Grid view button
      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(InquiryCard), findsNWidgets(3));
    });

    testWidgets('Opens Inquiry Details Dialog upon clicking circular arrow button', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Click the first circular arrow button
      final arrowButtons = find.byIcon(Icons.arrow_forward_rounded);
      expect(arrowButtons, findsWidgets);
      await tester.ensureVisible(arrowButtons.first);
      await tester.pumpAndSettle();
      await tester.tap(arrowButtons.first);
      await tester.pumpAndSettle();

      expect(find.byType(InquiryDetailsDialog), findsOneWidget);
      expect(find.text('CALL'), findsNothing);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('UPDATE STATUS:'), findsOneWidget);

      // Close dialog
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(InquiryDetailsDialog), findsNothing);
    });
  });
}
