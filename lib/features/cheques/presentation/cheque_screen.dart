import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';

class ChequeScreen extends ConsumerWidget {
  const ChequeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cheques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Record Cheque',
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Month calendar with cheque chips and status tracking',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
