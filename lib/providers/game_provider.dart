import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/achievement_models.dart';
import '../models/game_item.dart';
import '../models/game_review_dto.dart';
import '../models/player_progression.dart';
import '../models/quest_models.dart';
import '../models/roguelike_models.dart';
import '../models/round_model.dart';
import '../models/shop_models.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/local_round_cache_service.dart';

/// Her oyun modunun (Sonsuz Klasik, Roguelike Kule, Sahtekar) oyun turu ve ilerleme durumunu
/// birbirinden %100 izole tutan oturum modeli.
class GameModeSession {
  RoundModel? currentRound;
  List<GameReviewDto> reviews = [];
  int revealedReviewCount = 1;
  int activeCardIndex = 0;
  int attemptsRemaining = 5;
  int score = 0;
  int streak = 0;
  int lastWonCoins = 0;
  int lastWonDiamonds = 0;
  final List<String> wrongGuesses = [];
  final Set<int> revealedLetterIndices = {};
  bool isWordSlotUnlocked = false;
  int letterHintsUsedThisRound = 0;
  bool usedDiamondJokerThisRound = false;
  bool isRoundWon = false;
  bool isRoundLost = false;
  bool recycledUsedThisRound = false;
  int extraReviewsUsedThisRound = 0;
}

class GameProvider extends ChangeNotifier {
  final ApiService _apiService;

  GameProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    checkDailyQuestsReset();
  }

  // Currency & Player Profile (Tüm modlar arasında ortak kalıcı ilerleme)
  String? _activeUserId;
  String? get activeUserId => _activeUserId;

  int _coins = 50; // Başlangıç Altını
  int _diamonds = 2; // Başlangıç Elması
  int _totalWins = 0;
  int _totalGamesPlayed = 0;
  int _totalXp = 0; // Toplam Seviye XP
  int _highScore = 0; // En Yüksek Rekor Skoru
  int _unopenedChests = 0; // Açılmayı bekleyen Gizemli Sandıklar
  int _totalTowerWins = 0;
  int _bestStreak = 0;
  int _totalChestsOpened = 0;
  int _lastEarnedXp = 0;
  bool _justLeveledUp = false;
  int _newLevel = 1;
  bool _justEarnedChest = false;

  // Koleksiyon & Keşif Sistemi (Kalıcı keşfedilen yadigarlar)
  final Set<String> _discoveredPerkIds = {};

  // Kalıcı Mağaza (Shop) Sistemi & Kuşanılanlar
  final Set<String> _purchasedShopItemIds = {};
  String? _equippedAvatarId;
  String? _equippedFrameId;
  String? _equippedTitleId;

  // Günlük Görevler (Daily Quests)
  List<DailyQuest> _dailyQuests = [];
  String _dailyQuestsDateStr = '';

  // Kalıcı Başarımlar (Permanent Achievements)
  final Map<String, int> _achievementProgress = {};
  final Set<String> _claimedAchievementIds = {};

  // Zaman Yarışı & 1v1 Online Düello İstatistikleri
  int _timeAttackHighScore = 0;
  int _onlineDuelWins = 0;

  // Sahtekar Modu Özel Durumu
  final GameModeSession _imposterSession = GameModeSession();
  int? _imposterCardIndex;
  int? _selectedImposterCardIndex;
  String? _imposterOriginalGameName;
  bool _isImposterFound = false;
  final Set<int> _eliminatedRealCardIndices = {};

  Set<int> get eliminatedRealCardIndices => Set.unmodifiable(_eliminatedRealCardIndices);
  bool get canUnlockExtraImposterReview =>
      _gameMode == GameMode.imposter &&
      !isRoundFinished &&
      _imposterSession.revealedReviewCount < min(5, _imposterSession.reviews.length);

  // Mod Seçimi ve Ayrı Oturumlar
  GameMode _gameMode = GameMode.endless;
  final GameModeSession _endlessSession = GameModeSession();
  final GameModeSession _roguelikeSession = GameModeSession();
  final GameModeSession _timeAttackSession = GameModeSession();
  final GameModeSession _duelSession = GameModeSession();

  GameModeSession get _activeSession {
    if (_gameMode == GameMode.roguelike) return _roguelikeSession;
    if (_gameMode == GameMode.imposter) return _imposterSession;
    if (_gameMode == GameMode.timeAttack) return _timeAttackSession;
    if (_gameMode == GameMode.duel) return _duelSession;
    return _endlessSession;
  }

  // Roguelike Kule Koşusu Durum Değişkenleri (Sadece Roguelike moduna özel)
  int _currentFloor = 1;
  int _lastPlayedFloor = 1;
  static const int maxFloors = 10;
  final Set<String> _activePerkIds = {};
  List<RoguelikePerk> _offeredPerks = [];
  bool _shieldAvailableThisRound = true;
  bool _freeDiamondJokerAvailableThisRound = true;
  bool _secondWindUsedThisRun = false;
  bool _isRunCompleted = false;

  // Genel Durum
  List<GameItem> _gamesList = [];
  bool _isLoadingRound = false;
  bool _isLoadingGames = false;
  bool _isLoadingHint = false;
  String? _errorMessage;
  String? _infoToast;
  bool _censorProfanity = true; // Küfür sansürleme seçeneği (Varsayılan: Açık)
  int _cachedRoundCount = 0;

  // Getters
  GameMode get gameMode => _gameMode;
  int get currentFloor => _currentFloor;
  int get lastPlayedFloor => _lastPlayedFloor;
  int get maxFloor => maxFloors;
  bool get isRoguelike => _gameMode == GameMode.roguelike;
  bool get isImposterMode => _gameMode == GameMode.imposter;
  bool get isBossFloor => isRoguelike && (_currentFloor % 5 == 0);
  bool get isRunCompleted => _isRunCompleted;
  bool get isShieldAvailable => isRoguelike && hasPerk('guardian_shield') && _shieldAvailableThisRound;
  List<RoguelikePerk> get activePerks => _activePerkIds.map((id) => PerkCatalog.findById(id)).whereType<RoguelikePerk>().toList();
  List<RoguelikePerk> get offeredPerks => List.unmodifiable(_offeredPerks);

  // Sahtekar Modu Getters
  int? get imposterCardIndex => _imposterCardIndex;
  int? get selectedImposterCardIndex => _selectedImposterCardIndex;
  bool get isImposterFound => _isImposterFound;
  String? get imposterOriginalGameName => _imposterOriginalGameName;

  // Zaman Yarışı & Düello Getters
  int get timeAttackHighScore => _timeAttackHighScore;
  int get onlineDuelWins => _onlineDuelWins;

  // Günlük Görev Getters
  List<DailyQuest> get dailyQuests => List.unmodifiable(_dailyQuests);
  int get completedDailyQuestsCount => _dailyQuests.where((q) => q.isCompleted).length;
  int get claimableDailyQuestsCount => _dailyQuests.where((q) => q.isCompleted && !q.isClaimed).length;

  // Başarım Getters
  int getAchievementProgress(String id) => _achievementProgress[id] ?? 0;
  bool isAchievementClaimed(String id) => _claimedAchievementIds.contains(id);
  bool isAchievementCompleted(Achievement a) => (_achievementProgress[a.id] ?? 0) >= a.targetValue;
  int get claimableAchievementsCount => AchievementCatalog.allAchievements.where((a) => isAchievementCompleted(a) && !isAchievementClaimed(a.id)).length;
  
  // Can Limiti: Standart 5, Roguelike vitality ile 6, Sahtekar modunda 2 Can
  int get maxAttempts {
    if (_gameMode == GameMode.imposter) return 2;
    return (isRoguelike && hasPerk('vitality')) ? 6 : 5;
  }

  // Pasif yadigarlar sadece Roguelike modunda aktiftir
  bool hasPerk(String id) => isRoguelike && _activePerkIds.contains(id);

  // Koleksiyon & Keşif Getters
  Set<String> get discoveredPerkIds => Set.unmodifiable(_discoveredPerkIds);
  bool isPerkDiscovered(String id) => _discoveredPerkIds.contains(id);

  // Mağaza (Shop) Getters
  Set<String> get purchasedShopItemIds => Set.unmodifiable(_purchasedShopItemIds);
  String? get equippedAvatarId => _equippedAvatarId;
  String? get equippedFrameId => _equippedFrameId;
  String? get equippedTitleId => _equippedTitleId;
  bool hasShopItem(String id) => _purchasedShopItemIds.contains(id);

  ShopItem? get equippedAvatar => _equippedAvatarId != null ? ShopCatalog.findById(_equippedAvatarId!) : null;
  ShopItem? get equippedFrame => _equippedFrameId != null ? ShopCatalog.findById(_equippedFrameId!) : null;
  ShopItem? get equippedTitle => _equippedTitleId != null ? ShopCatalog.findById(_equippedTitleId!) : null;
  String get effectiveRankTitle => equippedTitle?.name ?? rankTitle;

  int get coins => _coins;
  int get diamonds => _diamonds;
  int get totalWins => _totalWins;
  int get totalGamesPlayed => _totalGamesPlayed;
  int get totalXp => _totalXp;
  int get level => PlayerRank.calculateLevel(_totalXp);
  int get currentLevelXp => PlayerRank.currentLevelXp(_totalXp);
  double get levelProgress => PlayerRank.levelProgress(_totalXp);
  String get rankTitle => PlayerRank.getRankTitle(level);
  String get rankBadge => PlayerRank.getRankBadge(level);
  Color get rankColor => PlayerRank.getRankColor(level);
  int get highScore => _highScore;
  int get unopenedChests => _unopenedChests;
  int get totalTowerWins => _totalTowerWins;
  int get bestStreak => _bestStreak;
  int get totalChestsOpened => _totalChestsOpened;
  int get lastEarnedXp => _lastEarnedXp;
  bool get justLeveledUp => _justLeveledUp;
  int get newLevel => _newLevel;
  bool get justEarnedChest => _justEarnedChest;
  bool get censorProfanity => _censorProfanity;
  int get cachedRoundCount => _cachedRoundCount;
  List<RoundModel> get queuedRounds => LocalRoundCacheService.getQueuedRounds(_gameMode);

  // Aktif Oturum Verileri
  RoundModel? get currentRound => _activeSession.currentRound;
  List<GameItem> get gamesList => _gamesList;
  List<GameReviewDto> get reviews => _activeSession.reviews;
  int get revealedReviewCount => _activeSession.revealedReviewCount;
  int get activeCardIndex => _activeSession.activeCardIndex;
  int get attemptsRemaining => _activeSession.attemptsRemaining;
  int get score => _activeSession.score;
  int get streak => _activeSession.streak;
  int get lastWonCoins => _activeSession.lastWonCoins;
  int get lastWonDiamonds => _activeSession.lastWonDiamonds;
  List<String> get wrongGuesses => List.unmodifiable(_activeSession.wrongGuesses);
  Set<int> get revealedLetterIndices => Set.unmodifiable(_activeSession.revealedLetterIndices);
  bool get isWordSlotUnlocked => _activeSession.isWordSlotUnlocked;
  int get letterHintsUsedThisRound => _activeSession.letterHintsUsedThisRound;
  bool get isRoundWon => _activeSession.isRoundWon;
  bool get isRoundLost => _activeSession.isRoundLost;
  bool get isRoundFinished => _activeSession.isRoundWon || _activeSession.isRoundLost;

  List<GameReviewDto> get visibleReviews =>
      _activeSession.reviews.take(_activeSession.revealedReviewCount).toList();

  /// Ekranda gösterilecek standart ipucu yuvası sayısı (Standart 5, elmas jokerle açılırsa daha fazlası)
  int get displayTotalReviewsCount => _activeSession.revealedReviewCount > 5 ? _activeSession.revealedReviewCount : 5;

  bool get isLoadingRound => _isLoadingRound;
  bool get isLoadingGames => _isLoadingGames;
  bool get isLoadingHint => _isLoadingHint;
  String? get errorMessage => _errorMessage;
  String? get infoToast => _infoToast;
  bool get canRecycleReview => hasPerk('recycler') && !_activeSession.recycledUsedThisRound && !_activeSession.isRoundWon;

  bool get hasOngoingRoguelikeRun =>
      !_isRunCompleted &&
      (_currentFloor > 1 || _activePerkIds.isNotEmpty || (_roguelikeSession.currentRound != null && !_roguelikeSession.isRoundLost));

  void resumeRoguelikeRun() {
    _gameMode = GameMode.roguelike;
    if (_roguelikeSession.currentRound == null) {
      startNewRound();
    }
    notifyListeners();
  }

  void setGameMode(GameMode mode) {
    if (_gameMode != mode) {
      _gameMode = mode;
      if (mode == GameMode.roguelike) {
        if (!hasOngoingRoguelikeRun) {
          startNewRoguelikeRun();
        } else if (_roguelikeSession.currentRound == null) {
          startNewRound();
        }
      } else {
        if (_activeSession.currentRound == null) {
          startNewRound();
        }
      }
      _silentWarmUpAndRefillQueue();
      notifyListeners();
    } else {
      if (_activeSession.currentRound == null) {
        startNewRound();
      }
      _silentWarmUpAndRefillQueue();
    }
  }

  void startNewRoguelikeRun() {
    _gameMode = GameMode.roguelike;
    _currentFloor = 1;
    _activePerkIds.clear();
    _offeredPerks.clear();
    _secondWindUsedThisRun = false;
    _isRunCompleted = false;
    _roguelikeSession.score = 0;
    _roguelikeSession.streak = 0;
    startNewRound();
  }

  void selectPerk(RoguelikePerk perk) {
    if (!isRoguelike) return;
    _activePerkIds.add(perk.id);
    _discoveredPerkIds.add(perk.id);
    _offeredPerks.clear();
    if (perk.id == 'vitality') {
      _roguelikeSession.attemptsRemaining = min(_roguelikeSession.attemptsRemaining + 1, 6);
    }
    _infoToast = '${perk.iconEmoji} "${perk.name}" yadigarı kuşanıldı!';
    _saveProfile();
    notifyListeners();
  }

  void dismissPerkSelection() {
    _offeredPerks.clear();
    notifyListeners();
  }

  void dismissLevelUpNotification() {
    _justLeveledUp = false;
    notifyListeners();
  }

  void dismissChestNotification() {
    _justEarnedChest = false;
    notifyListeners();
  }

  // ----------------------------------------------------
  // Günlük Görevler (Daily Quests) Motoru
  // ----------------------------------------------------
  void checkDailyQuestsReset() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (_dailyQuestsDateStr != todayStr || _dailyQuests.isEmpty) {
      _dailyQuests = DailyQuestCatalog.generateDailyQuests(now);
      _dailyQuestsDateStr = todayStr;
      _saveProfile();
      notifyListeners();
    }
  }

  void incrementQuestProgress(QuestType type, [int amount = 1]) {
    checkDailyQuestsReset();
    bool changed = false;
    for (final q in _dailyQuests) {
      if (q.type == type && !q.isCompleted) {
        q.currentValue += amount;
        changed = true;
      }
    }
    if (changed) {
      _saveProfile();
      notifyListeners();
    }
  }

  bool claimQuestReward(DailyQuest quest) {
    if (!quest.isCompleted || quest.isClaimed) return false;
    quest.isClaimed = true;
    _coins += quest.rewardGold;
    _diamonds += quest.rewardDiamonds;
    if (quest.rewardXp > 0) {
      _totalXp += quest.rewardXp;
    }
    _infoToast = '🎉 Görev Tamamlandı! +${quest.rewardGold > 0 ? "${quest.rewardGold} 🪙 " : ""}${quest.rewardDiamonds > 0 ? "${quest.rewardDiamonds} 💎 " : ""}kazandınız!';
    _saveProfile();
    notifyListeners();
    return true;
  }

  // ----------------------------------------------------
  // Kalıcı Başarımlar (Permanent Achievements) Motoru
  // ----------------------------------------------------
  void recordAchievementProgress(String id, int value) {
    final current = _achievementProgress[id] ?? 0;
    if (value > current) {
      _achievementProgress[id] = value;
      _saveProfile();
      notifyListeners();
    }
  }

  void incrementAchievementProgress(String id, [int amount = 1]) {
    final current = _achievementProgress[id] ?? 0;
    _achievementProgress[id] = current + amount;
    _saveProfile();
    notifyListeners();
  }

  bool claimAchievementReward(Achievement achievement) {
    if (!isAchievementCompleted(achievement) || isAchievementClaimed(achievement.id)) return false;
    _claimedAchievementIds.add(achievement.id);
    _coins += achievement.rewardGold;
    _diamonds += achievement.rewardDiamonds;
    if (achievement.rewardTitleId != null) {
      _purchasedShopItemIds.add(achievement.rewardTitleId!);
    }
    _infoToast = '🏆 Başarım Açıldı: "${achievement.title}"!';
    _saveProfile();
    notifyListeners();
    return true;
  }

  // ----------------------------------------------------
  // Sahtekar & Zaman Yarışı & Düello Metodları
  // ----------------------------------------------------
  void selectImposterCard(int index) {
    if (_gameMode != GameMode.imposter) return;
    _selectedImposterCardIndex = index;
    notifyListeners();
  }

  void unlockExtraImposterReview() {
    if (!canUnlockExtraImposterReview) return;
    _imposterSession.revealedReviewCount += 1;
    _infoToast = '🔍 +1 Ek İnceleme İpucu Açıldı!';
    notifyListeners();
  }

  void accuseImposter(int index) {
    if (_gameMode != GameMode.imposter || isRoundFinished) return;
    final session = _imposterSession;
    _selectedImposterCardIndex = index;

    if (index == _imposterCardIndex) {
      // DOĞRU SAHTEKAR TESPİT EDİLDİ! ZAFER!
      _isImposterFound = true;
      session.isRoundWon = true;
      session.streak += 1;
      _totalWins += 1;
      session.lastWonCoins = 50;
      session.lastWonDiamonds = 2;
      _coins += 50;
      _diamonds += 2;
      _totalXp += 500;

      incrementAchievementProgress('first_win', 1);
      incrementAchievementProgress('imposter_hunter', 1);
      incrementAchievementProgress('imposter_master', 1);
      _infoToast = '🎉 SAHTEKAR YAKALANDI! Turu Kazandınız! 🕵️ (+50 🪙, +2 💎)';
      _saveProfile();
      notifyListeners();
    } else {
      // YANLIŞ KART SEÇİLDİ!
      _eliminatedRealCardIndices.add(index);
      session.attemptsRemaining -= 1;

      if (session.attemptsRemaining <= 0) {
        session.isRoundLost = true;
        session.streak = 0;
        _infoToast = '💀 Canlarınız bitti! Sahtekar kaçtı. Gerçek sahtekar Kart #${(_imposterCardIndex ?? 0) + 1} idi.';
        _saveProfile();
      } else {
        _infoToast = '❌ Yanlış! Kart #${index + 1} gerçek incelemeydi. (-1 Can, Kalan: ${session.attemptsRemaining})';
      }
      notifyListeners();
    }
  }

  void recordTimeAttackResult(int scoreGuessed) {
    incrementQuestProgress(QuestType.timeAttackScore, scoreGuessed);
    recordAchievementProgress('time_attack_5', scoreGuessed);
    recordAchievementProgress('time_attack_10', scoreGuessed);
    if (scoreGuessed > _timeAttackHighScore) {
      _timeAttackHighScore = scoreGuessed;
      _infoToast = '⚡ YENİ REKOR! Zaman Yarışında $scoreGuessed Oyun!';
    }
    _saveProfile();
    notifyListeners();
  }

  void recordOnlineDuelWin() {
    _onlineDuelWins += 1;
    incrementAchievementProgress('duel_first_win', 1);
    incrementAchievementProgress('duel_5_wins', 1);
    _saveProfile();
    notifyListeners();
  }

  // ----------------------------------------------------
  // Geliştirici / Debug Panel Metodları
  // ----------------------------------------------------
  void debugSetCoins(int val) {
    _coins = val;
    _saveProfile();
    notifyListeners();
  }

  void debugSetDiamonds(int val) {
    _diamonds = val;
    _saveProfile();
    notifyListeners();
  }

  void debugSetChests(int val) {
    _unopenedChests = val;
    _saveProfile();
    notifyListeners();
  }

  void debugSetFloor(int floor) {
    _currentFloor = floor.clamp(1, maxFloors);
    notifyListeners();
  }

  Future<void> debugResetProfileToFactoryDefault() async {
    _coins = 50;
    _diamonds = 2;
    _unopenedChests = 0;
    _totalXp = 0;
    _highScore = 0;
    _totalTowerWins = 0;
    _bestStreak = 0;
    _totalChestsOpened = 0;
    _timeAttackHighScore = 0;
    _onlineDuelWins = 0;
    _discoveredPerkIds.clear();
    _purchasedShopItemIds.clear();
    _claimedAchievementIds.clear();
    _achievementProgress.clear();
    _equippedAvatarId = null;
    _equippedFrameId = null;
    _equippedTitleId = null;
    await _saveProfile();
    notifyListeners();
  }

  Future<void> debugFillAllCaches() async {
    for (final mode in GameMode.values) {
      final current = await LocalRoundCacheService.getCachedRoundCount(mode);
      if (current < 3) {
        try {
          final round = await _apiService.startRound(count: 20, censorProfanity: false);
          await LocalRoundCacheService.pushRoundToQueue(round, mode);
        } catch (_) {}
      }
    }
    _cachedRoundCount = await LocalRoundCacheService.getCachedRoundCount(_gameMode);
    notifyListeners();
  }

  Future<void> debugClearAllCaches() async {
    await LocalRoundCacheService.clearQueue();
    _cachedRoundCount = 0;
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    await LocalRoundCacheService.saveProfileData(
      highScore: _highScore,
      totalXp: _totalXp,
      unopenedChests: _unopenedChests,
      coins: _coins,
      diamonds: _diamonds,
      totalTowerWins: _totalTowerWins,
      bestStreak: _bestStreak,
      totalChestsOpened: _totalChestsOpened,
      discoveredPerks: _discoveredPerkIds.toList(),
      purchasedShopItems: _purchasedShopItemIds.toList(),
      equippedAvatar: _equippedAvatarId,
      equippedFrame: _equippedFrameId,
      equippedTitle: _equippedTitleId,
      dailyQuestsJson: _dailyQuests.isNotEmpty ? DailyQuestCatalog.serializeQuests(_dailyQuests) : null,
      dailyQuestsDate: _dailyQuestsDateStr,
      claimedAchievements: _claimedAchievementIds.toList(),
      achievementProgressJson: _achievementProgress.isNotEmpty ? jsonEncode(_achievementProgress) : null,
      timeAttackHighScore: _timeAttackHighScore,
      onlineDuelWins: _onlineDuelWins,
      userId: _activeUserId,
    );

    if (_activeUserId != null && _activeUserId!.isNotEmpty) {
      _apiService.syncProfile(
        googleId: _activeUserId!,
        level: PlayerRank.calculateLevel(_totalXp),
        xp: _totalXp,
        coins: _coins,
        totalGames: _totalChestsOpened + _totalTowerWins,
        totalWins: _totalTowerWins,
        eloRating: 1000 + (_totalTowerWins * 25),
        dailyStreak: 1,
      );
    }
  }

  bool buyShopItem(ShopItem item, {bool payWithDiamonds = false}) {
    if (item.type != ShopItemType.chest && _purchasedShopItemIds.contains(item.id)) {
      _infoToast = 'Bu eşyaya zaten kalıcı olarak sahipsiniz!';
      notifyListeners();
      return false;
    }

    if (payWithDiamonds || item.priceGold == 0) {
      if (_diamonds < item.priceDiamonds) {
        _infoToast = 'Yetersiz Elmas! (${item.priceDiamonds} 💎 gerekli)';
        notifyListeners();
        return false;
      }
      _diamonds -= item.priceDiamonds;
    } else {
      if (_coins < item.priceGold) {
        _infoToast = 'Yetersiz Altın! (${item.priceGold} 🪙 gerekli)';
        notifyListeners();
        return false;
      }
      _coins -= item.priceGold;
    }

    if (item.type == ShopItemType.chest) {
      final chestsToAdd = item.id == 'chest_diamond_buy' ? 2 : 1;
      _unopenedChests += chestsToAdd;
      _infoToast = '🎡 $chestsToAdd Adet Çark Çevirme Hakkı hesabınıza eklendi!';
    } else {
      _purchasedShopItemIds.add(item.id);
      if (item.type == ShopItemType.avatar) {
        _equippedAvatarId = item.id;
      } else if (item.type == ShopItemType.frame) {
        _equippedFrameId = item.id;
      } else if (item.type == ShopItemType.title) {
        _equippedTitleId = item.id;
      }
      _infoToast = '🛍️ "${item.name}" kalıcı olarak satın alındı!';
    }

    _saveProfile();
    notifyListeners();
    return true;
  }

  void equipAvatar(String? avatarId) {
    _equippedAvatarId = avatarId;
    _saveProfile();
    notifyListeners();
  }

  void equipFrame(String? frameId) {
    _equippedFrameId = frameId;
    _saveProfile();
    notifyListeners();
  }

  void equipTitle(String? titleId) {
    _equippedTitleId = titleId;
    _saveProfile();
    notifyListeners();
  }

  /// Tüm ilerlemeyi sıfırla (Yeni hesap için)
  void resetPlayerProgression() {
    _coins = 0;
    _diamonds = 0;
    _totalWins = 0;
    _totalGamesPlayed = 0;
    _totalXp = 0;
    _highScore = 0;
    _totalTowerWins = 0;
    _bestStreak = 0;
    _totalChestsOpened = 0;
    _unopenedChests = 1;
    _discoveredPerkIds.clear();
    _purchasedShopItemIds.clear();
    _equippedAvatarId = null;
    _equippedFrameId = null;
    _equippedTitleId = null;
    _achievementProgress.clear();
    _claimedAchievementIds.clear();
    _saveProfile();
    notifyListeners();
  }

  /// 8 Dilimli Şans Çarkı Ödül Listesi
  static const List<ChestReward> wheelSlices = [
    ChestReward(coins: 50, rewardTitle: '50 Altın', iconEmoji: '🪙'),
    ChestReward(diamonds: 2, rewardTitle: '2 Elmas', iconEmoji: '💎'),
    ChestReward(coins: 100, rewardTitle: '100 Altın', iconEmoji: '🪙'),
    ChestReward(diamonds: 4, rewardTitle: '4 Elmas', iconEmoji: '💎'),
    ChestReward(coins: 150, rewardTitle: '150 Altın', iconEmoji: '🪙'),
    ChestReward(diamonds: 6, rewardTitle: '6 Elmas', iconEmoji: '💎'),
    ChestReward(extraChests: 1, rewardTitle: '+1 Çevirme Hakkı', iconEmoji: '🎡'),
    ChestReward(coins: 250, diamonds: 10, rewardTitle: 'BÜYÜK İKRAMİYE!\n250 🪙 + 10 💎', iconEmoji: '👑'),
  ];

  ChestReward? spinMysteryWheel([int? forcedSliceIndex]) {
    if (_unopenedChests <= 0) return null;
    _unopenedChests -= 1;
    _totalChestsOpened += 1;

    int sliceIndex;
    if (forcedSliceIndex != null && forcedSliceIndex >= 0 && forcedSliceIndex < wheelSlices.length) {
      sliceIndex = forcedSliceIndex;
    } else {
      final rand = Random().nextInt(100);
      if (rand < 25) {
        sliceIndex = 0; // 50 Altın (%25)
      } else if (rand < 45) {
        sliceIndex = 1; // 2 Elmas (%20)
      } else if (rand < 65) {
        sliceIndex = 2; // 100 Altın (%20)
      } else if (rand < 80) {
        sliceIndex = 3; // 4 Elmas (%15)
      } else if (rand < 90) {
        sliceIndex = 4; // 150 Altın (%10)
      } else if (rand < 95) {
        sliceIndex = 5; // 6 Elmas (%5)
      } else if (rand < 98) {
        sliceIndex = 6; // +1 Çark (%3)
      } else {
        sliceIndex = 7; // Jackpot (%2)
      }
    }

    final reward = wheelSlices[sliceIndex];
    _coins += reward.coins;
    _diamonds += reward.diamonds;
    _unopenedChests += reward.extraChests;

    incrementQuestProgress(QuestType.spinWheel, 1);
    incrementAchievementProgress('wheel_spins_10', 1);

    _saveProfile();
    notifyListeners();

    return reward;
  }

  ChestReward? openMysteryChest() => spinMysteryWheel();

  void toggleCensorProfanity([bool? value]) {
    _censorProfanity = value ?? !_censorProfanity;
    _infoToast = _censorProfanity
        ? 'Küfür sansürü aktif edildi.'
        : 'Küfür sansürü kapatıldı (+18 ham yorumlar).';
    notifyListeners();
  }

  void clearInfoToast() {
    _infoToast = null;
    notifyListeners();
  }

  String generateShareSummary({bool isTowerVictory = false}) {
    if (isTowerVictory) {
      final perksText = activePerks.map((p) => '${p.iconEmoji} ${p.name}').join(' • ');
      return '🎮 Oyun Tahmin - KULE KOŞUSU FATİHİ 👑\n'
          '🚪 10/10 Kat Tamamlandı!\n'
          '${perksText.isNotEmpty ? "🎒 Yadigarlar: $perksText\n" : ""}'
          '🪙 +300 Altın • 💎 +10 Elmas • 🎡 +2 Çark Hakkı\n'
          '🎖️ Seviye $level ($rankTitle)\n'
          '🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩';
    } else {
      final isWon = _activeSession.isRoundWon;
      final gameName = _activeSession.currentRound?.oyunAdi ?? 'Gizemli Oyun';
      final attempts = maxAttempts - _activeSession.attemptsRemaining;
      final scoreVal = _activeSession.score;
      final streakVal = _activeSession.streak;
      
      final boxes = List.generate(maxAttempts, (i) => i < attempts ? (isWon && i == attempts - 1 ? '🟩' : '🟥') : '⬛').join();

      final modeText = isRoguelike ? "Kule Katı $_lastPlayedFloor/10" : "Sonsuz Mod";
      return '🎮 Oyun Tahmin ($modeText)\n'
          '🎯 Oyun: ${isWon ? gameName : "???"}\n'
          '${isWon ? "🏆 $attempts. Hakta Bildim!" : "💀 Bilemedim"}\n'
          '🔥 Seri: $streakVal • 🏆 Skor: $scoreVal\n'
          '$boxes\n'
          '🎖️ Seviye $level ($rankTitle)';
    }
  }

  int get nextExtraReviewCost {
    final isFreeDiamond = isRoguelike && hasPerk('free_diamond_joker') && _freeDiamondJokerAvailableThisRound;
    if (isFreeDiamond) return 0;
    return 1 + _activeSession.extraReviewsUsedThisRound;
  }

  int get nextLetterHintCost {
    int baseCost;
    if (!_activeSession.isWordSlotUnlocked) {
      baseCost = 10;
    } else {
      switch (_activeSession.letterHintsUsedThisRound) {
        case 0:
          baseCost = 8;
          break;
        case 1:
          baseCost = 15;
          break;
        case 2:
          baseCost = 25;
          break;
        default:
          baseCost = 35;
          break;
      }
    }
    if (hasPerk('letter_discount')) {
      baseCost = max(1, (baseCost * 0.5).round());
    }
    if (hasShopItem('boost_joker_discount')) {
      baseCost = max(1, (baseCost * 0.80).round());
    }
    return baseCost;
  }

  void setActiveCardIndex(int index) {
    if (index >= 0 && index < _activeSession.revealedReviewCount) {
      _activeSession.activeCardIndex = index;
      notifyListeners();
    }
  }

  bool _isRefillingQueue = false;

  /// Kullanıcı oturumuna göre profili yükler/değiştirir
  Future<void> initializeForUser(UserModel? user) async {
    final newUserId = user?.isGuest == false ? user?.id : null;
    if (_activeUserId != newUserId) {
      await _saveProfile();
    }
    _activeUserId = newUserId;
    await initializeGame(userId: _activeUserId);
  }

  /// Ziyaretçi verilerini belirtilen Google kullanıcısına aktarır ve misafir profilini temizler
  Future<void> migrateGuestToUser(String targetUserId) async {
    final guestData = await LocalRoundCacheService.loadProfileData(userId: null);
    if (guestData.isNotEmpty) {
      await LocalRoundCacheService.saveProfileData(
        highScore: guestData['highScore'] ?? 0,
        totalXp: guestData['totalXp'] ?? 0,
        unopenedChests: guestData['unopenedChests'] ?? 0,
        coins: guestData['coins'] ?? 50,
        diamonds: guestData['diamonds'] ?? 2,
        totalTowerWins: guestData['totalTowerWins'] ?? 0,
        bestStreak: guestData['bestStreak'] ?? 0,
        totalChestsOpened: guestData['totalChestsOpened'] ?? 0,
        discoveredPerks: (guestData['discoveredPerks'] as List<dynamic>?)?.cast<String>() ?? [],
        purchasedShopItems: (guestData['purchasedShopItems'] as List<dynamic>?)?.cast<String>() ?? [],
        equippedAvatar: guestData['equippedAvatar'] as String?,
        equippedFrame: guestData['equippedFrame'] as String?,
        equippedTitle: guestData['equippedTitle'] as String?,
        dailyQuestsJson: guestData['dailyQuestsJson'] as String?,
        dailyQuestsDate: guestData['dailyQuestsDate'] as String?,
        claimedAchievements: (guestData['claimedAchievements'] as List<dynamic>?)?.cast<String>() ?? [],
        achievementProgressJson: guestData['achievementProgressJson'] as String?,
        timeAttackHighScore: guestData['timeAttackHighScore'] as int?,
        userId: targetUserId,
      );
      await LocalRoundCacheService.clearGuestProfile();
    }
    _activeUserId = targetUserId;
    await initializeGame(userId: targetUserId);
  }

  Future<void> initializeGame({String? userId}) async {
    if (userId != null) {
      _activeUserId = userId;
    }
    final profile = await LocalRoundCacheService.loadProfileData(userId: _activeUserId);
    _highScore = profile['highScore'] ?? 0;
    _totalXp = profile['totalXp'] ?? 0;
    _unopenedChests = profile['unopenedChests'] ?? 0;
    _coins = profile['coins'] ?? 50;
    _diamonds = profile['diamonds'] ?? 2;
    _totalTowerWins = profile['totalTowerWins'] ?? 0;
    _bestStreak = profile['bestStreak'] ?? 0;
    _totalChestsOpened = profile['totalChestsOpened'] ?? 0;
    _timeAttackHighScore = profile['timeAttackHighScore'] ?? 0;
    _onlineDuelWins = profile['onlineDuelWins'] ?? 0;

    // Arka planda sessizce bulut profilini kontrol et (Açılışı asla bekletmez!)
    if (_activeUserId != null && _activeUserId!.isNotEmpty) {
      _syncCloudProfileInBackground(_activeUserId!);
    }

    final savedDiscovered = (profile['discoveredPerks'] as List<dynamic>?)?.cast<String>() ?? [];
    _discoveredPerkIds.clear();
    _discoveredPerkIds.addAll(savedDiscovered);

    final savedShopItems = (profile['purchasedShopItems'] as List<dynamic>?)?.cast<String>() ?? [];
    _purchasedShopItemIds.clear();
    _purchasedShopItemIds.addAll(savedShopItems);

    final savedClaimed = (profile['claimedAchievements'] as List<dynamic>?)?.cast<String>() ?? [];
    _claimedAchievementIds.clear();
    _claimedAchievementIds.addAll(savedClaimed);

    _achievementProgress.clear();
    if (profile['achievementProgressJson'] != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(profile['achievementProgressJson']);
        decoded.forEach((key, val) {
          if (val is int) _achievementProgress[key] = val;
        });
      } catch (_) {}
    }

    _dailyQuestsDateStr = profile['dailyQuestsDate'] as String? ?? '';
    if (profile['dailyQuestsJson'] != null) {
      _dailyQuests = DailyQuestCatalog.deserializeQuests(profile['dailyQuestsJson']);
    } else {
      _dailyQuests = [];
    }
    checkDailyQuestsReset();

    _equippedAvatarId = profile['equippedAvatar'] as String?;
    _equippedFrameId = profile['equippedFrame'] as String?;
    _equippedTitleId = profile['equippedTitle'] as String?;

    final cachedGames = await LocalRoundCacheService.loadGamesList();
    if (cachedGames.isNotEmpty) {
      _gamesList = cachedGames;
      notifyListeners();
    } else {
      loadGamesList();
    }

    if (_activeSession.currentRound == null) {
      await startNewRound();
    }

    _silentWarmUpAndRefillQueue();
  }

  Future<void> _syncCloudProfileInBackground(String userId) async {
    try {
      final cloudProfile = await _apiService.getProfile(userId);
      if (cloudProfile != null) {
        final cloudXp = cloudProfile['xp'] as int? ?? 0;
        final cloudCoins = cloudProfile['coins'] as int? ?? 0;
        final cloudWins = cloudProfile['totalWins'] as int? ?? 0;

        bool changed = false;
        if (cloudXp > _totalXp) {
          _totalXp = cloudXp;
          changed = true;
        }
        if (cloudCoins > _coins) {
          _coins = cloudCoins;
          changed = true;
        }
        if (cloudWins > _totalTowerWins) {
          _totalTowerWins = cloudWins;
          changed = true;
        }
        if (changed) {
          await _saveProfile();
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> loadGamesList() async {
    if (_isLoadingGames) return;
    _isLoadingGames = true;
    notifyListeners();

    try {
      final games = await _apiService.getGames();
      if (games.isNotEmpty) {
        _gamesList = games;
        await LocalRoundCacheService.saveGamesList(games);
        _errorMessage = null;
      }
    } catch (e) {
      if (_gamesList.isEmpty) {
        _errorMessage = 'Oyun listesi yüklenemedi: $e';
      }
    } finally {
      _isLoadingGames = false;
      notifyListeners();
    }
  }

  void _revealFirstLetter() {
    if (_activeSession.currentRound == null) return;
    final name = _activeSession.currentRound!.oyunAdi;
    for (int i = 0; i < name.length; i++) {
      if (name[i] != ' ') {
        _activeSession.revealedLetterIndices.add(i);
        _activeSession.isWordSlotUnlocked = true;
        break;
      }
    }
  }

  void _revealFirstVowel() {
    if (_activeSession.currentRound == null) return;
    final vowels = RegExp(r'[aeıioöuüAEIİOÖUÜ]');
    final name = _activeSession.currentRound!.oyunAdi;
    for (int i = 0; i < name.length; i++) {
      if (vowels.hasMatch(name[i])) {
        _activeSession.revealedLetterIndices.add(i);
        _activeSession.isWordSlotUnlocked = true;
        break;
      }
    }
  }

  void _revealTwoConsonants() {
    if (_activeSession.currentRound == null) return;
    final consonants = RegExp(r'[b-df-hj-np-tv-zB-DF-HJ-NP-TV-ZbcçdfgğhjklmnprsştvyzBCÇDFGĞHJKLMNPRSŞTVYZ]');
    final name = _activeSession.currentRound!.oyunAdi;
    int count = 0;
    for (int i = 0; i < name.length && count < 2; i++) {
      if (consonants.hasMatch(name[i]) && !_activeSession.revealedLetterIndices.contains(i)) {
        _activeSession.revealedLetterIndices.add(i);
        _activeSession.isWordSlotUnlocked = true;
        count++;
      }
    }
  }

  void _applyImposterReviewIfNeeded(GameModeSession session) {
    if (_gameMode != GameMode.imposter || session.reviews.isEmpty) return;
    _selectedImposterCardIndex = null;
    _isImposterFound = false;
    _eliminatedRealCardIndices.clear();
    session.attemptsRemaining = 2; // 2 Can Hakkı
    session.revealedReviewCount = min(5, session.reviews.length); // 5 yorumun hepsi açık gelir

    final random = Random();
    _imposterCardIndex = random.nextInt(session.revealedReviewCount);

    final fakePool = [
      const GameReviewDto(sira: 99, kullaniciAdi: 'GamerX', oynamaSuresiSaati: 145, yorum: 'Grafikleri fena değil ama sunucu çökmeleri ve eşleştirme sistemi oyunu mahvetmiş. Kesinlikle tavsiye etmiyorum.', tavsiye: false),
      const GameReviewDto(sira: 99, kullaniciAdi: 'ZombiAvcisi', oynamaSuresiSaati: 520, yorum: 'Envanter yönetimi ve zanaat sistemi inanılmaz derin. Arkadaşlarla üs kurup zombi dalgalarına karşı hayatta kalmak çok keyifli.', tavsiye: true),
      const GameReviewDto(sira: 99, kullaniciAdi: 'HikayeSever', oynamaSuresiSaati: 88, yorum: 'Hikayesi ve müzikleri insanı büyülüyor. Karakterler arası diyaloglar ve seçimlerin sonuca etkisi harika işlenmiş.', tavsiye: true),
      const GameReviewDto(sira: 99, kullaniciAdi: 'BossHunter', oynamaSuresiSaati: 310, yorum: 'Piksel sanat tasarımı ve boss dövüşlerindeki zorluk dengesi şahane. Souls-like türünü sevenler kaçırmasın.', tavsiye: true),
      const GameReviewDto(sira: 99, kullaniciAdi: 'DriftKrali', oynamaSuresiSaati: 45, yorum: 'Fizik motoru aşırı eğlenceli ve komik. Arabayla virajı alamayıp uçurumdan yuvarlanırken kahkahalara boğulduk.', tavsiye: true),
    ];
    final fake = fakePool[random.nextInt(fakePool.length)];
    if (_imposterCardIndex! < session.reviews.length) {
      session.reviews[_imposterCardIndex!] = fake;
    }
  }

  void recycleActiveReview() {
    final session = _activeSession;
    if (!canRecycleReview) return;
    if (session.reviews.isEmpty || session.activeCardIndex >= session.reviews.length) return;

    final currentIndex = session.activeCardIndex;
    final currentReview = session.reviews[currentIndex];

    final unrevealed = session.reviews.skip(session.revealedReviewCount).toList();
    if (unrevealed.isNotEmpty) {
      final random = Random();
      final swapIndexInUnrevealed = random.nextInt(unrevealed.length);
      final actualSwapIndex = session.revealedReviewCount + swapIndexInUnrevealed;

      session.reviews[currentIndex] = session.reviews[actualSwapIndex];
      session.reviews[actualSwapIndex] = currentReview;
      session.recycledUsedThisRound = true;
      _infoToast = '♻️ İnceleme başarıyla yenilendi!';
      notifyListeners();
    } else {
      _infoToast = 'Yenilenecek başka inceleme kalmadı.';
      notifyListeners();
    }
  }

  Future<void> startNewRound({int? initialCount}) async {
    _isLoadingRound = true;
    _errorMessage = null;
    _infoToast = null;
    
    final session = _activeSession;

    if (session.isRoundLost) {
      session.score = 0;
    }

    session.isRoundWon = false;
    session.isRoundLost = false;
    _lastPlayedFloor = _currentFloor;
    session.attemptsRemaining = maxAttempts;
    _shieldAvailableThisRound = true;
    _freeDiamondJokerAvailableThisRound = true;
    session.recycledUsedThisRound = false;
    session.isWordSlotUnlocked = false;
    session.letterHintsUsedThisRound = 0;
    session.usedDiamondJokerThisRound = false;
    session.extraReviewsUsedThisRound = 0;
    _justLeveledUp = false;
    _justEarnedChest = false;
    _offeredPerks.clear();

    if (hasPerk('lucky_start')) {
      _coins += 15;
    }

    if ((isBossFloor || _currentFloor == 5) && hasPerk('boss_slayer')) {
      session.attemptsRemaining = min(session.attemptsRemaining + 1, maxAttempts);
    }

    session.revealedLetterIndices.clear();
    session.wrongGuesses.clear();
    session.activeCardIndex = 0;
    _totalGamesPlayed += 1;

    final cachedRound = await LocalRoundCacheService.popNextCachedRound(_gameMode);
    if (cachedRound != null) {
      session.currentRound = cachedRound;
      session.reviews = List.from(cachedRound.yorumlar);

      if (hasPerk('veteran_eye')) {
        session.reviews.sort((a, b) => b.oynamaSuresiSaati.compareTo(a.oynamaSuresiSaati));
      }

      int startReviewCount = 1;
      if ((isBossFloor || _currentFloor == 5) && hasPerk('boss_slayer')) {
        startReviewCount = min(session.reviews.length, startReviewCount + 2);
      }
      session.revealedReviewCount = startReviewCount;

      if (hasPerk('first_letter_free')) {
        _revealFirstLetter();
      }
      if (hasPerk('xray_vowel')) {
        _revealFirstVowel();
      }
      if (hasPerk('consonant_crusher')) {
        _revealTwoConsonants();
      }

      _applyImposterReviewIfNeeded(session);

      _isLoadingRound = false;
      _errorMessage = null;
      notifyListeners();

      _silentWarmUpAndRefillQueue();
      return;
    }

    session.reviews.clear();
    session.revealedReviewCount = 0;
    notifyListeners();

    try {
      final requestCount = initialCount ?? (6 + _diamonds).clamp(6, 15);
      final round = await _apiService.startRound(
        count: requestCount,
        censorProfanity: false,
      );
      session.currentRound = round;
      session.reviews = List.from(round.yorumlar);

      if (hasPerk('veteran_eye')) {
        session.reviews.sort((a, b) => b.oynamaSuresiSaati.compareTo(a.oynamaSuresiSaati));
      }

      int startReviewCount = 1;
      if ((isBossFloor || _currentFloor == 5) && hasPerk('boss_slayer')) {
        startReviewCount = min(session.reviews.length, startReviewCount + 2);
      }
      session.revealedReviewCount = startReviewCount;

      if (hasPerk('first_letter_free')) {
        _revealFirstLetter();
      }
      if (hasPerk('xray_vowel')) {
        _revealFirstVowel();
      }
      if (hasPerk('consonant_crusher')) {
        _revealTwoConsonants();
      }

      _applyImposterReviewIfNeeded(session);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Yeni tur başlatılamadı: $e';
    } finally {
      _isLoadingRound = false;
      notifyListeners();
    }

    _silentWarmUpAndRefillQueue();
  }

  Future<void> _silentWarmUpAndRefillQueue() async {
    if (_isRefillingQueue) return;
    _isRefillingQueue = true;

    try {
      if (_gamesList.isEmpty) {
        final games = await _apiService.getGames();
        if (games.isNotEmpty) {
          _gamesList = games;
          await LocalRoundCacheService.saveGamesList(games);
          notifyListeners();
        }
      }

      _cachedRoundCount = await LocalRoundCacheService.getCachedRoundCount(_gameMode);
      notifyListeners();

      // Öncelik: Önce aktif oynanan modun kuyruğu, ardından diğer modlar
      final orderedModes = [
        _gameMode,
        ...GameMode.values.where((m) => m != _gameMode),
      ];

      for (final mode in orderedModes) {
        int targetLimit;
        switch (mode) {
          case GameMode.timeAttack:
            targetLimit = 15; // 1 dakikalık hızlı oyun için 15 tur yedek
            break;
          case GameMode.roguelike:
            targetLimit = 15; // Kule koşusu için 15 tur yedek
            break;
          case GameMode.endless:
          case GameMode.imposter:
          case GameMode.duel:
            targetLimit = 10;
            break;
        }

        try {
          int count = await LocalRoundCacheService.getCachedRoundCount(mode);
          while (count < targetLimit) {
            const prefetchCount = 20;
            final round = await _apiService.startRound(
              count: prefetchCount,
              censorProfanity: false,
            );
            await LocalRoundCacheService.pushRoundToQueue(round, mode);
            count = await LocalRoundCacheService.getCachedRoundCount(mode);
            _cachedRoundCount = await LocalRoundCacheService.getCachedRoundCount(_gameMode);
            notifyListeners();
          }
        } catch (modeErr) {
          debugPrint('Mode $mode refill error: $modeErr');
        }
      }
    } catch (e) {
      debugPrint('Global refill queue error: $e');
    } finally {
      _isRefillingQueue = false;
      _cachedRoundCount = await LocalRoundCacheService.getCachedRoundCount(_gameMode);
      notifyListeners();
    }
  }

  Future<void> refillQueueManually() async {
    _isRefillingQueue = false;
    await _silentWarmUpAndRefillQueue();
  }

  Future<void> clearAndRefillQueue() async {
    _isRefillingQueue = false;
    await LocalRoundCacheService.clearQueue();
    _cachedRoundCount = 0;
    notifyListeners();
    await _silentWarmUpAndRefillQueue();
  }

  bool submitGuess(String guessName) {
    final session = _activeSession;
    if (session.currentRound == null || isRoundFinished) return false;

    final sanitizedGuess = guessName.trim().toLowerCase();
    final targetName = session.currentRound!.oyunAdi.trim().toLowerCase();

    if (sanitizedGuess.isEmpty) return false;

    final cleanGuess = sanitizedGuess.replaceAll(RegExp(r'[^a-z0-9ğüşıöç]'), '');
    final cleanTarget = targetName.replaceAll(RegExp(r'[^a-z0-9ğüşıöç]'), '');

    final isMatch = sanitizedGuess == targetName ||
        (cleanGuess.isNotEmpty && cleanTarget == cleanGuess) ||
        (cleanGuess.length >= 4 && cleanTarget.contains(cleanGuess));

    if (isMatch) {
      if (_gameMode == GameMode.imposter) {
        session.isWordSlotUnlocked = true;
        _revealAllLetters();
        _coins += 25;
        _infoToast = '🎯 Yan Görev: Oyun adını bildiniz! (+25 🪙) Şimdi sahtekarı yakalayın!';
        _saveProfile();
        notifyListeners();
        return true;
      }

      session.isRoundWon = true;
      session.streak += 1;
      _totalWins += 1;
      session.isWordSlotUnlocked = true;
      
      session.revealedReviewCount = session.revealedReviewCount > 6 ? session.revealedReviewCount : min(session.reviews.length, 6);
      _revealAllLetters();

      int baseCoins;
      int baseDiamonds;
      switch (session.attemptsRemaining) {
        case 6:
        case 5:
          baseCoins = 10;
          baseDiamonds = 2;
          break;
        case 4:
          baseCoins = 7;
          baseDiamonds = 1;
          break;
        case 3:
          baseCoins = 5;
          baseDiamonds = 0;
          break;
        case 2:
          baseCoins = 3;
          baseDiamonds = 0;
          break;
        default:
          baseCoins = 2;
          baseDiamonds = 0;
          break;
      }

      final double streakStep = hasPerk('streak_master') ? 0.50 : 0.25;
      final double streakMultiplier = session.streak > 1 ? (1.0 + ((session.streak - 1) * streakStep)) : 1.0;
      session.lastWonCoins = (baseCoins * streakMultiplier).round();

      if (hasPerk('gold_merchant')) {
        session.lastWonCoins = (session.lastWonCoins * 1.5).round();
      }

      // Kalıcı Mağaza Güçlendirmesi: Tüccar Lisansı (+%15 Altın)
      if (hasShopItem('boost_gold_15') || hasShopItem('boost_gold_10')) {
        session.lastWonCoins = (session.lastWonCoins * 1.15).round();
      }

      if (session.attemptsRemaining >= maxAttempts && hasPerk('sharpshooter')) {
        session.lastWonCoins *= 2;
        baseDiamonds *= 2;
      }

      if (session.revealedReviewCount == 1 && hasPerk('gamblers_dice')) {
        session.lastWonCoins += 100;
        _infoToast = '🎲 Kumarbazın Zarı! +100 Ekstra Altın kazandınız!';
      }

      if (session.usedDiamondJokerThisRound) {
        session.lastWonDiamonds = 0;
      } else {
        int streakBonusDiamonds = 0;
        if (session.streak >= 5) {
          streakBonusDiamonds = (session.streak ~/ 5) + 1;
        } else if (session.streak >= 3) {
          streakBonusDiamonds = 1;
        }
        session.lastWonDiamonds = baseDiamonds + streakBonusDiamonds;

        // Kalıcı Mağaza Güçlendirmesi: Elmas Madencisi (+1 Elmas Bonusu)
        if (hasShopItem('boost_lucky_diamonds')) {
          session.lastWonDiamonds += 1;
        }
      }

      final oldLevel = level;
      final oldScore = session.score;
      final basePoints = session.attemptsRemaining * 200;
      int earnedScore = (basePoints * streakMultiplier).round();
      
      // Kalıcı Mağaza Güçlendirmesi: Usta Çırağı (+%15 XP)
      if (hasShopItem('boost_xp_15') || hasShopItem('boost_xp_10')) {
        earnedScore = (earnedScore * 1.15).round();
      }

      _lastEarnedXp = earnedScore;
      _totalXp += earnedScore;
      session.score += earnedScore;

      if (session.score > _highScore) {
        _highScore = session.score;
      }

      final oldThousands = oldScore ~/ 1000;
      final newThousands = session.score ~/ 1000;
      if (newThousands > oldThousands) {
        final chestsGained = newThousands - oldThousands;
        _unopenedChests += chestsGained;
        _justEarnedChest = true;
      }

      if (level > oldLevel) {
        final diff = level - oldLevel;
        _coins += 50 * diff;
        _diamonds += 2 * diff;
        _justLeveledUp = true;
        _newLevel = level;
      }

      // Sahtekar Modu 2x Ödül Bonusu Kontrolü
      if (_gameMode == GameMode.imposter && _selectedImposterCardIndex == _imposterCardIndex) {
        _isImposterFound = true;
        session.lastWonCoins *= 2;
        session.lastWonDiamonds = max(1, session.lastWonDiamonds * 2);
        incrementAchievementProgress('imposter_hunter', 1);
        incrementAchievementProgress('imposter_master', 1);
        _infoToast = '🕵️ SAHTEKAR YAKALANDI! 2X ALTIN & ELMAS!';
      }

      _coins += session.lastWonCoins;
      _diamonds += session.lastWonDiamonds;

      // Günlük Görevler İlerlemesi
      incrementQuestProgress(QuestType.winRounds, 1);
      final attemptsUsed = maxAttempts - session.attemptsRemaining;
      if (attemptsUsed <= 2) {
        incrementQuestProgress(QuestType.guessInAttempts, 1);
      }
      if (session.letterHintsUsedThisRound == 0) {
        incrementQuestProgress(QuestType.winWithoutHint, 1);
      }
      if (isRoguelike) {
        incrementQuestProgress(QuestType.reachTowerFloor, _currentFloor);
      }

      // Kalıcı Başarımlar İlerlemesi
      incrementAchievementProgress('first_win', 1);
      incrementAchievementProgress('win_25', 1);
      incrementAchievementProgress('win_100', 1);
      recordAchievementProgress('streak_5', session.streak);
      recordAchievementProgress('streak_10', session.streak);
      recordAchievementProgress('streak_20', session.streak);
      recordAchievementProgress('gold_collector', _coins);
      recordAchievementProgress('relic_collector_10', _discoveredPerkIds.length);
      if (session.attemptsRemaining >= maxAttempts) {
        incrementAchievementProgress('sharp_eye', 1);
      }
      if (isRoguelike) {
        recordAchievementProgress('tower_floor_5', _currentFloor);
      }

      if (session.streak > _bestStreak) {
        _bestStreak = session.streak;
      }

      if (isRoguelike) {
        if (_currentFloor == maxFloors && !_isRunCompleted) {
          _isRunCompleted = true;
          _totalTowerWins += 1;
          incrementAchievementProgress('tower_clear_1', 1);
          incrementAchievementProgress('tower_clear_5', 1);
          _coins += 300;
          _diamonds += 10;
          _totalXp += 2000;
          _unopenedChests += 2;
          _infoToast = '👑 10. KAT BOSS YENİLDİ! KOŞU ZAFERİ!';
        } else {
          _currentFloor += 1;
          _offeredPerks = PerkCatalog.getThreeRandomPerks(_activePerkIds);
          if (_currentFloor % 5 == 0) {
            _unopenedChests += 1;
            _diamonds += 3;
            _infoToast = '👑 $_currentFloor. KAT BOSS GELDİ! Ekstra Çark Hakkı & Elmas!';
          }
        }
      }

      _saveProfile();
      notifyListeners();
      return true;
    } else {
      if (!session.wrongGuesses.contains(guessName.trim())) {
        session.wrongGuesses.add(guessName.trim());
      }

      // Sıradaki yeni yorum kartını aç (Doğal akışta en fazla 5 yoruma kadar sınır)
      const maxNaturalReviews = 5;
      if (session.revealedReviewCount < session.reviews.length &&
          session.revealedReviewCount < maxNaturalReviews) {
        session.revealedReviewCount += 1;
        session.activeCardIndex = session.revealedReviewCount - 1;
      }

      // 🛡️ Koruyucu Kalkan kontrolü: Yeni yorum AÇILIR ama CAN DÜŞMEZ
      if (hasPerk('guardian_shield') && _shieldAvailableThisRound) {
        _shieldAvailableThisRound = false;
        _infoToast = '🛡️ Koruyucu Kalkan hasarı engelledi! Yeni ipucu açıldı, can gitmedi.';
        notifyListeners();
        return false;
      }

      // Zaman Yarışı, Düello ve Sahtekar modunda oyun adı tahmini can düşürmez (Sahtekar modunda can sahtekarı suçlarken gider)
      if (_gameMode != GameMode.imposter && _gameMode != GameMode.timeAttack && _gameMode != GameMode.duel) {
        session.attemptsRemaining -= 1;

        if (hasPerk('gamblers_dice') && session.attemptsRemaining > 0) {
          session.attemptsRemaining -= 1;
          _infoToast = '🎲 Kumarbazın Zarı! Ekstra 1 can daha kaybettiniz.';
        }

        if (session.attemptsRemaining <= 0) {
          if (hasPerk('second_wind') && !_secondWindUsedThisRun) {
            _secondWindUsedThisRun = true;
            session.attemptsRemaining = 2;
            session.isRoundLost = false;
            _infoToast = '🌪️ İkinci Rüzgar devreye girdi! +2 Canla kurtuldunuz!';
            notifyListeners();
            return false;
          }

          session.isRoundLost = true;
          if (session.score > _highScore) {
            _highScore = session.score;
          }
          session.streak = 0;

          if (isRoguelike) {
            _activePerkIds.clear();
            _currentFloor = 1;
          }
          _saveProfile();
        }
      }

      notifyListeners();
      return false;
    }
  }

  void giveUpAndRevealAnswer() {
    final session = _activeSession;
    session.isRoundLost = true;
    session.isWordSlotUnlocked = true;
    session.revealedReviewCount = session.revealedReviewCount > 6 ? session.revealedReviewCount : min(session.reviews.length, 6);
    _revealAllLetters();
    if (session.score > _highScore) {
      _highScore = session.score;
    }
    session.streak = 0;

    if (isRoguelike) {
      _activePerkIds.clear();
      _currentFloor = 1;
    }

    _saveProfile();
    notifyListeners();
  }

  void _revealAllLetters() {
    final session = _activeSession;
    if (session.currentRound != null) {
      final name = session.currentRound!.oyunAdi;
      for (int i = 0; i < name.length; i++) {
        session.revealedLetterIndices.add(i);
      }
    }
  }

  bool unlockWordSlotTable() {
    final session = _activeSession;
    if (session.isWordSlotUnlocked || isRoundFinished) return false;

    const cost = 10;
    if (_coins < cost) {
      _infoToast = 'Harf tablosunu açmak için en az $cost Altın gerekli!';
      notifyListeners();
      return false;
    }

    _coins -= cost;
    session.isWordSlotUnlocked = true;
    _saveProfile();
    notifyListeners();
    return true;
  }

  bool useLetterHintJoker() {
    final session = _activeSession;
    if (session.currentRound == null || isRoundFinished) return false;

    final cost = nextLetterHintCost;
    if (_coins < cost) {
      _infoToast = 'Harf açmak için $cost Altın gerekli!';
      notifyListeners();
      return false;
    }

    final targetName = session.currentRound!.oyunAdi;
    final unrevealedIndices = <int>[];
    for (int i = 0; i < targetName.length; i++) {
      if (targetName[i] != ' ' && !session.revealedLetterIndices.contains(i)) {
        unrevealedIndices.add(i);
      }
    }

    if (unrevealedIndices.isEmpty) {
      _infoToast = 'Tüm harfler zaten açık!';
      notifyListeners();
      return false;
    }

    final random = Random();
    final chosenIndex = unrevealedIndices[random.nextInt(unrevealedIndices.length)];

    _coins -= cost;
    session.letterHintsUsedThisRound += 1;
    session.revealedLetterIndices.add(chosenIndex);
    session.isWordSlotUnlocked = true;
    _saveProfile();
    notifyListeners();
    return true;
  }

  Future<bool> useExtraReviewJoker() async {
    final session = _activeSession;
    if (session.currentRound == null || isRoundFinished || _isLoadingHint) return false;

    if (session.revealedReviewCount >= 20) {
      _infoToast = 'Maksimum ipucu sınırına (20 Yorum) ulaştınız!';
      notifyListeners();
      return false;
    }

    final cost = nextExtraReviewCost;

    if (cost > 0) {
      if (_diamonds < cost) {
        _infoToast = 'Ekstra yorum için en az $cost Elmas gerekli!';
        notifyListeners();
        return false;
      }
      _diamonds -= cost;
      session.usedDiamondJokerThisRound = true;
      _saveProfile();
    } else {
      _freeDiamondJokerAvailableThisRound = false;
      _infoToast = '💎 Elmas Rezervi: İlk ekstra yorum ücretsiz kullanıldı!';
    }
    session.extraReviewsUsedThisRound += 1;

    if (session.revealedReviewCount < session.reviews.length) {
      session.revealedReviewCount += 1;
      session.activeCardIndex = session.revealedReviewCount - 1;
      notifyListeners();
      return true;
    }

    _isLoadingHint = true;
    notifyListeners();

    try {
      final hintResponse = await _apiService.getExtraReview(
        appId: session.currentRound!.appId,
        count: 1,
        censorProfanity: false,
      );

      if (hintResponse.isNotEmpty) {
        session.reviews.add(hintResponse.first);
        session.revealedReviewCount += 1;
        session.activeCardIndex = session.revealedReviewCount - 1;
        return true;
      }
    } catch (e) {
      _errorMessage = 'Ekstra yorum alınamadı: $e';
    } finally {
      _isLoadingHint = false;
      notifyListeners();
    }
    return false;
  }

  bool useExtraLifeJoker() {
    final session = _activeSession;
    if (!session.isRoundLost) return false;

    if (_diamonds < 1) {
      _infoToast = 'Son Şans canı için en az 1 Elmas gerekli!';
      notifyListeners();
      return false;
    }

    _diamonds -= 1;
    session.attemptsRemaining = 1;
    session.isRoundLost = false;
    _saveProfile();
    notifyListeners();
    return true;
  }

  void addDebugCurrency({int coins = 25, int diamonds = 1}) {
    _coins += coins;
    _diamonds += diamonds;
    _saveProfile();
    notifyListeners();
  }

  void addDebugXp({int xp = 500}) {
    final oldLevel = level;
    _totalXp += xp;
    if (level > oldLevel) {
      final diff = level - oldLevel;
      _coins += 50 * diff;
      _diamonds += 2 * diff;
      _justLeveledUp = true;
      _newLevel = level;
    }
    _saveProfile();
    notifyListeners();
  }

  void addDebugChest({int count = 1}) {
    _unopenedChests += count;
    _saveProfile();
    notifyListeners();
  }

  RoguelikePerk? addDebugPerk([String? perkId]) {
    _gameMode = GameMode.roguelike;
    RoguelikePerk? addedPerk;
    if (perkId != null) {
      addedPerk = PerkCatalog.findById(perkId);
      if (addedPerk != null) {
        _activePerkIds.add(perkId);
        if (perkId == 'vitality') {
          _roguelikeSession.attemptsRemaining = min(_roguelikeSession.attemptsRemaining + 1, 7);
        }
      }
    } else {
      final available = PerkCatalog.allPerks.where((p) => !_activePerkIds.contains(p.id)).toList();
      if (available.isNotEmpty) {
        addedPerk = available[Random().nextInt(available.length)];
        _activePerkIds.add(addedPerk.id);
        if (addedPerk.id == 'vitality') {
          _roguelikeSession.attemptsRemaining = min(_roguelikeSession.attemptsRemaining + 1, 6);
        }
      }
    }

    if (addedPerk != null) {
      _discoveredPerkIds.add(addedPerk.id);
      _infoToast = '🎒 "${addedPerk.name}" yadigarı eklendi! (Toplam ${_activePerkIds.length})';
      _saveProfile();
    } else {
      _infoToast = '🎒 Tüm yadigarlar zaten kuşanıldı!';
    }
    notifyListeners();
    return addedPerk;
  }

  void jumpToBossFloor() {
    _gameMode = GameMode.roguelike;
    _currentFloor = 10;
    notifyListeners();
  }

  void continueTowerAscension() {
    if (!isRoguelike) return;
    _currentFloor += 1;
    _offeredPerks = PerkCatalog.getThreeRandomPerks(_activePerkIds);
    _infoToast = '⚡ Kule Rekor Tırmanışı! Kat $_currentFloor';
    notifyListeners();
  }

  void clearActivePerks() {
    _activePerkIds.clear();
    _infoToast = '🗑️ Tüm yadigarlar temizlendi!';
    notifyListeners();
  }

  @visibleForTesting
  void setMockRoundForTesting(RoundModel round) {
    _activeSession.currentRound = round;
    _activeSession.reviews = List.from(round.yorumlar);
    _activeSession.revealedReviewCount = 1;
    _activeSession.attemptsRemaining = 5;
    notifyListeners();
  }
}
