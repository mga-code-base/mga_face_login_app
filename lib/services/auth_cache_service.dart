import 'package:shared_preferences/shared_preferences.dart';

class AuthCacheService {
  static const Duration _tokenTtl = Duration(hours: 3);

  static Future<void> saveAdminSession({required String token, required String adminId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('personId', adminId);
    await prefs.setString('token_issued_at', DateTime.now().millisecondsSinceEpoch.toString());
  }

  static Future<bool> _isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final String? issuedAtRaw = prefs.getString('token_issued_at');
    if (issuedAtRaw == null) return false;
    final int? issuedAtMillis = int.tryParse(issuedAtRaw);
    if (issuedAtMillis == null) return false;
    final DateTime issuedAt = DateTime.fromMillisecondsSinceEpoch(issuedAtMillis);
    return DateTime.now().difference(issuedAt) > _tokenTtl;
  }

  static Future<String?> getValidToken() async {
    if (await _isTokenExpired()) {
      await logoutAdmin();
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getAdminToken() async {
    return getValidToken();
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final String? token = await getValidToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> getBearerHeaderOnly() async {
    final String? token = await getValidToken();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<void> logoutAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('personId');
    await prefs.remove('token_issued_at');
  }
}
