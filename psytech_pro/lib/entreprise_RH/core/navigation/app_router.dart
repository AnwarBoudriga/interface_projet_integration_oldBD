import 'package:flutter/material.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/invitations/invitations_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/questions/questions_screen.dart';
import '../screens/results/results_screen.dart';
import '../screens/tests/tests_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String tests = '/tests';
  static const String questions = '/questions';
  static const String invitations = '/invitations';
  static const String results = '/results';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.dashboard:
        return _page(settings, const DashboardScreen());
      case AppRoutes.tests:
        return _page(settings, const TestsScreen());
      case AppRoutes.questions:
        return _page(settings, const QuestionsScreen());
      case AppRoutes.invitations:
        return _page(settings, const InvitationsScreen());
      case AppRoutes.results:
        return _page(settings, const ResultsScreen());
      case AppRoutes.login:
      default:
        return _page(settings, const LoginScreen());
    }
  }

  /// Transition instantanée (pas d'animation) pour une navigation type « web ».
  static Route<dynamic> _page(RouteSettings settings, Widget child) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, _, _) => child,
    );
  }
}
