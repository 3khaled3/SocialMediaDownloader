import 'package:flutter/material.dart';
import 'screens/download_screen.dart';

void main() {
  runApp(const InstagramDownloaderApp());
}

class InstagramDownloaderApp extends StatelessWidget {
  const InstagramDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Media Downloader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const DownloadScreen(),
    );
  }
}
