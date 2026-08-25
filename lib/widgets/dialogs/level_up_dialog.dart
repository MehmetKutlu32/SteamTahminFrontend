import 'package:flutter/material.dart';
import '../../models/player_progression.dart';
import '../../theme/steam_theme.dart';

class LevelUpDialog extends StatelessWidget {
  final int newLevel;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
  });

  static Future<void> show(BuildContext context, int newLevel) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => LevelUpDialog(newLevel: newLevel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rankTitle = PlayerRank.getRankTitle(newLevel);
    final rankBadge = PlayerRank.getRankBadge(newLevel);
    final rankColor = PlayerRank.getRankColor(newLevel);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF131D2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: rankColor.withValues(alpha: 0.8), width: 2),
          boxShadow: [
            BoxShadow(
              color: rankColor.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Rozet
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rankColor.withValues(alpha: 0.2),
                border: Border.all(color: rankColor, width: 2),
              ),
              child: Center(
                child: Text(rankBadge, style: const TextStyle(fontSize: 42)),
              ),
            ),
            const SizedBox(height: 16),

            // Tebrik Başlığı
            const Text(
              '🎉 TEBRİKLER! SEVİYE ATLADIN!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),

            // Yeni Rütbe ve Seviye
            Text(
              'Seviye $newLevel: $rankTitle',
              style: TextStyle(
                color: rankColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Seviye Atlama Ödülleri
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: SteamColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SteamColors.cardBorder),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ödülünüz: ', style: TextStyle(color: SteamColors.textSecondary, fontSize: 13)),
                  SizedBox(width: 4),
                  Text('🪙 +50 Altın', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13.5)),
                  SizedBox(width: 8),
                  Text('💎 +2 Elmas', style: TextStyle(color: SteamColors.steamCyan, fontWeight: FontWeight.bold, fontSize: 13.5)),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Tamam Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: rankColor,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('HARİKA!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
