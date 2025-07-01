import 'dart:convert';
import 'package:http/http.dart' as http;

class InstagramService {
  static const String _apiKey = '60832b8403mshc5d3416ff74d6bdp130adbjsn7733a09c249b';
  static const String _apiHost = 'instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com';
  static const String _baseUrl = 'https://instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com';

  Future<Map<String, dynamic>> fetchMediaInfo(String url) async {
    if (_isYouTubeUrl(url)) {
      return await _fetchYouTubeVideo(url);
    } else if (_isTikTokUrl(url)) {
      return await _fetchTikTokVideo(url);
    } else {
      return await _fetchInstagramMedia(url);
    }
  }

  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  bool _isTikTokUrl(String url) {
    return url.contains('tiktok.com') || url.contains('vt.tiktok.com');
  }

  Future<Map<String, dynamic>> _fetchYouTubeVideo(String url) async {
    try {
      final Uri apiUrl = Uri.parse('$_baseUrl/get-info-rapidapi?url=$url');

      final response = await http.get(
        apiUrl,
        headers: {
          'Accept': 'application/json',
          'X-RapidAPI-Key': _apiKey,
          'X-RapidAPI-Host': _apiHost,
        },
      );

      print("YouTube API Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['combain'] != null && data['combain'] is List && data['combain'].isNotEmpty) {
          var firstItem = data['combain'][0];

          // Prefer audio if available
          if (firstItem['audio'] != null && firstItem['audio']['url'] != null) {
            return {
              'success': true,
              'download_url': firstItem['audio']['url'],
              'message': 'YouTube audio found! Ready to download.',
              'type': 'audio',
            };
          }

          // If video exists
          if (firstItem['video'] != null && firstItem['video']['url'] != null) {
            return {
              'success': true,
              'download_url': firstItem['video']['url'],
              'message': 'YouTube video found! Ready to download.',
              'type': 'video',
            };
          }
        }

        return {
          'success': false,
          'message': 'No valid YouTube media found in API response.',
        };
      } else {
        return {
          'success': false,
          'message': 'YouTube API request failed with status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("YouTube API Error: $e");
      return {
        'success': false,
        'message': 'Error fetching YouTube media info: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _fetchInstagramMedia(String url) async {
    try {
      final Uri apiUrl = Uri.parse('$_baseUrl/get-info-rapidapi?url=$url');

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

        if (data.containsKey('error') && data['error'] == false) {
          String downloadUrl = data['download_url'] ?? '';

          if (data['type'] == 'video' && downloadUrl.isNotEmpty) {
            return {
              'success': true,
              'download_url': downloadUrl,
              'message': 'Instagram video found! Ready to download.',
              'type': 'video',
            };
          } else if (data['type'] == 'image' && downloadUrl.isNotEmpty) {
            return {
              'success': true,
              'download_url': downloadUrl,
              'message': 'Instagram image found! Ready to download.',
              'type': 'image',
            };
          } else {
            return {
              'success': false,
              'message': 'Could not determine media type from Instagram API.',
            };
          }
        } else {
          return {
            'success': false,
            'message': 'Instagram API returned error or unknown format.',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Instagram API failed with status: ${response.statusCode}',
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

  Future<Map<String, dynamic>> _fetchTikTokVideo(String url) async {
    var result = await _fetchTikTokVideoMethod1(url);
    if (result['success']) return result;

    result = await _fetchTikTokVideoMethod2(url);
    if (result['success']) return result;

    result = await _fetchTikTokVideoMethod3(url);
    if (result['success']) return result;

    result = await _fetchTikTokVideoMethod4(url);
    return result;
  }

  Future<Map<String, dynamic>> _fetchTikTokVideoMethod1(String url) async {
    final Uri apiUrl = Uri.parse('https://api.tikwm.com/api/?url=$url');

    try {
      final response = await http.get(apiUrl);
      print("TikTok Method 1 Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['code'] == 0 && data['data'] != null) {
          String downloadUrl = data['data']['play'] ?? '';
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
      return {'success': false, 'message': 'Method 1 failed.'};
    } catch (e) {
      return {'success': false, 'message': 'Method 1 error: $e'};
    }
  }

  Future<Map<String, dynamic>> _fetchTikTokVideoMethod2(String url) async {
    final Uri apiUrl = Uri.parse('https://www.tikwm.com/api/?url=$url');

    try {
      final response = await http.get(apiUrl);
      print("TikTok Method 2 Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['code'] == 0 && data['data'] != null) {
          String downloadUrl = data['data']['play'] ?? '';
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
      return {'success': false, 'message': 'Method 2 failed.'};
    } catch (e) {
      return {'success': false, 'message': 'Method 2 error: $e'};
    }
  }

  Future<Map<String, dynamic>> _fetchTikTokVideoMethod3(String url) async {
    try {
      String videoId = _extractTikTokVideoId(url);
      if (videoId.isEmpty) {
        return {'success': false, 'message': 'Could not extract TikTok video ID.'};
      }

      final response = await http.get(
        Uri.parse('https://www.tiktok.com/@tiktok/video/$videoId'),
        headers: {'User-Agent': 'Mozilla/5.0'},
      );

      if (response.statusCode == 200) {
        RegExp regex = RegExp(r'"downloadAddr":"([^"]+)"');
        var match = regex.firstMatch(response.body);

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

      return {'success': false, 'message': 'Method 3 failed.'};
    } catch (e) {
      return {'success': false, 'message': 'Method 3 error: $e'};
    }
  }

  Future<Map<String, dynamic>> _fetchTikTokVideoMethod4(String url) async {
    final Uri apiUrl = Uri.parse('https://api.tiktokv.us/api/video?url=$url');

    try {
      final response = await http.get(apiUrl);
      print("TikTok Method 4 Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == 'success' && data['data'] != null) {
          String downloadUrl = data['data']['video'] ?? '';
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

      return {'success': false, 'message': 'Method 4 failed.'};
    } catch (e) {
      return {'success': false, 'message': 'Method 4 error: $e'};
    }
  }

  String _extractTikTokVideoId(String url) {
    RegExp regex = RegExp(r'/video/(\d+)');
    var match = regex.firstMatch(url);
    return match != null ? match.group(1)! : '';
  }
}
