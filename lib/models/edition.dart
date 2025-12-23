/// Data model representing a single forum edition.
class Edition {
  final String title;
  final String date;
  final List<String> descriptionLines;

  /// ✅ Path to the main photo
  final String mainPhoto;

  /// ✅ List of 4 minor photo paths
  final List<String> minorPhotos;

  const Edition({
    required this.title,
    required this.date,
    required this.descriptionLines,
    required this.mainPhoto,
    required this.minorPhotos,
  });
}
