class ServiceCategory {
  final String id; // NEW: stable id for routing
  final String label;
  final String subtitle;
  final String? labelAr;
  final String? labelEn;
  final String? subtitleAr;
  final String? subtitleEn;
  final String icon;
  final String? iconUrl; // network icon url from backend (photo_url)
  final bool hasLocationFilter;
  final List<String> cities;

  const ServiceCategory({
    required this.id,
    required this.label,
    required this.subtitle,
    this.labelAr,
    this.labelEn,
    this.subtitleAr,
    this.subtitleEn,
    this.icon = '',
    this.iconUrl,
    this.hasLocationFilter = true,
    this.cities = const [],
  });

  factory ServiceCategory.fromMap(Map<String, dynamic> map) {
    final citiesString = map['cities'] as String? ?? '';
    return ServiceCategory(
      id: map['id'] as String,
      label: map['label'] as String,
      subtitle: map['subtitle'] as String? ?? '',
      labelAr: map['labelAr'] as String?,
      labelEn: map['labelEn'] as String?,
      subtitleAr: map['subtitleAr'] as String?,
      subtitleEn: map['subtitleEn'] as String?,
      icon: (map['icon'] as String?) ?? '',
      iconUrl: map['iconUrl'] as String?,
      hasLocationFilter: (map['hasLocationFilter'] as int) == 1,
      cities: citiesString.isEmpty ? [] : citiesString.split(','),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'subtitle': subtitle,
    'labelAr': labelAr,
    'labelEn': labelEn,
    'subtitleAr': subtitleAr,
    'subtitleEn': subtitleEn,
    'icon': icon,
    'iconUrl': iconUrl,
    'hasLocationFilter': hasLocationFilter ? 1 : 0,
    'cities': cities.join(','),
  };
}
