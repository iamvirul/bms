import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Add Customer',
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Customer list and balance tracking',
          style: AppTextStyles.bodySmall,
        ),
      ),
    );
  }
}
