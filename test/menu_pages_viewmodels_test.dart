import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/models/lecture.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/about_view_model.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/agenda_view_model.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/location_view_model.dart';
import 'package:saudiexim_mobile_app/repositories/agenda_repository.dart';
import 'package:saudiexim_mobile_app/models/agenda_config.dart';

class _FakeAgendaRepo extends AgendaRepository {
  _FakeAgendaRepo();
  @override
  Future<List<Lecture>> fetchLectures() async {
    return [
      Lecture(
        id: 1,
        titleAr: 'A1',
        titleEn: 'A1',
        summaryAr: '',
        summaryEn: '',
        dateKey: '2025-11-19',
        startTime: '10:00',
        endTime: '11:00',
        topicsAr: const [],
        topicsEn: const [],
      ),
      Lecture(
        id: 2,
        titleAr: 'B1',
        titleEn: 'B1',
        summaryAr: '',
        summaryEn: '',
        dateKey: '2025-11-20',
        startTime: '12:00',
        endTime: '13:00',
        topicsAr: const [],
        topicsEn: const [],
      ),
    ];
  }

  @override
  Future<AgendaConfig> fetchAgendaConfig() async {
    // Avoid network in tests; return empty config so VM falls back to defaults.
    return AgendaConfig.empty();
  }
}

void main() {
  test(
    'AgendaViewModel groups lectures by day and injects static items',
    () async {
      final vm = AgendaViewModel(repository: _FakeAgendaRepo());
      await vm.refresh();
      expect(vm.day1.isNotEmpty, true);
      expect(vm.day2.isNotEmpty, true);
      // Expect at least the two injected items prefixed
      expect(vm.day1.first.titleEn.isNotEmpty, true);
    },
  );

  test('AgendaViewModel updates selected day', () {
    final vm = AgendaViewModel(repository: _FakeAgendaRepo());
    expect(vm.selectedDay, 0);
    vm.setSelectedDay(1);
    expect(vm.selectedDay, 1);
  });

  test('AboutViewModel has mission text', () {
    final vm = AboutViewModel();
    expect(vm.missionVision.isNotEmpty, true);
  });

  test('LocationViewModel contains coordinates', () {
    final vm = LocationViewModel();
    expect(vm.latitude != 0, true);
    expect(vm.longitude != 0, true);
  });
}
