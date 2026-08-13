import 'package:flutter/material.dart';
import '../../screens/auth/admin_login_page.dart';
import '../../screens/common/splash_screen.dart';
import '../../screens/dashboard/dashboard_page.dart';
import '../../screens/face/face_login_page.dart';
import '../../screens/face/new_member_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String adminLogin = '/admin-login';
  static const String dashboard = '/dashboard';
  static const String faceLogin = '/face-login';
  static const String newMember = '/new-member';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        adminLogin: (_) => const AdminLoginPage(),
        dashboard: (_) => const DashboardPage(),
        faceLogin: (_) => const FaceLoginPage(),
        newMember: (_) => const NewMemberPage(),
      };
}
