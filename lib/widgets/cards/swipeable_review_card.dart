import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/game_provider.dart';
import '../../screens/game/game_dialog_helper.dart';
import '../../theme/steam_theme.dart';
import '../../utils/profanity_filter.dart';

class SwipeableReviewCard extends StatelessWidget {
  final GameReviewDto review;
  final int index;
  final int totalCount;

  const SwipeableReviewCard({
    super.key,
    required this.review,
    required this.index,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final isRecommended = review.tavsiye;
    final isCensored = context.select<GameProvider, bool>((p) => p.censorProfanity);

    final rawText = review.yorum.isEmpty
        ? '(Kullanıcı yalnızca tavsiye durumu belirtmiş, metin girmemiş.)'
        : review.yorum;
    final displayText = isCensored ? ProfanityFilter.censor(rawText) : rawText;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: SteamColors.darkCardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: SteamColors.steamBlue.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: SteamColors.steamBlue.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Satır: Avatar + Kullanıcı Adı & Saat + Tavsiye Rozeti
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: SteamColors.cardSurface,
                  child: Text(
                    review.kullaniciAdi.isNotEmpty
                        ? review.kullaniciAdi[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: SteamColors.steamBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.kullaniciAdi,
                        style: const TextStyle(
                          color: SteamColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: SteamColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${review.oynamaSuresiSaati} saat',
                              style: const TextStyle(
                                color: SteamColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            if (review.tarih != null && review.tarih!.isNotEmpty) ...[
                              const SizedBox(width: 5),
                              const Text('•', style: TextStyle(color: SteamColors.textMuted, fontSize: 10)),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 10.5,
                              color: SteamColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              review.tarih!,
                              style: const TextStyle(
                                color: SteamColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRecommended
                        ? SteamColors.steamBlue.withValues(alpha: 0.15)
                        : SteamColors.negativeReview.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isRecommended
                          ? SteamColors.steamBlue.withValues(alpha: 0.6)
                          : SteamColors.negativeReview.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRecommended
                            ? Icons.thumb_up_rounded
                            : Icons.thumb_down_rounded,
                        size: 13,
                        color: isRecommended
                            ? SteamColors.steamBlue
                            : SteamColors.negativeReview,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isRecommended ? 'Tavsiye Ediyor' : 'Önermiyor',
                        style: TextStyle(
                          color: isRecommended
                              ? SteamColors.steamBlue
                              : SteamColors.negativeReview,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(
              color: SteamColors.cardBorder,
              height: 22,
              thickness: 0.8,
            ),

            // Yorum Metni (Kaydırılabilir alan ile taşma yapmaz)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  displayText,
                  style: const TextStyle(
                    color: SteamColors.textPrimary,
                    fontSize: 14,
                    height: 1.5,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Alt Satır: İpucu Rozeti, Öğütücü ve Gezinme Yönlendirmesi
            Consumer<GameProvider>(
              builder: (context, provider, _) {
                final canRecycle = provider.canRecycleReview;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (index > 0)
                          const Icon(Icons.arrow_back_ios_rounded, size: 12, color: SteamColors.textMuted),
                        Text(
                          'İpucu #${index + 1} / $totalCount',
                          style: const TextStyle(
                            color: SteamColors.steamCyan,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (index < totalCount - 1)
                          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: SteamColors.textMuted),
                      ],
                    ),
                    if (provider.isImposterMode)
                      if (provider.isRoundFinished)
                        if (index == provider.imposterCardIndex)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.purpleAccent, width: 1.2),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🕵️ ', style: TextStyle(fontSize: 11)),
                                Text(
                                  'SAHTEKAR KART',
                                  style: TextStyle(color: Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.greenAccent, width: 0.8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('✅ ', style: TextStyle(fontSize: 10)),
                                Text(
                                  'Gerçek İnceleme',
                                  style: TextStyle(color: Colors.greenAccent, fontSize: 10.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                      else if (provider.eliminatedRealCardIndices.contains(index))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.greenAccent, width: 0.8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('✅ ', style: TextStyle(fontSize: 10)),
                              Text(
                                'Gerçek İnceleme',
                                style: TextStyle(color: Colors.greenAccent, fontSize: 10.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: provider.isRoundFinished
                              ? null
                              : () {
                                  provider.accuseImposter(index);
                                  if (provider.isRoundFinished) {
                                    GameDialogHelper.showResultDialog(
                                      context: context,
                                      isWon: provider.isRoundWon,
                                      gameName: provider.currentRound?.oyunAdi ?? 'Bilinmeyen Oyun',
                                      appId: provider.currentRound?.appId ?? 0,
                                      score: provider.score,
                                      attemptsUsed: provider.maxAttempts - provider.attemptsRemaining,
                                      wonCoins: provider.lastWonCoins,
                                      wonDiamonds: provider.lastWonDiamonds,
                                      currentStreak: provider.streak,
                                      releaseDate: provider.currentRound?.cikisTarihi,
                                      genres: provider.currentRound?.turler ?? const [],
                                      onNextRound: () async {
                                        await provider.startNewRound();
                                      },
                                    );
                                  }
                                },
                          icon: const Text('🕵️', style: TextStyle(fontSize: 12)),
                          label: const Text('SAHTEKAR BU!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: const Size(40, 30),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                    else if (canRecycle)
                      InkWell(
                        onTap: () => provider.recycleActiveReview(),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.tealAccent, width: 0.8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('♻️ ', style: TextStyle(fontSize: 10)),
                              Text(
                                'İncelemeyi Değiştir',
                                style: TextStyle(color: Colors.tealAccent, fontSize: 10.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Text(
                        '👉 Kartları kaydırabilirsiniz',
                        style: TextStyle(
                          color: SteamColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
