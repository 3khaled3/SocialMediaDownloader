import 'package:flutter/material.dart';
import '../services/instagram_service.dart';
import '../services/download_service.dart';
import '../services/permission_service.dart';
import '../widgets/custom_button.dart';
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
        _status = "Please enter a valid URL";
      });
      return;
    }

    setState(() {
      _isFetching = true;
      _status = AppConstants.fetchingMessage;
      _mediaUrl = "";
      _mediaType = "";
    });

    try {
      final result = await _instagramService.fetchMediaInfo(url);

      setState(() {
        if (result['success']) {
          _mediaUrl = result['download_url'];
          _mediaType = result['type'] ?? 'video';
          _status = result['message'];
        } else {
          _status = result['message'];
        }
      });
    } catch (e) {
      setState(() {
        _status = "${AppConstants.errorFetchingMessage}$e";
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
      final savePath = await _downloadService.downloadMedia(url, mediaType: _mediaType);

      setState(() {
        _status = "${AppConstants.downloadCompleteMessage}$savePath";
      });
    } catch (e) {
      setState(() {
        _status = "${AppConstants.errorDownloadingMessage}$e";
      });
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Social Media Downloader"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: "Enter Instagram or TikTok URL",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: "Fetch Media URL",
              onPressed: () => _fetchMediaInfo(_urlController.text),
              isLoading: _isFetching,
              backgroundColor: Colors.blue,
            ),
            const SizedBox(height: 20),
            if (_mediaUrl.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      "Media Type: ${_mediaType.toUpperCase()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "URL: ${_mediaUrl.length > 50 ? '${_mediaUrl.substring(0, 50)}...' : _mediaUrl}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: "Download ${_mediaType.toUpperCase()}",
                onPressed: () => _downloadMedia(_mediaUrl),
                isLoading: _isDownloading,
                backgroundColor: Colors.green,
              ),
            ],
            const SizedBox(height: 20),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _status.contains("Error") ? Colors.red : Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
