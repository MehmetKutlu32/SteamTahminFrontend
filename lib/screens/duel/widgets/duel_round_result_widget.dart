import 'package:flutter/material.dart';
import '../../../services/duel_signalr_service.dart';
import '../../../theme/steam_theme.dart';

class DuelRoundResultWidget extends StatelessWidget {
  final DuelResultEvent? result;
  final String player1Name;
  final String player2Name;

  const DuelRoundResultWidget({
    super.key,
    required this.result,
    required this.player1Name,
    required this.player2Name,
  });

  @override
  Widget build(BuildContext context) {
    final correctGame = result?.correctGameName ?? 'Bilinmeyen Oyun';
    final winner = result?.winner ?? '';
    final isForfeit = winner.toLowerCase().contains('pes') || winner.toLowerCase().contains('berabere');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF131A26),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isForfeit ? Colors.orangeAccent : Colors.greenAccent,
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: (isForfeit ? Colors.orangeAccent : Colors.greenAccent).withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık İkonu
              Text(
                isForfeit ? '🏳️' : '🏆',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 10),
              Text(
                isForfeit ? 'İKİ OYUNCU DA PES ETTİ' : 'DOĞRU TAHMİN EDİLDİ!',
                style: TextStyle(
                  color: isForfeit ? Colors.orangeAccent : Colors.greenAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 18),

              // Açığa Çıkan Oyun Adı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: SteamColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'DOĞRU OYUN',
                      style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      correctGame.isNotEmpty ? correctGame : 'Gizli Oyun',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Skor Durumu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScoreColumn(player1Name, result?.player1Score ?? 0, Colors.cyanAccent),
                  const Text('VS', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 14)),
                  _buildScoreColumn(player2Name, result?.player2Score ?? 0, Colors.orangeAccent),
                ],
              ),
              const SizedBox(height: 20),

              // Yükleniyor / Sonraki Tur
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amberAccent),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Sonraki tura geçiliyor...',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreColumn(String name, int score, Color color) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
