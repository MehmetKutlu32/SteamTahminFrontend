import 'package:flutter/material.dart';

class LocalDuelVictoryCard extends StatelessWidget {
  final String player1Name;
  final int player1Score;
  final String player2Name;
  final int player2Score;
  final int targetScore;
  final VoidCallback onRematch;
  final VoidCallback onChangePlayers;

  const LocalDuelVictoryCard({
    super.key,
    required this.player1Name,
    required this.player1Score,
    required this.player2Name,
    required this.player2Score,
    required this.targetScore,
    required this.onRematch,
    required this.onChangePlayers,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDraw = player1Score == player2Score;
    final winnerName = player1Score > player2Score ? player1Name : player2Name;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amberAccent, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            isDraw ? '🤝 DOSTÇA BERABERLİK!' : '👑 $winnerName KAZANDI! 🏆',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.amberAccent, fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'Nihai Skor: $player1Name $player1Score - $player2Score $player2Name',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onRematch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text('Rövanş Oyna 🥊', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onChangePlayers,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                child: const Text('Yeni Oyuncular ⚙️'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
