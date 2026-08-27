/// KD Listing Model /// Comprehensive data model for lease and short-stay listings
/// Holds all property information including utilities, kitchen type, and images
import 'package:intl/intl.dart';
enum FeedCategory { tenant, roommate, hotel, guesthouse } // Natural language toggles matching your UX
enum ElectricityType { prepaidMeter, sharedMeter }
enum ListingType { vacancy, roommate } // Internal data sorting tracking
enum UserRole { tenant, landlord, shortStayHost } // Differentiates system posting permission access logs
enum ToiletType { internal, shared } enum WaterAvailability { available, notAvailable } enum KitchenType {
hasKitchen, sharedKitchen, internalKitchen, } class KDListing { final String id;
final FeedCategory category; // 1.3 Natural category classifier flag final int rentPrice;
final String town; final String streetName; final List<String> imagePaths;
final bool waterAvailable; final ElectricityType electricityType; final KitchenType kitchenType;
final String generalDescription; final DateTime leavingByDate; final DateTime createdAt;
final DateTime expiresAt; // 1.5 Enforced non-nullable required expiration value block
final DateTime? reconfirmedAt; final String userId; final bool hasLiveAd;
final int bedroomCount; // 1.2 Strict explicit parameter value for feed grids final ListingType type;
final UserRole postedByRole; final WaterAvailability water; final ElectricityType electricity;
final KitchenType kitchen; final ToiletType toilet; // 1.4 ANTI-FRAUD TRACKING GEOMETRY
final double latitude; final double longitude; // SHORT-STAY & APPRAISAL SPECIFIC PARAMETERS
final int? shareAmount; final String? genderPreference; final List<String> targetAgeRanges;
final List<String> lifestyleTags; final String? expectedDuration; final bool isBoosted;
final DateTime? boostedUntil; final bool isOwnerVerified; const KDListing({ required this.id,
required this.category, required this.rentPrice, required this.town,
required this.streetName, required this.leavingByDate, required this.imagePaths,
required this.waterAvailable, required this.electricityType, required this.kitchenType,
required this.generalDescription, required this.createdAt, required this.expiresAt,
required this.userId, required this.bedroomCount, required this.latitude,
required this.longitude, this.hasLiveAd = false, this.reconfirmedAt,
this.type = ListingType.vacancy, this.postedByRole = UserRole.tenant,
this.water = WaterAvailability.available, this.electricity = ElectricityType.prepaidMeter,
this.kitchen = KitchenType.internalKitchen, this.toilet = ToiletType.internal, this.shareAmount,
this.genderPreference, this.targetAgeRanges = const [], this.lifestyleTags = const [],
this.expectedDuration, this.isBoosted = false, this.boostedUntil,
this.isOwnerVerified = false, }) : assert(imagePaths.length <= 3, 'Maximum 3 images allowed'); // Enfo
rces your strict photo cap asset limit String get freshnessLabel {
final diff = DateTime.now().difference(createdAt); if (diff.inMinutes < 60) return 'Just now';
if (diff.inHours < 24) return 'Today'; if (diff.inDays < 7) return 'This week';
return 'Recently'; } bool get isExpired => DateTime.now().isAfter(expiresAt);
bool get needsReconfirmation => isExpired && reconfirmedAt == null;
/// CLEAN CURRENCY FORMATTING (INTL INJECTION)
/// Outputs raw digits to beautiful thousands-separated pricing targets (e.g. 75,000 CFA)
String get formattedPrice => '${NumberFormat.decimalPattern('en_US').format(rentPrice)} CFA';
String get formattedShareAmount => shareAmount != null
? '${NumberFormat.decimalPattern('en_US').format(shareAmount)} CFA' : '0 CFA';
bool get isActive => DateTime.now().isBefore(leavingByDate) && !isExpired; KDListing copyWith({
String? id, FeedCategory? category, int? rentPrice, String? town, String? streetName,
DateTime? leavingByDate, List<String>? imagePaths, bool? waterAvailable,
ElectricityType? electricityType, KitchenType? kitchenType, String? generalDescription,
DateTime? createdAt, DateTime? expiresAt, String? userId, bool? hasLiveAd,
int? bedroomCount, }) { return KDListing( id: id ?? this.id,
category: category ?? this.category, rentPrice: rentPrice ?? this.rentPrice,
town: town ?? this.town, streetName: streetName ?? this.streetName,
leavingByDate: leavingByDate ?? this.leavingByDate, imagePaths: imagePaths ?? this.imagePaths,
waterAvailable: waterAvailable ?? this.waterAvailable,
electricityType: electricityType ?? this.electricityType,
kitchenType: kitchenType ?? this.kitchenType,
generalDescription: generalDescription ?? this.generalDescription,
createdAt: createdAt ?? this.createdAt, expiresAt: expiresAt ?? this.expiresAt,
userId: userId ?? this.userId, hasLiveAd: hasLiveAd ?? this.hasLiveAd,
bedroomCount: bedroomCount ?? this.bedroomCount, latitude: this.latitude,
longitude: this.longitude, reconfirmedAt: this.reconfirmedAt, type: this.type,
postedByRole: this.postedByRole, water: this.water, electricity: this.electricity,
kitchen: this.kitchen, toilet: this.toilet, shareAmount: this.shareAmount,
genderPreference: this.genderPreference, targetAgeRanges: this.targetAgeRanges,
lifestyleTags: this.lifestyleTags, expectedDuration: this.expectedDuration,
isBoosted: this.isBoosted, boostedUntil: this.boostedUntil,
isOwnerVerified: this.isOwnerVerified, ); } @override String toString() =>
'KDListing(id: $id, price: $formattedPrice, town: $town, bedrooms: $bedroomCount)'; }
class KDListingMockData { static final List<KDListing> sampleListings = [ // nnn LEGACY LEASES nnn
KDListing( id: '1', category: FeedCategory.tenant, rentPrice: 85000,
town: 'Douala', streetName: 'Pk-18',
leavingByDate: DateTime.now().add(const Duration(days: 60)),
imagePaths: const ['assets/mock_listing_1.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.internalKitchen,
generalDescription: 'Beautiful apartment with modern amenities, close to shopping centers.',
createdAt: DateTime.now().subtract(const Duration(days: 5)),
expiresAt: DateTime.now().add(const Duration(days: 25)), userId: 'user_1',
bedroomCount: 2, latitude: 4.0612, longitude: 9.7823, hasLiveAd: true, ),
KDListing( id: '2', category: FeedCategory.tenant, rentPrice: 55000,
town: 'Bertoua', streetName: 'Clerks Street',
leavingByDate: DateTime.now().add(const Duration(days: 45)),
imagePaths: const ['assets/mock_listing_2.png'], waterAvailable: true,
electricityType: ElectricityType.sharedMeter, kitchenType: KitchenType.sharedKitchen,
generalDescription: 'Neat and clean room, shared kitchen and bathroom, AC, Starlink.',
createdAt: DateTime.now().subtract(const Duration(days: 2)),
expiresAt: DateTime.now().add(const Duration(days: 28)), userId: 'user_2',
bedroomCount: 1, latitude: 4.5771, longitude: 13.6845, hasLiveAd: true, ),
KDListing( id: '3', category: FeedCategory.tenant, rentPrice: 125000,
town: 'Tiko', streetName: 'Cow Street',
leavingByDate: DateTime.now().add(const Duration(days: 90)),
imagePaths: const ['assets/mock_listing_3.png', 'assets/mock_listing_3b.png'],
waterAvailable: false, electricityType: ElectricityType.prepaidMeter,
kitchenType: KitchenType.internalKitchen,
generalDescription: 'Premium apartment with AC, balcony, and secure parking.',
createdAt: DateTime.now().subtract(const Duration(days: 7)),
expiresAt: DateTime.now().add(const Duration(days: 23)), userId: 'user_3',
bedroomCount: 3, latitude: 4.0752, longitude: 9.3601, hasLiveAd: true, ),
KDListing( id: '4', category: FeedCategory.tenant, rentPrice: 35000,
town: 'Bamenda', streetName: 'UpStation',
leavingByDate: DateTime.now().add(const Duration(days: 30)),
imagePaths: const ['assets/mock_listing_4.png'], waterAvailable: false,
electricityType: ElectricityType.sharedMeter, kitchenType: KitchenType.sharedKitchen,
generalDescription: 'Budget-friendly studio, quiet neighborhood.',
createdAt: DateTime.now().subtract(const Duration(days: 10)),
expiresAt: DateTime.now().add(const Duration(days: 20)), userId: 'user_4',
bedroomCount: 1, latitude: 5.9614, longitude: 10.1512, hasLiveAd: true, ),
KDListing( id: '5', category: FeedCategory.tenant, rentPrice: 200000,
town: 'Yaoundé', streetName: 'Simbock',
leavingByDate: DateTime.now().add(const Duration(days: 120)),
imagePaths: const ['assets/mock_listing_5.png'], waterAvailable: true,
electricityType: ElectricityType.sharedMeter, kitchenType: KitchenType.sharedKitchen,
generalDescription: '4 rooms shared accommodation space blocks.',
createdAt: DateTime.now().subtract(const Duration(days: 1)),
expiresAt: DateTime.now().add(const Duration(days: 29)), userId: 'user_5',
bedroomCount: 4, latitude: 3.8214, longitude: 11.4823, hasLiveAd: true, ),
KDListing( id: '6', category: FeedCategory.tenant, rentPrice: 150000,
town: 'Yaoundé', streetName: 'Effoulan Lac',
leavingByDate: DateTime.now().add(const Duration(days: 120)),
imagePaths: const ['assets/mock_listing_5.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.internalKitchen,
generalDescription: 'Luxury 4-bedroom with all amenities, golf course views.',
createdAt: DateTime.now().subtract(const Duration(days: 1)),
expiresAt: DateTime.now().add(const Duration(days: 29)), userId: 'user_6',
bedroomCount: 4, latitude: 3.8322, longitude: 11.4911, hasLiveAd: true, ),
// nnn ACTIVE ROOMMATES nnn KDListing( id: '7', category: FeedCategory.roommate,
type: ListingType.roommate, postedByRole: UserRole.tenant, town: 'Douala',
streetName: 'Bonamoussadi', leavingByDate: DateTime.now().add(const Duration(days: 90)),
imagePaths: const ['assets/roommate_2.jpg'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.internalKitchen,
createdAt: DateTime.now().subtract(const Duration(days: 2)),
expiresAt: DateTime.now().add(const Duration(days: 58)), generalDescription: 'Large room in 2-be
d apartment. Own balcony, built-in wardrobe. Prepaid meter, fiber internet.', rentPrice: 200000,
shareAmount: 100000, userId: 'user_7', bedroomCount: 2, latitude: 4.0911,
longitude: 9.7544, hasLiveAd: true, ), KDListing( id: '8',
category: FeedCategory.roommate, type: ListingType.roommate,
postedByRole: UserRole.tenant, town: 'Yaoundé', streetName: 'Bastos',
leavingByDate: DateTime.now().add(const Duration(days: 90)),
imagePaths: const ['assets/roommate_3.jpg'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.internalKitchen,
createdAt: DateTime.now().subtract(const Duration(hours: 6)),
expiresAt: DateTime.now().add(const Duration(days: 59)), generalDescription: 'Spacious room in v
illa. Pool access, generator, housekeeper. Share with 1 other professional.', rentPrice: 400000,
shareAmount: 200000, userId: 'user_8', bedroomCount: 3, latitude: 3.8892,
longitude: 11.5164, hasLiveAd: true, ), // nnn 14 NEW SHORT-STAY ENTRIES nnn
// HOTELS KDListing( id: 'h1', category: FeedCategory.hotel,
postedByRole: UserRole.shortStayHost, rentPrice: 25000, town: 'Yaoundé',
streetName: 'Bastos Hi-Line', leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/hotel_1.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.hasKitchen, genera
lDescription: 'Luxury single suites with premium bedding, AC, 24/7 power fallback generator, smart TV.',
createdAt: DateTime.now().subtract(const Duration(hours: 4)),
expiresAt: DateTime.now().add(const Duration(days: 90)), userId: 'host_hotel_1',
bedroomCount: 1, latitude: 3.8911, longitude: 11.5122, hasLiveAd: true, ),
KDListing( id: 'h2', category: FeedCategory.hotel,
postedByRole: UserRole.shortStayHost, rentPrice: 35000, town: 'Douala',
streetName: 'Akwa Boulevard', leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/hotel_2.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.sharedKitchen, gen
eralDescription: 'Executive double rooms located in the heart of commercial town center. Wifi included.',
createdAt: DateTime.now().subtract(const Duration(days: 1)),
expiresAt: DateTime.now().add(const Duration(days: 89)), userId: 'host_hotel_2',
bedroomCount: 1, latitude: 4.0501, longitude: 9.7094, hasLiveAd: true, ),
KDListing( id: 'h3', category: FeedCategory.hotel,
postedByRole: UserRole.shortStayHost, rentPrice: 45000, town: 'Kribi',
streetName: 'Plage Ngoye', leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/hotel_3.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.internalKitchen, g
eneralDescription: 'Oceanfront suite with panoramic glass balcony view, breakfast services included.',
createdAt: DateTime.now().subtract(const Duration(hours: 12)),
expiresAt: DateTime.now().add(const Duration(days: 90)), userId: 'host_hotel_3',
bedroomCount: 2, latitude: 2.9394, longitude: 9.9081, hasLiveAd: true,
isBoosted: true, ), KDListing( id: 'h4', category: FeedCategory.hotel,
postedByRole: UserRole.shortStayHost, rentPrice: 20000, town: 'Limbé',
streetName: 'Down Beach Road', leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/hotel_4.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.sharedKitchen, gen
eralDescription: 'Cozy coastal hotel room setup with modern shower fixtures, secure parking garage grids.',
createdAt: DateTime.now().subtract(const Duration(days: 3)),
expiresAt: DateTime.now().add(const Duration(days: 87)), userId: 'host_hotel_4',
bedroomCount: 1, latitude: 4.0121, longitude: 9.2144, hasLiveAd: true, ),
KDListing( id: 'h5', category: FeedCategory.hotel,
postedByRole: UserRole.shortStayHost, rentPrice: 30000, town: 'Buéa',
streetName: 'Molyko Hi-way', leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/hotel_5.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.hasKitchen, genera
lDescription: 'Mountain-view corporate executive suite equipped with desk workspace and high speed fiber.',
createdAt: DateTime.now().subtract(const Duration(hours: 22)),
expiresAt: DateTime.now().add(const Duration(days: 90)), userId: 'host_hotel_5',
bedroomCount: 1, latitude: 4.1564, longitude: 9.2811, hasLiveAd: true, ),
KDListing( id: 'h6', category: FeedCategory.hotel,
postedByRole: UserRole.shortStayHost, rentPrice: 18000, town: 'Bafoussam',
streetName: 'Tamdja Square', leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/hotel_6.png'], waterAvailable: true,
electricityType: ElectricityType.sharedMeter, kitchenType: KitchenType.sharedKitchen,
generalDescription: 'Budget-friendly clean hotel lodging, hot water heater systems operational.',
createdAt: DateTime.now().subtract(const Duration(days: 4)),
expiresAt: DateTime.now().add(const Duration(days: 86)), userId: 'host_hotel_6',
bedroomCount: 1, latitude: 5.4764, longitude: 10.4211, hasLiveAd: true, ),
KDListing( id: 'h7', category: FeedCategory.hotel,
postedByRole: UserRole.shortStayHost, rentPrice: 50000, town: 'Yaoundé',
streetName: 'Golf Course Lane', leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/hotel_7.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.internalKitchen,
generalDescription: 'VIP presidential double room suite with private security monitoring frameworks.',
createdAt: DateTime.now().subtract(const Duration(hours: 2)),
expiresAt: DateTime.now().add(const Duration(days: 90)), userId: 'host_hotel_7',
bedroomCount: 2, latitude: 3.8744, longitude: 11.5012, hasLiveAd: true, ),
// GUEST HOUSES KDListing( id: 'g1', category: FeedCategory.guesthouse,
postedByRole: UserRole.shortStayHost, rentPrice: 40000, town: 'Yaoundé',
streetName: 'Omnisport Lane', leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/guest_1.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.internalKitchen, g
eneralDescription: 'Fully furnished apartment studio Airbnb. Modern decoration, secure entrance gates.',
createdAt: DateTime.now().subtract(const Duration(hours: 8)),
expiresAt: DateTime.now().add(const Duration(days: 90)), userId: 'host_guest_1',
bedroomCount: 1, latitude: 3.8812, longitude: 11.5344, hasLiveAd: true, ),
KDListing( id: 'g2', category: FeedCategory.guesthouse,
postedByRole: UserRole.shortStayHost, rentPrice: 60000, town: 'Douala',
streetName: 'Bonapriso Avenue', leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/guest_2.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.internalKitchen, g
eneralDescription: 'Premium spacious 2-bedroom corporate residence block. Hot water systems + gym room acces
s.', createdAt: DateTime.now().subtract(const Duration(days: 1)),
expiresAt: DateTime.now().add(const Duration(days: 89)), userId: 'host_guest_2',
bedroomCount: 2, latitude: 4.0288, longitude: 9.6912, hasLiveAd: true,
isBoosted: true, ), KDListing( id: 'g3', category: FeedCategory.guesthouse,
postedByRole: UserRole.shortStayHost, rentPrice: 35000, town: 'Kribi',
streetName: 'Boulevard des Chutes',
leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/guest_3.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.internalKitchen, g
eneralDescription: 'Quiet holiday guesthouse chalet with standalone outdoor kitchen patio array panels.',
createdAt: DateTime.now().subtract(const Duration(hours: 18)),
expiresAt: DateTime.now().add(const Duration(days: 90)), userId: 'host_guest_3',
bedroomCount: 1, latitude: 2.9411, longitude: 9.9122, hasLiveAd: true, ),
KDListing( id: 'g4', category: FeedCategory.guesthouse,
postedByRole: UserRole.shortStayHost, rentPrice: 30000, town: 'Limbé',
streetName: 'Bota Island View', leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/guest_4.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.internalKitchen,
generalDescription: 'Furnished vacation rental, high security compound wall grid structure.',
createdAt: DateTime.now().subtract(const Duration(days: 2)),
expiresAt: DateTime.now().add(const Duration(days: 58)), userId: 'host_guest_4',
bedroomCount: 1, latitude: 4.0044, longitude: 9.1894, hasLiveAd: true, ),
KDListing( id: 'g5', category: FeedCategory.guesthouse,
postedByRole: UserRole.shortStayHost, rentPrice: 28000, town: 'Buéa',
streetName: 'GRA Residential', leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/guest_5.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.internalKitchen, g
eneralDescription: 'Charming mountain side guest cottage setup, absolute serenity, standalone borehole water
.', createdAt: DateTime.now().subtract(const Duration(hours: 15)),
expiresAt: DateTime.now().add(const Duration(days: 90)), userId: 'host_guest_5',
bedroomCount: 2, latitude: 4.1611, longitude: 9.2433, hasLiveAd: true, ),
KDListing( id: 'g6', category: FeedCategory.guesthouse,
postedByRole: UserRole.shortStayHost, rentPrice: 22000, town: 'Bafoussam',
streetName: 'Djeleng Heights', leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/guest_6.png'], waterAvailable: true,
electricityType: ElectricityType.sharedMeter, kitchenType: KitchenType.internalKitchen, ge
neralDescription: 'Secure modern furnished studio unit perfect for digital nomads visiting center market hub
s.', createdAt: DateTime.now().subtract(const Duration(days: 5)),
expiresAt: DateTime.now().add(const Duration(days: 85)), userId: 'host_guest_6',
bedroomCount: 1, latitude: 5.4811, longitude: 10.4144, hasLiveAd: true, ),
KDListing( id: 'g7', category: FeedCategory.guesthouse,
postedByRole: UserRole.shortStayHost, rentPrice: 55000, town: 'Douala',
streetName: 'Denver Heights', leavingByDate: DateTime.now().add(const Duration(days: 365)),
imagePaths: const ['assets/guest_7.png'], waterAvailable: true,
electricityType: ElectricityType.prepaidMeter, kitchenType: KitchenType.internalKitchen,
generalDescription: 'Luxury 3-bedroom spacious apartment Airbnb, interior design fittings completed.',
createdAt: DateTime.now().subtract(const Duration(hours: 1)),
expiresAt: DateTime.now().add(const Duration(days: 90)), userId: 'host_guest_7',
bedroomCount: 3, latitude: 4.0622, longitude: 9.7411, hasLiveAd: true, ), ];
static List<KDListing> filterListings({ required List<KDListing> listings,
required List<FeedCategory> activeCategories, String? town, int? maxBudget,
int? exactRoomCount, }) { final currentMoment = DateTime.now();
return listings.where((listing) { if (currentMoment.isAfter(listing.expiresAt)) return false;
if (activeCategories.isNotEmpty && !activeCategories.contains(listing.category)) {
return false; }
if (town != null && town.isNotEmpty && listing.town != town) return false;
if (maxBudget != null && listing.rentPrice > maxBudget) return false;
if (exactRoomCount != null && listing.bedroomCount != exactRoomCount) return false; return true;
}).toList(); } static List<String> getAllUniqueTowns(List<KDListing> listings) {
final towns = <String>{}; for (var listing in listings) {
if (!DateTime.now().isAfter(listing.expiresAt)) { towns.add(listing.town); } }
return towns.toList()..sort(); } }
