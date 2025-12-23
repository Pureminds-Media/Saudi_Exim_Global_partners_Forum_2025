import 'package:flutter/material.dart';
import '../../models/speaker.dart';
import '../../repositories/speakers_repository.dart';

class SessionGroup {
  final String title;
  final String titleAr;
  final List<Speaker> speakers;

  SessionGroup({
    required this.title,
    required this.titleAr,
    required this.speakers,
  });
}

class SpeakersViewModel extends ChangeNotifier {
  SpeakersViewModel({SpeakersRepository? repository})
      : _repository = repository ?? NetworkSpeakersRepository();

  final SpeakersRepository _repository;

  // Groups by day (date only, UTC) → session groups
  final Map<DateTime, List<SessionGroup>> _groupsByDay = {};
  List<DateTime> _days = const [];

  // UI state
  bool isLoading = false;
  String? error;

  // Selected day: 0 = 2025-11-19, 1 = 2025-11-20
  int _selectedDay = 0;
  int get selectedDay => _selectedDay;
  void setSelectedDay(int dayIndex) {
    if (dayIndex != _selectedDay) {
      _selectedDay = dayIndex;
      notifyListeners();
    }
  }

  // Data accessors
  List<DateTime> get days => _days;
  List<SessionGroup> get currentGroups {
    if (_days.isEmpty || _selectedDay < 0 || _selectedDay >= _days.length) {
      return const [];
    }
    final key = _days[_selectedDay];
    return _groupsByDay[key] ?? const [];
  }

  Future<void> fetchSpeakers() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> sessions = await _repository.fetchSessions();

      _groupsByDay.clear();

      for (final session in sessions) {
        final String? scheduledAt = session['scheduled_at'] as String?;
        if (scheduledAt == null || scheduledAt.length < 10) continue;

        // Robust day detection
        late final DateTime utc;
        try {
          utc = DateTime.parse(scheduledAt).toUtc();
        } catch (_) {
          continue;
        }
        final dateOnly = DateTime.utc(utc.year, utc.month, utc.day);

        // Build session speakers (instructors + moderator), de-duped
        final Map<String, Speaker> sessionSpeakers = {};
        void addOrMerge(Speaker s) {
          final key = (s.id != null) ? 'id:${s.id}' : 'name:${s.name_en}';
          final existing = sessionSpeakers[key];
          if (existing == null) {
            sessionSpeakers[key] = s;
          } else {
            // if either instance is a moderator, keep that info
            sessionSpeakers[key] = existing.copyWith(
              isModerator: existing.isModerator || s.isModerator,
            );
          }
        }

        void addUnique(Speaker s) {
          final key = (s.id != null) ? 'id:${s.id}' : 'name:${s.name_en}';
          sessionSpeakers.putIfAbsent(key, () => s);
        }

        final List instructors = (session['instructors'] as List?) ?? const [];
        for (final ins in instructors) {
          addUnique(Speaker.fromJson(ins as Map<String, dynamic>));
        }

        final mod = session['moderator'];
        if (mod != null) {
          final moderator = Speaker.fromJson(
            mod as Map<String, dynamic>,
          ).copyWith(isModerator: true);
          addOrMerge(moderator);
        }

        final group = SessionGroup(
          title: session['title'] as String? ?? '',
          titleAr: session['title_ar'] as String? ?? '',
          speakers: sessionSpeakers.values.toList(),
        );

        final list = _groupsByDay.putIfAbsent(dateOnly, () => <SessionGroup>[]);
        list.add(group);
      }

      // Sort days ascending and freeze
      final sortedDays = _groupsByDay.keys.toList()
        ..sort((a, b) => a.compareTo(b));
      _days = List.unmodifiable(sortedDays);
    } catch (e) {
      error = e.toString();
      _groupsByDay.clear();
      _days = const [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
