import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';
import '../../services/auth_cache_service.dart';

class ApiClient {
  final String _baseUrl;
  final http.Client _client;

  ApiClient({String? baseUrl, http.Client? client})
      : _baseUrl = baseUrl ?? AppConstants.mgaServiceUrl,
        _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, String>> _resolveHeaders(bool auth) async {
    return auth
        ? await AuthCacheService.getAuthHeaders()
        : const {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  Future<http.Response> post(String path, {Object? body, bool auth = true}) async {
    return _client.post(
      _uri(path),
      headers: await _resolveHeaders(auth),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> postMultipart(
    String path, {
    required String fileField,
    required String filePath,
    Map<String, String>? fields,
    bool auth = true,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    if (fields != null) request.fields.addAll(fields);
    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

    if (auth) {
      request.headers.addAll(await AuthCacheService.getBearerHeaderOnly());
    }

    final streamedResponse = await _client.send(request);
    return http.Response.fromStream(streamedResponse);
  }
}
