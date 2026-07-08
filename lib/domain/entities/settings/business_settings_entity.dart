part of '../settings_entities.dart';

class OfficeBranch {
  final String id;
  final String branchName;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String googleMapUrl;
  final String latitude;
  final String longitude;
  final String phone1;
  final String phone2;
  final String whatsapp;
  final String email;
  final String instagram;
  final String businessHours;
  final bool isPrimary;

  const OfficeBranch({
    required this.id,
    required this.branchName,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.googleMapUrl,
    required this.latitude,
    required this.longitude,
    required this.phone1,
    required this.phone2,
    required this.whatsapp,
    required this.email,
    required this.instagram,
    required this.businessHours,
    required this.isPrimary,
  });

  factory OfficeBranch.fromMap(String id, Map<dynamic, dynamic> map) {
    return OfficeBranch(
      id: id,
      branchName: map['branchName'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      pincode: map['pincode'] ?? '',
      googleMapUrl: map['googleMapUrl'] ?? '',
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      phone1: map['phone1'] ?? '',
      phone2: map['phone2'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      email: map['email'] ?? '',
      instagram: map['instagram'] ?? '',
      businessHours: map['businessHours'] ?? '',
      isPrimary: map['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'branchName': branchName,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'googleMapUrl': googleMapUrl,
      'latitude': latitude,
      'longitude': longitude,
      'phone1': phone1,
      'phone2': phone2,
      'whatsapp': whatsapp,
      'email': email,
      'instagram': instagram,
      'businessHours': businessHours,
      'isPrimary': isPrimary,
    };
  }
}

class BusinessProfile {
  final String name;
  final String companyName;
  final String logo;
  final String whiteLogo;
  final String favicon;
  final String gst;
  final String pan;
  final String ownerName;
  final List<ContactNumberEntity> contactNumbers;
  final String email;
  final String whatsapp;
  final List<OfficeBranch> officeBranches;
  final String workingHours;
  final Map<String, String> socialLinks;

  const BusinessProfile({
    required this.name,
    required this.companyName,
    required this.logo,
    required this.whiteLogo,
    required this.favicon,
    required this.gst,
    required this.pan,
    required this.ownerName,
    required this.contactNumbers,
    required this.email,
    required this.whatsapp,
    required this.officeBranches,
    required this.workingHours,
    required this.socialLinks,
  });

  factory BusinessProfile.defaultVal() {
    return const BusinessProfile(
      name: "",
      companyName: "",
      logo: "",
      whiteLogo: "",
      favicon: "",
      gst: "",
      pan: "",
      ownerName: "",
      contactNumbers: [],
      email: "",
      whatsapp: "",
      officeBranches: [],
      workingHours: "",
      socialLinks: {},
    );
  }
}
