import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/steam_theme.dart';

class ReviewCard extends StatelessWidget {
  final GameReviewDto review;
  final int index;
  final bool isLatestRevealed;

  const ReviewCard({
    super.key,
    required this.review,
    required this.index,
    this.isLatestRevealed = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRecommended = review.tavsiye;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: SteamColors.darkCardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLatestRevealed
              ? SteamColors.steamBlue.withValues(alpha: 0.8)
              : SteamColors.cardBorder,
          width: isLatestRevealed ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isLatestRevealed
                ? SteamColors.steamBlue.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.3),
            blurRadius: isLatestRevealed ? 12 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Satır: Kullanıcı Avatar/İsim + Steam Tavsiye Rozeti
            Row(
              children: [
                // Kullanıcı Avatarı / Baş Harf
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
                // Kullanıcı Adı ve Oynama Süresi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.kullaniciAdi,
                        style: const TextStyle(
                          color: SteamColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: SteamColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${review.oynamaSuresiSaati} saat kayıtlı',
                            style: const TextStyle(
                              color: SteamColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Steam Tavsiye Edildi / Edilmedi Rozeti
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isRecommended
                        ? SteamColors.steamBlue.withValues(alpha: 0.12)
                        : SteamColors.negativeReview.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isRecommended
                          ? SteamColors.steamBlue.withValues(alpha: 0.5)
                          : SteamColors.negativeReview.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRecommended
                            ? Icons.thumb_up_rounded
                            : Icons.thumb_down_rounded,
                        size: 14,
                        color: isRecommended
                            ? SteamColors.steamBlue
                            : SteamColors.negativeReview,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isRecommended ? 'Tavsiye Ediliyor' : 'Tavsiye Edilmiyor',
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
              height: 24,
              thickness: 0.8,
            ),
            // Yorum Metni
            Text(
              review.yorum.isEmpty
                  ? '(Bu kullanıcı yorum metni bırakmamış.)'
                  : review.yorum,
              style: const TextStyle(
                color: SteamColors.textPrimary,
                fontSize: 14,
                height: 1.45,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),
            // İpucu Rozet Altlığı
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SteamColors.cardSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'İpucu #${index + 1}',
                  style: const TextStyle(
                    color: SteamColors.steamCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
