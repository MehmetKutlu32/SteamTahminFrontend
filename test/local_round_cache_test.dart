import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steam_tahmin_frontend/models/models.dart';
import 'package:steam_tahmin_frontend/services/local_round_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalRoundCacheService Tests', () {
    test('Round Queue FIFO Push & Pop up to 5 items', () async {
      for (int i = 1; i <= 5; i++) {
        await LocalRoundCacheService.pushRoundToQueue(
          RoundModel(
            appId: i * 10,
            oyunAdi: 'Game $i',
            yorumlar: const [
              GameReviewDto(
                sira: 1,
                kullaniciAdi: 'Player',
                oynamaSuresiSaati: 10,
                yorum: 'Good',
                tavsiye: true,
              ),
            ],
          ),
        );
      }

      expect(await LocalRoundCacheService.getCachedRoundCount(), 5);

      // FIFO Check: First pushed should be first popped
      for (int i = 1; i <= 5; i++) {
        final popped = await LocalRoundCacheService.popNextCachedRound();
        expect(popped?.appId, i * 10);
        expect(popped?.oyunAdi, 'Game $i');
      }

      // Empty check
      expect(await LocalRoundCacheService.getCachedRoundCount(), 0);
      expect(await LocalRoundCacheService.popNextCachedRound(), isNull);
    });

    test('Games List caching and loading', () async {
      final games = [
        const GameItem(appId: 10, name: 'CS'),
        const GameItem(appId: 20, name: 'TF2'),
      ];

      await LocalRoundCacheService.saveGamesList(games);
      final loaded = await LocalRoundCacheService.loadGamesList();

      expect(loaded.length, 2);
      expect(loaded[0].name, 'CS');
      expect(loaded[1].name, 'TF2');
    });
  });
}
