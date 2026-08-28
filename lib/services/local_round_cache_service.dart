import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/popular_games_catalog.dart';
import '../models/game_item.dart';
import '../models/game_review_dto.dart';
import '../models/roguelike_models.dart';
import '../models/round_model.dart';

/// Render.com cold-start gecikmesini tamamen ortadan kaldıran ve her oyun modu için
/// (Sonsuz Klasik, Roguelike Kule, Sahtekar, Zaman Yarışı, 1v1 Düello)
/// bağımsız yedek tur kuyrukları yöneten servis.
class LocalRoundCacheService {
  static const Map<GameMode, String> _modeKeys = {
    GameMode.endless: 'cached_round_queue_endless_v4',
    GameMode.roguelike: 'cached_round_queue_roguelike_v4',
    GameMode.imposter: 'cached_round_queue_imposter_v4',
    GameMode.timeAttack: 'cached_round_queue_timeattack_v4',
    GameMode.duel: 'cached_round_queue_duel_v4',
  };

  static const Map<GameMode, int> _maxQueueSizes = {
    GameMode.endless: 10,
    GameMode.roguelike: 15,
    GameMode.imposter: 10,
    GameMode.timeAttack: 15, // 60s boyunca hızlı tahminler için 15 tur yedek
    GameMode.duel: 10,
  };

  static const int maxQueueSizeEndless = 10;
  static const int maxQueueSizeRoguelike = 15;

  // 1. Katman: Hızlı Bellek (RAM) Kuyrukları
  static final Map<GameMode, List<RoundModel>> _memoryQueues = {
    GameMode.endless: [],
    GameMode.roguelike: [],
    GameMode.imposter: [],
    GameMode.timeAttack: [],
    GameMode.duel: [],
  };

  static List<GameItem> _memoryGames = [];

  // Son oynanan oyunların ID geçmişi (Mükerrer tur engelleme için)
  static final List<int> _recentPlayedAppIds = [];
  static const int _maxRecentPlayedHistory = 50;
  static const String _keyPlayedAppIdsHistory = 'played_app_ids_history_v1';

  // Geçmişte tamamlanmış turlardan toplanan gerçek inceleme havuzu (Sahtekar modu için sızıntısız kaynak)
  static final List<MapEntry<int, GameReviewDto>> _historicalRealReviews = [];

  static List<RoundModel> _getMemoryQueue(GameMode mode) =>
      _memoryQueues[mode] ?? (_memoryQueues[GameMode.endless]!);

  static String _getKey(GameMode mode) =>
      _modeKeys[mode] ?? 'cached_round_queue_endless_v4';

  static int _getMaxSize(GameMode mode) =>
      _maxQueueSizes[mode] ?? 5;

  /// Bellekteki hazır kuyruğu dışarıya okuma amaçlı açar
  static List<RoundModel> get queuedRounds => List.unmodifiable(_getMemoryQueue(GameMode.endless));
  static List<RoundModel> getQueuedRounds([GameMode mode = GameMode.endless]) =>
      List.unmodifiable(_getMemoryQueue(mode));

  /// Oynanan oyunu geçmişe kaydeder (Mükerrer önleme)
  static Future<void> recordPlayedGame(RoundModel round) async {
    if (!_recentPlayedAppIds.contains(round.appId)) {
      _recentPlayedAppIds.insert(0, round.appId);
      if (_recentPlayedAppIds.length > _maxRecentPlayedHistory) {
        _recentPlayedAppIds.removeLast();
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
          _keyPlayedAppIdsHistory,
          _recentPlayedAppIds.map((id) => id.toString()).toList(),
        );
      } catch (_) {}
    }

    // Sahtekar modu için geçmiş turlardan gerçek yorum havuzu oluştur (Gelecek turlardan ASLA çekilmez)
    for (final review in round.yorumlar) {
      if (_historicalRealReviews.length < 100) {
        _historicalRealReviews.add(MapEntry(round.appId, review));
      }
    }
  }

  /// Bir oyunun yakın zamanda oynanıp oynanmadığını kontrol eder
  static bool isAppIdRecentlyPlayed(int appId) => _recentPlayedAppIds.contains(appId);

  /// Yerelde hazır bekleyen bir tur varsa anında çeker ve kuyruktan çıkarır (0 ms)
  /// Kule modunda ve genel akışta mükerrer önleme için son oynananları eler
  static Future<RoundModel?> popNextCachedRound([GameMode mode = GameMode.endless]) async {
    final memQueue = _getMemoryQueue(mode);
    final key = _getKey(mode);

    // 1. Önce RAM kuyruğuna bak
    if (memQueue.isNotEmpty) {
      // Mümkünse yakın zamanda oynanmamış olan taze bir oyunu tercih et
      int targetIndex = 0;
      if (memQueue.length > 1) {
        final unplayedIndex = memQueue.indexWhere((r) => !_recentPlayedAppIds.contains(r.appId));
        if (unplayedIndex != -1) {
          targetIndex = unplayedIndex;
        }
      }

      final popped = memQueue.removeAt(targetIndex);
      _syncDiskQueue(mode);
      return popped;
    }

    // 2. RAM boşsa diskten oku
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getStringList(key) ?? [];
      if (queueJson.isNotEmpty) {
        final firstItemJson = queueJson.removeAt(0);
        await prefs.setStringList(key, queueJson);

        final Map<String, dynamic> decoded = jsonDecode(firstItemJson);
        return RoundModel.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('LocalRoundCache pop error: $e');
    }

    // 3. Modun kendi kuyruğu tamamen boşsa, diğer modların yedek kuyruklarından ödünç al (Çevrimdışı Hayatta Kalma)
    for (final otherMode in GameMode.values) {
      if (otherMode != mode) {
        final otherMemQueue = _getMemoryQueue(otherMode);
        if (otherMemQueue.isNotEmpty) {
          final popped = otherMemQueue.removeAt(0);
          _syncDiskQueue(otherMode);
          return popped;
        }
      }
    }

    return null;
  }

  /// Sahtekar modu için sıradaki turları ASLA sızdırmadan, sadece geçmiş turlardan gerçek bir Steam incelemesi bulur
  static GameReviewDto? findRealReviewFromDifferentGame({
    required int excludeAppId,
    List<String> preferredGenres = const [],
  }) {
    if (_historicalRealReviews.isEmpty) return null;

    final candidates = _historicalRealReviews
        .where((entry) => entry.key != excludeAppId && entry.value.yorum.isNotEmpty)
        .map((entry) => entry.value)
        .toList();

    if (candidates.isEmpty) return null;

    final random = Random();
    return candidates[random.nextInt(candidates.length)];
  }

  /// Arka planda sunucudan yeni çekilen turu yerel kuyruğa ekler
  static Future<void> pushRoundToQueue(RoundModel round, [GameMode mode = GameMode.endless]) async {
    final memQueue = _getMemoryQueue(mode);
    final maxSize = _getMaxSize(mode);

    // 1. RAM kuyruğuna ekle (mükerrer kontrolü ile)
    final existsInRam = memQueue.any((r) => r.appId == round.appId);
    if (!existsInRam && memQueue.length < maxSize) {
      memQueue.add(round);
    }

    // 2. Diske kaydet
    await _syncDiskQueue(mode);
  }

  static Future<void> _syncDiskQueue(GameMode mode) async {
    try {
      final memQueue = _getMemoryQueue(mode);
      final key = _getKey(mode);
      final prefs = await SharedPreferences.getInstance();
      final queueJson = memQueue.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(key, queueJson);
    } catch (_) {}
  }

  /// Kuyruğu tamamen temizler (Test ve sıfırlama için)
  static Future<void> clearQueue([GameMode? mode]) async {
    final prefs = await SharedPreferences.getInstance();
    if (mode == null) {
      for (final m in GameMode.values) {
        _getMemoryQueue(m).clear();
        try {
          await prefs.remove(_getKey(m));
        } catch (_) {}
      }
    } else {
      _getMemoryQueue(mode).clear();
      try {
        await prefs.remove(_getKey(mode));
      } catch (_) {}
    }
  }

  /// Kuyruktaki mevcut hazır tur sayısını döner
  static Future<int> getCachedRoundCount([GameMode mode = GameMode.endless]) async {
    final memQueue = _getMemoryQueue(mode);
    final key = _getKey(mode);

    if (memQueue.isNotEmpty) {
      return memQueue.length;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getStringList(key) ?? [];
      if (queueJson.isNotEmpty && memQueue.isEmpty) {
        for (final item in queueJson) {
          final decoded = jsonDecode(item);
          memQueue.add(RoundModel.fromJson(decoded));
        }
      }
      return memQueue.length;
    } catch (_) {
      return memQueue.length;
    }
  }

  /// Oyun arama listesini yerelde önbelleğe alır ve popüler oyunlar ile birleştirir
  static const String _keyGamesList = 'cached_games_list_v1';

  static Future<void> saveGamesList(List<GameItem> games) async {
    final mergedMap = <int, GameItem>{};
    for (final g in PopularGamesCatalog.defaultPopularGames) {
      mergedMap[g.appId] = g;
    }
    for (final g in games) {
      mergedMap[g.appId] = g;
    }
    _memoryGames = mergedMap.values.toList();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _memoryGames.map((g) => g.toJson()).toList();
      await prefs.setString(_keyGamesList, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Kayıtlı oyun listesini yerelden çeker (Eksiksiz 600+ oyun garantisi)
  static Future<List<GameItem>> loadGamesList() async {
    if (_memoryGames.isNotEmpty) return _memoryGames;

    final mergedMap = <int, GameItem>{};
    for (final g in PopularGamesCatalog.defaultPopularGames) {
      mergedMap[g.appId] = g;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final gamesJson = prefs.getString(_keyGamesList);
      if (gamesJson != null) {
        final List<dynamic> decoded = jsonDecode(gamesJson);
        for (final item in decoded) {
          final game = GameItem.fromJson(item);
          mergedMap[game.appId] = game;
        }
      }

      // Oynanan oyun geçmişini de yükle
      final playedHistory = prefs.getStringList(_keyPlayedAppIdsHistory);
      if (playedHistory != null) {
        _recentPlayedAppIds.clear();
        _recentPlayedAppIds.addAll(playedHistory.map((s) => int.tryParse(s) ?? 0).where((id) => id > 0));
      }
    } catch (e) {
      debugPrint('LocalRoundCache loadGamesList error: $e');
    }

    _memoryGames = mergedMap.values.toList();
    return _memoryGames;
  }

  /// Kalıcı profil verilerini diske yazar (Kullanıcıya özel izole anahtar)
  static const String _keyLegacyProfileData = 'player_profile_v2';
  static const String _keyGuestProfileData = 'player_profile_guest';

  static String _getProfileKey(String? userId) {
    if (userId != null && userId.trim().isNotEmpty) {
      return 'player_profile_user_${userId.trim()}';
    }
    return _keyGuestProfileData;
  }

  /// Kullanıcının daha önce kaydedilmiş bir profili var mı?
  static Future<bool> hasUserProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_getProfileKey(userId));
  }

  /// Ziyaretçi olarak anlamlı bir oyun ilerlemesi var mı?
  static Future<bool> hasGuestProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyGuestProfileData);
    if (jsonStr == null) return false;
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final gamesPlayed = (data['totalChestsOpened'] ?? 0) + (data['totalTowerWins'] ?? 0);
      final totalXp = data['totalXp'] ?? 0;
      final coins = data['coins'] ?? 50;
      return gamesPlayed > 0 || totalXp > 0 || coins > 50;
    } catch (_) {
      return false;
    }
  }

  /// Ziyaretçi profilini sıfırlar
  static Future<void> clearGuestProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyGuestProfileData);
    } catch (_) {}
  }

  static Future<void> saveProfileData({
    required int highScore,
    required int totalXp,
    required int unopenedChests,
    required int coins,
    required int diamonds,
    required int totalTowerWins,
    required int bestStreak,
    required int totalChestsOpened,
    required List<String> discoveredPerks,
    required List<String> purchasedShopItems,
    String? equippedAvatar,
    String? equippedFrame,
    String? equippedTitle,
    String? dailyQuestsJson,
    String? dailyQuestsDate,
    List<String>? claimedAchievements,
    String? achievementProgressJson,
    int? timeAttackHighScore,
    int? onlineDuelWins,
    int? towerCurrentFloor,
    List<String>? towerActivePerkIds,
    int? towerBestFloor,
    String? userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getProfileKey(userId);
      final data = {
        'highScore': highScore,
        'totalXp': totalXp,
        'unopenedChests': unopenedChests,
        'coins': coins,
        'diamonds': diamonds,
        'totalTowerWins': totalTowerWins,
        'bestStreak': bestStreak,
        'totalChestsOpened': totalChestsOpened,
        'discoveredPerks': discoveredPerks,
        'purchasedShopItems': purchasedShopItems,
        'equippedAvatar': equippedAvatar,
        'equippedFrame': equippedFrame,
        'equippedTitle': equippedTitle,
        'dailyQuestsJson': dailyQuestsJson,
        'dailyQuestsDate': dailyQuestsDate,
        'claimedAchievements': claimedAchievements,
        'achievementProgressJson': achievementProgressJson,
        'timeAttackHighScore': timeAttackHighScore,
        'onlineDuelWins': onlineDuelWins,
        'towerCurrentFloor': towerCurrentFloor,
        'towerActivePerkIds': towerActivePerkIds,
        'towerBestFloor': towerBestFloor,
      };
      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      debugPrint('Profile save error: $e');
    }
  }

  /// Kalıcı profil verilerini diskten okur (Kullanıcıya özel)
  static Future<Map<String, dynamic>> loadProfileData({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getProfileKey(userId);
      var jsonStr = prefs.getString(key);

      // Legacy migrasyonu (Eski tekil veriyi bu kullanıcıya aktar)
      if (jsonStr == null && prefs.containsKey(_keyLegacyProfileData)) {
        jsonStr = prefs.getString(_keyLegacyProfileData);
        if (jsonStr != null) {
          await prefs.setString(key, jsonStr);
          await prefs.remove(_keyLegacyProfileData);
        }
      }

      if (jsonStr == null) return {};
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Profile load error: $e');
      return {};
    }
  }
}
