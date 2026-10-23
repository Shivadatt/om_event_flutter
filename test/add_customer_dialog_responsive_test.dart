import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:om_event/domain/entities/admin_role.dart';
import 'package:om_event/presentation/controllers/admin_controller.dart';
import 'package:om_event/presentation/controllers/auth_controller.dart';
import 'package:om_event/presentation/screens/admin/widgets/add_customer_dialog.dart';
import 'package:om_event/presentation/screens/admin/widgets/add_customer_desktop_fields.dart';
import 'package:om_event/presentation/screens/admin/widgets/add_customer_mobile_fields.dart';
import 'package:om_event/presentation/screens/admin/widgets/add_customer_photo_upload.dart';

class MockAuthController extends GetxController implements AuthController {
  @override
  final rxIsLoggedIn = true.obs;

  @override
  final rxUserRole = 'super_admin'.obs;

  @override
  final rxAdminRole = Rxn<AdminRole>(
    AdminRole(
      uid: 'admin_1',
      name: 'Super Admin',
      email: 'admin@omevents.com',
      role: 'super_admin',
      roleType: 'super_admin',
      isActive: true,
      createdBy: 'system',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      permissions: {'can_manage_customers': true},
    ),
  );

  @override
  final rxAdminBootstrapped = true.obs;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAdminController extends GetxController implements AdminController {
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put<AuthController>(MockAuthController());
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestHost(AdminController controller) {
    return GetMaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color(0xFF070B08),
        body: Center(
          child: AddCustomerDialog(controller: controller),
        ),
      ),
    );
  }

  testWidgets('1. Desktop (1920 x 1080) renders centered dialog with photo on left and 2-column fields', (tester) async {
    final adminCtrl = MockAdminController();
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestHost(adminCtrl));
    await tester.pumpAndSettle();

    expect(find.text('Add New Client'), findsOneWidget);
    expect(find.text('Create a new client profile with complete information.'), findsOneWidget);
    expect(find.byType(AddCustomerPhotoUpload), findsOneWidget);
    expect(find.byType(AddCustomerDesktopFields), findsOneWidget);
    expect(find.byType(AddCustomerMobileFields), findsNothing);

    expect(find.text('FULL NAME *'), findsOneWidget);
    expect(find.text('PHONE NUMBER *'), findsOneWidget);
    expect(find.text('EMAIL ADDRESS'), findsOneWidget);
    expect(find.text('CLIENT TYPE *'), findsOneWidget);
    expect(find.text('STREET ADDRESS'), findsOneWidget);
    expect(find.text('CITY'), findsOneWidget);
    expect(find.text('STATE'), findsOneWidget);
    expect(find.text('MAP LOCATION / GPS URL'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Create Client'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('2. Laptop (1366 x 768) renders centered dialog comfortably without overflow', (tester) async {
    final adminCtrl = MockAdminController();
    tester.view.physicalSize = const Size(1366, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestHost(adminCtrl));
    await tester.pumpAndSettle();

    expect(find.text('Add New Client'), findsOneWidget);
    expect(find.byType(AddCustomerDesktopFields), findsOneWidget);
    expect(find.text('Create Client'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('3. Tablet (768 x 1024) renders within available area without overflow', (tester) async {
    final adminCtrl = MockAdminController();
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestHost(adminCtrl));
    await tester.pumpAndSettle();

    expect(find.text('Add New Client'), findsOneWidget);
    expect(find.byType(AddCustomerPhotoUpload), findsOneWidget);
    expect(find.byType(AddCustomerDesktopFields), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('4. Mobile (375 x 812) renders single-column stacked layout', (tester) async {
    final adminCtrl = MockAdminController();
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestHost(adminCtrl));
    await tester.pumpAndSettle();

    expect(find.text('Add New Client'), findsOneWidget);
    expect(find.byType(AddCustomerMobileFields), findsOneWidget);
    expect(find.byType(AddCustomerDesktopFields), findsNothing);

    expect(find.text('FULL NAME *'), findsOneWidget);
    expect(find.text('PHONE NUMBER *'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Create Client'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('5. Boundary widths (500, 600, 700, 900, 1200) and short height (800 x 480) render safely', (tester) async {
    final adminCtrl = MockAdminController();
    addTearDown(tester.view.resetPhysicalSize);

    final testSizes = [
      const Size(500, 800),
      const Size(600, 800),
      const Size(700, 900),
      const Size(900, 700),
      const Size(1200, 800),
      const Size(800, 480),
    ];

    for (final size in testSizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildTestHost(adminCtrl));
      await tester.pumpAndSettle();

      expect(find.text('Add New Client'), findsOneWidget);
      expect(find.text('Create Client'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('6. Form inputs and dropdown interaction work correctly', (tester) async {
    final adminCtrl = MockAdminController();
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestHost(adminCtrl));
    await tester.pumpAndSettle();

    final nameField = find.widgetWithText(TextField, 'e.g. Shivadatt Goswami');
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'Rajesh Patel');
    await tester.pump();
    expect(find.text('Rajesh Patel'), findsOneWidget);

    final phoneField = find.widgetWithText(TextField, '9876543210');
    expect(phoneField, findsOneWidget);
    await tester.enterText(phoneField, '9988776655');
    await tester.pump();
    expect(find.text('9988776655'), findsOneWidget);

    expect(find.text('Individual'), findsOneWidget);
    await tester.tap(find.text('Individual'));
    await tester.pumpAndSettle();

    expect(find.text('VIP'), findsWidgets);
    await tester.tap(find.text('VIP').last);
    await tester.pumpAndSettle();

    expect(find.text('VIP'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
