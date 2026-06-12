import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';

class SuppliersScreen extends ConsumerWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Supplier',
            onPressed: () {
              // TODO(phase2): open supplier form
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Supplier list, purchases, GRN -- Phase 2', style: AppTextStyles.bodySmall),
      ),
    );
  }
}
