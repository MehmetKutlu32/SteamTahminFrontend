import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpClient, Platform, X509Certificate;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../models/game_item.dart';
import '../models/game_review_dto.dart';
import '../models/round_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message ${statusCode != null ? '($statusCode)' : ''}';
}

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? _getDefaultBaseUrl(),
        _client = client ?? _createDefaultClient();

  static http.Client _createDefaultClient() {
    if (kIsWeb) {
      return http.Client();
    }
    final ioHttpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return IOClient(ioHttpClient);
  }

  static const String liveBaseUrl = 'https://steamtahminbackend.onrender.com';

  /// Returns the default production backend URL
  static String _getDefaultBaseUrl() {
    return liveBaseUrl;
  }

  static const Duration _timeout = Duration(seconds: 60);

  /// 1. GET /api/game/start-round?count=10&censorProfanity=true
  Future<RoundModel> startRound({
    int count = 10,
    bool censorProfanity = true,
  }) async {
    final uri = Uri.parse('$baseUrl/api/game/start-round?count=$count&censorProfanity=$censorProfanity');
    final response = await _get(uri);
    final dynamic decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return RoundModel.fromJson(decoded);
    } else {
      throw ApiException('Invalid response format for startRound: expected JSON object');
    }
  }

  /// 2. GET /api/game/games
  Future<List<GameItem>> getGames() async {
    final uri = Uri.parse('$baseUrl/api/game/games');
    final response = await _get(uri);
    final dynamic decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .map((item) => GameItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException('Invalid response format for getGames: expected JSON array');
    }
  }

  /// 3. GET /api/game/extra-review?appId={id}&count=1&censorProfanity=true
  Future<List<GameReviewDto>> getExtraReview({
    required int appId,
    int count = 1,
    bool censorProfanity = true,
  }) async {
    final uri = Uri.parse('$baseUrl/api/game/extra-review?appId=$appId&count=$count&censorProfanity=$censorProfanity');
    final response = await _get(uri);
    final dynamic decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .map((item) => GameReviewDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (decoded is Map<String, dynamic>) {
      // In case single object is returned
      return [GameReviewDto.fromJson(decoded)];
    } else {
      throw ApiException('Invalid response format for getExtraReview');
    }
  }

  /// 4. POST /api/user/google-login
  Future<Map<String, dynamic>?> googleLogin({
    required String googleId,
    required String userName,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/user/google-login');
      final body = jsonEncode({
        'googleId': googleId,
        'userName': userName,
        'email': email,
        'avatarUrl': avatarUrl,
      });
      final response = await _post(uri, body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Cloud google-login error: $e');
    }
    return null;
  }

  /// 5. GET /api/user/profile/{googleId}
  Future<Map<String, dynamic>?> getProfile(String googleId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/user/profile/$googleId');
      final response = await _get(uri);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Cloud get-profile error: $e');
    }
    return null;
  }

  /// 6. POST /api/user/sync-profile
  Future<void> syncProfile({
    required String googleId,
    required int level,
    required int xp,
    required int coins,
    required int totalGames,
    required int totalWins,
    required int eloRating,
    required int dailyStreak,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/user/sync-profile');
      final body = jsonEncode({
        'googleId': googleId,
        'level': level,
        'xp': xp,
        'coins': coins,
        'totalGames': totalGames,
        'totalWins': totalWins,
        'eloRating': eloRating,
        'dailyStreak': dailyStreak,
      });
      await _post(uri, body);
    } catch (e) {
      debugPrint('Cloud sync-profile error: $e');
    }
  }

  Future<http.Response> _post(Uri uri, String body) async {
    try {
      return await _client.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: body,
      ).timeout(_timeout);
    } catch (e) {
      throw ApiException('POST $uri failed: $e');
    }
  }

  /// Helper GET method with redirect handling, host rewriting for Android emulator, and timeout
  Future<http.Response> _get(Uri uri) async {
    try {
      final response = await _executeRequest(uri);

      // Handle redirect if returned
      if (response.isRedirect ||
          response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 307 ||
          response.statusCode == 308) {
        final location = response.headers['location'];
        if (location != null) {
          var redirectUri = Uri.parse(location);
          if (!kIsWeb && Platform.isAndroid) {
            if (redirectUri.host == 'localhost' || redirectUri.host == '127.0.0.1') {
              redirectUri = redirectUri.replace(host: '10.0.2.2');
            }
          }
          return await _executeRequest(redirectUri);
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw ApiException(
          'Server returned error: ${response.reasonPhrase ?? response.body}',
          response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Connection timed out while reaching ${uri.path}');
    } on ApiException {
      rethrow;
    } catch (e) {
      // Fallback: If HTTP 5173 failed, try HTTPS 7038
      if (uri.port == 5173) {
        try {
          final httpsUri = uri.replace(scheme: 'https', port: 7038);
          final httpsResponse = await _executeRequest(httpsUri);
          if (httpsResponse.statusCode >= 200 && httpsResponse.statusCode < 300) {
            return httpsResponse;
          }
        } catch (_) {}
      }
      throw ApiException('Failed to connect to backend server ($baseUrl): $e');
    }
  }

  Future<http.Response> _executeRequest(Uri uri) {
    return _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
    ).timeout(_timeout);
  }

  void dispose() {
    _client.close();
  }
}
