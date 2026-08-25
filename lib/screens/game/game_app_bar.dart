import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';
import '../../widgets/dialogs/active_relics_modal.dart';
import '../../widgets/dialogs/debug_panel.dart';
import '../../widgets/dialogs/player_profile_modal.dart';
import '../../widgets/dialogs/shop_modal.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onGiveUp;
  final bool isRoundFinished;

  const GameAppBar({
    super.key,
    this.onGiveUp,
    this.isRoundFinished = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(50);

  void _confirmGiveUp(BuildContext context, GameProvider provider) {
    if (onGiveUp != null) onGiveUp!();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final isRoguelike = provider.isRoguelike;
    final activePerksCount = provider.activePerks.length;
    final rankColor = provider.rankColor;

    return Container(
      color: SteamColors.darkBg,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: SteamColors.cardBorder, width: 0.8),
            ),
          ),
          child: Row(
            children: [
              // Geri Butonu
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: Colors.white70),
                tooltip: 'Ana Menü',
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),

              // Başlık & İkon
              Icon(
                isRoguelike ? Icons.shield_moon_rounded : (provider.isImposterMode ? Icons.fingerprint_rounded : Icons.sports_esports_rounded),
                color: isRoguelike ? SteamColors.steamCyan : (provider.isImposterMode ? Colors.purpleAccent : SteamColors.steamBlue),
                size: 17,
              ),
              const SizedBox(width: 4),
              Text(
                isRoguelike ? 'KULE' : (provider.isImposterMode ? 'SAHTEKAR' : 'TAHMİN'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),

              const Spacer(),

              // Roguelike Aktif Yadigarlar Çipi
              if (isRoguelike) ...[
                InkWell(
                  onTap: () => ActiveRelicsModal.show(context),
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: SteamColors.steamCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: SteamColors.steamCyan.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎒', style: TextStyle(fontSize: 10.5)),
                        const SizedBox(width: 2.5),
                        Text(
                          '$activePerksCount',
                          style: const TextStyle(
                            color: SteamColors.steamCyan,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],

              // Profil Çipi (Lv. X)
              InkWell(
                onTap: () => PlayerProfileModal.show(context),
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: rankColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: rankColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'Lv.${provider.level} ${provider.rankBadge}',
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),

              // 🛡️ Küfür Sansürü Aç/Kapat Butonu
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: Icon(
                  provider.censorProfanity ? Icons.shield_rounded : Icons.explicit_rounded,
                  color: provider.censorProfanity ? Colors.greenAccent : Colors.orangeAccent,
                  size: 17,
                ),
                tooltip: provider.censorProfanity ? 'Küfür Filtresi: AÇIK' : 'Küfür Filtresi: KAPALI',
                onPressed: () => provider.toggleCensorProfanity(),
              ),

              // 🛍️ Dükkan / Mağaza Butonu
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.amberAccent, size: 17),
                tooltip: 'Tahmin Dükkanı',
                onPressed: () => ShopModal.show(context),
              ),

              // Debug Butonu
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: const Icon(Icons.bug_report_outlined, color: Colors.amber, size: 17),
                tooltip: 'Test Paneli',
                onPressed: () => DebugPanelModal.show(context),
              ),

              // Pes Et Butonu (Sahtekar modunda pas geçme/pes etme yoktur)
              if (!provider.isImposterMode && !isRoundFinished && onGiveUp != null)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  icon: const Icon(Icons.flag_outlined, color: Colors.redAccent, size: 17),
                  tooltip: 'Pes Et & Cevabı Gör',
                  onPressed: () => _confirmGiveUp(context, provider),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
