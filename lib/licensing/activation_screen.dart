import 'package:bms/licensing/license_provider.dart';
import 'package:bms/licensing/license_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  final _controller = TextEditingController();
  final _focus      = FocusNode();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Enter your license key');
      return;
    }

    setState(() => _error = null);

    try {
      await ref.read(licenseProvider.notifier).activate(key);
    } on LicenseException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not connect to the licensing server. Check your internet connection.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(licenseProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/images/bms_logo.svg',
                    width: 56, height: 56),
                const SizedBox(height: 24),
                const Text(
                  'BMS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your license key to continue',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
                const SizedBox(height: 40),
                _KeyField(
                  controller: _controller,
                  focus: _focus,
                  error: _error,
                  enabled: !isLoading,
                  onSubmit: _submit,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Activate',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Need a license key? Contact support@getbms.app',
                  style: TextStyle(color: Color(0xFF475569), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyField extends StatelessWidget {
  const _KeyField({
    required this.controller,
    required this.focus,
    required this.error,
    required this.enabled,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final String? error;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focus,
      enabled: enabled,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [_LicenseKeyFormatter()],
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'monospace',
        fontSize: 16,
        letterSpacing: 1.5,
      ),
      decoration: InputDecoration(
        hintText: 'BMS-XXXX-XXXX-XXXX-XXXX',
        hintStyle: const TextStyle(
            color: Color(0xFF334155), fontFamily: 'monospace', fontSize: 15),
        errorText: error,
        errorStyle: const TextStyle(color: Color(0xFFF87171)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onSubmitted: (_) => onSubmit(),
    );
  }
}

class _LicenseKeyFormatter extends TextInputFormatter {
  // Formats input as BMS-XXXX-XXXX-XXXX-XXXX (19 alphanum chars + 4 dashes).
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final clean = newValue.text
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();

    // Max 19 alphanum characters (3 prefix + 4x4 segments).
    final limited =
        clean.length > 19 ? clean.substring(0, 19) : clean;

    final buf = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 3 || i == 7 || i == 11 || i == 15) buf.write('-');
      buf.write(limited[i]);
    }

    final result = buf.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
