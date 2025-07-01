import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  Future<String> downloadMedia(String url, {String? mediaType}) async {
    if (url.isEmpty) {
      throw Exception('URL cannot be empty');
    }

    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory("/storage/emulated/0/Download");
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    // Ensure the directory exists
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }

    // Determine file extension based on URL and media type
    String fileExtension = _getFileExtension(url, mediaType);
    
    // Generate filename with timestamp
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String fileName = "media_$timestamp$fileExtension";

    String savePath = "${dir.path}/$fileName";

    // Download file
    await Dio().download(url, savePath);

    return savePath;
  }

  String _getFileExtension(String url, String? mediaType) {
    // Check URL for file extension first
    String urlLower = url.toLowerCase();
    
    if (urlLower.contains('.mp4')) return '.mp4';
    if (urlLower.contains('.mov')) return '.mov';
    if (urlLower.contains('.avi')) return '.avi';
    if (urlLower.contains('.mkv')) return '.mkv';
    if (urlLower.contains('.webm')) return '.webm';
    if (urlLower.contains('.jpg') || urlLower.contains('.jpeg')) return '.jpg';
    if (urlLower.contains('.png')) return '.png';
    if (urlLower.contains('.gif')) return '.gif';
    if (urlLower.contains('.heic')) return '.heic';
    
    // Fallback based on media type
    if (mediaType == 'video') return '.mp4';
    if (mediaType == 'image') return '.jpg';
    
    // Default fallback
    return '.mp4';
  }

  Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      Directory downloadDir = Directory("/storage/emulated/0/Download");
      return await downloadDir.exists();
    }
    return true;
  }
} 