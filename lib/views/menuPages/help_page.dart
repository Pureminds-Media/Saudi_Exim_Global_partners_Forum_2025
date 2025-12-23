// lib/views/menuPages/help_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/help_view_model.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HelpViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('الخدمات المساعدة')),
        body: Consumer<HelpViewModel>(
          builder: (context, vm, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('خط المساندة: ${vm.hotline}'),
                const SizedBox(height: 8),
                Text('البريد الإلكتروني: ${vm.email}'),
                const SizedBox(height: 8),
                Text('ساعات العمل: ${vm.workingHours}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
