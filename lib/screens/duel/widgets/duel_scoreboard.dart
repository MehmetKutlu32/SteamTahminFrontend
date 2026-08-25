import 'package:flutter/material.dart';
import '../../../models/shop_models.dart';

class DuelScoreboard extends StatelessWidget {
  final String player1Name;
  final int player1Score;
  final String player2Name;
  final int player2Score;
  final int currentRound;
  final int targetScore;
  final String? p1AvatarEmoji;
  final String? p1FrameId;
  final String? p2AvatarEmoji;
  final String? p2FrameId;
  final bool isCompact;

  const DuelScoreboard({
    super.key,
    required this.player1Name,
    required this.player1Score,
    required this.player2Name,
    required this.player2Score,
    required this.currentRound,
    this.targetScore = 3,
    this.p1AvatarEmoji,
    this.p1FrameId,
    this.p2AvatarEmoji,
    this.p2FrameId,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final targetStr = targetScore > 0 ? '/$targetScore' : '';

    if (isCompact) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: const BoxDecoration(
          color: Color(0xFF131A26),
          border: Border(bottom: BorderSide(color: Colors.white12, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${p1AvatarEmoji ?? "🤖"} $player1Name: $player1Score$targetStr',
              style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 11.5),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
              child: Text('R$currentRound', style: const TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            Text(
              '$player2Score$targetStr :$player2Name ${p2AvatarEmoji ?? "🦊"}',
              style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 11.5),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF131A26),
        border: Border(
          bottom: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 1. Oyuncu (Sol)
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildPlayerBadge(
                name: player1Name,
                score: player1Score,
                baseColor: Colors.cyanAccent,
                avatarEmoji: p1AvatarEmoji ?? '🤖',
                frameId: p1FrameId ?? 'frame_gold',
                isLeft: true,
              ),
            ),
          ),

          // Tur Bilgisi (Orta)
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TUR $currentRound',
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  (targetScore >= 100 || targetScore <= 0)
                      ? 'Sonsuz Mod ♾️'
                      : 'İlk $targetScore Alan',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),

          // 2. Oyuncu (Sağ)
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildPlayerBadge(
                name: player2Name,
                score: player2Score,
                baseColor: Colors.orangeAccent,
                avatarEmoji: p2AvatarEmoji ?? '🦊',
                frameId: p2FrameId ?? 'frame_diamond',
                isLeft: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerBadge({
    required String name,
    required int score,
    required Color baseColor,
    required String avatarEmoji,
    required String? frameId,
    required bool isLeft,
  }) {
    final frameItem = frameId != null ? ShopCatalog.findById(frameId) : null;
    final frameColor = frameItem?.accentColor ?? baseColor;

    final avatarWidget = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: frameColor.withValues(alpha: 0.2),
        border: Border.all(
          color: frameColor,
          width: frameItem != null ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: frameColor.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Center(
        child: Text(avatarEmoji, style: const TextStyle(fontSize: 14)),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: frameColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) ...[
            avatarWidget,
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: baseColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$score',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          if (!isLeft) ...[
            const SizedBox(width: 5),
            avatarWidget,
          ],
        ],
      ),
    );
  }
}
