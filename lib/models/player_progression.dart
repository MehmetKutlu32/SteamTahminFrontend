import 'package:flutter/material.dart';

/// Oyuncu seviye, rütbe ve kademeli (progresif) XP ilerleme modeli
class PlayerRank {
  /// Bir seviyeyi tamamlamak için gereken XP miktarı (Kademeli artan eğri)
  static int xpRequiredForLevel(int level) {
    if (level <= 1) return 1000;
    // Seviye 2: 1450, Seviye 3: 2000, Seviye 4: 2650, Seviye 5: 3400...
    return 800 + (level * 350) + (level * level * 50);
  }

  /// Belirli bir seviyeye ulaşmak için gereken toplam kümülatif XP
  static int cumulativeXpForLevel(int level) {
    if (level <= 1) return 0;
    int total = 0;
    for (int lvl = 1; lvl < level; lvl++) {
      total += xpRequiredForLevel(lvl);
    }
    return total;
  }

  /// Toplam XP'ye göre mevcut seviyeyi hesaplar
  static int calculateLevel(int totalXp) {
    if (totalXp <= 0) return 1;
    int level = 1;
    int accumulated = 0;
    while (true) {
      final req = xpRequiredForLevel(level);
      if (totalXp < accumulated + req) {
        return level;
      }
      accumulated += req;
      level++;
      if (level >= 999) return 999;
    }
  }

  /// Mevcut seviyedeki kazanılan XP (Dilim içi ilerleme)
  static int currentLevelXp(int totalXp) {
    if (totalXp <= 0) return 0;
    int level = 1;
    int accumulated = 0;
    while (true) {
      final req = xpRequiredForLevel(level);
      if (totalXp < accumulated + req) {
        return totalXp - accumulated;
      }
      accumulated += req;
      level++;
    }
  }

  /// Mevcut seviyeyi tamamlamak için gereken toplam dilim XP
  static int xpNeededForNextLevel(int totalXp) {
    final currentLvl = calculateLevel(totalXp);
    return xpRequiredForLevel(currentLvl);
  }

  /// Seviye ilerleme yüzdesi (0.0 - 1.0)
  static double levelProgress(int totalXp) {
    if (totalXp <= 0) return 0.0;
    final current = currentLevelXp(totalXp);
    final target = xpNeededForNextLevel(totalXp);
    return (current / target).clamp(0.0, 1.0);
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
