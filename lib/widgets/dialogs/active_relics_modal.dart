import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';

class ActiveRelicsModal extends StatelessWidget {
  const ActiveRelicsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ActiveRelicsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final activePerks = provider.activePerks;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF131D29),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: SteamColors.cardBorder, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SteamColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🎒 ', style: TextStyle(fontSize: 20)),
                  const Text(
                    'Aktif Yadigarlarım',
                    style: TextStyle(
                      color: SteamColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: SteamColors.steamCyan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${activePerks.length} Adet',
                      style: const TextStyle(
                        color: SteamColors.steamCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: SteamColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Liste
          if (activePerks.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Text('📭', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 10),
                  Text(
                    'Henüz aktif bir yadigarınız yok.',
                    style: TextStyle(color: SteamColors.textSecondary, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Katları geçtikçe yeni yadigarlar kazanırsınız.',
                    style: TextStyle(color: SteamColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: activePerks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final perk = activePerks[index];
                  final color = perk.rarityColor;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SteamColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Text(perk.iconEmoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
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
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    perk.rarityTitle,
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                perk.description,
                                style: const TextStyle(
                                  color: SteamColors.textMuted,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
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
