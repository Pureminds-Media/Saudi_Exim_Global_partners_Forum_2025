/// Model representing a single lecture/session item in the agenda.
///
/// Notes:
/// - The backend provides `scheduled_at` and `end_time` as full timestamps.
///   We treat them as naive and display the substring HH:mm as-is (no TZ math).
/// - Arabic/English fields exist; UI chooses based on the current locale.
class Lecture {
  final int? id;
  final String dateKey; // YYYY-MM-DD derived from `scheduled_at`
  final String startTime; // HH:mm derived from `scheduled_at`
  final String endTime; // HH:mm derived from `end_time`

  final String titleEn;
  final String titleAr;
  final String summaryEn; // basic_description
  final String summaryAr;
  final List<String> topicsEn; // description split by \n
  final List<String> topicsAr; // description_ar split by \n

  /// Marks items we inject locally (e.g., Arrival/Registration, Welcoming Remarks)
  final bool isStatic;

  const Lecture({
    required this.id,
    required this.dateKey,
    required this.startTime,
    required this.endTime,
    required this.titleEn,
    required this.titleAr,
    required this.summaryEn,
    required this.summaryAr,
    required this.topicsEn,
    required this.topicsAr,
    this.isStatic = false,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    String scheduled = (json['scheduled_at'] ?? '').toString();
    String end = (json['end_time'] ?? '').toString();

    String dateKey = scheduled.length >= 10 ? scheduled.substring(0, 10) : '';
    String startTime = _extractTime(scheduled);
    String endTime = _extractTime(end);

    // Split descriptions into bullet points by new line characters
    List<String> _splitLines(dynamic v) {
      final raw = (v ?? '').toString();
      if (raw.trim().isEmpty) return const [];
      return raw
          .replaceAll('\r\n', '\n')
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return Lecture(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      dateKey: dateKey,
      startTime: startTime,
      endTime: endTime,
      titleEn: (json['title'] ?? '').toString(),
      titleAr: (json['title_ar'] ?? '').toString(),
      summaryEn: (json['basic_description'] ?? '').toString(),
      summaryAr: (json['basic_description_ar'] ?? '').toString(),
      topicsEn: _splitLines(json['description']),
      topicsAr: _splitLines(json['description_ar']),
    );
  }

  /// Build a static agenda entry for a given day.
  factory Lecture.static({
    required String dateKey,
    required String startTime,
    required String endTime,
    required String titleEn,
    required String titleAr,
  }) {
    return Lecture(
      id: null,
      dateKey: dateKey,
      startTime: startTime,
      endTime: endTime,
      titleEn: titleEn,
      titleAr: titleAr,
      summaryEn: '',
      summaryAr: '',
      topicsEn: const [],
      topicsAr: const [],
      isStatic: true,
    );
  }

  static String _extractTime(String iso) {
    // Expecting formats like YYYY-MM-DDTHH:mm:SS(.SSS)Z
    // We display HH:mm as-is to avoid any TZ conversion.
    if (iso.length >= 16) {
      return iso.substring(11, 16);
    }
    return '';
  }
}
