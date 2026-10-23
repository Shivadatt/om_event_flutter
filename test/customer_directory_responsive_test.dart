import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:om_event/data/models/customer_model.dart';
import 'package:om_event/domain/entities/admin_role.dart';
import 'package:om_event/domain/entities/quotation.dart';
import 'package:om_event/presentation/controllers/admin_controller.dart';
import 'package:om_event/presentation/controllers/auth_controller.dart';
import 'package:om_event/presentation/screens/admin/manage_customers_screen.dart';
import 'package:om_event/presentation/screens/admin/widgets/admin_layout.dart';
import 'package:om_event/presentation/screens/admin/widgets/customer_directory_mobile_card.dart';
import 'package:om_event/presentation/screens/admin/widgets/customer_directory_table_row.dart';

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
      permissions: {
        'can_manage_categories': true,
        'can_manage_items': true,
        'can_manage_quotes': true,
        'can_manage_customers': true,
      },
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
  final rxCustomers = <CustomerModel>[
    CustomerModel(
      id: 'cust_1',
      name: 'aaryan',
      email: 'aaryan@yopmail.com',
      phone: '9874563652',
      address: 'kadi',
      city: 'kadi',
      mapLocation: '',
      type: 'Individual',
      createdAt: DateTime(2026, 1, 10),
      updatedAt: DateTime(2026, 1, 10),
    ),
    CustomerModel(
      id: 'cust_2',
      name: 'shiwa',
      email: 'shiwa@gmail.com',
      phone: '9856327415',
      address: 'kadi',
      city: 'kadi',
      mapLocation: '',
      type: 'Individual',
      createdAt: DateTime(2026, 1, 15),
      updatedAt: DateTime(2026, 1, 15),
    ),
  ].obs;

  @override
  final rxQuotes = <Quotation>[].obs;

  @override
  final pipelineRevenue = 11400.0.obs;

  @override
  Future<void> loadCustomers() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    Get.put<AuthController>(MockAuthController());
    Get.put<AdminController>(MockAdminController());
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestApp({required Size size}) {
    return MediaQuery(
      data: MediaQueryData(
        size: size,
        devicePixelRatio: 1.0,
      ),
      child: const GetMaterialApp(
        home: Scaffold(
          body: AdminLayout(
            child: ManageCustomersScreen(),
          ),
        ),
      ),
    );
  }

  group('OM Events — Customer Directory Responsive Tests', () {
    testWidgets('1. Desktop (1920 x 1080) renders expanded sidebar, statistics row, and table view', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      await tester.pumpWidget(buildTestApp(size: const Size(1920, 1080)));
      await tester.pumpAndSettle();

      expect(find.text('Client Directory'), findsOneWidget);
      expect(find.text('2 Total Customers'), findsOneWidget);
      expect(find.text('Total Clients'), findsOneWidget);
      expect(find.text('VIP Clients'), findsOneWidget);
      expect(find.text('Corporate Clients'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('CLIENT'), findsOneWidget);
      expect(find.text('TOTAL SPENDING'), findsOneWidget);
      expect(find.byType(CustomerDirectoryTableRow), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('2. Laptop (1366 x 768) renders table without horizontal overflow on root page', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1366, 768));
      await tester.pumpWidget(buildTestApp(size: const Size(1366, 768)));
      await tester.pumpAndSettle();

      expect(find.text('Client Directory'), findsOneWidget);
      expect(find.text('Total Clients'), findsOneWidget);
      expect(find.byType(CustomerDirectoryTableRow), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('3. Tablet (768 x 1024) renders collapsed icon sidebar and 2x2 statistics grid', (tester) async {
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      await tester.pumpWidget(buildTestApp(size: const Size(768, 1024)));
      await tester.pumpAndSettle();

      expect(find.text('Client Directory'), findsOneWidget);
      expect(find.text('Total Clients'), findsOneWidget);
      expect(find.text('VIP Clients'), findsOneWidget);
      expect(find.text('Corporate Clients'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('4. Mobile (375 x 812) renders mobile header, 2x2 statistics grid, and mobile cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 812));
      await tester.pumpWidget(buildTestApp(size: const Size(375, 812)));
      await tester.pumpAndSettle();

      expect(find.text('Client Directory'), findsOneWidget);
      expect(find.text('Add Customer'), findsOneWidget);
      expect(find.text('Total Clients'), findsOneWidget);
      expect(find.text('VIP Clients'), findsOneWidget);
      expect(find.text('Corporate Clients'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.byType(CustomerDirectoryMobileCard), findsNWidgets(2));
      expect(find.text('9874563652'), findsOneWidget);
      expect(find.text('9856327415'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('5. Boundary widths (700, 800, 950, 1100, 1400) and short height (800 x 480) render safely', (tester) async {
      final testSizes = [
        const Size(700, 900),
        const Size(800, 900),
        const Size(950, 900),
        const Size(1100, 900),
        const Size(1400, 900),
        const Size(800, 480),
      ];

      for (final size in testSizes) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(buildTestApp(size: size));
        await tester.pumpAndSettle();

        expect(find.text('Client Directory'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('6. Search filtering dynamically filters customer records', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      await tester.pumpWidget(buildTestApp(size: const Size(1920, 1080)));
      await tester.pumpAndSettle();

      final searchFinder = find.byType(TextField);
      expect(searchFinder, findsOneWidget);

      await tester.enterText(searchFinder, 'shiwa');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(CustomerDirectoryTableRow, 'shiwa'), findsOneWidget);
      expect(find.widgetWithText(CustomerDirectoryTableRow, 'aaryan'), findsNothing);

      await tester.enterText(searchFinder, 'nonexistent');
      await tester.pumpAndSettle();

      expect(find.text("No clients match 'nonexistent'"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
