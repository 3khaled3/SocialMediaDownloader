class MediaInfo {
  final String downloadUrl;
  final String message;
  final bool success;

  MediaInfo({
    required this.downloadUrl,
    required this.message,
    required this.success,
  });

  factory MediaInfo.fromJson(Map<String, dynamic> json) {
    return MediaInfo(
      downloadUrl: json['download_url'] ?? '',
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'download_url': downloadUrl,
      'message': message,
      'success': success,
    };
  }
} 