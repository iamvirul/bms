import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0D47A1);

  // Backgrounds
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF2F7);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF9A825);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF0277BD);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFB0B7C3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocus = Color(0xFF42A5F5);

  // Cheque status colors
  static const Color chequePending = Color(0xFFF9A825);
  static const Color chequeDeposited = Color(0xFF42A5F5);
  static const Color chequeCleared = Color(0xFF2E7D32);
  static const Color chequeBounced = Color(0xFFC62828);

  // Payment method colors (POS)
  static const Color paymentCash = Color(0xFF2E7D32);
  static const Color paymentCard = Color(0xFF1565C0);
  static const Color paymentCheque = Color(0xFFF9A825);
  static const Color paymentCredit = Color(0xFF6A1B9A);
}
