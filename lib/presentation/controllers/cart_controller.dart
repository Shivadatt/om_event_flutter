import 'dart:convert';
import 'package:get/get.dart';
import '../../core/config/constants.dart';
import '../../data/datasources/local_storage_source.dart';
import '../../domain/entities/experience.dart';

class CartItemSelection {
  final Experience experience;
  int quantity;
  String color;
  String theme;
  String notes;

  CartItemSelection({
    required this.experience,
    this.quantity = 1,
    this.color = '',
    this.theme = '',
    this.notes = '',
  });

  double get totalPrice => experience.effectivePrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': experience.id,
      'name': experience.name,
      'slug': experience.slug,
      'categoryName': experience.categoryName,
      'categorySlug': experience.categorySlug,
      'imageUrl': experience.imageUrl,
      'price': experience.price,
      'offerPrice': experience.offerPrice,
      'quantity': quantity,
      'color': color,
      'theme': theme,
      'notes': notes,
    };
  }
}

class CartController extends GetxController {
  final LocalStorageSource localStorage;
  CartController(this.localStorage);

  final rxCartItems = <CartItemSelection>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCartFromCache();
  }

  // Add Item to Cart
  void addToCart(Experience experience, {String color = '', String theme = '', String notes = ''}) {
    // Check if identical item (same experience and same color) exists
    final existingIndex = rxCartItems.indexWhere(
      (element) => element.experience.id == experience.id && element.color == color,
    );

    if (existingIndex != -1) {
      rxCartItems[existingIndex].quantity += 1;
      rxCartItems.refresh();
    } else {
      rxCartItems.add(CartItemSelection(
        experience: experience,
        quantity: 1,
        color: color,
        theme: theme,
        notes: notes,
      ));
    }
    persistCart();
    Get.snackbar("Added to Selection", "${experience.name} added to your design canvas.");
  }

  void changeQuantity(int index, int delta) {
    if (index >= 0 && index < rxCartItems.length) {
      rxCartItems[index].quantity += delta;
      if (rxCartItems[index].quantity < 1) {
        rxCartItems.removeAt(index);
      } else {
        rxCartItems.refresh();
      }
      persistCart();
    }
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < rxCartItems.length) {
      final name = rxCartItems[index].experience.name;
      rxCartItems.removeAt(index);
      persistCart();
      Get.snackbar("Removed", "$name removed from your canvas.");
    }
  }

  void clearCart() {
    rxCartItems.clear();
    persistCart();
  }

  // Caching Persistence
  void persistCart() {
    final list = rxCartItems.map((e) => e.toJson()).toList();
    localStorage.saveCart(json.encode(list));
  }

  void loadCartFromCache() {
    try {
      final jsonStr = localStorage.getCart();
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decodedList = json.decode(jsonStr);
        final List<CartItemSelection> cachedItems = [];

        for (var item in decodedList) {
          final exp = Experience(
            id: item['id'] ?? '',
            name: item['name'] ?? '',
            slug: item['slug'] ?? '',
            categoryId: '',
            categoryName: item['categoryName'] ?? '',
            categorySlug: item['categorySlug'] ?? '',
            description: '',
            price: (item['price'] as num?)?.toDouble() ?? 0.0,
            offerPrice: (item['offerPrice'] as num?)?.toDouble(),
            durationHours: 3.0,
            popularity: 0,
            rating: 5.0,
            reviewCount: 0,
            availability: 'available',
            tags: [],
            colors: [],
            themes: [],
            imageUrl: item['imageUrl'] ?? '',
            videoUrl: '',
            isFeatured: false,
            isActive: true,
          );

          cachedItems.add(CartItemSelection(
            experience: exp,
            quantity: item['quantity'] ?? 1,
            color: item['color'] ?? '',
            theme: item['theme'] ?? '',
            notes: item['notes'] ?? '',
          ));
        }

        rxCartItems.assignAll(cachedItems);
      }
    } catch (_) {
      // Fail silently if cache corrupted
    }
  }

  // Pricing calculations
  double get subtotal => rxCartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get volumeDiscount => subtotal >= 50000 ? (subtotal * 0.05) : 0.0;

  double get deliveryCharge => rxCartItems.isNotEmpty ? AppConstants.deliveryCharge : 0.0;

  double get travelCharge => AppConstants.travelCharge;

  double get taxableAmount => subtotal - volumeDiscount + deliveryCharge + travelCharge;

  double get gstAmount => taxableAmount * (AppConstants.gstPercent / 100.0);

  // WAIVER promotional discount: waives delivery fee + GST
  double get clientWaiverDiscount {
    if (AppConstants.enableClientFeeWaiver) {
      return deliveryCharge + gstAmount;
    }
    return 0.0;
  }

  double get grandTotal {
    if (AppConstants.enableClientFeeWaiver) {
      // Waives delivery and GST: GrandTotal = Subtotal - Discount
      return subtotal - volumeDiscount;
    } else {
      return taxableAmount + gstAmount;
    }
  }
}
