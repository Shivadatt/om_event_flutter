import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:om_event/core/services/business_details_service.dart';
import 'package:om_event/domain/entities/business_details_entity.dart';
import 'package:om_event/presentation/controllers/auth_controller.dart';
import 'package:om_event/presentation/screens/auth/login_screen.dart';
import 'package:om_event/presentation/screens/auth/widgets/login_brand_header.dart';

class MockBusinessDetailsService extends GetxService implements BusinessDetailsService {
  @override
  final rxDetails = BusinessDetailsEntity.defaultVal().obs;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthController extends GetxController implements AuthController {
  @override
  final rxIsLoggedIn = false.obs;

  @override
  final rxUserRole = ''.obs;

  @override
  final rxAdminRole = Rxn();

  @override
  final rxAdminBootstrapped = false.obs;

  @override
  final isLoading = false.obs;

  @override
  final isProfileSaving = false.obs;

  @override
  final isPhotoUploading = false.obs;

  @override
  final isPasswordChanging = false.obs;

  @override
  bool get isStaffOrAdmin => false;

  @override
  bool get isCurrentAdminSessionValid => false;

  @override
  bool isSessionExpired() => true;

  @override
  Future<void> handleSessionExpired() async {}

  @override
  Future<void> checkAuthStatus() async {}

  @override
  void markAdminBootstrapped(bool value) {}

  @override
  Future<bool> login(String email, String password) async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthController mockAuthController;

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    mockAuthController = MockAuthController();
    Get.put<AuthController>(mockAuthController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestableScreen({required Size screenSize}) {
    return MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: const GetMaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('Admin Login Screen Responsive Layout Tests', () {
    testWidgets('1. Desktop (1920 x 1080) renders 2-column layout with no overflow', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableScreen(screenSize: const Size(1920, 1080)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text("Beautiful work\nbegins with a\nclear view."), findsOneWidget);
      expect(find.text("TEAM STUDIO"), findsOneWidget);
      expect(find.text("Welcome back."), findsOneWidget);
      expect(find.text("EMAIL ADDRESS"), findsOneWidget);
      expect(find.text("PASSWORD"), findsOneWidget);
      expect(find.text("Remember me"), findsOneWidget);
      expect(find.text("Forgot password?"), findsOneWidget);
      expect(find.text("ENTER THE STUDIO"), findsOneWidget);
      // OE text placeholder must be completely replaced
      expect(find.text("OE"), findsNothing);
      expect(find.byType(LoginCompanyLogo), findsNWidgets(2));
    });

    testWidgets('2. Laptop (1366 x 768) renders 2-column layout without overflow', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableScreen(screenSize: const Size(1366, 768)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text("Beautiful work\nbegins with a\nclear view."), findsOneWidget);
      expect(find.text("TEAM STUDIO"), findsOneWidget);
      expect(find.text("Welcome back."), findsOneWidget);
      expect(find.text("ENTER THE STUDIO"), findsOneWidget);
      expect(find.text("OE"), findsNothing);
      expect(find.byType(LoginCompanyLogo), findsNWidgets(2));
    });

    testWidgets('3. Tablet Portrait (768 x 1024) renders 2-column split layout', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableScreen(screenSize: const Size(768, 1024)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Both left hero and right form are visible in 2-column layout
      expect(find.text("Beautiful work\nbegins with a\nclear view."), findsOneWidget);
      expect(find.text("TEAM STUDIO"), findsOneWidget);
      expect(find.text("Welcome back."), findsOneWidget);
      expect(find.text("ENTER THE STUDIO"), findsOneWidget);
      expect(find.text("OE"), findsNothing);
      expect(find.byType(LoginCompanyLogo), findsNWidgets(2));
    });

    testWidgets('4. Mobile (375 x 812) renders single-column layout without duplicate OE badge in form', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableScreen(screenSize: const Size(375, 812)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text("Beautiful work\nbegins with a\nclear view."), findsOneWidget);
      expect(find.text("TEAM STUDIO"), findsOneWidget);
      expect(find.text("Welcome back."), findsOneWidget);
      expect(find.text("EMAIL ADDRESS"), findsOneWidget);
      expect(find.text("PASSWORD"), findsOneWidget);
      expect(find.text("ENTER THE STUDIO"), findsOneWidget);
      expect(find.text("OE"), findsNothing);
      // Only 1 logo in mobile hero (no duplicate badge in form)
      expect(find.byType(LoginCompanyLogo), findsOneWidget);
    });

    testWidgets('5. Boundary widths (700, 860, 992, 1400) and short-height viewports (800 x 480) render safely', (tester) async {
      final testSizes = [
        const Size(700, 900),
        const Size(860, 900),
        const Size(992, 768),
        const Size(1400, 900),
        const Size(800, 480), // Short viewport height
      ];

      for (final size in testSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(buildTestableScreen(screenSize: size));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Failed at size: $size');
        expect(find.text("ENTER THE STUDIO"), findsOneWidget, reason: 'Button missing at size: $size');
        expect(find.text("OE"), findsNothing, reason: 'OE placeholder found at size: $size');
      }
      tester.view.resetPhysicalSize();
    });

    testWidgets('6. LoginCompanyLogo gracefully falls back without broken image icon or OE text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoginCompanyLogo(size: 36, withGlow: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text("OE"), findsNothing);
      expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('7. LoginCompanyLogo dynamically binds and renders when Firebase logo is configured', (tester) async {
      final mockBizService = MockBusinessDetailsService();
      Get.put<BusinessDetailsService>(mockBizService);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoginCompanyLogo(size: 36, withGlow: true),
            ),
          ),
        ),
      );
      await tester.pump();

      // Initially empty -> fallback
      expect(find.byType(LoginCompanyLogo), findsOneWidget);
      expect(find.text("OE"), findsNothing);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);

      // Now configure a Firebase logo URL in BusinessDetailsService
      const testLogoUrl = 'https://kwegyvbgdaednljyhcgm.supabase.co/storage/v1/object/public/gallery/logos/om_events_logo.png';
      final defaultEntity = BusinessDetailsEntity.defaultVal();
      mockBizService.rxDetails.value = BusinessDetailsEntity(
        general: GeneralProfileEntity(
          businessName: defaultEntity.general.businessName,
          companyName: defaultEntity.general.companyName,
          tagline: defaultEntity.general.tagline,
          description: defaultEntity.general.description,
          ownerName: defaultEntity.general.ownerName,
          ownerDesignation: defaultEntity.general.ownerDesignation,
          logo: testLogoUrl,
          coverImage: defaultEntity.general.coverImage,
          favicon: defaultEntity.general.favicon,
          registrationNumber: defaultEntity.general.registrationNumber,
          gstNumber: defaultEntity.general.gstNumber,
          panNumber: defaultEntity.general.panNumber,
          licenseNumber: defaultEntity.general.licenseNumber,
          establishedYear: defaultEntity.general.establishedYear,
        ),
        contacts: defaultEntity.contacts,
        branches: defaultEntity.branches,
        addresses: defaultEntity.addresses,
        social: defaultEntity.social,
        workingHours: defaultEntity.workingHours,
        bank: defaultEntity.bank,
        legal: defaultEntity.legal,
        seo: defaultEntity.seo,
        maps: defaultEntity.maps,
      );
      await tester.pump();

      // Verify CachedNetworkImage is rendered with the configured Firebase logo URL and BoxFit.contain
      final imageFinder = find.byType(CachedNetworkImage);
      expect(imageFinder, findsOneWidget);
      final cachedImage = tester.widget<CachedNetworkImage>(imageFinder);
      expect(cachedImage.imageUrl, testLogoUrl);
      expect(cachedImage.fit, BoxFit.contain);
      expect(find.text("OE"), findsNothing);
    });
  });
}
