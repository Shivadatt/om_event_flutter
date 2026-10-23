import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:om_event/domain/entities/admin_role.dart';
import 'package:om_event/domain/entities/lead.dart';
import 'package:om_event/domain/entities/quotation.dart';
import 'package:om_event/presentation/controllers/admin_booking_controller.dart';
import 'package:om_event/presentation/controllers/admin_controller.dart';
import 'package:om_event/presentation/controllers/auth_controller.dart';
import 'package:om_event/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:om_event/presentation/screens/admin/widgets/admin_layout.dart';
import 'package:om_event/presentation/screens/admin/widgets/admin_sidebar.dart';
import 'package:om_event/presentation/screens/admin/widgets/inquiries_trend_chart.dart';

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
  final isLoading = false.obs;

  @override
  final isProfileSaving = false.obs;

  @override
  final isPhotoUploading = false.obs;

  @override
  final isPasswordChanging = false.obs;

  @override
  bool get isStaffOrAdmin => true;

  @override
  bool get isCurrentAdminSessionValid => true;

  @override
  bool isSessionExpired() => false;

  @override
  Future<void> handleSessionExpired() async {}

  @override
  Future<void> checkAuthStatus() async {}

  @override
  void markAdminBootstrapped(bool value) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAdminController extends GetxController implements AdminController {
  @override
  final isLoadingStats = false.obs;

  @override
  final leadCount = 5.obs;

  @override
  final quoteCount = 12.obs;

  @override
  final rxLeads = <Lead>[].obs;

  @override
  final rxQuotes = <Quotation>[].obs;

  @override
  Future<void> loadDashboardStats() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAdminBookingController extends GetxController implements AdminBookingController {
  @override
  final totalCount = 6.obs;

  @override
  final pendingCount = 3.obs;

  @override
  final confirmedCount = 0.obs;

  @override
  final upcomingEventsCount = 0.obs;

  @override
  final cancellationRequestsCount = 0.obs;

  @override
  final selectedStatusTab = 'All'.obs;

  @override
  final upcomingEvents = <Quotation>[].obs;

  @override
  final recentBookings = <Quotation>[].obs;

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
    Get.put<AdminBookingController>(MockAdminBookingController());
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestableScreen({required Size screenSize}) {
    return MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: const GetMaterialApp(
        home: AdminLayout(child: AdminDashboardScreen()),
      ),
    );
  }

  group('OM Events — Admin Dashboard Responsive Tests', () {
    testWidgets('1. Desktop (1920 x 1080) renders persistent sidebar and 4 KPI cards in one row without overflow', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableScreen(screenSize: const Size(1920, 1080)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Verify persistent sidebar is visible
      expect(find.byType(AdminSidebar), findsOneWidget);
      expect(find.text("OVERVIEW"), findsOneWidget);

      // Verify header and top controls
      expect(find.textContaining("Super Admin,"), findsOneWidget);
      expect(find.text("1,500 PTS"), findsOneWidget);
      expect(find.text("PLATINUM TIER"), findsOneWidget);

      // Verify 4 KPI cards
      expect(find.text("TOTAL BOOKINGS"), findsOneWidget);
      expect(find.text("PENDING ACTION"), findsOneWidget);
      expect(find.text("CONFIRMED EVENTS"), findsOneWidget);
      expect(find.text("UPCOMING EVENTS"), findsOneWidget);

      // Verify quick actions and chart
      expect(find.text("QUICK ACTIONS"), findsOneWidget);
      expect(find.text("Add Category"), findsOneWidget);
      expect(find.byType(InquiriesTrendChart), findsOneWidget);
    });

    testWidgets('2. Laptop (1366 x 768) renders with sidebar and full dashboard layout without overflow', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableScreen(screenSize: const Size(1366, 768)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AdminSidebar), findsOneWidget);
      expect(find.text("TOTAL BOOKINGS"), findsOneWidget);
      expect(find.text("QUICK ACTIONS"), findsOneWidget);
      expect(find.byType(InquiriesTrendChart), findsOneWidget);
    });

    testWidgets('3. Tablet (768 x 1024) renders collapsed icon sidebar and full width trend chart', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableScreen(screenSize: const Size(768, 1024)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // In tablet, sidebar is collapsed with OE logo and icon navigation
      expect(find.byType(AdminSidebar), findsOneWidget);
      expect(find.text("OE"), findsOneWidget);

      // 4 KPI cards are rendered in one compact row
      expect(find.text("TOTAL BOOKINGS"), findsOneWidget);
      expect(find.text("PENDING ACTION"), findsOneWidget);
      expect(find.text("CONFIRMED EVENTS"), findsOneWidget);
      expect(find.text("UPCOMING EVENTS"), findsOneWidget);

      // Full-width trend chart
      expect(find.byType(InquiriesTrendChart), findsOneWidget);
    });

    testWidgets('4. Mobile (375 x 812) renders mobile header with drawer, 2x2 KPI grid, and 2x2 Quick Actions', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableScreen(screenSize: const Size(375, 812)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Mobile top header with hamburger and branding
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
      expect(find.text("STUDIO ADMIN"), findsOneWidget);

      // 4 KPI cards rendered in 2x2 grid
      expect(find.text("TOTAL BOOKINGS"), findsOneWidget);
      expect(find.text("PENDING ACTION"), findsOneWidget);
      expect(find.text("CONFIRMED EVENTS"), findsOneWidget);
      expect(find.text("UPCOMING EVENTS"), findsOneWidget);

      // Quick Actions rendered
      expect(find.text("QUICK ACTIONS"), findsOneWidget);
      expect(find.text("Add Category"), findsOneWidget);
      expect(find.text("Add Inspiration"), findsOneWidget);
      expect(find.text("Create Quote"), findsOneWidget);
      expect(find.text("Add Customer"), findsOneWidget);

      // Full-width trend chart
      expect(find.byType(InquiriesTrendChart), findsOneWidget);
    });

    testWidgets('5. Boundary widths (700, 800, 950, 1024, 1400) and short height (800 x 480) render safely without overflow', (tester) async {
      final testSizes = [
        const Size(700, 900),
        const Size(800, 1000),
        const Size(950, 900),
        const Size(1024, 768),
        const Size(1400, 900),
        const Size(800, 480),
      ];

      for (final size in testSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(buildTestableScreen(screenSize: size));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Failed at size: $size');
        expect(find.text("TOTAL BOOKINGS"), findsOneWidget, reason: 'KPI missing at size: $size');
        expect(find.text("QUICK ACTIONS"), findsOneWidget, reason: 'Quick actions missing at size: $size');
      }
      tester.view.resetPhysicalSize();
    });
  });
}
