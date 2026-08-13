import 'package:camera/camera.dart';

class CameraService {
  static List<CameraDescription> cameras = [];

  static Future<void> initialize() async {
    try {
      cameras = await availableCameras();
    } catch (_) {
      cameras = [];
    }
  }
}
