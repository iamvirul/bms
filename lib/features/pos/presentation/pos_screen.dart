import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  // Barcode input auto-focused to support USB/Bluetooth HID scanners (they act as keyboard)
  final _barcodeController = TextEditingController();
  final _barcodeFocus = FocusNode();

  @override
  void dispose() {
    _barcodeController.dispose();
    _barcodeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS / Sales')),
      body: Row(
        children: [
          // Left: product search + grid
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _barcodeController,
                    focusNode: _barcodeFocus,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Scan barcode or search product...',
                      prefixIcon: Icon(Icons.qr_code_scanner),
                    ),
                    onSubmitted: (_) {
                      // TODO(phase1): lookup barcode and add to cart
                      _barcodeController.clear();
                      _barcodeFocus.requestFocus();
                    },
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Product grid -- Phase 1',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Right: cart panel
          SizedBox(
            width: 360,
            child: _CartPanel(),
          ),
        ],
      ),
    );
  }
}

class _CartPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              Center(child: Text('Cart is empty', style: AppTextStyles.bodySmall)),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Total', style: AppTextStyles.titleMedium),
                  Text('Rs. 0.00', style: AppTextStyles.posAmount),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _PayButton(
                      label: 'Cash',
                      color: AppColors.paymentCash,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PayButton(
                      label: 'Card',
                      color: AppColors.paymentCard,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PayButton(
                      label: 'Credit',
                      color: AppColors.paymentCredit,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: onTap,
        child: Text(label, style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }
}
