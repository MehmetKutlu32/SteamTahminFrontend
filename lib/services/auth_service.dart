import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _keyUserSession = 'user_auth_session';
  static const String _keyLastGuestName = 'last_guest_name';
  static const String _googleClientId =
      '258890473227-addok4m8p6f0qqp4oh6ho1p1cur8c0u0.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _googleClientId : null,
    serverClientId: _googleClientId,
    scopes: ['email', 'profile'],
  );

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null && !_currentUser!.isGuest;
  bool get isGuest => _currentUser != null && _currentUser!.isGuest;

  /// Kayıtlı kullanıcı oturumunu yerel depolamadan yükle
  Future<UserModel?> loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonStr = prefs.getString(_keyUserSession);
      if (userJsonStr != null) {
        final data = jsonDecode(userJsonStr) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(data);
        return _currentUser;
      }
    } catch (e) {
      debugPrint('Auth session load error: $e');
    }
    return null;
  }

  /// Son kullanılan ziyaretçi adını getir
  Future<String?> getLastGuestName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyLastGuestName);
    } catch (_) {
      return null;
    }
  }

  /// Ziyaretçi adını kalıcı olarak kaydet
  Future<void> saveGuestName(String name) async {
    if (name.trim().isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastGuestName, name.trim());
    } catch (_) {}
  }

  /// Google ile Giriş Yap
  Future<UserModel?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final user = UserModel(
          id: account.id,
          displayName: account.displayName ?? 'Oyuncu',
          email: account.email,
          photoUrl: account.photoUrl,
          isGuest: false,
        );
        _currentUser = user;
        await _saveUserSession(user);
        return user;
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
    return null;
  }

  /// Misafir Olarak Giriş Yap / Devam Et
  Future<UserModel> signInAsGuest({String? customName}) async {
    final nameToUse = customName?.trim().isNotEmpty == true
        ? customName!.trim()
        : (await getLastGuestName() ?? 'Misafir_${DateTime.now().millisecond}');

    final guestUser = UserModel.guest(name: nameToUse);
    _currentUser = guestUser;
    await _saveUserSession(guestUser);

    // Son ziyaretçi adını kalıcı kaydet
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastGuestName, nameToUse);
    } catch (_) {}

    return guestUser;
  }

  /// Çıkış Yap (Oturumu Sıfırla)
  Future<void> signOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserSession);
      _currentUser = null;
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  Future<void> _saveUserSession(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserSession, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Auth session save error: $e');
    }
  }
}
