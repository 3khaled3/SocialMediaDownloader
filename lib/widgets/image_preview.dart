import 'package:flutter/material.dart';
import 'dart:io';

class ImagePreview extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onClose;

  const ImagePreview({
    super.key,
    required this.imagePath,
    this.onClose,
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkImageFile();
  }

  Future<void> _checkImageFile() async {
    try {
      final file = File(widget.imagePath);
      if (await file.exists()) {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Image Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              widget.onClose?.call();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : _hasError
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _hasError = false;
                          });
                          _checkImageFile();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                : InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
      ),
    );
  }
} 