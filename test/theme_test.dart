import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';
import 'package:saudiexim_mobile_app/theme/light_theme.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Theme colors', () {
    test('light theme uses AppColors.primary', () {
      expect(lightTheme.colorScheme.primary, AppColors.primary);
    });

    test('light theme uses AppColors.secondary', () {
      expect(lightTheme.colorScheme.secondary, AppColors.secondary);
    });

    test('light theme uses AppColors.background', () {
      expect(lightTheme.colorScheme.background, AppColors.background);
      expect(lightTheme.scaffoldBackgroundColor, AppColors.background);
    });
  }, skip: true);
}
