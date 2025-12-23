import 'package:flutter/foundation.dart';

class Partner {
  final String name;
  final String description;
  final String companyLogo;
  final String role;

  const Partner({
    required this.name,
    required this.role,
    required this.companyLogo,
    required this.description,
  });
}

/// Holds the lists of participants and sponsors and manages the selected
/// segment in the [PartnersPage].
class PartnersViewModel extends ChangeNotifier {
  /// List of participants at the forum.
  final List<Partner> participants = const [
    Partner(
      name: 'ارامكو',
      role: 'مشارك',
      description:
          "وريم إيبسوم(Lorem Ipsum) هو ببساطة نص شكلي (بمعنى أن الغاية هي الشكل وليس المحتوى) ويُستخدم في صناعات المطابع ودور النشر. ",
      companyLogo: "assets/partners/Aramco.png",
    ),
    Partner(
      name: 'وزارة الاستثمار',
      role: 'مشارك',
      description:
          "وريم إيبسوم(Lorem Ipsum) هو ببساطة نص شكلي (بمعنى أن الغاية هي الشكل وليس المحتوى) ويُستخدم في صناعات المطابع ودور النشر. ",
      companyLogo: "assets/partners/investment.png",
    ),
    Partner(
      name: 'وزارة الصناعية والثورة المعدنية',
      role: 'مشارك',
      description:
          "وريم إيبسوم(Lorem Ipsum) هو ببساطة نص شكلي (بمعنى أن الغاية هي الشكل وليس المحتوى) ويُستخدم في صناعات المطابع ودور النشر. ",
      companyLogo: "assets/partners/mineralResources.png",
    ),
    Partner(
      name: 'الصادرات السعودية',
      role: 'مشارك',
      description:
          "وريم إيبسوم(Lorem Ipsum) هو ببساطة نص شكلي (بمعنى أن الغاية هي الشكل وليس المحتوى) ويُستخدم في صناعات المطابع ودور النشر. ",
      companyLogo: "assets/partners/sadarat.png",
    ),
    Partner(
      name: 'هيئة الزكاة والضريبة والجمارك',
      role: 'مشارك',
      description:
          "وريم إيبسوم(Lorem Ipsum) هو ببساطة نص شكلي (بمعنى أن الغاية هي الشكل وليس المحتوى) ويُستخدم في صناعات المطابع ودور النشر. ",
      companyLogo: "assets/partners/zakat.png",
    ),
  ];

  /// Whether to show participants instead of partners.
  /// Defaults to showing sponsors first.
  bool showParticipants = false;

  /// Returns the list currently visible in the UI.
  List<Partner> get currentList => participants;

  /// Toggles between showing participants and partners.
  void toggleShowParticipants() {
    showParticipants = !showParticipants;

    notifyListeners();
  }
}
