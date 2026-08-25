import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/roguelike_models.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';

class RelicCollectionModal extends StatelessWidget {
  const RelicCollectionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const RelicCollectionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    const allPerks = PerkCatalog.allPerks;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF111A24),
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
              const Row(
                children: [
                  Text('📚 ', style: TextStyle(fontSize: 22)),
                  Text(
                    'Yadigar & Rütbe Koleksiyonu',
                    style: TextStyle(
                      color: SteamColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
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

          // Sekmeli Liste
          Flexible(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: SteamColors.steamCyan,
                    labelColor: SteamColors.steamCyan,
                    unselectedLabelColor: SteamColors.textMuted,
                    tabs: [
                      Tab(text: '🎴 Yadigarlar (${provider.discoveredPerkIds.length}/${allPerks.length})'),
                      const Tab(text: '🎖️ Rütbeler (5)'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // 1. Yadigarlar Listesi (Nadirliğe göre sıralı: Efsanevi -> Nadir -> Sıradan)
                        Builder(
                          builder: (context) {
                            final sortedPerks = List<RoguelikePerk>.from(allPerks)
                              ..sort((a, b) => b.rarity.index.compareTo(a.rarity.index));
                            final discoveredCount = provider.discoveredPerkIds.length;
                            final totalCount = allPerks.length;
                            final progressPercent = (discoveredCount / totalCount * 100).toInt();

                            return Column(
                              children: [
                                // Keşif İlerleme Çubuğu
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: SteamColors.cardBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: SteamColors.steamCyan.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text('🔍', style: TextStyle(fontSize: 16)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  'Koleksiyon İlerlemesi',
                                                  style: TextStyle(color: SteamColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  '$discoveredCount / $totalCount (%$progressPercent)',
                                                  style: const TextStyle(color: SteamColors.steamCyan, fontSize: 11, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(3),
                                              child: LinearProgressIndicator(
                                                value: totalCount > 0 ? discoveredCount / totalCount : 0,
                                                minHeight: 5,
                                                backgroundColor: Colors.white10,
                                                valueColor: const AlwaysStoppedAnimation<Color>(SteamColors.steamCyan),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Yadigar Kartları
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: sortedPerks.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final perk = sortedPerks[index];
                                      final isDiscovered = provider.isPerkDiscovered(perk.id);
                                      final isCurrentlyActive = provider.hasPerk(perk.id);
                                      final color = isDiscovered ? perk.rarityColor : Colors.grey;

                                      if (!isDiscovered) {
                                        // 🔒 Kilitli / Henüz Keşfedilmemiş Yadigar Kartı
                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: SteamColors.cardBg.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.white.withValues(alpha: 0.1),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.black26,
                                                  border: Border.all(color: Colors.white12),
                                                ),
                                                child: const Center(
                                                  child: Text('❓', style: TextStyle(fontSize: 20)),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          'Gizemli Yadigar',
                                                          style: TextStyle(
                                                            color: SteamColors.textMuted,
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                          perk.rarityTitle,
                                                          style: TextStyle(
                                                            color: perk.rarityColor.withValues(alpha: 0.6),
                                                            fontSize: 10.5,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 3),
                                                    const Text(
                                                      '🔒 Bu yadigar henüz keşfedilmedi. Kule koşularında bularak kilidini açın.',
                                                      style: TextStyle(
                                                        color: Colors.white30,
                                                        fontSize: 11,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      // ✨ Keşfedilmiş Açık Yadigar Kartı
                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: SteamColors.cardBg,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isCurrentlyActive
                                                ? Colors.amberAccent
                                                : color.withValues(alpha: 0.4),
                                            width: isCurrentlyActive ? 1.5 : 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // İkon
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: color.withValues(alpha: 0.15),
                                                border: Border.all(color: color.withValues(alpha: 0.4)),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  perk.iconEmoji,
                                                  style: const TextStyle(fontSize: 22),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // Detay
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
                                                      if (isCurrentlyActive) ...[
                                                        const SizedBox(width: 6),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                          decoration: BoxDecoration(
                                                            color: Colors.amber.withValues(alpha: 0.2),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: const Text(
                                                            'AKTİF',
                                                            style: TextStyle(
                                                              color: Colors.amberAccent,
                                                              fontSize: 9.5,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
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
                                                  const SizedBox(height: 3),
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
                            );
                          },
                        ),

                        // 2. Rütbeler Listesi
                        ListView(
                          children: [
                            _buildRankCard(1, 4, 'Çaylak Tahminci', '🥉', const Color(0xFFCD7F32), provider.level),
                            _buildRankCard(5, 9, 'Oyun Kaşifi', '🥈', const Color(0xFFC0C0C0), provider.level),
                            _buildRankCard(10, 19, 'Koleksiyoncu', '🥇', const Color(0xFFFFD700), provider.level),
                            _buildRankCard(20, 49, 'Kıdemli Eleştirmen', '💎', const Color(0xFF00E5FF), provider.level),
                            _buildRankCard(50, 999, 'Büyük Usta', '👑', const Color(0xFFFF4081), provider.level),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard(
    int minLv,
    int maxLv,
    String title,
    String badge,
    Color color,
    int currentLevel,
  ) {
    final isCurrentRank = currentLevel >= minLv && currentLevel <= maxLv;
    final isUnlocked = currentLevel >= minLv;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SteamColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentRank
              ? color
              : isUnlocked
                  ? color.withValues(alpha: 0.3)
                  : Colors.white10,
          width: isCurrentRank ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(badge, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isUnlocked ? SteamColors.textPrimary : SteamColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCurrentRank) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'MEVCUT',
                          style: TextStyle(
                            color: color,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  maxLv > 100 ? 'Seviye $minLv+' : 'Seviye $minLv - $maxLv',
                  style: TextStyle(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
