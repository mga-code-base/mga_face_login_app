import 'dart:convert';
import '../core/network/api_client.dart';
import 'auth_cache_service.dart';

class AdminApiService {
  static final ApiClient _client = ApiClient();

  static Future<String?> loginAdmin(String username, String password) async {
    try {
      final response = await _client.post(
        '/admins/login',
        body: {'username': username, 'password': password},
        auth: false,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final bool? isActive = responseData['isActive'];
        final String? token = responseData['token'];
        final String? adminId = responseData['personId'];

        if (isActive == false) return 'Inactive Account';

        if (token != null) {
          await AuthCacheService.saveAdminSession(token: token, adminId: adminId ?? '');
          return null;
        }
      }
      return 'Invalid Admin Credentials.';
    } catch (_) {
      return 'Connection error. Please try again.';
    }
  }
}
