import 'package:flutter/foundation.dart';
import 'package:saudiexim_mobile_app/models/edition.dart';

class CopiesViewModel extends ChangeNotifier {
  final List<Edition> editions = const [
    Edition(
      title: 'النسخة الأولى',
      date: '01 أكتوبر 2023',
      descriptionLines: [
        'وريم إيبسوم(Lorem Ipsum) هو ببساطة نص شكلي (بمعنى أن الغاية هي الشكل وليس المحتوى) ويُستخدم في صناعات المطابع ودور النشر.  وريم إيبسوم(Lorem Ipsum) هو ببساطة نص شكلي (بمعنى أن الغاية هي الشكل وليس المحتوى) ويُستخدم في صناعات المطابع ودور النشر. ',
      ],
      mainPhoto: 'assets/editions/edition1_main.png',
      minorPhotos: [
        'assets/editions/edition1_minor1.png',
        'assets/editions/edition1_minor2.png',
        'assets/editions/edition1_minor3.png',
        'assets/editions/edition1_minor4.png',
      ],
    ),
    Edition(
      title: 'النسخة الثانية',
      date: '01 نوفمبر 2023',
      descriptionLines: [
        'وريم إيبسوم(Lorem Ipsum) هو ببساطة نص شكلي (بمعنى أن الغاية هي الشكل وليس المحتوى) ويُستخدم في صناعات المطابع ودور النشر.  وريم إيبسوم(Lorem Ipsum) هو ببساطة نص شكلي (بمعنى أن الغاية هي الشكل وليس المحتوى) ويُستخدم في صناعات المطابع ودور النشر. ',
      ],
      mainPhoto: 'assets/editions/edition1_main.png',
      minorPhotos: [
        'assets/editions/edition1_minor1.png',
        'assets/editions/edition1_minor2.png',
        'assets/editions/edition1_minor3.png',
        'assets/editions/edition1_minor4.png',
      ],
    ),
  ];
}
