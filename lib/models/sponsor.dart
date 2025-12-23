class Sponsor {
  final int id;
  final String nameEn;
  final String nameAr;
  final String? detailsEn;
  final String? detailsAr;
  final String type;
  final String photoPath;

  const Sponsor({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.detailsEn,
    required this.detailsAr,
    required this.type,
    required this.photoPath,
  });

  factory Sponsor.fromJson(Map<String, dynamic> json) {
    return Sponsor(
      id: json['id'] as int,
      nameEn: (json['name_en'] ?? '').toString(),
      nameAr: (json['name_ar'] ?? '').toString(),
      detailsEn: (json['details_en']?.toString().isEmpty ?? true)
          ? null
          : json['details_en'].toString(),
      detailsAr: (json['details_ar']?.toString().isEmpty ?? true)
          ? null
          : json['details_ar'].toString(),
      type: (json['type'] ?? '').toString(),
      photoPath: (json['photo_path'] ?? '').toString(),
    );
  }
}

