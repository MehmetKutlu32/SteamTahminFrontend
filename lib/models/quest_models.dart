import 'dart:convert';

enum QuestType {
  winRounds,
  reachTowerFloor,
  spinWheel,
  winWithoutHint,
  timeAttackScore,
  guessInAttempts,
}

class DailyQuest {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final QuestType type;
  final int targetValue;
  int currentValue;
  final int rewardGold;
  final int rewardDiamonds;
  final int rewardXp;
  bool isClaimed;

  DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    this.rewardGold = 0,
    this.rewardDiamonds = 0,
    this.rewardXp = 0,
    this.isClaimed = false,
  });

  bool get isCompleted => currentValue >= targetValue;
  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconEmoji': iconEmoji,
        'type': type.name,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'rewardGold': rewardGold,
        'rewardDiamonds': rewardDiamonds,
        'rewardXp': rewardXp,
        'isClaimed': isClaimed,
      };

  factory DailyQuest.fromJson(Map<String, dynamic> json) => DailyQuest(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        iconEmoji: json['iconEmoji'] as String? ?? '📋',
        type: QuestType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => QuestType.winRounds,
        ),
        targetValue: json['targetValue'] as int? ?? 1,
        currentValue: json['currentValue'] as int? ?? 0,
        rewardGold: json['rewardGold'] as int? ?? 0,
        rewardDiamonds: json['rewardDiamonds'] as int? ?? 0,
        rewardXp: json['rewardXp'] as int? ?? 0,
        isClaimed: json['isClaimed'] as bool? ?? false,
      );
}

class DailyQuestCatalog {
  static List<DailyQuest> generateDailyQuests(DateTime date) {
    // Günün tarihine göre sabit deterministik veya zengin 3 görev üret
    final daySeed = date.year * 10000 + date.month * 100 + date.day;
    final index1 = daySeed % 4;
    final index2 = (daySeed ~/ 3) % 3;
    final index3 = (daySeed ~/ 7) % 3;

    final pool1 = [
      DailyQuest(
        id: 'quest_win_3',
        title: 'Usta Tahminci',
        description: 'Herhangi bir modda 3 oyun tahmin et.',
        iconEmoji: '🎯',
        type: QuestType.winRounds,
        targetValue: 3,
        rewardGold: 75,
        rewardXp: 150,
      ),
      DailyQuest(
        id: 'quest_win_5',
        title: 'Oyun Avcısı',
        description: 'Herhangi bir modda 5 oyun tahmin et.',
        iconEmoji: '🏹',
        type: QuestType.winRounds,
        targetValue: 5,
        rewardGold: 120,
        rewardDiamonds: 1,
        rewardXp: 250,
      ),
      DailyQuest(
        id: 'quest_win_no_hint',
        title: 'Saf Zeka',
        description: 'Hiç harf ipucu kullanmadan 2 oyun bil.',
        iconEmoji: '🧠',
        type: QuestType.winWithoutHint,
        targetValue: 2,
        rewardGold: 100,
        rewardDiamonds: 2,
        rewardXp: 200,
      ),
      DailyQuest(
        id: 'quest_first_try',
        title: 'İlk Görüşte',
        description: 'İlk 2 denemede 2 oyunu doğru bil.',
        iconEmoji: '⚡',
        type: QuestType.guessInAttempts,
        targetValue: 2,
        rewardGold: 90,
        rewardDiamonds: 1,
        rewardXp: 180,
      ),
    ];

    final pool2 = [
      DailyQuest(
        id: 'quest_tower_3',
        title: 'Kule Tırmanışı',
        description: 'Kule Koşusunda en az 3. kata ulaş.',
        iconEmoji: '🏰',
        type: QuestType.reachTowerFloor,
        targetValue: 3,
        rewardGold: 80,
        rewardDiamonds: 1,
        rewardXp: 200,
      ),
      DailyQuest(
        id: 'quest_tower_5',
        title: 'Kule Şövalyesi',
        description: 'Kule Koşusunda en az 5. kata ulaş.',
        iconEmoji: '🛡️',
        type: QuestType.reachTowerFloor,
        targetValue: 5,
        rewardGold: 130,
        rewardDiamonds: 2,
        rewardXp: 300,
      ),
      DailyQuest(
        id: 'quest_time_attack',
        title: 'Zaman Yarışçısı',
        description: 'Zaman Yarışında en az 3 oyun bil.',
        iconEmoji: '⏱️',
        type: QuestType.timeAttackScore,
        targetValue: 3,
        rewardGold: 100,
        rewardDiamonds: 1,
        rewardXp: 220,
      ),
    ];

    final pool3 = [
      DailyQuest(
        id: 'quest_wheel_1',
        title: 'Çark Tutkunu',
        description: 'Şans Çarkını 1 kez çevir.',
        iconEmoji: '🎡',
        type: QuestType.spinWheel,
        targetValue: 1,
        rewardGold: 50,
        rewardXp: 100,
      ),
      DailyQuest(
        id: 'quest_wheel_2',
        title: 'Şans Peşinde',
        description: 'Şans Çarkını 2 kez çevir.',
        iconEmoji: '🎁',
        type: QuestType.spinWheel,
        targetValue: 2,
        rewardGold: 100,
        rewardDiamonds: 1,
        rewardXp: 180,
      ),
      DailyQuest(
        id: 'quest_win_2',
        title: 'Hızlı Başlangıç',
        description: 'Günün ilk 2 oyununu tamamla.',
        iconEmoji: '☕',
        type: QuestType.winRounds,
        targetValue: 2,
        rewardGold: 60,
        rewardXp: 120,
      ),
    ];

    return [
      pool1[index1 % pool1.length],
      pool2[index2 % pool2.length],
      pool3[index3 % pool3.length],
    ];
  }

  static String serializeQuests(List<DailyQuest> quests) {
    return jsonEncode(quests.map((q) => q.toJson()).toList());
  }

  static List<DailyQuest> deserializeQuests(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => DailyQuest.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
