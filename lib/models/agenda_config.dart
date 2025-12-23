class AgendaFixedItem {
  final String start;
  final String end;
  final String titleEn;
  final String titleAr;
  final String? descEn;
  final String? descAr;

  const AgendaFixedItem({
    required this.start,
    required this.end,
    required this.titleEn,
    required this.titleAr,
    this.descEn,
    this.descAr,
  });
}

/// Parsed agenda configuration containing localized day titles and
/// fixed (non-session) items per day.
class AgendaConfig {
  final Map<int, String> dayTitleEn;
  final Map<int, String> dayTitleAr;
  final Map<int, List<AgendaFixedItem>> fixedByDay;

  const AgendaConfig({
    required this.dayTitleEn,
    required this.dayTitleAr,
    required this.fixedByDay,
  });

  static AgendaConfig empty() => const AgendaConfig(
        dayTitleEn: {},
        dayTitleAr: {},
        fixedByDay: {},
      );
}

