import '../utils/platform_helper.dart';

class Service {
  final String id; // NEW
  final String categoryId; // NEW – ties to ServiceCategory.id
  final String name;
  final String subtitle; // Short tagline shown on cards
  final String description; // Longer body text
  // Optional localized variants; used to render based on locale when provided
  final String? nameAr;
  final String? nameEn;
  final String? subtitleAr;
  final String? subtitleEn;
  final String? descriptionAr;
  final String? descriptionEn;

  /// Full-size photo URL for details page (backend: photo_url)
  final String? photoUrl;
  final String image; // Asset or network path to logo
  final bool emphasized; // Whether to highlight the card
  final String city; // e.g., 'كل السعودية' | 'الرياض' | ...

  /// Cuisine classification for food services only (e.g., 'آسيوي').
  final String? foodType;

  final String? website;
  final String? androidDownloadUrl;
  final String? iosDownloadUrl;
  final String? mapLatLng; // "lat,lng"
  final String? mapLink; // direct Google Maps link
  final String? cityAr; // Arabic city name (from backend)
  final String? cityEn; // English city name (from backend)

  const Service({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.image,
    this.emphasized = false,
    required this.city,
    this.foodType,
    this.website,
    this.androidDownloadUrl,
    this.iosDownloadUrl,
    this.mapLatLng,
    this.mapLink,
    this.cityAr,
    this.cityEn,
    this.nameAr,
    this.nameEn,
    this.subtitleAr,
    this.subtitleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.photoUrl,
  });

  factory Service.fromMap(Map<String, dynamic> map) => Service(
    id: map['id'] as String,
    categoryId: map['categoryId'] as String,
    name: map['name'] as String,
    subtitle: map['subtitle'] as String? ?? '',
    description: map['description'] as String,
    image: map['image'] as String? ?? '',
    emphasized: (map['emphasized'] as int? ?? 0) == 1,
    city: map['city'] as String,
    foodType: map['foodType'] as String?,
    website: map['website'] as String?,
    androidDownloadUrl: map['appDownloadUrlAndroid'] as String?,
    iosDownloadUrl: map['appDownloadUrlIos'] as String?,
    mapLatLng: map['mapLatLng'] as String?,
    mapLink: map['mapLink'] as String?,
    cityAr: map['cityAr'] as String?,
    cityEn: map['cityEn'] as String?,
    nameAr: map['nameAr'] as String?,
    nameEn: map['nameEn'] as String?,
    subtitleAr: map['subtitleAr'] as String?,
    subtitleEn: map['subtitleEn'] as String?,
    descriptionAr: map['descriptionAr'] as String?,
    descriptionEn: map['descriptionEn'] as String?,
    photoUrl: map['photoUrl'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryId': categoryId,
    'name': name,
    'subtitle': subtitle,
    'description': description,
    'image': image,
    'emphasized': emphasized ? 1 : 0,
    'city': city,
    'foodType': foodType,
    'website': website,
    'appDownloadUrlAndroid': androidDownloadUrl,
    'appDownloadUrlIos': iosDownloadUrl,
    'mapLatLng': mapLatLng,
    'mapLink': mapLink,
    'cityAr': cityAr,
    'cityEn': cityEn,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'subtitleAr': subtitleAr,
    'subtitleEn': subtitleEn,
    'descriptionAr': descriptionAr,
    'descriptionEn': descriptionEn,
    'photoUrl': photoUrl,
  };

  /// Platform-aware download URL getter.
  ///
  /// On iOS and Android this only returns the store URL for the current
  /// platform to avoid cross-store references. Other platforms fall back to
  /// whichever link is available.
  String? get appDownloadUrl {
    if (PlatformHelper.isIOS) {
      return iosDownloadUrl;
    }
    if (PlatformHelper.isAndroid) {
      return androidDownloadUrl;
    }
    return iosDownloadUrl ?? androidDownloadUrl;
  }
}
