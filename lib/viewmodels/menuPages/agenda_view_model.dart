import 'package:flutter/foundation.dart';
import 'package:saudiexim_mobile_app/models/lecture.dart';
import 'package:saudiexim_mobile_app/models/agenda_config.dart';
import 'package:saudiexim_mobile_app/repositories/agenda_repository.dart';

/// ViewModel backing the Agenda page: sessions-only redesign.
class AgendaViewModel extends ChangeNotifier {
  final AgendaRepository _repo;

  AgendaViewModel({AgendaRepository? repository})
    : _repo = repository ?? AgendaRepository();

  // Loading state
  bool _loading = false;
  String? _error;
  bool get loading => _loading;
  String? get error => _error;

  // Two-day agenda data
  int _selectedDay = 0; // 0 = day one, 1 = day two
  int get selectedDay => _selectedDay;
  void setSelectedDay(int i) {
    if (_selectedDay == i) return;
    _selectedDay = i;
    notifyListeners();
  }

  List<String> _dayKeys = const [];
  List<String> get dayKeys => _dayKeys;

  final Map<String, List<Lecture>> _byDay = {};

  List<Lecture> get day1 =>
      _dayKeys.isNotEmpty ? (_byDay[_dayKeys[0]] ?? const []) : const [];
  List<Lecture> get day2 =>
      _dayKeys.length > 1 ? (_byDay[_dayKeys[1]] ?? const []) : const [];

  /// Optional: provide direct PDF links per day when available.
  final Map<String, String> _pdfLinks = {};
  String? pdfUrlForDayIndex(int index) =>
      (index >= 0 && index < _dayKeys.length)
      ? _pdfLinks[_dayKeys[index]]
      : null;

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Fetch lectures and agenda config in parallel.
      final results = await Future.wait([
        _repo.fetchLectures(),
        _repo
            .fetchAgendaConfig()
            .catchError((_) => AgendaConfig.empty()), // tolerate config failure
      ]);
      final all = results[0] as List<Lecture>;
      final cfg = results[1] as AgendaConfig;
      _applyConfig(cfg);
      _buildDays(all, cfg);
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Localized titles loaded from agenda-config
  String? _day1TitleEn;
  String? _day1TitleAr;
  String? _day2TitleEn;
  String? _day2TitleAr;

  void _applyConfig(AgendaConfig cfg) {
    _day1TitleEn = cfg.dayTitleEn[1];
    _day1TitleAr = cfg.dayTitleAr[1];
    _day2TitleEn = cfg.dayTitleEn[2];
    _day2TitleAr = cfg.dayTitleAr[2];
  }

  /// Returns the localized heading for the given day index (0 or 1),
  /// falling back to null when not available.
  String? titleForDay(int index, {required bool ar}) {
    if (index == 0) return ar ? _day1TitleAr : _day1TitleEn;
    if (index == 1) return ar ? _day2TitleAr : _day2TitleEn;
    return null;
  }

  void _buildDays(List<Lecture> items, AgendaConfig cfg) {
    // Group by date key, then sort by time
    final Map<String, List<Lecture>> grouped = {};
    for (final it in items) {
      if (it.dateKey.isEmpty) continue;
      (grouped[it.dateKey] ??= []).add(it);
    }
    // Sort date keys
    final keys = grouped.keys.toList()..sort();
    // Take first two dates if more are present
    _dayKeys = keys.take(2).toList();
    _byDay.clear();

    for (var i = 0; i < _dayKeys.length; i++) {
      final key = _dayKeys[i];
      final lectures = grouped[key]!
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

      // Merge fixed items from config for Day 1/2 (index 0 -> day 1)
      final dayNumber = i + 1; // 1-based in config
      final fixed = cfg.fixedByDay[dayNumber] ?? const <AgendaFixedItem>[];
      final staticItems = <Lecture>[];
      if (fixed.isNotEmpty) {
        for (final f in fixed) {
          staticItems.add(
            Lecture(
              id: null,
              dateKey: key,
              startTime: f.start,
              endTime: f.end,
              titleEn: f.titleEn,
              titleAr: f.titleAr,
              summaryEn: (f.descEn ?? ''),
              summaryAr: (f.descAr ?? ''),
              topicsEn: const [],
              topicsAr: const [],
              isStatic: true,
            ),
          );
        }
      } else {
        // Fallback to previous defaults if config lacks fixed items
        staticItems.addAll([
          Lecture.static(
            dateKey: key,
            startTime: '08:30',
            endTime: '09:30',
            titleEn: 'Arrival And Registration',
            titleAr: 'التسجيل والاستقبال',
          ),
          Lecture.static(
            dateKey: key,
            startTime: '09:30',
            endTime: '09:35',
            titleEn:
                i == 0 ? 'Welcoming Remarks' : 'Welcoming Remarks and Day One Recap',
            titleAr: i == 0 ? 'كلمة ترحيبية' : 'كلمة ترحيبية ومراجعة اليوم الأول',
          ),
        ]);
      }

      final combined = <Lecture>[...staticItems, ...lectures]
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      _byDay[key] = combined;
    }
  }
}
