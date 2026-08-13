import 'dart:async';
import 'package:flutter/material.dart';
import 'core/config/app_routes.dart';
import 'services/auth_cache_service.dart';
import 'services/camera_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CameraService.initialize();
  runApp(const MgaFaceLoginApp());
}

const Set<String> _publicRoutes = {
  AppRoutes.splash,
  AppRoutes.adminLogin,
};

class _CurrentRouteObserver extends NavigatorObserver {
  String? currentRouteName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName = route.settings.name;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName = previousRoute?.settings.name;
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    currentRouteName = newRoute?.settings.name;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName = previousRoute?.settings.name;
    super.didRemove(route, previousRoute);
  }
}

class MgaFaceLoginApp extends StatefulWidget {
  const MgaFaceLoginApp({super.key});

  @override
  State<MgaFaceLoginApp> createState() => _MgaFaceLoginAppState();
}

class _MgaFaceLoginAppState extends State<MgaFaceLoginApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final _CurrentRouteObserver _routeObserver = _CurrentRouteObserver();
  Timer? _sessionCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionCheckTimer = Timer.periodic(const Duration(minutes: 5), (_) => _checkSession());
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkSession();
    }
  }

  Future<void> _checkSession() async {
    final String? currentRoute = _routeObserver.currentRouteName;
    if (currentRoute == null || _publicRoutes.contains(currentRoute)) return;

    final String? token = await AuthCacheService.getValidToken();
    if (token == null) {
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(AppRoutes.adminLogin, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      navigatorObservers: [_routeObserver],
      title: 'mga-face-login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
