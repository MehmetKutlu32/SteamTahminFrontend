import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';

class JokerActionBar extends StatelessWidget {
  final VoidCallback onSkipClue;
  final ValueChanged<int>? onExtraReviewUsed;

  const JokerActionBar({
    super.key,
    required this.onSkipClue,
    this.onExtraReviewUsed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        if (provider.isRoundFinished || provider.currentRound == null) {
          return const SizedBox.shrink();
        }

        final isTableUnlocked = provider.isWordSlotUnlocked;
        final letterCost = provider.nextLetterHintCost;
        final canAffordLetter = provider.coins >= letterCost;

        // Sahtekar Modunda SADECE Harf İpucu Bulunur
        if (provider.isImposterMode) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    icon: isTableUnlocked ? Icons.spellcheck_rounded : Icons.grid_view_rounded,
                    title: isTableUnlocked ? 'Harf Aç (Yan Görev)' : 'Oyun Tablosunu Aç (Yan Görev)',
                    badge: '$letterCost 🪙',
                    isEnabled: canAffordLetter,
                    badgeColor: Colors.amberAccent,
                    onTap: () {
                      if (isTableUnlocked) {
                        provider.useLetterHintJoker();
                      } else {
                        provider.unlockWordSlotTable();
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        }

        // Kural: İlk 2 tahmin yapılmadan ekstra yorum jokeri açılmaz (Kule modunda veya 3. ipucunda açılır)
        final isReviewJokerAvailable = provider.isRoguelike || provider.revealedReviewCount >= 3 || provider.attemptsRemaining <= 3;
        final isReviewCapped = provider.revealedReviewCount >= 20;
        final reviewCost = provider.nextExtraReviewCost;
        final canAffordReview = provider.diamonds >= reviewCost && isReviewJokerAvailable && !isReviewCapped;

        final canSkip = provider.attemptsRemaining > 1 &&
            provider.revealedReviewCount < provider.reviews.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              // 1. Joker: Harf Tablosunu Aç / Harf Aç (Kademeli Altın)
              Expanded(
                child: _buildActionBtn(
                  icon: isTableUnlocked ? Icons.spellcheck_rounded : Icons.grid_view_rounded,
                  title: isTableUnlocked ? 'Harf Aç' : 'Tabloyu Aç',
                  badge: '$letterCost 🪙',
                  isEnabled: canAffordLetter,
                  badgeColor: Colors.amberAccent,
                  onTap: () {
                    if (isTableUnlocked) {
                      provider.useLetterHintJoker();
                    } else {
                      provider.unlockWordSlotTable();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),

              // 2. Joker: Ekstra Yorum (Kademeli Elmas - 3. İpucundan İtibaren Aktif - Maksimum 20)
              Expanded(
                child: _buildActionBtn(
                  icon: isReviewCapped
                      ? Icons.block_rounded
                      : (isReviewJokerAvailable ? Icons.speaker_notes_rounded : Icons.lock_clock_rounded),
                  title: 'Ekstra Yorum',
                  badge: isReviewCapped
                      ? 'Maks (20)'
                      : (isReviewJokerAvailable
                          ? (reviewCost == 0 ? 'Ücretsiz 💎' : '$reviewCost 💎')
                          : '3. İpucunda'),
                  isEnabled: canAffordReview && !provider.isLoadingHint,
                  isLoading: provider.isLoadingHint,
                  badgeColor: isReviewCapped
                      ? Colors.orangeAccent
                      : (isReviewJokerAvailable ? SteamColors.steamCyan : SteamColors.textMuted),
                  onTap: () async {
                    final success = await provider.useExtraReviewJoker();
                    if (success && onExtraReviewUsed != null) {
                      onExtraReviewUsed!(provider.activeCardIndex);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),

              // 3. Aksiyon: Pas Geç / Sıradaki İpucu (-1 Can)
              Expanded(
                child: _buildActionBtn(
                  icon: Icons.skip_next_rounded,
                  title: 'Pas Geç',
                  badge: '-1 ❤️',
                  isEnabled: canSkip,
                  badgeColor: Colors.redAccent,
                  onTap: onSkipClue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String title,
    required String badge,
    required bool isEnabled,
    required Color badgeColor,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          decoration: BoxDecoration(
            color: isEnabled
                ? SteamColors.cardBg
                : SteamColors.cardBg.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isEnabled
                  ? SteamColors.steamBlue.withValues(alpha: 0.5)
                  : SteamColors.cardBorder.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(SteamColors.steamCyan),
                      ),
                    )
                  else
                    Icon(
                      icon,
                      size: 14,
                      color: isEnabled ? SteamColors.steamCyan : SteamColors.textMuted,
                    ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isEnabled ? SteamColors.textPrimary : SteamColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isEnabled ? SteamColors.navyBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isEnabled ? badgeColor : SteamColors.textMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
