import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/duel/online_duel_screen.dart';

class DeepLinkService {
  static const MethodChannel _channel = MethodChannel('com.example.steam_tahmin_frontend/gallery');
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        final String? link = call.arguments as String?;
        if (link != null) {
          _handleIncomingLink(link);
        }
      }
    });

    // İlk açılış linkini kontrol et
    _checkInitialLink();
  }

  static Future<void> _checkInitialLink() async {
    try {
      final String? initialLink = await _channel.invokeMethod('getInitialLink');
      if (initialLink != null && initialLink.isNotEmpty) {
        _handleIncomingLink(initialLink);
      }
    } catch (e) {
      debugPrint('Initial deep link error: $e');
    }
  }

  static void _handleIncomingLink(String link) {
    debugPrint('Incoming deep link: $link');
    final roomCode = parseRoomCode(link);
    if (roomCode != null && roomCode.isNotEmpty) {
      _navigateToDuelRoom(roomCode);
    }
  }

  static String? parseRoomCode(String link) {
    try {
      final uri = Uri.parse(link);
      // 1. ?room=123456 sorgu parametresi
      if (uri.queryParameters.containsKey('room')) {
        return uri.queryParameters['room'];
      }
      // 2. /duel/123456 veya /j/123456 yolu
      if (uri.pathSegments.isNotEmpty) {
        final last = uri.pathSegments.last;
        if (RegExp(r'^\d{4,8}$').hasMatch(last)) {
          return last;
        }
      }
      // 3. #123456 hash parçası
      if (uri.fragment.isNotEmpty && RegExp(r'^\d{4,8}$').hasMatch(uri.fragment)) {
        return uri.fragment;
      }
    } catch (_) {}
    return null;
  }

  static void _navigateToDuelRoom(String roomCode) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OnlineDuelScreen(initialRoomCode: roomCode),
        ),
      );
    }
  }
}
