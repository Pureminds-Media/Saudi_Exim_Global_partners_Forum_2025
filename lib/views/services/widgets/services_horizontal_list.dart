import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/models/service.dart';
import 'package:saudiexim_mobile_app/views/services/widgets/keep_alive_service_card.dart';

class ServicesHorizontalList extends StatefulWidget {
  const ServicesHorizontalList({
    super.key,
    required this.loading,
    required this.selectedCategoryId,
    required this.services,
    required this.noServicesText,
    required this.isAr,
    this.itemWidth = 250,
  });

  final bool loading;
  final String? selectedCategoryId;
  final List<Service> services;
  final String noServicesText;
  final bool isAr;
  final double itemWidth;

  @override
  State<ServicesHorizontalList> createState() => _ServicesHorizontalListState();
}

class _ServicesHorizontalListState extends State<ServicesHorizontalList> {
  double? _measuredHeight;
  String? _lastCategoryId;
  final GlobalKey _offstageKey = GlobalKey();

  @override
  void didUpdateWidget(covariant ServicesHorizontalList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategoryId != _lastCategoryId ||
        oldWidget.isAr != widget.isAr) {
      _lastCategoryId = widget.selectedCategoryId;
      _measuredHeight = null; // re-measure for new category
    }
  }

  void _scheduleMeasurement() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _offstageKey.currentContext;
      final render = ctx?.findRenderObject() as RenderBox?;
      final size = render?.size;
      if (size != null && size.height > 0 && mounted) {
        setState(() => _measuredHeight = size.height);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final needsMeasure = widget.services.isNotEmpty && _measuredHeight == null;
    if (needsMeasure) _scheduleMeasurement();

    final listHeight = _measuredHeight ?? 0;

    // Choose a prototype card for measuring: prefer the item with the most
    // text in title/subtitle for the active locale (best height approximation).
    Service? _pickPrototype() {
      String clean(String? s) {
        final v = (s ?? '').trim();
        if (v.toLowerCase() == 'n/a') return '';
        return v;
      }

      String titleFor(Service s) {
        final t = widget.isAr ? clean(s.nameAr) : clean(s.nameEn);
        return t.isNotEmpty ? t : clean(s.name);
      }

      String subFor(Service s) {
        if (widget.isAr) {
          final a = clean(s.subtitleAr);
          return a.isNotEmpty ? a : clean(s.subtitle);
        } else {
          final e = clean(s.subtitleEn);
          return e.isNotEmpty ? e : clean(s.subtitle);
        }
      }

      Service? best;
      var bestScore = -1;
      for (final s in widget.services) {
        final score = titleFor(s).length + subFor(s).length * 2;
        if (score > bestScore) {
          best = s;
          bestScore = score;
        }
      }
      return best ??
          (widget.services.isNotEmpty ? widget.services.first : null);
    }

    final prototype = _pickPrototype();

    final Widget content = widget.loading
        ? SizedBox(
            key: const ValueKey('loading'),
            height: (_measuredHeight ?? 260),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : (widget.selectedCategoryId == null)
        ? const SizedBox.shrink()
        : (widget.services.isEmpty)
        ? Center(
            key: const ValueKey('empty'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(widget.noServicesText),
            ),
          )
        : SizedBox(
            key: ValueKey(
              'list-${widget.selectedCategoryId}-${widget.services.length}',
            ),
            height: listHeight > 0 ? listHeight : 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: widget.services.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final sItem = widget.services[index];
                return SizedBox(
                  width: widget.itemWidth,
                  child: KeepAliveServiceCard(
                    key: ValueKey('service-${sItem.id}'),
                    service: sItem,
                  ),
                );
              },
            ),
          );

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: content,
            ),
            if (needsMeasure)
              Offstage(
                offstage: true,
                child: SizedBox(
                  key: _offstageKey,
                  width: widget.itemWidth,
                  child: KeepAliveServiceCard(
                    service: prototype ?? widget.services.first,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
