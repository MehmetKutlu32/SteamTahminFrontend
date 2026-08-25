import 'package:flutter/material.dart';

/// Oyuncu seviye, rütbe ve XP ilerleme modeli
class PlayerRank {
  static const int xpPerLevel = 1000;

  static int calculateLevel(int totalXp) {
    if (totalXp < 0) return 1;
    return 1 + (totalXp ~/ xpPerLevel);
  }

  static int currentLevelXp(int totalXp) {
    if (totalXp < 0) return 0;
    return totalXp % xpPerLevel;
  }

  static double levelProgress(int totalXp) {
    return currentLevelXp(totalXp) / xpPerLevel;
  }

  static String getRankTitle(int level) {
    if (level < 5) return 'Çaylak Tahminci';
    if (level < 10) return 'Oyun Kaşifi';
    if (level < 20) return 'Koleksiyoncu';
    if (level < 50) return 'Kıdemli Eleştirmen';
    return 'Büyük Usta';
  }

  static String getRankBadge(int level) {
    if (level < 5) return '🥉';
    if (level < 10) return '🥈';
    if (level < 20) return '🥇';
    if (level < 50) return '💎';
    return '👑';
  }

  static Color getRankColor(int level) {
    if (level < 5) return const Color(0xFFCD7F32); // Bronze
    if (level < 10) return const Color(0xFFC0C0C0); // Silver
    if (level < 20) return const Color(0xFFFFD700); // Gold
    if (level < 50) return const Color(0xFF00E5FF); // Diamond Cyan
    return const Color(0xFFFF9100); // Master Amber/Orange
  }
}

/// Gizemli Sandık / Şans Çarkı ödül içeriği
class ChestReward {
  final int coins;
  final int diamonds;
  final int extraChests;
  final String rewardTitle;
  final String iconEmoji;

  const ChestReward({
    this.coins = 0,
    this.diamonds = 0,
    this.extraChests = 0,
    this.rewardTitle = 'Ödül',
    this.iconEmoji = '🎡',
  });
}
