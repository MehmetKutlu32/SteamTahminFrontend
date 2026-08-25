import 'package:flutter/material.dart';
import '../../theme/steam_theme.dart';

class SecondChanceDialog extends StatelessWidget {
  final int streak;
  final int diamonds;
  final VoidCallback onContinue;
  final VoidCallback onGiveUp;

  const SecondChanceDialog({
    super.key,
    required this.streak,
    required this.diamonds,
    required this.onContinue,
    required this.onGiveUp,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = diamonds >= 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF141D29),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kırık Kalp İkonu
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.heart_broken_rounded,
                size: 44,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'CANLARIN TÜKENDİ!',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              streak > 1
                  ? '🔥 $streak galibiyetlik serin yanmak üzere! 1 Elmas harcayarak +1 canla oyunu kurtarabilirsin.'
                  : 'Tahmin hakkın bitti! 1 Elmas harcayarak +1 canla oyunu çözmeye devam edebilirsin.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: SteamColors.textPrimary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // 1. Ana Buton: 💎 1 Elmas İle +1 Can Al
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  gradient: canAfford
                      ? SteamColors.steamButtonGradient
                      : null,
                  color: canAfford ? null : SteamColors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: canAfford
                      ? [
                          BoxShadow(
                            color: SteamColors.steamBlue.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton.icon(
                  onPressed: canAfford
                      ? () {
                          Navigator.of(context).pop();
                          onContinue();
                        }
                      : null,
                  icon: const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
                  label: Text(
                    canAfford ? '+1 CANLA DEVAM ET (1 💎)' : 'YETERSİZ ELMAS (1 💎 GEREKLİ)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 2. Buton: Pes Et ve Doğru Cevabı Gör
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onGiveUp();
                },
                icon: const Icon(Icons.flag_outlined, size: 16, color: SteamColors.textMuted),
                label: const Text(
                  'Pes Et & Doğru Cevabı Gör',
                  style: TextStyle(
                    color: SteamColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
