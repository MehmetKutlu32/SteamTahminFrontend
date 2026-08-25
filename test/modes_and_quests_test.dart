import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steam_tahmin_frontend/models/achievement_models.dart';
import 'package:steam_tahmin_frontend/models/roguelike_models.dart';
import 'package:steam_tahmin_frontend/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Daily Quests & Achievements Tests', () {
    test('Daily Quests generate 3 diverse quests and progress properly', () {
      final provider = GameProvider();
      provider.checkDailyQuestsReset();
      expect(provider.dailyQuests.length, 3);

      final firstQuest = provider.dailyQuests.first;
      expect(firstQuest.isClaimed, isFalse);

      // Increment progress
      provider.incrementQuestProgress(firstQuest.type, firstQuest.targetValue);
      expect(firstQuest.isCompleted, isTrue);

      final initialCoins = provider.coins;
      final claimed = provider.claimQuestReward(firstQuest);
      expect(claimed, isTrue);
      expect(firstQuest.isClaimed, isTrue);
      expect(provider.coins, initialCoins + firstQuest.rewardGold);
    });

    test('Achievement catalog contains 14+ achievements and tracks progress', () {
      final provider = GameProvider();
      expect(AchievementCatalog.allAchievements.length >= 14, isTrue);

      final firstWinAch = AchievementCatalog.findById('first_win')!;
      expect(provider.isAchievementCompleted(firstWinAch), isFalse);

      provider.incrementAchievementProgress('first_win', 1);
      expect(provider.isAchievementCompleted(firstWinAch), isTrue);

      final initialCoins = provider.coins;
      final claimed = provider.claimAchievementReward(firstWinAch);
      expect(claimed, isTrue);
      expect(provider.isAchievementClaimed('first_win'), isTrue);
      expect(provider.coins, initialCoins + firstWinAch.rewardGold);
    });

    test('Time attack and duel stats recording', () {
      final provider = GameProvider();
      expect(provider.timeAttackHighScore, 0);

      provider.recordTimeAttackResult(6);
      expect(provider.timeAttackHighScore, 6);

      provider.recordDuelWin(1);
      expect(provider.duelP1Wins, 1);
      expect(provider.duelP2Wins, 0);
    });

    test('Imposter mode switching, accusing and card selection', () {
      final provider = GameProvider();
      provider.setGameMode(GameMode.imposter);
      expect(provider.gameMode, GameMode.imposter);
      expect(provider.isImposterMode, isTrue);
      expect(provider.maxAttempts, 2);

      provider.selectImposterCard(2);
      expect(provider.selectedImposterCardIndex, 2);
    });
  });
}
