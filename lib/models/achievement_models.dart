import 'package:flutter/material.dart';

enum AchievementCategory {
  general,
  endless,
  tower,
  imposter,
  timeAttack,
  duel,
  wealth,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final AchievementCategory category;
  final int targetValue;
  final int rewardDiamonds;
  final int rewardGold;
  final String? rewardTitleId;
  final Color accentColor;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.category,
    required this.targetValue,
    this.rewardDiamonds = 0,
    this.rewardGold = 0,
    this.rewardTitleId,
    this.accentColor = const Color(0xFFFFD700),
  });

  String get categoryLabel {
    switch (category) {
      case AchievementCategory.endless:
        return '♾️ Sonsuz Klasik';
      case AchievementCategory.tower:
        return '🏰 Kule Koşusu';
      case AchievementCategory.imposter:
        return '🕵️ Sahtekar Modu';
      case AchievementCategory.timeAttack:
        return '⚡ Zaman Yarışı';
      case AchievementCategory.duel:
        return '🥊 1v1 Düello';
      case AchievementCategory.wealth:
        return '🪙 Ekonomi & Çark';
      case AchievementCategory.general:
        return '🎯 Genel';
    }
  }
}

class AchievementCatalog {
  static const List<Achievement> allAchievements = [
    // 🎯 Genel Tahmin Başarımları
    Achievement(
      id: 'first_win',
      title: 'İlk Zafer',
      description: 'Herhangi bir modda ilk oyununu doğru tahmin et.',
      iconEmoji: '🎉',
      category: AchievementCategory.general,
      targetValue: 1,
      rewardGold: 50,
      rewardDiamonds: 1,
      accentColor: Color(0xFF66BB6A),
    ),
    Achievement(
      id: 'win_25',
      title: 'Kıdemli Tahminci',
      description: 'Toplam 25 farklı oyunu başarıyla bil.',
      iconEmoji: '🎯',
      category: AchievementCategory.general,
      targetValue: 25,
      rewardGold: 250,
      rewardDiamonds: 5,
      accentColor: Color(0xFF42A5F5),
    ),
    Achievement(
      id: 'win_100',
      title: 'Oyun Kütüphanesi Fatihi',
      description: 'Toplam 100 farklı oyunu başarıyla bil.',
      iconEmoji: '📚',
      category: AchievementCategory.general,
      targetValue: 100,
      rewardGold: 1000,
      rewardDiamonds: 20,
      rewardTitleId: 'title_library_master',
      accentColor: Color(0xFFAB47BC),
    ),
    Achievement(
      id: 'sharp_eye',
      title: 'Keskin Gözler',
      description: 'İlk incelemeden (1. denemede) 5 oyun bil.',
      iconEmoji: '👁️',
      category: AchievementCategory.general,
      targetValue: 5,
      rewardGold: 200,
      rewardDiamonds: 4,
      accentColor: Color(0xFF00E5FF),
    ),

    // ♾️ Sonsuz Klasik Başarımları
    Achievement(
      id: 'streak_5',
      title: 'Ateşli Seri',
      description: 'Sonsuz Modda arka arkaya 5 galibiyetlik seri yakala.',
      iconEmoji: '🔥',
      category: AchievementCategory.endless,
      targetValue: 5,
      rewardGold: 150,
      rewardDiamonds: 3,
      accentColor: Color(0xFFFF7043),
    ),
    Achievement(
      id: 'streak_10',
      title: 'Durdurulamaz!',
      description: 'Sonsuz Modda arka arkaya 10 galibiyetlik efsanevi seri yakala.',
      iconEmoji: '⚡',
      category: AchievementCategory.endless,
      targetValue: 10,
      rewardGold: 500,
      rewardDiamonds: 10,
      accentColor: Color(0xFFFFD54F),
    ),
    Achievement(
      id: 'streak_20',
      title: 'Kahin',
      description: 'Sonsuz Modda 20 galibiyetlik rekor seri yap.',
      iconEmoji: '🔮',
      category: AchievementCategory.endless,
      targetValue: 20,
      rewardGold: 1200,
      rewardDiamonds: 25,
      accentColor: Color(0xFF9C27B0),
    ),

    // 🏰 Kule Koşusu Başarımları
    Achievement(
      id: 'tower_floor_5',
      title: 'Kule Yolcusu',
      description: 'Kule Koşusunda 5. kata ulaş.',
      iconEmoji: '🧗',
      category: AchievementCategory.tower,
      targetValue: 5,
      rewardGold: 150,
      rewardDiamonds: 3,
      accentColor: Color(0xFF26A69A),
    ),
    Achievement(
      id: 'tower_clear_1',
      title: 'Kule Fatihi',
      description: '10 katlık Kule Koşusunu başarıyla tamamla.',
      iconEmoji: '👑',
      category: AchievementCategory.tower,
      targetValue: 1,
      rewardGold: 500,
      rewardDiamonds: 10,
      accentColor: Color(0xFFFFD700),
    ),
    Achievement(
      id: 'tower_clear_5',
      title: 'Zirvenin Hükümdarı',
      description: 'Kule Koşusunu 5 kez fethet.',
      iconEmoji: '🏰',
      category: AchievementCategory.tower,
      targetValue: 5,
      rewardGold: 1500,
      rewardDiamonds: 25,
      accentColor: Color(0xFFE040FB),
    ),

    // ⚡ Zaman Yarışı Başarımları
    Achievement(
      id: 'time_attack_5',
      title: 'Hız Canavarı',
      description: 'Zaman Yarışında 60 saniyede en az 5 oyun bil.',
      iconEmoji: '⏱️',
      category: AchievementCategory.timeAttack,
      targetValue: 5,
      rewardGold: 300,
      rewardDiamonds: 5,
      accentColor: Color(0xFFFF5252),
    ),
    Achievement(
      id: 'time_attack_10',
      title: 'Zamanın Efendisi',
      description: 'Zaman Yarışında tek turda 10 oyun bil.',
      iconEmoji: '⚡',
      category: AchievementCategory.timeAttack,
      targetValue: 10,
      rewardGold: 750,
      rewardDiamonds: 15,
      accentColor: Color(0xFFFF1744),
    ),

    // 🕵️ Sahtekar Modu Başarımları
    Achievement(
      id: 'imposter_hunter',
      title: 'Sahtekar Avcısı',
      description: 'Sahtekar modunda 5 kez sahte incelemeyi doğru yakala.',
      iconEmoji: '🕵️',
      category: AchievementCategory.imposter,
      targetValue: 5,
      rewardGold: 250,
      rewardDiamonds: 5,
      accentColor: Color(0xFF7E57C2),
    ),
    Achievement(
      id: 'imposter_master',
      title: 'Sherlock Holmes',
      description: 'Sahtekar modunda toplam 15 sahtekarı yakala.',
      iconEmoji: '🔍',
      category: AchievementCategory.imposter,
      targetValue: 15,
      rewardGold: 700,
      rewardDiamonds: 15,
      accentColor: Color(0xFFBA68C8),
    ),

    // 🥊 1v1 Düello Başarımları
    Achievement(
      id: 'duel_first_win',
      title: 'Düello Şampiyonu',
      description: '1v1 Düello modunda ilk maçını kazan.',
      iconEmoji: '🥊',
      category: AchievementCategory.duel,
      targetValue: 1,
      rewardGold: 150,
      rewardDiamonds: 2,
      accentColor: Color(0xFFFF9800),
    ),
    Achievement(
      id: 'duel_5_wins',
      title: 'Arena Gladyatörü',
      description: '1v1 Düello modunda toplam 5 maç kazan.',
      iconEmoji: '🏆',
      category: AchievementCategory.duel,
      targetValue: 5,
      rewardGold: 450,
      rewardDiamonds: 8,
      accentColor: Color(0xFFFF6D00),
    ),

    // 💰 Zenginlik & Çark Başarımları
    Achievement(
      id: 'wheel_spins_10',
      title: 'Çark Tutkunu',
      description: 'Şans Çarkını toplam 10 kez çevir.',
      iconEmoji: '🎡',
      category: AchievementCategory.wealth,
      targetValue: 10,
      rewardGold: 200,
      rewardDiamonds: 3,
      accentColor: Color(0xFFFFCA28),
    ),
    Achievement(
      id: 'gold_collector',
      title: 'Hazine Sandığı',
      description: 'Toplam 2.500 Altın kazan.',
      iconEmoji: '🪙',
      category: AchievementCategory.wealth,
      targetValue: 2500,
      rewardDiamonds: 8,
      accentColor: Color(0xFFFFD54F),
    ),
    Achievement(
      id: 'relic_collector_10',
      title: 'Yadigar Kaşifi',
      description: 'Koleksiyonunda en az 10 farklı yadigar keşfet.',
      iconEmoji: '🎒',
      category: AchievementCategory.wealth,
      targetValue: 10,
      rewardGold: 400,
      rewardDiamonds: 6,
      accentColor: Color(0xFF26C6DA),
    ),
  ];

  static Achievement? findById(String id) {
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
