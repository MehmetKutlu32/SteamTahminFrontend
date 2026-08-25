import 'package:flutter/material.dart';
import '../../models/game_review_dto.dart';
import '../../theme/steam_theme.dart';

class LockedReviewCard extends StatelessWidget {
  final int clueNumber;
  final bool isNextToUnlock;
  final GameReviewDto? review;

  const LockedReviewCard({
    super.key,
    required this.clueNumber,
    required this.isNextToUnlock,
    this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SteamColors.cardBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNextToUnlock
              ? SteamColors.steamBlue.withValues(alpha: 0.4)
              : SteamColors.cardBorder.withValues(alpha: 0.3),
          width: isNextToUnlock ? 1.2 : 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isNextToUnlock
                  ? SteamColors.steamBlue.withValues(alpha: 0.15)
                  : SteamColors.cardSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isNextToUnlock ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
              color: isNextToUnlock ? SteamColors.steamBlue : SteamColors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'İpucu #$clueNumber (Kilitli)',
                      style: TextStyle(
                        color: isNextToUnlock
                            ? SteamColors.textPrimary
                            : SteamColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isNextToUnlock
                      ? 'Bir sonraki yanlış tahminle veya pas geçerek açılır'
                      : 'Kilidi açmak için sıradaki ipucunu geçin',
                  style: const TextStyle(
                    color: SteamColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isNextToUnlock)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: SteamColors.steamBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: SteamColors.steamBlue.withValues(alpha: 0.5),
                ),
              ),
              child: const Text(
                'SIRADAKİ',
                style: TextStyle(
                  color: SteamColors.steamBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
