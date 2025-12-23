import 'package:flutter/foundation.dart';
import 'package:saudiexim_mobile_app/models/sponsor.dart';
import 'package:saudiexim_mobile_app/repositories/sponsors_repository.dart';
import 'package:saudiexim_mobile_app/utils/api_endpoints.dart';

/// Sponsor tier types used to group items in the UI.
enum SponsorTier { strategic, diamond, gold }

SponsorTier? _tierFromType(String raw) {
  final t = raw.toLowerCase();
  if (t.contains('strategic')) return SponsorTier.strategic;
  if (t.contains('diamond')) return SponsorTier.diamond;
  if (t.contains('gold')) return SponsorTier.gold;
  return null;
}

class SponsorsViewModel extends ChangeNotifier {
  final SponsorsRepository _repo;
  SponsorsViewModel({SponsorsRepository? repo}) : _repo = repo ?? SponsorsRepository();

  bool _loading = false;
  String? _error;
  SponsorTier _selected = SponsorTier.strategic;

  final Map<SponsorTier, List<Sponsor>> _groups = {
    SponsorTier.strategic: <Sponsor>[],
    SponsorTier.diamond: <Sponsor>[],
    SponsorTier.gold: <Sponsor>[],
  };

  bool get isLoading => _loading;
  String? get error => _error;
  SponsorTier get selected => _selected;
  List<Sponsor> get currentList => _groups[_selected] ?? const [];

  String imageUrlFor(Sponsor s) {
    final p = s.photoPath.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    final base = sponsorsStorageBaseUrl.endsWith('/')
        ? sponsorsStorageBaseUrl.substring(0, sponsorsStorageBaseUrl.length - 1)
        : sponsorsStorageBaseUrl;
    final rel = p.startsWith('/') ? p.substring(1) : p;
    return '$base/$rel';
  }

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final items = await _repo.fetchSponsors();
      // clear groups
      for (final k in _groups.keys) {
        _groups[k] = [];
      }
      for (final s in items) {
        final tier = _tierFromType(s.type);
        if (tier != null) {
          _groups[tier]!.add(s);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectTier(SponsorTier tier) {
    if (_selected == tier) return;
    _selected = tier;
    notifyListeners();
  }
}
