import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/business_details_service.dart';

/// Models a public business studio location.
class StudioLocation {
  final String name;
  final String address;
  final String city;
  final String district;
  final String pincode;
  final String? phone;
  final String? googleMapUrl;

  const StudioLocation({
    required this.name,
    required this.address,
    required this.city,
    required this.district,
    required this.pincode,
    this.phone,
    this.googleMapUrl,
  });

  String get fullAddress => "$address, $city, $district, Gujarat $pincode";
}

/// Helper for Google Maps and directions exclusively for public studio locations.
class StudioLocationsHelper {
  StudioLocationsHelper._();

  static const kadiStudio = StudioLocation(
    name: "Kadi Studio (Mehsana)",
    address: "Near APMC Market Yard",
    city: "Kadi",
    district: "Mehsana",
    pincode: "382715",
    phone: "9512149944",
  );

  static const thangadhStudio = StudioLocation(
    name: "Thangadh Showroom (Surendranagar)",
    address: "Main Bazar, Near Railway Station",
    city: "Thangadh",
    district: "Surendranagar",
    pincode: "363530",
    phone: "9979058145",
  );

  /// Returns public studio locations, dynamically merging with registered branch settings.
  static List<StudioLocation> getPublicStudios() {
    try {
      if (Get.isRegistered<BusinessDetailsService>()) {
        final branches = BusinessDetailsService.to.rxDetails.value.branches
            .where((b) => b.isActive)
            .toList();

        if (branches.isNotEmpty) {
          return branches.map((b) {
            return StudioLocation(
              name: b.branchName.isNotEmpty ? b.branchName : "OM Events Studio",
              address: b.fullAddress.isNotEmpty ? b.fullAddress : "Gujarat",
              city: b.branchName.toLowerCase().contains("thangadh") ? "Thangadh" : "Kadi",
              district: b.branchName.toLowerCase().contains("thangadh") ? "Surendranagar" : "Mehsana",
              pincode: b.branchName.toLowerCase().contains("thangadh") ? "363530" : "382715",
              phone: b.phoneNumber.isNotEmpty ? b.phoneNumber : b.whatsapp,
              googleMapUrl: b.googleMapUrl.isNotEmpty ? b.googleMapUrl : null,
            );
          }).toList();
        }
      }
    } catch (_) {}
    return const [kadiStudio, thangadhStudio];
  }

  /// Opens Google Maps searching for the given public studio location.
  static Future<bool> openInGoogleMaps(String addressOrQuery) async {
    final query = addressOrQuery.trim();
    if (query.isEmpty) return false;

    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}");
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Opens Google Maps turn-by-turn navigation / directions to the public studio.
  static Future<bool> getDirections(String destinationAddress) async {
    final destination = destinationAddress.trim();
    if (destination.isEmpty) return false;

    final uri = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(destination)}");
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
