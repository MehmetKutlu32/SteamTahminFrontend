import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';
import '../dialogs/mystery_chest_dialog.dart';

class RoundHeader extends StatelessWidget {
  final int score;
  final int streak;
  final int attemptsRemaining;
  final int maxAttempts;

  const RoundHeader({
    super.key,
    required this.score,
    required this.streak,
    required this.attemptsRemaining,
    this.maxAttempts = 5,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final isRoguelike = provider.isRoguelike;
    final isBoss = provider.isBossFloor;
    final chests = provider.unopenedChests;
    final isShieldActive = provider.isShieldAvailable;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: const BoxDecoration(
        color: SteamColors.navyBg,
        border: Border(
          bottom: BorderSide(color: SteamColors.cardBorder, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Sol Alan: Canlar / Kalpler & Seri
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kalpler
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(provider.maxAttempts, (index) {
                      final isAvailable = index < attemptsRemaining;
                      return Padding(
                        padding: const EdgeInsets.only(right: 3.0),
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 18,
                          color: isAvailable
                              ? (provider.isImposterMode ? Colors.purpleAccent : SteamColors.negativeReview)
                              : Colors.white12,
                        ),
                      );
                    }),
                  ),

                  if (provider.isImposterMode) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.purpleAccent, width: 1),
                      ),
                      child: const Text(
                        '🕵️ SAHTEKAR',
                        style: TextStyle(color: Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],

                  // 🛡️ Koruyucu Kalkan Rozeti
                  if (isShieldActive) ...[
                    const SizedBox(width: 4),
                    Tooltip(
                      message: 'Koruyucu Kalkan Aktif',
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueAccent, width: 1),
                        ),
                        child: const Text('🛡️', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],

                  // 🔥 Seri Rozeti
                  if (streak > 1) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF381E10),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orangeAccent, width: 1),
                      ),
                      child: Text(
                        '🔥$streak',
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // 2. Orta Alan: Kat / Skor Bilgisi
              if (isRoguelike)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isBoss
                        ? Colors.amber.withValues(alpha: 0.2)
                        : (provider.currentFloor > 10
                            ? Colors.purple.withValues(alpha: 0.2)
                            : SteamColors.steamBlue.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isBoss
                          ? Colors.amberAccent
                          : (provider.currentFloor > 10
                              ? Colors.purpleAccent
                              : SteamColors.steamCyan.withValues(alpha: 0.6)),
                      width: (isBoss || provider.currentFloor > 10) ? 1.2 : 0.8,
                    ),
                  ),
                  child: Text(
                    isBoss
                        ? '👑 ${provider.currentFloor}. KAT BOSS'
                        : (provider.currentFloor > 10
                            ? '⚡ Kat ${provider.currentFloor}'
                            : '🚪 Kat ${provider.currentFloor}/10'),
                    style: TextStyle(
                      color: isBoss
                          ? Colors.amberAccent
                          : (provider.currentFloor > 10 ? Colors.purpleAccent : SteamColors.steamCyan),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              else if (!provider.isImposterMode)
                Text(
                  'Skor: $score',
                  style: const TextStyle(
                    color: SteamColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              // 3. Sağ Alan: Cüzdan (🪙, 💎, 🎡)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCurrencyChip('🪙', '${provider.coins}', Colors.amberAccent),
                  const SizedBox(width: 5),
                  _buildCurrencyChip('💎', '${provider.diamonds}', SteamColors.steamCyan),
                  if (chests > 0) ...[
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () => MysteryChestDialog.show(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amberAccent, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎡', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 3),
                            Text(
                              '$chests',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // 💡 Aktif İpucu Yadigarları Rozet Alanı (Kelime Sayacı, Çıkış Tarihi, Tür Radarı)
          if (provider.currentRound != null &&
              (provider.hasPerk('length_checker') ||
                  provider.hasPerk('time_traveler') ||
                  provider.hasPerk('genre_radar'))) ...[
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                // 📏 Kelime Sayacı
                if (provider.hasPerk('length_checker'))
                  Builder(
                    builder: (context) {
                      final name = provider.currentRound!.oyunAdi;
                      final wordsCount = name.split(' ').where((w) => w.trim().isNotEmpty).length;
                      final charsCount = name.replaceAll(' ', '').length;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: SteamColors.cardBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: SteamColors.steamCyan.withValues(alpha: 0.5), width: 0.8),
                        ),
                        child: Text(
                          '📏 $wordsCount Kelime • $charsCount Harf',
                          style: const TextStyle(
                            color: SteamColors.steamCyan,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      );
                    },
                  ),

                // 📅 Çıkış Tarihi Dedektifi
                if (provider.hasPerk('time_traveler'))
                  Builder(
                    builder: (context) {
                      final date = provider.currentRound?.cikisTarihi;
                      final eraText = (date != null && date.trim().isNotEmpty)
                          ? date
                          : 'Klasik Dönem';

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: SteamColors.cardBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5), width: 0.8),
                        ),
                        child: Text(
                          '📅 $eraText',
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      );
                    },
                  ),

                // 🏷️ Tür Radarı
                if (provider.hasPerk('genre_radar') && provider.currentRound!.turler.isNotEmpty)
                  Builder(
                    builder: (context) {
                      final genresText = provider.currentRound!.turler.take(2).join(' • ');

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: SteamColors.cardBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5), width: 0.8),
                        ),
                        child: Text(
                          '🏷️ $genresText',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrencyChip(String emoji, String amount, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: SteamColors.cardBg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: textColor.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 9.5)),
          const SizedBox(width: 2.5),
          Text(
            amount,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
