import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';

class ChequeCalendarScreen extends ConsumerWidget {
  const ChequeCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cheque Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Record Cheque',
            onPressed: () {
              // TODO(phase2): open cheque form
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Month calendar with cheque chips, status tracking -- Phase 2',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
