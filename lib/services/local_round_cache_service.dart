import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_item.dart';
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

  /// Yerelde hazır bekleyen bir tur varsa anında çeker ve kuyruktan çıkarır (0 ms)
  static Future<RoundModel?> popNextCachedRound([GameMode mode = GameMode.endless]) async {
    final memQueue = _getMemoryQueue(mode);
    final key = _getKey(mode);

    // 1. Önce RAM kuyruğuna bak
    if (memQueue.isNotEmpty) {
      final popped = memQueue.removeAt(0);
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

  /// Oyun arama listesini (tüm oyunları) yerelde önbelleğe alır
  static const String _keyGamesList = 'cached_games_list_v1';

  static Future<void> saveGamesList(List<GameItem> games) async {
    _memoryGames = List.from(games);
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = games.map((g) => g.toJson()).toList();
      await prefs.setString(_keyGamesList, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Kayıtlı oyun listesini yerelden çeker
  static Future<List<GameItem>> loadGamesList() async {
    if (_memoryGames.isNotEmpty) return _memoryGames;

    try {
      final prefs = await SharedPreferences.getInstance();
      final gamesJson = prefs.getString(_keyGamesList);
      if (gamesJson == null) return [];

      final List<dynamic> decoded = jsonDecode(gamesJson);
      _memoryGames = decoded.map((item) => GameItem.fromJson(item)).toList();
      return _memoryGames;
    } catch (e) {
      debugPrint('LocalRoundCache loadGamesList error: $e');
      return [];
    }
  }

  /// Kalıcı profil verilerini diske yazar
  static const String _keyProfileData = 'player_profile_v2';

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
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
      };
      await prefs.setString(_keyProfileData, jsonEncode(data));
    } catch (e) {
      debugPrint('Profile save error: $e');
    }
  }

  /// Kalıcı profil verilerini diskten okur
  static Future<Map<String, dynamic>> loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyProfileData);
      if (jsonStr == null) return {};
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Profile load error: $e');
      return {};
    }
  }
}
