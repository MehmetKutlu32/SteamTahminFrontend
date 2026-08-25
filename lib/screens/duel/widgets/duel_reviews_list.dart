import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/steam_theme.dart';
import '../../../utils/profanity_filter.dart';

class DuelReviewsList extends StatelessWidget {
  final List<GameReviewDto> reviews;
  final int revealedCount;
  final bool censorProfanity;
  final VoidCallback? onUnlockNext;

  const DuelReviewsList({
    super.key,
    required this.reviews,
    this.revealedCount = 1,
    this.censorProfanity = true,
    this.onUnlockNext,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: SteamColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: const Column(
          children: [
            Text('🔍', style: TextStyle(fontSize: 32)),
            SizedBox(height: 10),
            Text(
              'İpucu incelemeleri yükleniyor...',
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final visibleCount = revealedCount.clamp(1, reviews.length);
    final visibleReviews = reviews.take(visibleCount).toList();
    final remainingCount = reviews.length - visibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // İpucu Sayacı Başlığı
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Açılan İpuçları ($visibleCount / ${reviews.length})',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (remainingCount > 0 && onUnlockNext != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onUnlockNext,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: SteamColors.steamCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: SteamColors.steamCyan, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_open_rounded, size: 12, color: SteamColors.steamCyan),
                          const SizedBox(width: 4),
                          Text(
                            'Sıradaki İpucunu Aç ($remainingCount)',
                            style: const TextStyle(
                              color: SteamColors.steamCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Açık Olan İnceleme Kartları
        ...visibleReviews.asMap().entries.map((entry) {
          final index = entry.key;
          final review = entry.value;
          final isRecommended = review.tavsiye;
          final rawText = review.yorum.isEmpty
              ? '(Kullanıcı yalnızca tavsiye durumu belirtmiş, metin girmemiş.)'
              : review.yorum;
          final displayText = censorProfanity ? ProfanityFilter.censor(rawText) : rawText;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SteamColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst Satır: Yazar, Süre, Tavsiye Durumu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: SteamColors.cardSurface,
                          child: Text(
                            review.kullaniciAdi.isNotEmpty
                                ? review.kullaniciAdi[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: SteamColors.steamBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'İpucu #${index + 1}',
                          style: const TextStyle(
                            color: SteamColors.steamCyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${review.oynamaSuresiSaati}s)',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isRecommended
                            ? Colors.blue.withValues(alpha: 0.15)
                            : Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isRecommended ? Colors.blueAccent : Colors.redAccent,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isRecommended
                                ? Icons.thumb_up_rounded
                                : Icons.thumb_down_rounded,
                            size: 11,
                            color: isRecommended ? Colors.blueAccent : Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isRecommended ? 'Tavsiye Ediyor' : 'Önermiyor',
                            style: TextStyle(
                              color: isRecommended ? Colors.blueAccent : Colors.redAccent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 16),

                // Yorum Metni
                Text(
                  displayText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
