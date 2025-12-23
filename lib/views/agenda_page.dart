// lib/views/agenda_page.dart
import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/components/agenda/day_tab.dart';
import 'package:saudiexim_mobile_app/components/agenda/session_card.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/agenda_view_model.dart'
    as page_vm;
import 'package:saudiexim_mobile_app/components/ui/no_network_placeholder.dart';
import 'package:saudiexim_mobile_app/utils/network_error_classifier.dart';

import '../theme/app_colors.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final GlobalKey _captureKey = GlobalKey();
  int _day = 0; // 0 = Day One, 1 = Day Two
  bool _generatingPdf = false;
  static const kTeal = Color(0xFF00B3AF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<page_vm.AgendaViewModel>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<page_vm.AgendaViewModel>();
    final s = AppLocalizations.of(context)!;

    Widget header() {
      final titleStyle = Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900);

      // Two full-width day tabs under the title
      final dayTab1 = DayTab(
        text: s.agendaDayOne,
        selected: _day == 0,
        onTap: () => setState(() => _day = 0),
        activeColor: kTeal,
      );
      final dayTab2 = DayTab(
        text: s.agendaDayTwo,
        selected: _day == 1,
        onTap: () => setState(() => _day = 1),
        activeColor: kTeal,
      );

      final isAr = Localizations.localeOf(context).languageCode == 'ar';
      final dynamicTitle = vm.titleForDay(_day, ar: isAr);
      final dayHeading = dynamicTitle ?? (_day == 0
          ? s.agendaDayOneHeading
          : s.agendaDayTwoHeading);

      final dateLabel = _formatDateChip(context, vm, _day);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bold page title: Agenda / الأجندة
          const SizedBox(height: 12),
          Text(s.agendaTitle, style: titleStyle),
          const SizedBox(height: 24),

          // Day tabs (full width with margins)
          Row(
            children: [
              Expanded(child: dayTab1),
              const SizedBox(width: 12),
              Expanded(child: dayTab2),
            ],
          ),

          const SizedBox(height: 32),
          // Day heading below the tabs
          Text(
            dayHeading,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF174B86),
              fontSize: 19,
            ),
            textAlign: TextAlign.start,
          ),

          const SizedBox(height: 24),
          // Date chip with calendar icon and download button beside it
          // Date chip + download (adaptive, no overflow)
          // Date chip + download (keeps original look unless it would overflow)
          LayoutBuilder(
            builder: (context, c) {
              final s = AppLocalizations.of(context)!;
              double measureTextWidth(
                BuildContext context,
                String text,
                TextStyle style,
              ) {
                final tp = TextPainter(
                  text: TextSpan(text: text, style: style),
                  maxLines: 1,
                  textDirection: Directionality.of(context),
                )..layout(minWidth: 0, maxWidth: double.infinity);
                return tp.size.width;
              }

              // Returns true if the row (_DateChip + spacing + _DownloadAgendaButton) won’t fit.
              bool agendaRowWillOverflow({
                required BuildContext context,
                required double maxWidth,
                required String dateLabel,
                required String downloadLabel,
              }) {
                // --- styles used in your widgets (match your current code) ---
                const dateFont = TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                );
                final btnFont =
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ) ??
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

                // --- measure text ---
                final dateTextW = measureTextWidth(
                  context,
                  dateLabel,
                  dateFont,
                );
                final btnTextW = measureTextWidth(
                  context,
                  downloadLabel,
                  btnFont,
                );

                // --- current shapes (non-dense chip + full button) ---
                const dateIconW = 24.0;
                const dateGap = 6.0;
                const dateHPad = 10.0; // chip horizontal padding (your current)
                const chipBorderAllowance = 2.0; // ~1px each side

                final dateChipW =
                    dateIconW +
                    dateGap +
                    dateTextW +
                    (2 * dateHPad) +
                    chipBorderAllowance;

                const btnIconW = 20.0;
                const btnGap = 8.0;
                const btnHPad = 18.0; // your current OutlinedButton padding
                const btnBorderAllowance = 3.0; // 1.5px * 2

                final fullBtnW =
                    btnIconW +
                    btnGap +
                    btnTextW +
                    (2 * btnHPad) +
                    btnBorderAllowance;

                const between = 12.0; // SizedBox between children

                final total = dateChipW + between + fullBtnW;

                // If total exceeds available width, we’ll switch to dense chip + icon-only button.
                return total > maxWidth;
              }

              final willOverflow = agendaRowWillOverflow(
                context: context,
                maxWidth: c.maxWidth,
                dateLabel: dateLabel,
                downloadLabel: s.agendaDownload,
              );

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DateChip(
                    label: dateLabel,
                    dense: willOverflow,
                  ), // only densify if needed
                  _DownloadAgendaButton(
                    label: s.agendaDownload,
                    color: const Color(0xFF02548C),
                    loading: _generatingPdf,
                    onTap: () => _onDownload(context),
                    iconOnly:
                        willOverflow, // switch to icon-only only when overflow
                    compact: willOverflow, // tighter padding only when overflow
                  ),
                ],
              );
            },
          ),
        ],
      );
    }

    Widget body() {
      if (vm.loading) {
        return const _LoadingSkeleton();
      }
      if (vm.error != null) {
        final message = vm.error!;
        if (isNetworkErrorMessage(message)) {
          return NoNetworkPlaceholder(onRetry: () => vm.refresh());
        }
        return _ErrorBox(message: message, onRetry: () => vm.refresh());
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header(),
          const Divider(height: 32, thickness: 2, color: Color(0xFFD9D9D9)),
          _SessionsList(day: _day),
        ],
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: RepaintBoundary(key: _captureKey, child: body()),
      ),
    );
  }

  String _formatDateChip(
    BuildContext context,
    page_vm.AgendaViewModel vm,
    int dayIndex,
  ) {
    if (vm.dayKeys.isEmpty) return '';
    final key = dayIndex == 0
        ? (vm.dayKeys.isNotEmpty ? vm.dayKeys.first : null)
        : (vm.dayKeys.length > 1 ? vm.dayKeys[1] : null);
    if (key == null) return '';
    // Parse Y-M-D as a local date
    try {
      final date = DateTime.parse(key);
      final locale = Localizations.localeOf(context).languageCode;
      // Format like: الخميس، 20 نوفمبر (ar) or Thursday, 20 November (en)
      final pattern = locale == 'ar' ? 'EEEE، d MMMM' : 'EEEE, d MMMM';
      final df = DateFormat(pattern, locale);
      return df.format(date);
    } catch (_) {
      return key;
    }
  }

  Future<void> _onDownload(BuildContext context) async {
    final s = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final boundary =
        _captureKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;

    if (boundary == null || _generatingPdf) {
      messenger.showSnackBar(SnackBar(content: Text(s.agendaDownloadFailed)));
      return;
    }

    setState(() => _generatingPdf = true);
    try {
      await Future.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;

      // 1) Capture the agenda into a bitmap (limit DPR to keep memory sane)
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final pixelRatio = dpr > 2.0 ? 2.0 : dpr;
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Unable to capture widget to image');
      }
      final pngBytes = byteData.buffer.asUint8List();
      final src = img.decodeImage(pngBytes)!;
      image.dispose();

      // 2) Prepare a single-page PDF sized to the captured agenda
      final pdf = pw.Document();
      const margin = 20.0;
      final targetWidth = PdfPageFormat.a4.width; // Keep standard A4 width
      final usableWidth = targetWidth - 2 * margin;
      final scale = usableWidth / src.width;
      final requiredHeight = src.height * scale;
      final pageFormat = PdfPageFormat(
        targetWidth,
        requiredHeight + 2 * margin,
      );

      final mem = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(margin),
          build: (_) =>
              pw.Image(mem, width: usableWidth, fit: pw.BoxFit.fitWidth),
        ),
      );

      // 4) Save (download) instead of share
      final filename =
          'agenda_day_${_day + 1}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';

      // Try a user-facing “Save As” when available; otherwise fall back to direct save.
      await FileSaver.instance.saveAs(
        name: filename,
        bytes: await pdf.save(),
        fileExtension: "pdf",
        mimeType: MimeType.pdf,
      );

      final dayLabel = _day == 0 ? s.agendaDayOne : s.agendaDayTwo;
      messenger.showSnackBar(
        SnackBar(content: Text(s.agendaDownloadSuccess(dayLabel))),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(s.agendaDownloadFailed)));
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }
}

class _DownloadAgendaButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool loading;

  final bool iconOnly; // only icon when true
  final bool compact; // tighter padding/min size when true

  const _DownloadAgendaButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.loading = false,
    this.iconOnly = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- icon-only variant (used only when overflow) ---
    if (iconOnly) {
      return OutlinedButton(
        onPressed: loading ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: const BorderSide(color: Color(0xffDFDFDF), width: 1.5),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 8 : 10,
          ),
          minimumSize: const Size(36, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : SvgPicture.asset(
                'assets/icons/download_pdf.svg',
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                width: 20,
                height: 20,
              ),
      );
    }

    // --- original look (unchanged) ---
    return OutlinedButton.icon(
      onPressed: loading ? null : onTap,
      icon: loading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          : SvgPicture.asset(
              'assets/icons/download_pdf.svg',
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              width: 20,
              height: 20,
            ),
      label: Text(label),
      iconAlignment: IconAlignment.end,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: const BorderSide(color: Color(0xffDFDFDF), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

/* --------------------------- Sessions List -------------------------- */

class _SessionsList extends StatelessWidget {
  const _SessionsList({required this.day});
  final int day;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<page_vm.AgendaViewModel>();
    final data = day == 0 ? vm.day1 : vm.day2;
    return Column(
      children: List.generate(
        data.length,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SessionCard(item: data[i]),
        ),
      ),
    );
  }
}

/* --------------------------- UI Helpers ----------------------------- */
class _DateChip extends StatelessWidget {
  final String label;
  final bool dense;
  const _DateChip({required this.label, this.dense = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 6 : 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: dense ? 20 : 24,
            color: AppColors.teal,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.teal,
                fontSize: 14, // keep as-is
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const _SkeletonBox(height: 28, width: 190),
        const SizedBox(height: 24),
        Row(
          children: const [
            Expanded(
              child: _SkeletonBox(
                height: 52,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _SkeletonBox(
                height: 52,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const _SkeletonBox(height: 24, width: 220),
        const SizedBox(height: 24),
        Row(
          children: [
            const SizedBox(
              width: 210,
              child: _SkeletonBox(
                height: 44,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 56,
              child: _SkeletonBox(
                height: 44,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(height: 2, color: Colors.black.withValues(alpha: .05)),
        const SizedBox(height: 24),
        ...List.generate(3, (index) => const _SessionSkeleton()),
      ],
    );
  }
}

class _SessionSkeleton extends StatelessWidget {
  const _SessionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _SkeletonBox(
                  height: 10,
                  width: 46,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                SizedBox(height: 12),
                _SkeletonBox(
                  height: 16,
                  width: 42,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                SizedBox(height: 12),
                _SkeletonBox(
                  height: 16,
                  width: 42,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
              ],
            ),
          ),
          Container(
            width: 2,
            height: 96,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.black.withValues(alpha: .06),
          ),
          const Expanded(child: _SessionTextSkeleton()),
        ],
      ),
    );
  }
}

class _SessionTextSkeleton extends StatelessWidget {
  const _SessionTextSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FractionallySizedBox(
          widthFactor: 0.85,
          child: _SkeletonBox(height: 18),
        ),
        const SizedBox(height: 12),
        const _SkeletonBox(height: 14),
        const SizedBox(height: 8),
        const FractionallySizedBox(
          widthFactor: 0.9,
          child: _SkeletonBox(height: 14),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            _SkeletonBullet(),
            SizedBox(width: 8),
            Expanded(child: _SkeletonBox(height: 12)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            _SkeletonBullet(),
            SizedBox(width: 8),
            Expanded(
              child: FractionallySizedBox(
                widthFactor: 0.9,
                child: _SkeletonBox(height: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SkeletonBullet extends StatelessWidget {
  const _SkeletonBullet();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .08),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius borderRadius;

  const _SkeletonBox({
    required this.height,
    this.width,
    BorderRadius? borderRadius,
  }) : borderRadius =
           borderRadius ?? const BorderRadius.all(Radius.circular(10));

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDF2),
        borderRadius: borderRadius,
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
