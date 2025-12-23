// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get titleHome => 'الرئيسية';

  @override
  String get titleServices => 'الخدمات الداعمة';

  @override
  String get titleAgenda => 'أجندة المنتدى';

  @override
  String get titleMenu => 'القائمة';

  @override
  String get menuHeader => 'القائمة';

  @override
  String get menuAgenda => 'الأجندة';

  @override
  String get menuLocationDate => 'الموقع';

  @override
  String get menuAboutForum => 'عن المنتدى';

  @override
  String get menuWhoWeAre => 'من نحن';

  @override
  String get menuSupportServices => 'الخدمات المساعدة';

  @override
  String get menuInspiringPartners => 'شراكات ملهمة';

  @override
  String get menuForumCopies => 'إصدارات المنتدى';

  @override
  String get menuNews => 'الأخبار';

  @override
  String get menuSaudi => 'المملكة العربية السعودية';

  @override
  String get menuSpeakers => 'المتحدثين';

  @override
  String get badgeNew10 => '+10 جديد';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navLocation => 'الموقع';

  @override
  String get navMenu => 'القائمة';

  @override
  String get servicesNearby => 'الخدمات القريبة';

  @override
  String get menuRegisterNow => 'سجل الآن';

  @override
  String get cityAllSaudia => 'كل السعودية';

  @override
  String get agendaDayOne => 'اليوم الاول';

  @override
  String get agendaDayTwo => 'اليوم الثاني';

  @override
  String get agendaDownload => 'تحميل';

  @override
  String agendaDownloadSuccess(String day) {
    return 'أصبحت أجندة $day جاهزة للمشاركة.';
  }

  @override
  String get agendaDownloadFailed =>
      'تعذر إنشاء ملف الأجندة. يرجى المحاولة مرة أخرى.';

  @override
  String get agendaTime => 'الوقت';

  @override
  String get agendaSessionTopics => 'محاور الجلسة';

  @override
  String get agendaDownloadComingSoon => 'رابط التحميل سيتوفر قريبًا';

  @override
  String get agendaTitle => 'الأجندة';

  @override
  String get agendaDayOneHeading => 'التحولات العالمية وفرص الاقتصاد السعودي';

  @override
  String get agendaDayTwoHeading => 'الابتكار والتمويل في الجنوب العالمي';

  @override
  String get menuOverview => 'عن المنتدى';

  @override
  String get menuSponsorship => 'الرعايات';

  @override
  String get sponsorTypeStrategic => 'الشريك الإستراتيجي';

  @override
  String get sponsorTypeDiamond => 'الشريك الماسي';

  @override
  String get sponsorTypeGold => 'الشريك الذهبي';

  @override
  String get noServicesAvailable => 'لا توجد خدمات متاحة';

  @override
  String get serviceInfoTitle => 'معلومات عن الخدمة';

  @override
  String get websiteTitle => 'الموقع';

  @override
  String get locationTitle => 'الموقع';

  @override
  String get notFound => 'غير موجود';

  @override
  String get back => 'رجوع';

  @override
  String get cameraPermissionTitle => 'السماح باستخدام الكاميرا';

  @override
  String get cameraPermissionRationale =>
      'قد تطلب منك بوابة التسجيل مسح الشارة أو الهوية. يرجى السماح بالوصول إلى الكاميرا حتى يتمكن فريق بنك التصدير والاستيراد السعودي من التحقق من بياناتك.';

  @override
  String get cameraPermissionDenied =>
      'يتطلب إتمام التسجيل منح صلاحية الكاميرا.';

  @override
  String get cameraPermissionSettings => 'فتح الإعدادات';

  @override
  String get cameraPermissionNotNow => 'لاحقًا';

  @override
  String get cameraPermissionLaunchFailed =>
      'تعذر فتح بوابة التسجيل. يرجى المحاولة مرة أخرى.';

  @override
  String get googleMaps => 'خرائط Google';

  @override
  String get openMap => 'فتح الخريطة';

  @override
  String get noNetworkTitle => 'أنت غير متصل بالإنترنت';

  @override
  String get noNetworkSubtitle => 'تحقق من الاتصال للمتابعة';

  @override
  String get noNetworkDescription =>
      'تعذر الوصول إلى خوادم المنتدى. يرجى إعادة الاتصال بشبكة Wi-Fi أو بيانات الهاتف ثم المحاولة مجددًا.';

  @override
  String get noNetworkRetry => 'إعادة المحاولة';
}
