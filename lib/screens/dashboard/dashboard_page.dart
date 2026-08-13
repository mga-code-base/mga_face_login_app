import 'package:flutter/material.dart';
import '../../core/config/app_routes.dart';
import '../../services/auth_cache_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _handleLogout(BuildContext context) async {
    await AuthCacheService.logoutAdmin();
    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.adminLogin, (route) => false);
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to end your administration session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleLogout(context);
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MGA'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Log Out Workspace',
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(24)),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.faceLogin),
              icon: const Icon(Icons.face, size: 32, color: Colors.greenAccent),
              label: const Text('Option A: Face Login', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(24)),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.newMember),
              icon: const Icon(Icons.person_add, size: 32, color: Colors.orangeAccent),
              label: const Text('Option B: New Member', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
