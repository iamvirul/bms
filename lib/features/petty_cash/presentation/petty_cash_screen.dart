import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';

class PettyCashScreen extends ConsumerWidget {
  const PettyCashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Petty Cash'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Entry',
            onPressed: () {
              // TODO(phase3): open petty cash entry form
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Cash entries, approval workflow, daily reconciliation -- Phase 3',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
