import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:om_event/data/datasources/local_storage_source.dart';
import 'package:om_event/domain/entities/experience.dart';
import 'package:om_event/presentation/controllers/cart_controller.dart';
import 'package:om_event/presentation/screens/customer/experience_detail/experience_action_buttons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageSource localStorageSource;
  late CartController cartController;

  const testExperience = Experience(
    id: 'exp_wedding_mandap_01',
    categoryId: 'cat_wedding',
    categoryName: 'Wedding Decor',
    categorySlug: 'wedding-decor',
    name: 'Royal Heritage Mandap',
    slug: 'royal-heritage-mandap',
    description: 'Bespoke hand-crafted floral mandap.',
    price: 35000.0,
    durationHours: 6.0,
    popularity: 95,
    rating: 4.9,
    reviewCount: 42,
    availability: 'available',
    tags: ['wedding', 'mandap', 'luxury'],
    colors: ['Maroon & Gold', 'Ivory & Blush'],
    themes: ['Royal Palace', 'Minimal Modern'],
    imageUrl: 'https://example.com/mandap.jpg',
    videoUrl: '',
    isFeatured: true,
    isActive: true,
  );

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    localStorageSource = LocalStorageSource(prefs);
    cartController = CartController(localStorageSource);
    Get.put<CartController>(cartController);
  });

  tearDown(() {
    Get.reset();
  });

  group('ExperienceActionButtons Notes Dynamic Evaluation Regression Tests', () {
    testWidgets('1. Dynamically reads latest notes entered after initial build', (tester) async {
      final notesController = TextEditingController(text: '');

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ExperienceActionButtons(
              item: testExperience,
              currentPkg: null,
              selectedColor: 'Maroon & Gold',
              selectedTheme: 'Royal Palace',
              notesController: notesController,
              cartController: cartController,
              isDesktop: true,
              goldColor: const Color(0xFFD4AF37),
            ),
          ),
        ),
      );

      final addBtnFinder = find.text('ADD TO MY SELECTION');
      expect(addBtnFinder, findsOneWidget);

      // User enters note AFTER widget build (simulating typing in TextField)
      const customerNote = 'Please include extra brass urlis with marigold petals at the entrance.';
      notesController.text = customerNote;

      // Tap "ADD TO MY SELECTION" without rebuilding the widget
      await tester.tap(addBtnFinder);
      await tester.pump();
      await tester.pump(const Duration(seconds: 10));

      // Verify item in cart received the exact latest note
      expect(cartController.rxCartItems.length, equals(1));
      final addedItem = cartController.rxCartItems.first;
      expect(addedItem.experience.id, equals('exp_wedding_mandap_01'));
      expect(addedItem.color, equals('Maroon & Gold'));
      expect(addedItem.theme, equals('Royal Palace'));
      expect(addedItem.notes, equals(customerNote));
    });

    testWidgets('2. Empty note correctly adds to cart with empty string', (tester) async {
      final notesController = TextEditingController(text: '');

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ExperienceActionButtons(
              item: testExperience,
              currentPkg: null,
              selectedColor: 'Ivory & Blush',
              selectedTheme: 'Minimal Modern',
              notesController: notesController,
              cartController: cartController,
              isDesktop: false,
              goldColor: const Color(0xFFD4AF37),
            ),
          ),
        ),
      );

      final addBtnFinder = find.text('ADD TO MY SELECTION');
      expect(addBtnFinder, findsOneWidget);

      await tester.tap(addBtnFinder);
      await tester.pump();
      await tester.pump(const Duration(seconds: 10));

      expect(cartController.rxCartItems.length, equals(1));
      final addedItem = cartController.rxCartItems.first;
      expect(addedItem.notes, equals(''));
    });
  });
}
