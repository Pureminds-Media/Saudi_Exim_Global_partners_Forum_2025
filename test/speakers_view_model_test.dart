import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/repositories/speakers_repository.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/speakers_view_model.dart';

void main() {
  test('SpeakersViewModel updates selected day', () {
    final vm = SpeakersViewModel();
    expect(vm.selectedDay, 0);
    vm.setSelectedDay(1);
    expect(vm.selectedDay, 1);
    vm.setSelectedDay(0);
    expect(vm.selectedDay, 0);
  });

  test('fetchSpeakers merges static entries with remote sessions', () async {
    final vm = SpeakersViewModel(
      repository: _FakeSpeakersRepository(),
    );

    await vm.fetchSpeakers();

    expect(vm.error, isNull);
    expect(vm.isLoading, isFalse);
    expect(vm.currentGroups.length, greaterThan(1));

    // Ensure remote session exists in Day 1 results.
    final hasDynamicGroup = vm.currentGroups.any(
      (group) => group.title == 'Keynote' && group.speakers.length == 2,
    );
    expect(hasDynamicGroup, isTrue);
  });

  test('fetchSpeakers falls back to static data when repository throws', () async {
    final vm = SpeakersViewModel(
      repository: _ErroringSpeakersRepository(),
    );

    await vm.fetchSpeakers();

    expect(vm.error, isNotNull);
    expect(vm.currentGroups, isNotEmpty);
  });
}

class _FakeSpeakersRepository implements SpeakersRepository {
  @override
  Future<List<Map<String, dynamic>>> fetchSessions() async {
    return [
      {
        'title': 'Keynote',
        'title_ar': 'الكلمة الرئيسية',
        'scheduled_at': '2025-11-19T09:45:00Z',
        'instructors': [
          {
            'id': 1,
            'name': 'Dr. Sarah Example',
            'name_ar': 'الدكتورة سارة مثال',
            'title_en': 'Chief Economist',
            'title_ar': 'كبير الاقتصاديين',
            'country_id': 'SA',
          },
          {
            'id': 2,
            'name': 'Mr. Jamal Example',
            'name_ar': 'السيد جمال مثال',
            'title_en': 'Head of Strategy',
            'title_ar': 'رئيس الاستراتيجية',
            'country_id': 'SA',
          },
        ],
        'moderator': {
          'id': 2,
          'name': 'Mr. Jamal Example',
          'name_ar': 'السيد جمال مثال',
          'title_en': 'Head of Strategy',
          'title_ar': 'رئيس الاستراتيجية',
          'country_id': 'SA',
        },
      },
    ];
  }
}

class _ErroringSpeakersRepository implements SpeakersRepository {
  @override
  Future<List<Map<String, dynamic>>> fetchSessions() async {
    throw Exception('network down');
  }
}
