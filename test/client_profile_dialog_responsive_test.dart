import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:om_event/data/models/customer_model.dart';
import 'package:om_event/data/models/lead_model.dart';
import 'package:om_event/presentation/controllers/admin_controller.dart';
import 'package:om_event/presentation/screens/admin/widgets/customer_details_dialog.dart';
import 'package:om_event/presentation/screens/admin/widgets/client_profile_details_card.dart';
import 'package:om_event/presentation/screens/admin/widgets/client_portal_login_card.dart';
import 'package:om_event/presentation/screens/admin/widgets/client_profile_dialog_header.dart';
import 'package:om_event/presentation/screens/admin/widgets/client_profile_inquiries_tab.dart';
import 'package:om_event/presentation/screens/admin/widgets/client_profile_media_tab.dart';

class MockAdminController extends GetxController implements AdminController {
  @override
  final rxLeads = <LeadModel>[].obs;

  @override
  final isLoadingCustomers = false.obs;

  @override
  final customerLoadError = ''.obs;

  @override
  Future<void> loadCustomers({bool force = false}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAdminController mockAdminController;

  final sampleCustomer = CustomerModel(
    id: 'cust_1',
    name: 'shiwa',
    type: 'Individual',
    phone: '9856327415',
    email: 'shiwa@gmail.com',
    address: 'kadi',
    city: 'kadi',
    state: 'Gujarat',
    pincode: '382715',
    mapLocation: 'https://maps.google.com',
    loginEnabled: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    mockAdminController = MockAdminController();
    Get.put<AdminController>(mockAdminController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestDialog(CustomerModel customer, {Size? size}) {
    return GetMaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Center(
          child: CustomerDetailsDialog(
            customer: customer,
            controller: mockAdminController,
          ),
        ),
      ),
    );
  }

  group('Client Profile Details Dialog Responsive Tests', () {
    testWidgets('renders properly on Desktop (1920x1080)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestDialog(sampleCustomer));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerDetailsDialog), findsOneWidget);
      expect(find.byType(ClientProfileDialogHeader), findsOneWidget);
      expect(find.byType(ClientProfileDetailsCard), findsOneWidget);
      expect(find.byType(ClientPortalLoginCard), findsOneWidget);
      expect(find.text('SHIWA'), findsOneWidget);
      expect(find.text('PROFILE'), findsOneWidget);
      expect(find.text('INQUIRIES'), findsOneWidget);
      expect(find.text('MEDIA'), findsOneWidget);
      expect(find.text('shiwa@gmail.com'), findsWidgets);
      expect(find.text('Gujarat'), findsOneWidget);
      expect(find.text('382715'), findsOneWidget);
      expect(find.text('Send Portal Invite'), findsOneWidget);
      expect(find.text('Disable Client Login'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders properly on Laptop (1366x768)', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestDialog(sampleCustomer));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerDetailsDialog), findsOneWidget);
      expect(find.text('SHIWA'), findsOneWidget);
      expect(find.text('Send Portal Invite'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders properly on Tablet (768x1024)', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestDialog(sampleCustomer));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerDetailsDialog), findsOneWidget);
      expect(find.text('SHIWA'), findsOneWidget);
      expect(find.text('9856327415'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders properly on Mobile (375x812) with stacked action buttons', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestDialog(sampleCustomer));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerDetailsDialog), findsOneWidget);
      expect(find.text('SHIWA'), findsOneWidget);
      expect(find.text('PROFILE'), findsOneWidget);
      expect(find.text('INQUIRIES'), findsOneWidget);
      expect(find.text('MEDIA'), findsOneWidget);
      expect(find.text('Send Portal Invite'), findsOneWidget);
      expect(find.text('Disable Client Login'), findsOneWidget);

      // Verify that Send Portal Invite and Disable Client Login buttons are stacked vertically
      final inviteBtnFinder = find.widgetWithText(ElevatedButton, 'Send Portal Invite');
      final disableBtnFinder = find.widgetWithText(OutlinedButton, 'Disable Client Login');
      expect(inviteBtnFinder, findsOneWidget);
      expect(disableBtnFinder, findsOneWidget);

      final inviteBox = tester.getRect(inviteBtnFinder);
      final disableBox = tester.getRect(disableBtnFinder);
      expect(disableBox.top, greaterThanOrEqualTo(inviteBox.bottom));

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders properly on Short Viewport (800x480)', (tester) async {
      tester.view.physicalSize = const Size(800, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestDialog(sampleCustomer));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerDetailsDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('switches between Profile, Inquiries, and Media tabs smoothly', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Add a sample inquiry lead for this customer
      mockAdminController.rxLeads.add(
        LeadModel(
          id: 'lead_1',
          name: 'shiwa',
          email: 'shiwa@gmail.com',
          phone: '9856327415',
          requestType: 'Wedding Reception',
          requirements: 'Decorations and catering',
          status: 'Confirmed',
          eventDate: DateTime(2026, 12, 25),
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );

      await tester.pumpWidget(buildTestDialog(sampleCustomer));
      await tester.pumpAndSettle();

      // Initially on Profile tab
      expect(find.byType(ClientProfileDetailsCard), findsOneWidget);

      // Switch to Inquiries tab
      await tester.tap(find.text('INQUIRIES'));
      await tester.pumpAndSettle();
      expect(find.byType(ClientProfileInquiriesTab), findsOneWidget);
      expect(find.text('WEDDING RECEPTION'), findsOneWidget);

      // Switch to Media tab
      await tester.tap(find.text('MEDIA'));
      await tester.pumpAndSettle();
      expect(find.byType(ClientProfileMediaTab), findsOneWidget);
      expect(find.text('Customer Media Gallery'), findsOneWidget);
      expect(find.text('UPLOAD PROPOSAL MEDIA'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows Enable Client Login button when login is disabled', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final disabledCustomer = sampleCustomer.copyWith(loginEnabled: false);
      await tester.pumpWidget(buildTestDialog(disabledCustomer));
      await tester.pumpAndSettle();

      expect(find.text('Disabled'), findsOneWidget);
      expect(find.text('Enable Client Login'), findsOneWidget);
      expect(find.text('Disable Client Login'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
