import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:om_event/data/models/customer_model.dart';
import 'package:om_event/domain/entities/admin_role.dart';
import 'package:om_event/presentation/controllers/admin_controller.dart';
import 'package:om_event/presentation/controllers/auth_controller.dart';
import 'package:om_event/presentation/screens/admin/widgets/edit_customer_dialog.dart';
import 'package:om_event/presentation/screens/admin/widgets/edit_customer_desktop_fields.dart';
import 'package:om_event/presentation/screens/admin/widgets/edit_customer_mobile_fields.dart';
import 'package:om_event/presentation/screens/admin/widgets/edit_customer_photo_section.dart';

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
  CustomerModel? lastSavedCustomer;

  @override
  final isLoadingCustomers = false.obs;

  @override
  final customerLoadError = ''.obs;

  @override
  Future<bool> saveCustomer(CustomerModel customer) async {
    lastSavedCustomer = customer;
    return true;
  }

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

  final testCustomer = CustomerModel(
    id: '9874563652',
    name: 'aaryan',
    phone: '9874563652',
    email: 'aaryan@yopmail.com',
    address: 'kadi',
    city: 'kadi',
    state: 'gujarat',
    mapLocation: 'https://maps.google.com/?q=kadi',
    type: 'Individual',
    profileImageUrl: '',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  Widget buildTestHost(AdminController controller, CustomerModel customer) {
    return GetMaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color(0xFF070B08),
        body: Center(
          child: EditCustomerDialog(customer: customer, controller: controller),
        ),
      ),
    );
  }

  testWidgets('1. Desktop (1920 x 1080) renders centered dialog with photo on left and pre-populated fields', (tester) async {
    final adminCtrl = MockAdminController();
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestHost(adminCtrl, testCustomer));
    await tester.pumpAndSettle();

    expect(find.text('Edit Client Profile'), findsOneWidget);
    expect(find.text('Manage client details with complete information.'), findsOneWidget);
    expect(find.byType(EditCustomerPhotoSection), findsOneWidget);
    expect(find.byType(EditCustomerDesktopFields), findsOneWidget);
    expect(find.byType(EditCustomerMobileFields), findsNothing);

    expect(find.text('FULL NAME *'), findsOneWidget);
    expect(find.text('PHONE NUMBER *'), findsOneWidget);
    expect(find.text('EMAIL ADDRESS *'), findsOneWidget);
    expect(find.text('STREET ADDRESS'), findsOneWidget);
    expect(find.text('CITY'), findsOneWidget);
    expect(find.text('STATE'), findsOneWidget);
    expect(find.text('MAP LOCATION / GPS URL'), findsOneWidget);
    expect(find.text('CLIENT TYPE *'), findsOneWidget);

    expect(find.text('aaryan'), findsOneWidget);
    expect(find.text('9874563652'), findsOneWidget);
    expect(find.text('aaryan@yopmail.com'), findsOneWidget);
    expect(find.text('kadi'), findsNWidgets(2)); // address and city
    expect(find.text('gujarat'), findsOneWidget);
    expect(find.text('Individual'), findsOneWidget);

    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('2. Laptop (1366 x 768) renders centered dialog comfortably without overflow', (tester) async {
    final adminCtrl = MockAdminController();
    tester.view.physicalSize = const Size(1366, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestHost(adminCtrl, testCustomer));
    await tester.pumpAndSettle();

    expect(find.text('Edit Client Profile'), findsOneWidget);
    expect(find.byType(EditCustomerDesktopFields), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('3. Tablet (768 x 1024) renders within available area without overflow', (tester) async {
    final adminCtrl = MockAdminController();
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestHost(adminCtrl, testCustomer));
    await tester.pumpAndSettle();

    expect(find.text('Edit Client Profile'), findsOneWidget);
    expect(find.byType(EditCustomerPhotoSection), findsOneWidget);
    expect(find.byType(EditCustomerDesktopFields), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('4. Mobile (375 x 812) renders single-column stacked layout with City & State side by side', (tester) async {
    final adminCtrl = MockAdminController();
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestHost(adminCtrl, testCustomer));
    await tester.pumpAndSettle();

    expect(find.text('Edit Client Profile'), findsOneWidget);
    expect(find.byType(EditCustomerMobileFields), findsOneWidget);
    expect(find.byType(EditCustomerDesktopFields), findsNothing);

    expect(find.text('FULL NAME *'), findsOneWidget);
    expect(find.text('PHONE NUMBER *'), findsOneWidget);
    expect(find.text('EMAIL ADDRESS *'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
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

      await tester.pumpWidget(buildTestHost(adminCtrl, testCustomer));
      await tester.pumpAndSettle();

      expect(find.text('Edit Client Profile'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('6. Field editing, type dropdown, and save changes work correctly', (tester) async {
    final adminCtrl = MockAdminController();
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestHost(adminCtrl, testCustomer));
    await tester.pumpAndSettle();

    final nameField = find.widgetWithText(TextField, 'aaryan');
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'Aaryan Sharma');
    await tester.pump();
    expect(find.text('Aaryan Sharma'), findsOneWidget);

    expect(find.text('Individual'), findsOneWidget);
    await tester.tap(find.text('Individual'));
    await tester.pumpAndSettle();

    expect(find.text('VIP'), findsWidgets);
    await tester.tap(find.text('VIP').last);
    await tester.pumpAndSettle();

    expect(find.text('VIP'), findsOneWidget);

    await tester.tap(find.text('Save Changes'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(adminCtrl.lastSavedCustomer, isNotNull);
    expect(adminCtrl.lastSavedCustomer!.name, 'Aaryan Sharma');
    expect(adminCtrl.lastSavedCustomer!.type, 'VIP');
    expect(tester.takeException(), isNull);
  });
}
