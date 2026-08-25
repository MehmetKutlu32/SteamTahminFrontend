import 'package:flutter/material.dart';
import '../../../theme/steam_theme.dart';

class LocalDuelHeader extends StatelessWidget {
  final String player1Name;
  final int player1Score;
  final String player2Name;
  final int player2Score;
  final int currentTurnPlayer;
  final int targetScore;
  final int remainingTurnSeconds;
  final int turnTimeLimit;
  final bool isMatchOver;

  const LocalDuelHeader({
    super.key,
    required this.player1Name,
    required this.player1Score,
    required this.player2Name,
    required this.player2Score,
    required this.currentTurnPlayer,
    required this.targetScore,
    this.remainingTurnSeconds = 0,
    this.turnTimeLimit = 0,
    required this.isMatchOver,
  });

  @override
  Widget build(BuildContext context) {
    final currentTurnName = currentTurnPlayer == 1 ? player1Name : player2Name;
    final isP1Turn = currentTurnPlayer == 1;

    final isUrgent = turnTimeLimit > 0 && remainingTurnSeconds <= 5;
    final isWarning = turnTimeLimit > 0 && remainingTurnSeconds <= 10;

    return Column(
      children: [
        // Skor Kutusu
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SteamColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPlayerScoreCard(player1Name, player1Score, isP1Turn, Colors.cyanAccent),
              const Text('VS', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 16)),
              _buildPlayerScoreCard(player2Name, player2Score, !isP1Turn, Colors.orangeAccent),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Sıra Kimde & Kalan Süre Banner'ı
        if (!isMatchOver)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isP1Turn
                  ? Colors.cyanAccent.withValues(alpha: 0.15)
                  : Colors.orangeAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isP1Turn ? Colors.cyanAccent : Colors.orangeAccent,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '👉 Sıra: $currentTurnName\'de! (${isP1Turn ? "Mavi" : "Turuncu"})',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: isP1Turn ? Colors.cyanAccent : Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (turnTimeLimit > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? Colors.redAccent.withValues(alpha: 0.3)
                          : (isWarning ? Colors.amberAccent.withValues(alpha: 0.25) : Colors.black45),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isUrgent ? Colors.redAccent : (isWarning ? Colors.amberAccent : Colors.white24),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          size: 14,
                          color: isUrgent ? Colors.redAccent : (isWarning ? Colors.amberAccent : Colors.white70),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${remainingTurnSeconds}s',
                          style: TextStyle(
                            color: isUrgent ? Colors.redAccent : (isWarning ? Colors.amberAccent : Colors.white),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPlayerScoreCard(String name, int score, bool isTurn, Color color) {
    final targetStr = targetScore > 0 ? '/$targetScore' : '';
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score$targetStr',
          style: TextStyle(
            color: isTurn ? Colors.white : Colors.white60,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
