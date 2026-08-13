import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mga_face_login_app/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiClient.post', () {
    test('builds the correct default base URL and JSON-encodes the body', () async {
      late http.Request captured;
      final mockClient = MockClient((request) async {
        captured = request as http.Request;
        return http.Response('{}', 200);
      });
      final client = ApiClient(client: mockClient);

      await client.post('/admins/login', body: {'username': 'bob', 'password': 'pw'}, auth: false);

      expect(captured.method, 'POST');
      expect(captured.url.toString(), 'https://api.06071995.xyz/api/admins/login');
      expect(captured.body, '{"username":"bob","password":"pw"}');
    });

    test('a custom baseUrl overrides the default', () async {
      late http.Request captured;
      final mockClient = MockClient((request) async {
        captured = request as http.Request;
        return http.Response('{}', 200);
      });
      final client = ApiClient(baseUrl: 'https://custom.example.com', client: mockClient);

      await client.post('/admins/login', auth: false);

      expect(captured.url.toString(), 'https://custom.example.com/admins/login');
    });

    test('auth:false never attaches Authorization, even with a cached token', () async {
      SharedPreferences.setMockInitialValues({
        'token': 'some-token',
        'token_issued_at': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      late http.Request captured;
      final mockClient = MockClient((request) async {
        captured = request as http.Request;
        return http.Response('{}', 200);
      });
      final client = ApiClient(client: mockClient);

      await client.post('/admins/login', auth: false);

      expect(captured.headers.containsKey('Authorization'), isFalse);
    });

    test('auth:true (the default) injects a Bearer token when one is cached', () async {
      SharedPreferences.setMockInitialValues({
        'token': 'test-token-123',
        'token_issued_at': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      late http.Request captured;
      final mockClient = MockClient((request) async {
        captured = request as http.Request;
        return http.Response('{}', 200);
      });
      final client = ApiClient(client: mockClient);

      await client.post('/face/some-json-endpoint');

      expect(captured.headers['Authorization'], 'Bearer test-token-123');
    });

    test('an expired cached token is not attached', () async {
      SharedPreferences.setMockInitialValues({
        'token': 'stale-token',
        'token_issued_at': DateTime.now().subtract(const Duration(hours: 4)).millisecondsSinceEpoch.toString(),
      });
      late http.Request captured;
      final mockClient = MockClient((request) async {
        captured = request as http.Request;
        return http.Response('{}', 200);
      });
      final client = ApiClient(client: mockClient);

      await client.post('/face/some-json-endpoint');

      expect(captured.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('ApiClient.postMultipart', () {
    late File tempFile;

    setUp(() async {
      tempFile = File('${Directory.systemTemp.path}/api_client_test_upload.tmp');
      await tempFile.writeAsBytes([1, 2, 3, 4]);
    });

    tearDown(() async {
      if (await tempFile.exists()) await tempFile.delete();
    });

    test('sends a multipart request with the file and extra fields attached', () async {
      late http.MultipartRequest captured;
      final mockClient = MockClient.streaming((request, bodyStream) async {
        captured = request as http.MultipartRequest;
        return http.StreamedResponse(Stream.value('ok'.codeUnits), 200);
      });
      final client = ApiClient(client: mockClient);

      await client.postMultipart(
        '/face/register-video',
        fileField: 'video',
        filePath: tempFile.path,
        fields: {'username': 'bob'},
        auth: false,
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/api/face/register-video');
      expect(captured.fields['username'], 'bob');
      expect(captured.files.single.field, 'video');
    });

    test('does not force a Content-Type header, letting the multipart boundary stand', () async {
      late http.MultipartRequest captured;
      final mockClient = MockClient.streaming((request, bodyStream) async {
        captured = request as http.MultipartRequest;
        return http.StreamedResponse(Stream.value('ok'.codeUnits), 200);
      });
      final client = ApiClient(client: mockClient);

      await client.postMultipart('/face/identify', fileField: 'file', filePath: tempFile.path, auth: false);

      expect(captured.headers['content-type'], contains('multipart/form-data'));
    });

    test('auth:true attaches only an Authorization header, no Content-Type override', () async {
      SharedPreferences.setMockInitialValues({
        'token': 'upload-token',
        'token_issued_at': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      late http.MultipartRequest captured;
      final mockClient = MockClient.streaming((request, bodyStream) async {
        captured = request as http.MultipartRequest;
        return http.StreamedResponse(Stream.value('ok'.codeUnits), 200);
      });
      final client = ApiClient(client: mockClient);

      await client.postMultipart('/face/identify', fileField: 'file', filePath: tempFile.path);

      expect(captured.headers['Authorization'], 'Bearer upload-token');
      expect(captured.headers['content-type'], contains('multipart/form-data'));
    });

    test('the raw response is returned untouched', () async {
      final mockClient = MockClient((request) async => http.Response('{"success":true}', 201));
      final client = ApiClient(client: mockClient);

      final response = await client.postMultipart('/face/identify', fileField: 'file', filePath: tempFile.path, auth: false);

      expect(response.statusCode, 201);
      expect(response.body, '{"success":true}');
    });
  });
}