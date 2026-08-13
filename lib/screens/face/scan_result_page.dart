import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/face_scan_result.dart';

class ScanResultPage extends StatefulWidget {
  final FaceScanResult result;

  const ScanResultPage({super.key, required this.result});

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  Timer? _countdownTimer;
  int _secondsRemaining = 5;

  @override
  void initState() {
    super.initState();
    _startAutoRedirectTimer();
  }

  void _startAutoRedirectTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 1) {
            _secondsRemaining--;
          } else {
            _countdownTimer?.cancel();
            Navigator.pop(context);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = widget.result.isSuccess;
    final String userId = widget.result.identifiedUser;
    final String confidence = widget.result.confidenceScore;

    return Scaffold(
      backgroundColor: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Icon(
                          isSuccess ? Icons.check_circle : Icons.cancel,
                          color: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
                          size: 90,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isSuccess ? 'ACCESS GRANTED' : 'ACCESS DENIED',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Divider(height: 1, thickness: 1.2),
                      ),
                      if (isSuccess) ...[
                        _buildResultRow('MEMBER ID', userId, Icons.badge),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            'Face profile could not be verified against any registered database entry.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.4),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _buildResultRow('MATCH CONFIDENCE', confidence, Icons.analytics),
                      const SizedBox(height: 36),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'OK (${_secondsRemaining}s)',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
