import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/roguelike_models.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';

class PerkSelectionDialog extends StatelessWidget {
  final List<RoguelikePerk> perks;

  const PerkSelectionDialog({
    super.key,
    required this.perks,
  });

  static Future<void> show(BuildContext context, List<RoguelikePerk> perks) {
    if (perks.isEmpty) return Future.value();
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PerkSelectionDialog(perks: perks),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GameProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111923),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: SteamColors.steamCyan.withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: SteamColors.steamCyan.withValues(alpha: 0.25),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🃏 ', style: TextStyle(fontSize: 22)),
                Text(
                  'YADİGAR KARTI SEÇ',
                  style: TextStyle(
                    color: SteamColors.steamCyan,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Kat ${provider.currentFloor - 1} Geçildi! Koşunu güçlendirecek 1 yadigar seç:',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: SteamColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 18),

            // 3 Perk Kartı
            ...perks.map((perk) {
              final color = perk.rarityColor;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      provider.selectPerk(perk);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SteamColors.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: color.withValues(alpha: 0.7),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.15),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Emoji İkonu
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(alpha: 0.15),
                              border: Border.all(color: color.withValues(alpha: 0.4)),
                            ),
                            child: Center(
                              child: Text(
                                perk.iconEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Kart Detayı
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      perk.name,
                                      style: const TextStyle(
                                        color: SteamColors.textPrimary,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        perk.rarityTitle,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  perk.description,
                                  style: const TextStyle(
                                    color: SteamColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // Pas Geç Butonu
            TextButton(
              onPressed: () {
                provider.dismissPerkSelection();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Pas Geç (Yadigar Alma)',
                style: TextStyle(color: SteamColors.textMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
