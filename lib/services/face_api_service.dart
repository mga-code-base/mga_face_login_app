import 'dart:convert';
import '../core/network/api_client.dart';

class FaceApiService {
  static final ApiClient _client = ApiClient();

  static Future<Map<String, dynamic>?> verifyFace(String imagePath) async {
    try {
      final response = await _client.postMultipart('/face/identify', fileField: 'file', filePath: imagePath);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> registerMember(String username, String videoPath) async {
    try {
      final response = await _client.postMultipart(
        '/face/register-video',
        fileField: 'video',
        filePath: videoPath,
        fields: {'username': username},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': response.body};
      }
      return {'success': false, 'message': response.body};
    } catch (e) {
      return {'success': false, 'message': "Unexpected processing error: $e"};
    }
  }
}
