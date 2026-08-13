import 'package:flutter_test/flutter_test.dart';
import 'package:mga_face_login_app/services/auth_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('saveAdminSession / getValidToken', () {
    test('a freshly saved session returns its token', () async {
      await AuthCacheService.saveAdminSession(token: 'fresh-token', adminId: 'A-1');
      expect(await AuthCacheService.getValidToken(), 'fresh-token');
    });

    test('a token cached less than 3 hours ago is still valid', () async {
      SharedPreferences.setMockInitialValues({
        'token': 'still-good',
        'token_issued_at': DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch.toString(),
      });

      expect(await AuthCacheService.getValidToken(), 'still-good');
    });

    test('a token cached more than 3 hours ago is expired and cleared', () async {
      SharedPreferences.setMockInitialValues({
        'token': 'stale',
        'personId': 'A-1',
        'token_issued_at': DateTime.now().subtract(const Duration(hours: 3, minutes: 1)).millisecondsSinceEpoch.toString(),
      });

      expect(await AuthCacheService.getValidToken(), isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('personId'), isNull);
    });

    test('a token exactly at the boundary is treated as expired', () async {
      SharedPreferences.setMockInitialValues({
        'token': 'boundary',
        'token_issued_at': DateTime.now().subtract(const Duration(hours: 3, seconds: 1)).millisecondsSinceEpoch.toString(),
      });

      expect(await AuthCacheService.getValidToken(), isNull);
    });

    test('a token with no issued-at timestamp is treated as not expired', () async {
      SharedPreferences.setMockInitialValues({'token': 'legacy-token'});
      expect(await AuthCacheService.getValidToken(), 'legacy-token');
    });

    test('no cached session at all returns null', () async {
      expect(await AuthCacheService.getValidToken(), isNull);
    });
  });

  group('getAdminToken', () {
    test('is TTL-aware, same as getValidToken', () async {
      SharedPreferences.setMockInitialValues({
        'token': 'stale',
        'token_issued_at': DateTime.now().subtract(const Duration(hours: 4)).millisecondsSinceEpoch.toString(),
      });

      expect(await AuthCacheService.getAdminToken(), isNull);
    });
  });

  group('getAuthHeaders / getBearerHeaderOnly', () {
    test('getAuthHeaders includes Content-Type and a Bearer token', () async {
      await AuthCacheService.saveAdminSession(token: 'my-token', adminId: 'A-1');
      final headers = await AuthCacheService.getAuthHeaders();

      expect(headers['Content-Type'], 'application/json');
      expect(headers['Authorization'], 'Bearer my-token');
    });

    test('getBearerHeaderOnly omits Content-Type, for multipart uploads', () async {
      await AuthCacheService.saveAdminSession(token: 'my-token', adminId: 'A-1');
      final headers = await AuthCacheService.getBearerHeaderOnly();

      expect(headers.containsKey('Content-Type'), isFalse);
      expect(headers['Authorization'], 'Bearer my-token');
    });

    test('both omit Authorization when the token is expired', () async {
      SharedPreferences.setMockInitialValues({
        'token': 'stale',
        'token_issued_at': DateTime.now().subtract(const Duration(hours: 5)).millisecondsSinceEpoch.toString(),
      });

      final headers = await AuthCacheService.getAuthHeaders();
      final bearerOnly = await AuthCacheService.getBearerHeaderOnly();

      expect(headers.containsKey('Authorization'), isFalse);
      expect(bearerOnly.containsKey('Authorization'), isFalse);
    });
  });

  group('logoutAdmin', () {
    test('wipes token, personId, and the issued-at timestamp', () async {
      await AuthCacheService.saveAdminSession(token: 't', adminId: 'A-1');
      await AuthCacheService.logoutAdmin();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('token'), isNull);
      expect(prefs.getString('personId'), isNull);
      expect(prefs.getString('token_issued_at'), isNull);
    });
  });
}
