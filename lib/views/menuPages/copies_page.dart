// lib/views/menuPages/copies_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/components/ui/title_back_top_bar.dart';
import 'package:saudiexim_mobile_app/components/edition_card.dart';
import 'package:saudiexim_mobile_app/models/edition.dart';

import '../../viewmodels/menuPages/copies_view_model.dart';

/// Page displaying a list of past forum editions with subtle animations.
class CopiesPage extends StatelessWidget {
  const CopiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CopiesViewModel(),
      child: const _CopiesPageBody(),
    );
  }
}

class _CopiesPageBody extends StatefulWidget {
  const _CopiesPageBody();

  @override
  State<_CopiesPageBody> createState() => _CopiesPageBodyState();
}

class _CopiesPageBodyState extends State<_CopiesPageBody> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  final List<Edition> _items = [];

  double _headerOpacity = 1;
  Alignment _headerAlign = Alignment.center;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Animate list items after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final editions = context.read<CopiesViewModel>().editions;
      for (var i = 0; i < editions.length; i++) {
        Future.delayed(Duration(milliseconds: 100 * i), () {
          _items.insert(i, editions[i]);
          _listKey.currentState?.insertItem(i);
        });
      }
    });
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _headerOpacity = (1 - offset / 80).clamp(0.0, 1.0);
      _headerAlign = Alignment(0, -offset / 200);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AnimatedAlign(
            alignment: _headerAlign,
            duration: const Duration(milliseconds: 200),
            child: AnimatedOpacity(
              opacity: _headerOpacity,
              duration: const Duration(milliseconds: 200),
              child: const BackTitleBar(title: 'نسخ المنتدى'),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedList(
                key: _listKey,
                controller: _scrollController,
                initialItemCount: _items.length,
                itemBuilder: (context, index, animation) {
                  final edition = _items[index];
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: animation.drive(
                        Tween(begin: const Offset(0, 0.1), end: Offset.zero),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: index == _items.length - 1 ? 0 : 32,
                        ),
                        child: EditionCard(edition: edition),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
