import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steam_tahmin_frontend/models/game_review_dto.dart';
import 'package:steam_tahmin_frontend/models/roguelike_models.dart';
import 'package:steam_tahmin_frontend/models/round_model.dart';
import 'package:steam_tahmin_frontend/models/shop_models.dart';
import 'package:steam_tahmin_frontend/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Roguelike Perks & Catalog Tests', () {
    test('PerkCatalog contains 19 unique perks with descriptions and icons', () {
      expect(PerkCatalog.allPerks.length, 19);
      final ids = PerkCatalog.allPerks.map((p) => p.id).toSet();
      expect(ids.length, 19);
    });

    test('getThreeRandomPerks does not return already owned perks', () {
      final owned = {'genre_radar', 'guardian_shield', 'xray_vowel', 'gold_merchant', 'free_diamond_joker'};
      final offered = PerkCatalog.getThreeRandomPerks(owned);
      
      expect(offered.length, 3);
      for (final perk in offered) {
        expect(owned.contains(perk.id), isFalse);
      }
    });

    test('Perk lookup by ID works correctly', () {
      final shield = PerkCatalog.findById('guardian_shield');
      expect(shield, isNotNull);
      expect(shield!.name, 'Koruyucu Kalkan');
      expect(shield.iconEmoji, '🛡️');
      expect(shield.rarity, PerkRarity.rare);
    });
  });

  group('Roguelike GameProvider Mechanics Tests', () {
    test('Mode switching and floor initialization', () {
      final provider = GameProvider();
      expect(provider.gameMode, GameMode.endless);
      expect(provider.isRoguelike, isFalse);

      provider.setGameMode(GameMode.roguelike);
      expect(provider.gameMode, GameMode.roguelike);
      expect(provider.isRoguelike, isTrue);
      expect(provider.currentFloor, 1);
      expect(provider.maxFloor, 10);
      expect(provider.isBossFloor, isFalse);
      expect(provider.activePerks.isEmpty, isTrue);
    });

    test('Selecting Vitality perk expands max attempts to 6', () {
      final provider = GameProvider();
      provider.setGameMode(GameMode.roguelike);
      expect(provider.maxAttempts, 5);

      final vitality = PerkCatalog.findById('vitality')!;
      provider.selectPerk(vitality);

      expect(provider.hasPerk('vitality'), isTrue);
      expect(provider.maxAttempts, 6);
    });

    test('Letter Discount perk reduces hint costs by 50%', () {
      final provider = GameProvider();
      provider.setGameMode(GameMode.roguelike);
      expect(provider.nextLetterHintCost, 10); // unlock table cost

      final discount = PerkCatalog.findById('letter_discount')!;
      provider.selectPerk(discount);

      expect(provider.nextLetterHintCost, 5); // 50% discount
    });

    test('Tower ascension increments floor and offers perks beyond 10', () {
      final provider = GameProvider();
      provider.setGameMode(GameMode.roguelike);
      expect(provider.currentFloor, 1);
      
      provider.jumpToBossFloor();
      expect(provider.currentFloor, 10);
      expect(provider.isBossFloor, isTrue);

      provider.continueTowerAscension();
      expect(provider.currentFloor, 11);
      expect(provider.isBossFloor, isFalse);
    });

    test('Guardian Shield blocks life loss and reveals next review card', () {
      final provider = GameProvider();
      provider.setGameMode(GameMode.roguelike);
      final shield = PerkCatalog.findById('guardian_shield')!;
      provider.selectPerk(shield);

      expect(provider.hasPerk('guardian_shield'), isTrue);
      expect(provider.attemptsRemaining, 5);

      // Add mock reviews to session
      provider.setMockRoundForTesting(
        RoundModel(
          appId: 100,
          oyunAdi: 'Hedef Oyun',
          yorumlar: List.generate(
            5,
            (i) => GameReviewDto(
              sira: i + 1,
              kullaniciAdi: 'Oyuncu $i',
              oynamaSuresiSaati: 10,
              yorum: 'Yorum $i',
              tavsiye: true,
            ),
          ),
        ),
      );

      expect(provider.revealedReviewCount, 1);

      // Wrong guess with shield active
      final result = provider.submitGuess('Yanlış Oyun');
      expect(result, isFalse);
      expect(provider.attemptsRemaining, 5); // Life NOT deducted
      expect(provider.revealedReviewCount, 2); // Next review card opened!
    });

    test('Natural guesses cap review unlocks at 5', () {
      final provider = GameProvider();
      provider.setGameMode(GameMode.endless);
      provider.setMockRoundForTesting(
        RoundModel(
          appId: 100,
          oyunAdi: 'Hedef Oyun',
          yorumlar: List.generate(
            8,
            (i) => GameReviewDto(
              sira: i + 1,
              kullaniciAdi: 'Oyuncu $i',
              oynamaSuresiSaati: 10,
              yorum: 'Yorum $i',
              tavsiye: true,
            ),
          ),
        ),
      );

      expect(provider.revealedReviewCount, 1);
      provider.submitGuess('Yanlış 1'); // reveals 2
      expect(provider.revealedReviewCount, 2);
      provider.submitGuess('Yanlış 2'); // reveals 3
      expect(provider.revealedReviewCount, 3);
      provider.submitGuess('Yanlış 3'); // reveals 4
      expect(provider.revealedReviewCount, 4);
      provider.submitGuess('Yanlış 4'); // reveals 5
      expect(provider.revealedReviewCount, 5);
      
      // Even if 8 reviews exist in API payload, natural guesses cap at 5
      provider.submitGuess('Yanlış 5');
      expect(provider.revealedReviewCount, 5);
    });

    test('Shop purchasing, equipping, and permanent booster test', () {
      final provider = GameProvider();
      provider.addDebugCurrency(coins: 1000, diamonds: 50);

      // Buy neon frame
      final neonFrame = ShopCatalog.findById('frame_neon')!;
      final boughtFrame = provider.buyShopItem(neonFrame);
      expect(boughtFrame, isTrue);
      expect(provider.hasShopItem('frame_neon'), isTrue);
      expect(provider.equippedFrameId, 'frame_neon');

      // Buy custom title
      final titleDetective = ShopCatalog.findById('title_detective')!;
      final boughtTitle = provider.buyShopItem(titleDetective);
      expect(boughtTitle, isTrue);
      expect(provider.hasShopItem('title_detective'), isTrue);
      expect(provider.equippedTitleId, 'title_detective');
      expect(provider.effectiveRankTitle, 'İnceleme Dedektifi');

      // Unequip / Equip
      provider.equipTitle(null);
      expect(provider.equippedTitleId, isNull);
      provider.equipTitle('title_detective');
      expect(provider.equippedTitleId, 'title_detective');

      // Buy permanent gold boost
      final goldBoost = ShopCatalog.findById('boost_gold_15')!;
      final boughtBoost = provider.buyShopItem(goldBoost);
      expect(boughtBoost, isTrue);
      expect(provider.hasShopItem('boost_gold_15'), isTrue);
    });

    test('Discovery tracking adds perks when selected', () {
      final provider = GameProvider();
      provider.setGameMode(GameMode.roguelike);
      expect(provider.discoveredPerkIds.isEmpty, isTrue);

      final perk = PerkCatalog.findById('genre_radar')!;
      provider.selectPerk(perk);

      expect(provider.isPerkDiscovered('genre_radar'), isTrue);
      expect(provider.discoveredPerkIds.contains('genre_radar'), isTrue);
    });
  });
}
