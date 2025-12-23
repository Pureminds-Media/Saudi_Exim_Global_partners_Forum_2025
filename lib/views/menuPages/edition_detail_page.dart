import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/components/ui/title_back_top_bar.dart';
import 'package:saudiexim_mobile_app/components/edition_card.dart';
import 'package:saudiexim_mobile_app/models/edition.dart';

/// Detail view for a single [Edition].
class EditionDetailPage extends StatelessWidget {
  const EditionDetailPage({super.key, required this.edition});

  final Edition edition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const BackTitleBar(title: 'تفاصيل النسخة'),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Hero(
                tag: edition.title,
                child: Material(
                  color: Colors.transparent,
                  child: EditionCard(edition: edition, enableTap: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
