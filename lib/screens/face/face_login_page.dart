import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../models/face_scan_result.dart';
import '../../services/camera_service.dart';
import '../../services/face_api_service.dart';
import 'scan_result_page.dart';

class FaceLoginPage extends StatefulWidget {
  const FaceLoginPage({super.key});

  @override
  State<FaceLoginPage> createState() => _FaceLoginPageState();
}

class _FaceLoginPageState extends State<FaceLoginPage> {
  CameraController? _cameraController;
  bool _isProcessing = false;

  static const Color _themeAccent = Colors.cyanAccent;

  @override
  void initState() {
    super.initState();
    _initFrontCamera();
  }

  Future<void> _initFrontCamera() async {
    if (CameraService.cameras.isEmpty) return;
    final frontCam = CameraService.cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => CameraService.cameras.first,
    );

    _cameraController = CameraController(frontCam, ResolutionPreset.high, enableAudio: false);
    await _cameraController!.initialize();
    if (mounted) setState(() {});

    _triggerAutomaticDetectionPipeline();
  }

  Future<void> _triggerAutomaticDetectionPipeline() async {
    await Future.delayed(const Duration(seconds: 3));
    if (_cameraController != null && _cameraController!.value.isInitialized && !_isProcessing) {
      _captureAndVerify();
    }
  }

  void _captureAndVerify() async {
    if (!mounted) return;
    setState(() => _isProcessing = true);
    try {
      final XFile photo = await _cameraController!.takePicture();

      final result = await FaceApiService.verifyFace(photo.path);
      if (!mounted) return;

      final FaceScanResult scanResult = FaceScanResult.fromJson(result);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanResultPage(result: scanResult),
          ),
        ).then((_) async {
          if (mounted) {
            await _cameraController?.dispose();
            _cameraController = null;
            setState(() => _isProcessing = false);
            _initFrontCamera();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification exception occurred: $e')),
      );
      if (mounted) {
        await _cameraController?.dispose();
        _cameraController = null;
        setState(() => _isProcessing = false);
        _initFrontCamera();
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F14),
        body: Center(child: CircularProgressIndicator(color: _themeAccent)),
      );
    }

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F14),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16161F),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _themeAccent),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Face Login Active Scan'), centerTitle: true),
        body: Stack(
          children: [
            CameraPreview(_cameraController!),
            Center(
              child: Container(
                width: 250,
                height: 320,
                decoration: BoxDecoration(
                  border: Border.all(color: _isProcessing ? Colors.orangeAccent : _themeAccent, width: 3),
                  borderRadius: BorderRadius.circular(160),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  color: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _isProcessing ? 'Verifying Vectors...' : 'Hold still: Auto capturing face...',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
