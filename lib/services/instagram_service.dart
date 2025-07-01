import 'dart:convert';
import 'package:http/http.dart' as http;

class InstagramService {
  static const String _apiKey = '60832b8403mshc5d3416ff74d6bdp130adbjsn7733a09c249b';
  static const String _apiHost = 'instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com';
  static const String _baseUrl = 'https://instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com';
  
  // Free TikTok video extraction service
  static const String _tiktokFreeApiUrl = 'https://api16-normal-c-useast1a.tiktokv.com/aweme/v1/feed/';

  Future<Map<String, dynamic>> fetchMediaInfo(String url) async {
    // Check if it's a TikTok URL
    if (_isTikTokUrl(url)) {
      return await _fetchTikTokVideo(url);
    } else {
      return await _fetchInstagramMedia(url);
    }
  }

  bool _isTikTokUrl(String url) {
    return url.contains('tiktok.com') || url.contains('vt.tiktok.com');
  }

  Future<Map<String, dynamic>> _fetchTikTokVideo(String url) async {
    // Try multiple free methods to extract TikTok video
    var result = await _fetchTikTokVideoMethod1(url);
    if (result['success']) {
      return result;
    }
    
    result = await _fetchTikTokVideoMethod2(url);
    if (result['success']) {
      return result;
    }
    
    result = await _fetchTikTokVideoMethod3(url);
    if (result['success']) {
      return result;
    }
    
    result = await _fetchTikTokVideoMethod4(url);
    return result;
  }

  Future<Map<String, dynamic>> _fetchTikTokVideoMethod1(String url) async {
    // Method 1: Use a free TikTok video downloader service
    final Uri apiUrl = Uri.parse('https://api.tikwm.com/api/?url=$url');

    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      print("TikTok Method 1 Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        
        if (data['code'] == 0 && data['data'] != null) {
          var videoData = data['data'];
          String downloadUrl = videoData['play'] ?? videoData['wmplay'] ?? '';
          
          if (downloadUrl.isNotEmpty) {
            return {
              'success': true,
              'download_url': downloadUrl,
              'message': 'TikTok video found! Ready to download.',
              'type': 'video',
            };
          }
        }
      }
      
      return {
        'success': false,
        'message': 'Method 1 failed.',
      };
    } catch (e) {
      print("TikTok Method 1 Error: $e");
      return {
        'success': false,
        'message': 'Method 1 error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _fetchTikTokVideoMethod2(String url) async {
    // Method 2: Use another free service
    final Uri apiUrl = Uri.parse('https://www.tikwm.com/api/?url=$url');

    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      print("TikTok Method 2 Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        
        if (data['code'] == 0 && data['data'] != null) {
          var videoData = data['data'];
          String downloadUrl = videoData['play'] ?? videoData['wmplay'] ?? '';
          
          if (downloadUrl.isNotEmpty) {
            return {
              'success': true,
              'download_url': downloadUrl,
              'message': 'TikTok video found! Ready to download.',
              'type': 'video',
            };
          }
        }
      }
      
      return {
        'success': false,
        'message': 'Method 2 failed.',
      };
    } catch (e) {
      print("TikTok Method 2 Error: $e");
      return {
        'success': false,
        'message': 'Method 2 error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _fetchTikTokVideoMethod3(String url) async {
    // Method 3: Try to extract video ID and use direct TikTok API
    try {
      // Extract video ID from URL
      String videoId = _extractTikTokVideoId(url);
      if (videoId.isEmpty) {
        return {
          'success': false,
          'message': 'Could not extract TikTok video ID.',
        };
      }

      // Use a simple web scraping approach
      final response = await http.get(
        Uri.parse('https://www.tiktok.com/@tiktok/video/$videoId'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        String body = response.body;
        
        // Look for video URL in the page source
        RegExp videoRegex = RegExp(r'"downloadAddr":"([^"]+)"');
        var match = videoRegex.firstMatch(body);
        
        if (match != null) {
          String videoUrl = match.group(1)!.replaceAll('\\u002F', '/');
          return {
            'success': true,
            'download_url': videoUrl,
            'message': 'TikTok video found! Ready to download.',
            'type': 'video',
          };
        }
      }
      
      return {
        'success': false,
        'message': 'Could not extract TikTok video URL from all methods.',
      };
    } catch (e) {
      print("TikTok Method 3 Error: $e");
      return {
        'success': false,
        'message': 'Error extracting TikTok video: $e',
      };
    }
  }

  String _extractTikTokVideoId(String url) {
    // Extract video ID from various TikTok URL formats
    RegExp regex = RegExp(r'/video/(\d+)');
    var match = regex.firstMatch(url);
    if (match != null) {
      return match.group(1)!;
    }
    
    // Try alternative format
    regex = RegExp(r'@[^/]+/video/(\d+)');
    match = regex.firstMatch(url);
    if (match != null) {
      return match.group(1)!;
    }
    
    return '';
  }

  Future<Map<String, dynamic>> _fetchTikTokVideoMethod4(String url) async {
    // Method 4: Use another free TikTok downloader service
    final Uri apiUrl = Uri.parse('https://api.tiktokv.us/api/video?url=$url');

    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      print("TikTok Method 4 Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        
        if (data['status'] == 'success' && data['data'] != null) {
          var videoData = data['data'];
          String downloadUrl = videoData['video'] ?? videoData['play'] ?? '';
          
          if (downloadUrl.isNotEmpty) {
            return {
              'success': true,
              'download_url': downloadUrl,
              'message': 'TikTok video found! Ready to download.',
              'type': 'video',
            };
          }
        }
      }
      
      return {
        'success': false,
        'message': 'Method 4 failed.',
      };
    } catch (e) {
      print("TikTok Method 4 Error: $e");
      return {
        'success': false,
        'message': 'Method 4 error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _fetchInstagramMedia(String url) async {
    final Uri apiUrl = Uri.parse('$_baseUrl/get-info-rapidapi?url=$url');

    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Accept': 'application/json',
          'X-RapidAPI-Key': _apiKey,
          'X-RapidAPI-Host': _apiHost,
        },
      );

      print("Instagram API Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        
        if (!data['error']) {
          String downloadUrl = data['download_url'];
          
          // Check if the URL is actually a video (not an image)
          if (data['type'] == 'video' && !downloadUrl.contains('.heic') && !downloadUrl.contains('.jpg') && !downloadUrl.contains('.jpeg') && !downloadUrl.contains('.png')) {
            return {
              'success': true,
              'download_url': downloadUrl,
              'message': 'Instagram video found! Ready to download.',
              'type': 'video',
            };
          } else if (data['type'] == 'image' || downloadUrl.contains('.heic') || downloadUrl.contains('.jpg') || downloadUrl.contains('.jpeg') || downloadUrl.contains('.png')) {
            return {
              'success': true,
              'download_url': downloadUrl,
              'message': 'Instagram image found! Ready to download.',
              'type': 'image',
            };
          } else {
            return {
              'success': false,
              'message': 'Could not determine media type.',
            };
          }
        } else {
          return {
            'success': false,
            'message': 'Error fetching Instagram media info.',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch Instagram media info: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("Instagram API Error: $e");
      return {
        'success': false,
        'message': 'Error fetching Instagram media info: $e',
      };
    }
  }
} 