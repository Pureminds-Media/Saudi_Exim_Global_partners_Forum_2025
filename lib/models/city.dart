class City {
  final int id;
  final String nameAr;
  final String nameEn;
  final String? photoUrl;
  final String? desAr;
  final String? desEn;

  const City({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.photoUrl,
    this.desAr,
    this.desEn,
  });
}
