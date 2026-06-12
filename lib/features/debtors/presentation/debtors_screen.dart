import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';

class DebtorsScreen extends ConsumerWidget {
  const DebtorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debtors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Add Customer',
            onPressed: () {
              // TODO(phase2): open customer form
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Debtor list and aging report -- Phase 2', style: AppTextStyles.bodySmall),
      ),
    );
  }
}
