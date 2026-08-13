import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../services/camera_service.dart';
import '../../services/face_api_service.dart';

class NewMemberPage extends StatefulWidget {
  const NewMemberPage({super.key});

  @override
  State<NewMemberPage> createState() => _NewMemberPageState();
}

class _NewMemberPageState extends State<NewMemberPage> {
  CameraController? _cameraController;
  final _usernameController = TextEditingController();
  bool _isRecording = false;
  bool _isProcessing = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (CameraService.cameras.isEmpty) return;
    _cameraController = CameraController(CameraService.cameras[_selectedCameraIndex], ResolutionPreset.medium, enableAudio: false);
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  void _toggleLens() {
    if (CameraService.cameras.length < 2) return;
    setState(() {
      _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    });
    _initCamera();
  }

  void _onRecordPressed() async {
    if (_isRecording) {
      final XFile file = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      final Map<String, dynamic> response = await FaceApiService.registerMember(
        _usernameController.text.trim(),
        file.path,
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (response['success'] == true) {
        _showNotification(
          message: response['message'] ?? "Face processed successfully.",
          isSuccess: true,
        );
        _usernameController.clear();
      } else {
        _showNotification(
          message: response['message'] ?? "An unknown validation error occurred.",
          isSuccess: false,
        );
      }
    } else {
      if (_usernameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a username first.')),
        );
        return;
      }
      await _cameraController!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  void _showNotification({required String message, required bool isSuccess}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Registration'),
        actions: [IconButton(icon: const Icon(Icons.flip_camera_android), onPressed: _toggleLens)],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text('Thank You for Waiting, almost there...'),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'New Member Username', border: OutlineInputBorder()),
                  ),
                ),
                Expanded(child: CameraPreview(_cameraController!)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? Colors.red : Colors.blueAccent,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: _onRecordPressed,
                    icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
                    label: Text(_isRecording ? 'Stop Recording' : 'Start Registration Video'),
                  ),
                )
              ],
            ),
    );
  }
}
