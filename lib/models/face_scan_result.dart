class FaceScanResult {
  final String status;
  final String identifiedUser;
  final String confidenceScore;

  const FaceScanResult({
    required this.status,
    required this.identifiedUser,
    required this.confidenceScore,
  });

  factory FaceScanResult.fromJson(Map<String, dynamic>? json) {
    final Map<String, dynamic> data = json ?? {};
    return FaceScanResult(
      status: data['status'] ?? 'error',
      identifiedUser: data['identifiedUser'] ?? 'UNKNOWN',
      confidenceScore: data['confidenceScore'] ?? '0.0%',
    );
  }

  bool get isSuccess => status == 'success' && identifiedUser != 'UNKNOWN' && identifiedUser != 'Unknown';
}
