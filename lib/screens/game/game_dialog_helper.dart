import 'package:flutter/material.dart';
import '../../theme/steam_theme.dart';
import '../../widgets/dialogs/game_result_dialog.dart';
import '../../widgets/dialogs/second_chance_dialog.dart';

class GameDialogHelper {
  /// Canlar bittiğinde cevabı ele vermeden çıkan "Son Şans" penceresi
  static void showSecondChanceDialog({
    required BuildContext context,
    required int streak,
    required int diamonds,
    required VoidCallback onContinue,
    required VoidCallback onGiveUp,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => SecondChanceDialog(
        streak: streak,
        diamonds: diamonds,
        onContinue: onContinue,
        onGiveUp: onGiveUp,
      ),
    );
  }

  /// Tur tamamlandığında (Kazanıldığında veya Pes Edildiğinde) açılan nihai sonuç penceresi
  static void showResultDialog({
    required BuildContext context,
    required bool isWon,
    required String gameName,
    required int appId,
    required int score,
    required int attemptsUsed,
    int wonCoins = 25,
    int wonDiamonds = 0,
    int currentStreak = 0,
    String? releaseDate,
    List<String> genres = const [],
    required VoidCallback onNextRound,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GameResultDialog(
        isWon: isWon,
        gameName: gameName,
        appId: appId,
        score: score,
        attemptsUsed: attemptsUsed,
        wonCoins: wonCoins,
        wonDiamonds: wonDiamonds,
        currentStreak: currentStreak,
        releaseDate: releaseDate,
        genres: genres,
        onNextRound: onNextRound,
      ),
    );
  }

  /// Oyuncu takıldığında "Pes Et & Çözümü Gör" onay penceresi
  static void showGiveUpConfirmationDialog({
    required BuildContext context,
    bool isRoguelike = false,
    int currentFloor = 1,
    required VoidCallback onConfirmGiveUp,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: SteamColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SteamColors.negativeReview, width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.flag_rounded, color: SteamColors.negativeReview),
            const SizedBox(width: 8),
            Text(
              isRoguelike ? 'Koşudan Çekil? (Kat $currentFloor)' : 'Turu Bitir / Pes Et?',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          isRoguelike
              ? '$currentFloor. Kattasınız. Pes ederseniz oyunun cevabı açılır ve bu koşunuz sonlanır. Çekilmek istediğinize emin misiniz?'
              : 'Kalan haklarınızı harcayıp oyunun doğru cevabını ve tüm incelemelerini görmek istiyor musunuz?\n\n(Mevcut galibiyet seriniz sıfırlanır)',
          style: const TextStyle(color: SteamColors.textPrimary, fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('İPTAL', style: TextStyle(color: SteamColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirmGiveUp();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SteamColors.negativeReview,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isRoguelike ? 'PES ET & CEVABI GÖR' : 'CEVABI GÖR'),
          ),
        ],
      ),
    );
  }

  /// Yanlış tahmin bildirim SnackBar'ı
  static void showWrongGuessSnackBar(
    BuildContext context, {
    required String guess,
    required int revealedReviewCount,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SteamColors.cardBg,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.close_rounded, color: SteamColors.negativeReview),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '"$guess" yanlış tahmin! Yeni ipucu açıldı (#$revealedReviewCount).',
                style: const TextStyle(color: SteamColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bilgilendirme SnackBar'ı (Joker kullanımı vs.)
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E2F42),
        duration: const Duration(seconds: 2),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
