import 'package:flutter/material.dart';
import '../../core/config/app_routes.dart';
import '../../services/admin_api_service.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  String? _screenErrorMessage;
  bool _obscurePassword = true;

  void _handleLogin() async {
    final String username = _userController.text.trim();

    if (username.isEmpty || _passController.text.isEmpty) {
      setState(() {
        _screenErrorMessage = 'Please fill out all fields.';
      });
      return;
    }

    if (username == 'admin') {
      setState(() {
        _screenErrorMessage = 'Super Admin Login Restricted on this App';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _screenErrorMessage = null;
    });

    String? errorMessage = await AdminApiService.loginAdmin(username, _passController.text);

    setState(() => _isLoading = false);

    if (errorMessage == null && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else if (mounted) {
      setState(() {
        _screenErrorMessage = errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Portal')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_screenErrorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 20.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.red.shade300, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _screenErrorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: _handleLogin,
              child: const Text('Authenticate'),
            ),
          ],
        ),
      ),
    );
  }
}