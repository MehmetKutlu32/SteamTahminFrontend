import 'package:flutter_test/flutter_test.dart';
import 'package:steam_tahmin_frontend/models/player_progression.dart';

void main() {
  group('PlayerRank Progression Tests', () {
    test('Calculates correct level from total XP', () {
      expect(PlayerRank.calculateLevel(0), 1);
      expect(PlayerRank.calculateLevel(500), 1);
      expect(PlayerRank.calculateLevel(999), 1);
      expect(PlayerRank.calculateLevel(1000), 2);
      expect(PlayerRank.calculateLevel(4500), 5);
      expect(PlayerRank.calculateLevel(10000), 11);
      expect(PlayerRank.calculateLevel(50000), 51);
    });

    test('Calculates current level XP and progress percentage', () {
      expect(PlayerRank.currentLevelXp(0), 0);
      expect(PlayerRank.currentLevelXp(450), 450);
      expect(PlayerRank.currentLevelXp(1750), 750);
      expect(PlayerRank.levelProgress(1750), 0.75);
    });

    test('Returns correct rank titles without Steam branding', () {
      expect(PlayerRank.getRankTitle(1), 'Çaylak Tahminci');
      expect(PlayerRank.getRankTitle(4), 'Çaylak Tahminci');
      expect(PlayerRank.getRankTitle(5), 'Oyun Kaşifi');
      expect(PlayerRank.getRankTitle(10), 'Koleksiyoncu');
      expect(PlayerRank.getRankTitle(20), 'Kıdemli Eleştirmen');
      expect(PlayerRank.getRankTitle(50), 'Büyük Usta');
    });

    test('Returns correct rank badges and colors', () {
      expect(PlayerRank.getRankBadge(1), '🥉');
      expect(PlayerRank.getRankBadge(5), '🥈');
      expect(PlayerRank.getRankBadge(10), '🥇');
      expect(PlayerRank.getRankBadge(20), '💎');
      expect(PlayerRank.getRankBadge(50), '👑');
    });
  });
}
