import 'package:flutter_test/flutter_test.dart';
import 'package:mga_face_login_app/models/face_scan_result.dart';

void main() {
  group('FaceScanResult.fromJson', () {
    test('parses a successful match', () {
      final result = FaceScanResult.fromJson({
        'status': 'success',
        'identifiedUser': 'M-42',
        'confidenceScore': '98.6%',
      });

      expect(result.status, 'success');
      expect(result.identifiedUser, 'M-42');
      expect(result.confidenceScore, '98.6%');
      expect(result.isSuccess, isTrue);
    });

    test('a null response (e.g. a failed API call) falls back to the same defaults the page used to build manually', () {
      final result = FaceScanResult.fromJson(null);

      expect(result.status, 'error');
      expect(result.identifiedUser, 'UNKNOWN');
      expect(result.confidenceScore, '0.0%');
      expect(result.isSuccess, isFalse);
    });

    test('an empty map uses the same defaults as null', () {
      final result = FaceScanResult.fromJson({});
      expect(result.status, 'error');
      expect(result.identifiedUser, 'UNKNOWN');
      expect(result.isSuccess, isFalse);
    });
  });

  group('FaceScanResult.isSuccess', () {
    test('status must be exactly "success"', () {
      final result = FaceScanResult(status: 'partial', identifiedUser: 'M-1', confidenceScore: '80%');
      expect(result.isSuccess, isFalse);
    });

    test('rejects the uppercase sentinel "UNKNOWN" even with a success status', () {
      final result = FaceScanResult(status: 'success', identifiedUser: 'UNKNOWN', confidenceScore: '0.0%');
      expect(result.isSuccess, isFalse);
    });

    test('rejects the mixed-case sentinel "Unknown" too', () {
      final result = FaceScanResult(status: 'success', identifiedUser: 'Unknown', confidenceScore: '0.0%');
      expect(result.isSuccess, isFalse);
    });

    test('a real identified user with success status is a success', () {
      final result = FaceScanResult(status: 'success', identifiedUser: 'M-7', confidenceScore: '91.2%');
      expect(result.isSuccess, isTrue);
    });
  });
}
