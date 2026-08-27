/// KD Listing Model
/// Comprehensive data model for lease listings
/// Holds all property information including utilities, kitchen type, and images

enum ElectricityType { prepaidMeter, sharedMeter }

enum ListingType { vacancy, roommate } // for sorting

enum UserRole { tenant, landlord } // who posted it

enum ToiletType { internal, shared }

enum WaterAvailability { available, notAvailable }

enum KitchenType {
  hasKitchen,
  sharedKitchen,
  internalKitchen,
} // renamed + helper text

// lib/models/kd_listing_model.dart

class KDListing {
  final String id;
  final int rentPrice;
  final String town;
  final String streetName;
  final List<String> imagePaths;
  final bool waterAvailable;
  final ElectricityType electricityType;
  final KitchenType kitchenType;
  final String generalDescription;
  final DateTime leavingByDate;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? reconfirmedAt;
  final String userId;
  final bool hasLiveAd;

  final ListingType type;
  final UserRole postedByRole;
  final WaterAvailability water;
  final ElectricityType electricity;
  final KitchenType kitchen;
  final ToiletType toilet;
  final int? shareAmount;
  final String? genderPreference;
  final List<String> targetAgeRanges;
  final List<String> lifestyleTags;
  final String? expectedDuration;
  final bool isBoosted;
  final DateTime? boostedUntil;

  const KDListing({
    required this.id,
    required this.rentPrice,
    required this.town,
    required this.streetName,
    required this.leavingByDate,
    required this.imagePaths,
    required this.waterAvailable,
    required this.electricityType,
    required this.kitchenType,
    required this.generalDescription,
    required this.createdAt,
    required this.userId,
    this.hasLiveAd = false,
    this.expiresAt,
    this.reconfirmedAt,
    this.type = ListingType.vacancy,
    roomamte,
    this.postedByRole = UserRole.tenant,
    this.water = WaterAvailability.available,
    this.electricity = ElectricityType.prepaidMeter,
    this.kitchen = KitchenType.internalKitchen,
    this.toilet = ToiletType.internal,
    this.shareAmount,
    this.genderPreference,
    this.targetAgeRanges = const [],
    this.lifestyleTags = const [],
    this.expectedDuration,
    this.isBoosted = false,
    this.boostedUntil,
  }) : assert(imagePaths.length <= 3, 'Maximum 3 images allowed');

  String get freshnessLabel {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return 'Just now';
    if (diff.inHours < 24) return 'Today';
    if (diff.inDays < 7) return 'This week';
    return 'Recently';
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get needsReconfirmation => isExpired && reconfirmedAt == null;

  /// Format price as "75000 CFA"
  String get formattedPrice => '$rentPrice CFA';

  /// Check if listing is still active (hasn't passed leaving date)
  bool get isActive => DateTime.now().isBefore(leavingByDate);

  /// Create a copy with modified fields
  KDListing copyWith({
    String? id,
    int? rentPrice,
    String? town,
    String? streetName,
    DateTime? leavingByDate,
    List<String>? imagePaths,
    bool? waterAvailable,
    ElectricityType? electricityType,
    KitchenType? kitchenType,
    String? generalDescription,
    DateTime? createdAt,
    String? userId,
    bool? hasLiveAd,
  }) {
    return KDListing(
      id: id ?? this.id,
      rentPrice: rentPrice ?? this.rentPrice,
      town: town ?? this.town,
      streetName: streetName ?? this.streetName,
      leavingByDate: leavingByDate ?? this.leavingByDate,
      imagePaths: imagePaths ?? this.imagePaths,
      waterAvailable: waterAvailable ?? this.waterAvailable,
      electricityType: electricityType ?? this.electricityType,
      kitchenType: kitchenType ?? this.kitchenType,
      generalDescription: generalDescription ?? this.generalDescription,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      hasLiveAd: hasLiveAd ?? this.hasLiveAd,
    );
  }

  @override
  String toString() =>
      'KDListing(id: $id, price: $formattedPrice, '
      'town: $town, street: $streetName, leaving: $leavingByDate)';
}

/// Mock data generator for MVP
class KDListingMockData {
  static final List<KDListing> sampleListings = [
    KDListing(
      id: '1',
      type: ListingType.vacancy,
      postedByRole: UserRole.tenant,
      rentPrice: 85000,
      town: 'Douala',
      streetName: 'Pk-18',
      leavingByDate: DateTime.now().add(const Duration(days: 60)),
      imagePaths: ['assets/mock_listing_1.png'],
      waterAvailable: true,
      electricityType: ElectricityType.prepaidMeter,
      kitchenType: KitchenType.internalKitchen,
      generalDescription:
          'Beautiful apartment with modern amenities, close to shopping centers.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      userId: 'user_1',
      hasLiveAd: false,
    ),
    KDListing(
      id: '2',
      type: ListingType.vacancy,
      postedByRole: UserRole.tenant,
      rentPrice: 55000,
      town: 'Bertoua',
      streetName: 'Clerks streetNames',
      leavingByDate: DateTime.now().add(const Duration(days: 45)),
      imagePaths: ['assets/mock_listing_2.png'],
      waterAvailable: true,
      electricityType: ElectricityType.sharedMeter,
      kitchenType: KitchenType.sharedKitchen,
      generalDescription:
          'Neat and clean room, shared kitchen and bathroom,AC,Starlink',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      userId: 'user_2',
      hasLiveAd: false,
    ),
    KDListing(
      id: '3',
      type: ListingType.vacancy,
      postedByRole: UserRole.tenant,
      rentPrice: 125000,
      town: 'Tiko',
      streetName: 'Cow Street',
      leavingByDate: DateTime.now().add(const Duration(days: 90)),
      imagePaths: ['assets/mock_listing_3.png', 'assets/mock_listing_3b.png'],
      waterAvailable: false,
      electricityType: ElectricityType.prepaidMeter,
      kitchenType: KitchenType.internalKitchen,
      generalDescription:
          'Premium apartment with AC, balcony, and secure parking.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      userId: 'user_3',
      hasLiveAd: false,
    ),
    KDListing(
      id: '4',
      type: ListingType.vacancy,
      postedByRole: UserRole.tenant,
      rentPrice: 35000,
      town: 'Bamenda',
      streetName: 'UpStation',
      leavingByDate: DateTime.now().add(const Duration(days: 30)),
      imagePaths: ['assets/mock_listing_4.png'],
      waterAvailable: false,
      electricityType: ElectricityType.sharedMeter,
      kitchenType: KitchenType.sharedKitchen,
      generalDescription: 'Budget-friendly studio, quiet neighborhood.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      userId: 'user_4',
      hasLiveAd: false,
    ),
    KDListing(
      id: '5',
      type: ListingType.vacancy,
      postedByRole: UserRole.tenant,
      rentPrice: 200000,
      town: 'Yaoundé',
      streetName: 'Simbock',
      leavingByDate: DateTime.now().add(const Duration(days: 120)),
      imagePaths: [
        'assets/mock_listing_5.png',
        'assets/mock_listing_5b.png',
        'assets/mock_listing_5c.png',
      ],
      waterAvailable: true,
      electricityType: ElectricityType.sharedMeter,
      kitchenType: KitchenType.sharedKitchen,
      generalDescription: '4 rooms shared accomodation.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      userId: 'user_5',
      hasLiveAd: false,
    ),
    KDListing(
      id: '6',
      type: ListingType.vacancy,
      postedByRole: UserRole.tenant,
      rentPrice: 15000,
      town: 'Yaoundé',
      streetName: 'Effoulan Lac',
      leavingByDate: DateTime.now().add(const Duration(days: 120)),
      imagePaths: [
        'assets/mock_listing_5.png',
        'assets/mock_listing_5b.png',
        'assets/mock_listing_5c.png',
      ],
      waterAvailable: true,
      electricityType: ElectricityType.prepaidMeter,
      kitchenType: KitchenType.internalKitchen,
      generalDescription:
          'Luxury 4-bedroom with all amenities, golf course views.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      userId: 'user_6',
      hasLiveAd: false,
    ),
    KDListing(
      id: '7',
      type: ListingType.roommate,
      postedByRole: UserRole.landlord,
      town: 'Douala',
      streetName: 'Bonamoussadi',
      leavingByDate: DateTime.now().add(const Duration(days: 90)),
      imagePaths: ['assets/roommate_2.jpg'],
      waterAvailable: true,
      electricityType: ElectricityType.prepaidMeter,
      kitchenType: KitchenType.internalKitchen,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      expiresAt: DateTime.now().add(const Duration(days: 58)),
      generalDescription:
          'Large room in 2-bed apartment. Own balcony, built-in wardrobe. Prepaid meter, fiber internet. Working professionals only.',
      rentPrice: 200000,
      shareAmount: 100000,
      genderPreference: 'Open to All',
      targetAgeRanges: ['20s', '30s', '40s'],
      lifestyleTags: ['No Smoking', 'No Pets'],
      expectedDuration: 'Flexible/Negotiable',
      userId: 'user_7',
    ),

    KDListing(
      id: '8',
      type: ListingType.roommate,
      postedByRole: UserRole.tenant,
      town: 'Yaoundé',
      streetName: 'Bastos',
      leavingByDate: DateTime.now().add(const Duration(days: 90)),
      imagePaths: ['assets/roommate_3.jpg'],
      waterAvailable: true,
      electricityType: ElectricityType.prepaidMeter,
      kitchenType: KitchenType.internalKitchen,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      expiresAt: DateTime.now().add(const Duration(days: 59)),
      generalDescription:
          'Spacious room in villa. Pool access, generator, housekeeper. Share with 1 other professional. All bills included in share.',
      rentPrice: 400000,
      shareAmount: 200000,
      genderPreference: 'Males Only',
      targetAgeRanges: ['30s', '40s', '50+'],
      lifestyleTags: ['Quiet Space'],
      expectedDuration: 'Long term: 1 year+',
      userId: 'user_8',
    ),

    KDListing(
      id: '9',
      type: ListingType.roommate,
      postedByRole: UserRole.tenant,
      town: 'Bafoussam',
      streetName: 'Djeleng',
      leavingByDate: DateTime.now().add(const Duration(days: 90)),
      imagePaths: ['assets/roommate_4.jpg'],
      waterAvailable: true,
      electricityType: ElectricityType.prepaidMeter,
      kitchenType: KitchenType.internalKitchen,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      expiresAt: DateTime.now().add(const Duration(days: 59)),
      generalDescription:
          'Room in family house, separate entrance. Kitchen access, water tank. Quiet area near market.',
      rentPrice: 80000,
      shareAmount: 40000,
      genderPreference: 'Females Only',
      targetAgeRanges: ['20s', '30s'],
      lifestyleTags: ['No Smoking', 'no tiff man'],
      expectedDuration: 'Medium term: 6 months',
      userId: 'user_9',
    ),

    KDListing(
      id: '10',
      type: ListingType.roommate,
      postedByRole: UserRole.tenant,
      town: 'Limbé',
      streetName: 'Mile 4',
      leavingByDate: DateTime.now().add(const Duration(days: 90)),
      imagePaths: ['assets/roommate_5.jpg'],
      waterAvailable: true,
      electricityType: ElectricityType.prepaidMeter,
      kitchenType: KitchenType.internalKitchen,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      expiresAt: DateTime.now().add(const Duration(days: 59)),
      generalDescription:
          'Beachside apartment, 2 rooms available. Modern furnishing, AC, high-speed internet. Digital nomad friendly.',
      rentPrice: 250000,
      shareAmount: 125000,
      genderPreference: 'Open to All',
      targetAgeRanges: ['20s', '30s'],
      lifestyleTags: ['No Smoking', 'Quiet Space'],
      expectedDuration: 'Short term: 1-3 months',
      userId: 'user_10',
    ),

    KDListing(
      id: '11',
      type: ListingType.roommate,
      postedByRole: UserRole.tenant,
      town: 'Ngaoundéré',
      streetName: 'Ngong',
      leavingByDate: DateTime.now().add(const Duration(days: 90)),
      imagePaths: ['assets/roommate_6.jpg'],
      waterAvailable: true,
      electricityType: ElectricityType.prepaidMeter,
      kitchenType: KitchenType.internalKitchen,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      expiresAt: DateTime.now().add(const Duration(days: 55)),
      generalDescription:
          'Room in shared house near university. Separate meter for electricity. Water from borehole. Quiet, studious environment.',
      rentPrice: 60000,
      shareAmount: 30000,
      genderPreference: 'Females Only',
      targetAgeRanges: ['<20', '20s'],
      lifestyleTags: ['No Smoking', 'No Pets', 'Quiet Space', 'No Nye man'],
      expectedDuration: 'Long term: 1 year+',
      userId: 'user_11',
    ),

    KDListing(
      id: '12',
      type: ListingType.roommate,
      postedByRole: UserRole.tenant,
      town: 'Kumba',
      streetName: 'Fiango',
      leavingByDate: DateTime.now().add(const Duration(days: 90)),
      imagePaths: ['assets/roommate_7.jpg'],
      waterAvailable: true,
      electricityType: ElectricityType.prepaidMeter,
      kitchenType: KitchenType.internalKitchen,
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      expiresAt: DateTime.now().add(const Duration(days: 58)),
      generalDescription:
          'Master bedroom with ensuite in 3-bed flat. Shared living/kitchen. Prepaid meter. Prefer female professional.',
      rentPrice: 150000,
      shareAmount: 75000,
      genderPreference: 'Females Only',
      targetAgeRanges: ['20s', '30s'],
      lifestyleTags: ['No Smoking'],
      expectedDuration: 'Flexible/Negotiable',
      userId: 'user_12',
    ),

    KDListing(
      id: '13',
      type: ListingType.roommate,
      postedByRole: UserRole.tenant,
      town: 'Bamenda',
      streetName: 'Mile 3 Nkwen',
      leavingByDate: DateTime.now().add(const Duration(days: 90)),
      imagePaths: ['assets/roommate_8.jpg'],
      waterAvailable: true,
      electricityType: ElectricityType.prepaidMeter,
      kitchenType: KitchenType.internalKitchen,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      expiresAt: DateTime.now().add(const Duration(days: 58)),
      generalDescription:
          'Room in quiet compound. Shared kitchen and toilet. Water available. Walking distance to main road.',
      rentPrice: 50000,
      shareAmount: 25000,
      genderPreference: 'Open to All',
      targetAgeRanges: ['20s', '30s'],
      lifestyleTags: ['Quiet Space'],
      expectedDuration: 'Medium term: 6 months',
      userId: 'user_13',
    ),

    KDListing(
      id: '14',
      type: ListingType.roommate,
      postedByRole: UserRole.tenant,
      town: 'Foumban',
      streetName: 'Njimom',
      leavingByDate: DateTime.now().add(const Duration(days: 90)),
      imagePaths: ['assets/roommate_9.jpg'],
      waterAvailable: true,
      electricityType: ElectricityType.sharedMeter,
      kitchenType: KitchenType.sharedKitchen,
      createdAt: DateTime.now().subtract(const Duration(hours: 30)),
      expiresAt: DateTime.now().add(const Duration(days: 57)),
      generalDescription:
          'Furnished room in sultanate area. Shared compound with owner family. Very cultural, peaceful. Meals negotiable.',
      rentPrice: 70000,
      shareAmount: 35000,
      genderPreference: 'Males Only',
      targetAgeRanges: ['20s', '30s', '40s'],
      lifestyleTags: ['No Smoking', 'No Pets'],
      expectedDuration: 'Long term: 1 year+',
      userId: 'user_14',
    ),

    KDListing(
      id: '15',
      type: ListingType.roommate,
      postedByRole: UserRole.tenant,
      town: 'Garoua',
      streetName: 'Lamido',
      leavingByDate: DateTime.now().add(const Duration(days: 90)),
      imagePaths: ['assets/roommate_10.jpg'],
      waterAvailable: true,
      electricityType: ElectricityType.prepaidMeter,
      kitchenType: KitchenType.internalKitchen,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      expiresAt: DateTime.now().add(const Duration(days: 57)),
      generalDescription:
          'Air-conditioned room in modern apartment./ Shared with 1 other tenant./ Generator,/ water tank,/ fiber. Professional only.',
      rentPrice: 180000,
      shareAmount: 90000,
      genderPreference: 'Open to All',
      targetAgeRanges: ['20s', '30s', '40s'],
      lifestyleTags: ['No Smoking', 'Quiet Space'],
      expectedDuration: 'Long term: 1 year+',
      userId: 'user_15',
    ),
  ];

  /// Filter listings by criteria
  static List<KDListing> filterListings({
    required List<KDListing> listings,
    String? town,
    int? maxBudget,
    int? minBedrooms,
  }) {
    return listings.where((listing) {
      // Filter by town
      if (town != null && town.isNotEmpty && listing.town != town) {
        return false;
      }

      // Filter by max budget
      if (maxBudget != null && listing.rentPrice > maxBudget) {
        return false;
      }
      //check this next code later for the other version loosing the listing fnn
      //if (minBedrooms != null) {
      //       if ((listing.bedroomCount ?? 0) < minBedrooms) return false;
      //  }

      // Filter by minimum bedrooms (estimate from title)
      if (minBedrooms != null) {
        // Simple extraction: "2-Bedroom", "3-Bedroom", etc.
        final match = RegExp(
          r'(\d+)-[Bb]edroom',
        ).firstMatch(listing.generalDescription);
        if (match != null) {
          final bedroomCount = int.tryParse(match.group(1) ?? '0') ?? 0;
          if (bedroomCount < minBedrooms) {
            return false;
          }
        } else {
          // If no bedroom count found, exclude (assuming it's a studio)
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Get unique towns from all listings
  static List<String> getAllUniqueTowns(List<KDListing> listings) {
    final towns = <String>{};
    for (var listing in listings) {
      towns.add(listing.town);
    }
    return towns.toList()..sort();
  }
}
