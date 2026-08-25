import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/steam_theme.dart';
import 'share_card_modal.dart';

class RunVictoryDialog extends StatefulWidget {
  final int totalScore;
  final VoidCallback onContinue;
  final VoidCallback? onContinueAscension;

  const RunVictoryDialog({
    super.key,
    required this.totalScore,
    required this.onContinue,
    this.onContinueAscension,
  });

  static Future<void> show(
    BuildContext context, {
    required int totalScore,
    required VoidCallback onContinue,
    VoidCallback? onContinueAscension,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RunVictoryDialog(
        totalScore: totalScore,
        onContinue: onContinue,
        onContinueAscension: onContinueAscension,
      ),
    );
  }

  @override
  State<RunVictoryDialog> createState() => _RunVictoryDialogState();
}

class _RunVictoryDialogState extends State<RunVictoryDialog> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _confettiController.play();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _shareVictory(BuildContext context) {
    HapticFeedback.mediumImpact();
    ShareCardModal.show(context, isTowerVictory: true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF131D2C),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.amberAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.35),
                  blurRadius: 35,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Kupa
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.amberAccent, width: 2),
                  ),
                  child: const Center(
                    child: Text('👑', style: TextStyle(fontSize: 42)),
                  ),
                ),
                const SizedBox(height: 14),

                // Başlık
                const Text(
                  'KOŞU TAMAMLANDI!',
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '10. Kat Boss oyununu devirip Kuleyi fethettiniz!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: SteamColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),

                // Büyük Zafer Ödülleri
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SteamColors.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5)),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '🏆 Kule Fatihi Büyük Ödülleri',
                        style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _RewardChip(emoji: '🪙', text: '+300 Altın', color: Colors.amberAccent),
                          _RewardChip(emoji: '💎', text: '+10 Elmas', color: SteamColors.steamCyan),
                          _RewardChip(emoji: '🎡', text: '+2 Çark Hakkı', color: Colors.purpleAccent),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ⚡ Kuleye Devam Et (Sonsuz Rekor Modu) Butonu
                if (widget.onContinueAscension != null) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onContinueAscension!();
                      },
                      icon: const Icon(Icons.flash_on_rounded, color: Colors.black87, size: 18),
                      label: const Text(
                        'KULEYE DEVAM ET (KAT 11+) ⚡',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, letterSpacing: 0.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // 📋 Wordle / Balatro Tarzı "Skoru Paylaş" Butonu
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () => _shareVictory(context),
                    icon: const Icon(
                      Icons.share_rounded,
                      color: SteamColors.steamCyan,
                      size: 16,
                    ),
                    label: const Text(
                      'Zafer Kartını Gör & Paylaş 📋',
                      style: TextStyle(
                        color: SteamColors.steamCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: SteamColors.steamCyan.withValues(alpha: 0.8)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Ana Menüye Dön Butonu
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onContinue();
                    },
                    child: const Text(
                      'Koşuyu Bitir & Ana Menüye Dön',
                      style: TextStyle(
                        color: SteamColors.textMuted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Konfeti
        Positioned(
          top: 80,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.amber,
              Colors.cyan,
              Colors.purple,
              Colors.green,
              Colors.white,
            ],
          ),
        ),
      ],
    );
  }
}

class _RewardChip extends StatelessWidget {
  final String emoji;
  final String text;
  final Color color;

  const _RewardChip({required this.emoji, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
