import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/steam_theme.dart';

class LocalDuelReviewsList extends StatelessWidget {
  final List<GameReviewDto> reviews;
  final int revealedCount;
  final String? roundResultMessage;

  const LocalDuelReviewsList({
    super.key,
    required this.reviews,
    required this.revealedCount,
    this.roundResultMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101924),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Açılan İpuçları ($revealedCount/${reviews.length}):',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              if (roundResultMessage != null)
                Flexible(
                  child: Text(
                    roundResultMessage!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const Divider(color: Colors.white10, height: 12),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: revealedCount,
              itemBuilder: (context, idx) {
                final rev = idx < reviews.length ? reviews[idx] : null;
                if (rev == null) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SteamColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İpucu #${idx + 1} (${rev.oynamaSuresiSaati} Saat):',
                        style: const TextStyle(color: SteamColors.steamCyan, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(rev.yorum, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
