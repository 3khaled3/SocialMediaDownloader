import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../services/instagram_service.dart';
import '../services/download_service.dart';
import '../services/permission_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/video_preview.dart';
import '../widgets/image_preview.dart';
import '../utils/constants.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final TextEditingController _urlController = TextEditingController();
  final InstagramService _instagramService = InstagramService();
  final DownloadService _downloadService = DownloadService();
  final PermissionService _permissionService = PermissionService();

  String _status = AppConstants.enterUrlMessage;
  String _mediaUrl = "";
  String _mediaType = "";
  bool _isFetching = false;
  bool _isDownloading = false;
  String? _downloadedFilePath;
  String? _downloadedFileName;
  int? _downloadedFileSize;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _permissionService.requestStoragePermissions();
  }

  Future<void> _fetchMediaInfo(String url) async {
    if (url.isEmpty) {
      setState(() {
        _status = "⚠️ Please enter a valid URL";
        _showSnackBar("Please enter a valid URL");
      });
      return;
    }

    setState(() {
      _isFetching = true;
      _status = AppConstants.fetchingMessage;
      _mediaUrl = "";
      _mediaType = "";
      _downloadedFilePath = null;
    });

    try {
      final result = await _instagramService.fetchMediaInfo(url);

      setState(() {
        if (result['success']) {
          _mediaUrl = result['download_url'];
          _mediaType = result['type'] ?? 'video';
          _status = "✅ ${result['message']}";
          _showSnackBar("Media found! Ready to download");
        } else {
          _status = "❌ ${result['message']}";
          _showSnackBar("Failed to fetch media: ${result['message']}");
        }
      });
    } catch (e) {
      setState(() {
        _status = "❌ ${AppConstants.errorFetchingMessage}";
        _showSnackBar("Error fetching media: $e");
      });
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  Future<void> _downloadMedia(String url) async {
    if (url.isEmpty) return;

    setState(() {
      _isDownloading = true;
      _status = AppConstants.downloadingMessage;
    });

    try {
      await _requestPermissions();
      final result = await _downloadService.downloadMedia(url,
          mediaType:
              _urlController.text.contains("youtube") ? "mp3" : _mediaType);

      setState(() {
        _downloadedFilePath = result['path'];
        _downloadedFileName = result['fileName'];
        _downloadedFileSize = result['fileSize'];
        _status = "✅ ${AppConstants.downloadCompleteMessage}";
        _showSnackBar("Download complete! Tap to preview");
      });
    } catch (e) {
      setState(() {
        _status = "❌ ${AppConstants.errorDownloadingMessage}";
        _showSnackBar("Download failed: $e");
      });
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showPreview() {
    if (_downloadedFilePath == null) return;
    if (_urlController.text.contains("youtube")) {
      //open file 
      File file = File(_downloadedFilePath!);
      if (file.existsSync()) {
        OpenFile.open(file.path);
      }
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _mediaType == 'video'
            ? VideoPreview(videoPath: _downloadedFilePath!, onClose: () {})
            : ImagePreview(imagePath: _downloadedFilePath!, onClose: () {}),
      ),
    );
  }

  void _resetDownloadState() {
    setState(() {
      _downloadedFilePath = null;
      _downloadedFileName = null;
      _downloadedFileSize = null;
      _status = AppConstants.enterUrlMessage;
      _mediaUrl = "";
      _urlController.clear();
    });
  }

  Widget _buildStatusMessage() {
    Color textColor = Colors.grey[800]!;
    IconData statusIcon = Icons.info_outline;

    if (_status.contains("❌")) {
      textColor = Colors.red[600]!;
      statusIcon = Icons.error_outline;
    } else if (_status.contains("✅")) {
      textColor = Colors.green[700]!;
      statusIcon = Icons.check_circle_outline;
    } else if (_status.contains("⚠️")) {
      textColor = Colors.orange[700]!;
      statusIcon = Icons.warning_amber_outlined;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 16),
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(statusIcon, color: textColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _status
                    .replaceAll("⚠️", "")
                    .replaceAll("❌", "")
                    .replaceAll("✅", "")
                    .trim(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadInfoCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _showPreview,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.blue.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _mediaType == 'video'
                          ? Icons.videocam_rounded
                          : Icons.image_rounded,
                      color: Colors.blue.shade800,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Download Complete!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.insert_drive_file, "File:",
                  _downloadedFileName ?? "Unknown"),
              if (_downloadedFileSize != null)
                _buildInfoRow(Icons.storage, "Size:",
                    "${(_downloadedFileSize! / 1024 / 1024).toStringAsFixed(2)} MB"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: CustomButton(
                        text: "Preview",
                        onPressed: _showPreview,
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        icon: Icons.play_arrow_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: CustomButton(
                        text: "New Download",
                        onPressed: _resetDownloadState,
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.grey.shade800,
                        icon: Icons.refresh_rounded,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey.shade600),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.blueGrey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Social Media Downloader",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              "Paste your link below",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: "Paste Instagram, TikTok, or YouTube URL here",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultBorderRadius),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultBorderRadius),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultBorderRadius),
                  borderSide: BorderSide(
                    color: Colors.blue.shade400,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.link_rounded,
                  color: Colors.blue.shade600,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: CustomButton(
                text: "Fetch Media",
                onPressed: () => _fetchMediaInfo(_urlController.text),
                isLoading: _isFetching,
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                icon: Icons.search_rounded,
              ),
            ),
            const SizedBox(height: 12),
            if (_mediaUrl.isNotEmpty)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  height: 50,
                  child: CustomButton(
                    key: ValueKey(_mediaUrl),
                    text: "Download ${_mediaType.toUpperCase()}",
                    onPressed: () => _downloadMedia(_mediaUrl),
                    isLoading: _isDownloading,
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    icon: Icons.download_rounded,
                  ),
                ),
              ),
            if (_downloadedFilePath != null) _buildDownloadInfoCard(),
            _buildStatusMessage(),
            const SizedBox(height: 20),
            if (_mediaUrl.isEmpty && _downloadedFilePath == null)
              Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.download_rounded,
                    size: 80,
                    color: Colors.blue.shade200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Download social media content",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Paste a link from Instagram, TikTok, or YouTube to download photos, videos, or reels",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
