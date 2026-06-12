import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_state.dart';
import 'app_router.dart';

abstract final class RouteGuard {
  static const Set<String> _publicRoutes = {AppRoutes.login};

  /// Cashiers cannot access supplier and report screens beyond daily summary.
  static const Set<String> _adminOnlyRoutes = {
    AppRoutes.suppliers,
  };

  static String? redirect({
    required GoRouterState state,
    required AuthState authState,
  }) {
    final isPublic = _publicRoutes.contains(state.matchedLocation);

    return switch (authState) {
      Unauthenticated() => isPublic ? null : AppRoutes.login,
      Authenticated(:final user) => _guardAuthenticated(
          location: state.matchedLocation,
          isPublic: isPublic,
          role: user.role,
        ),
    };
  }

  static String? _guardAuthenticated({
    required String location,
    required bool isPublic,
    required String role,
  }) {
    if (isPublic) return AppRoutes.dashboard;

    if (_adminOnlyRoutes.contains(location) && role == 'cashier') {
      return AppRoutes.dashboard;
    }

    return null;
  }
}
