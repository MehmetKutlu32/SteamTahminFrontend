import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/achievement_models.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';

class AchievementsModal extends StatefulWidget {
  const AchievementsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AchievementsModal(),
    );
  }

  @override
  State<AchievementsModal> createState() => _AchievementsModalState();
}

class _AchievementsModalState extends State<AchievementsModal> {
  AchievementCategory? _selectedCategory; // null = Tümü

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    const all = AchievementCatalog.allAchievements;
    final completedCount = all.where((a) => provider.isAchievementCompleted(a)).length;

    final filtered = _selectedCategory == null
        ? all
        : all.where((a) => a.category == _selectedCategory).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF101924),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.amberAccent.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık Çubuğu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🏆 ', style: TextStyle(fontSize: 22)),
                    const Text(
                      'KUPA ODASI',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '$completedCount/${all.length}',
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Her oyun modu için özel hedefleri tamamla, ödülleri topla!',
              style: TextStyle(color: SteamColors.textMuted, fontSize: 11.5),
            ),
            const SizedBox(height: 10),

            // Kategori Filtre Çipleri
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tümü (${all.length})', null),
                  _buildFilterChip('🏰 Kule', AchievementCategory.tower),
                  _buildFilterChip('♾️ Sonsuz', AchievementCategory.endless),
                  _buildFilterChip('⚡ Zaman', AchievementCategory.timeAttack),
                  _buildFilterChip('🕵️ Sahtekar', AchievementCategory.imposter),
                  _buildFilterChip('🥊 Düello', AchievementCategory.duel),
                  _buildFilterChip('🪙 Ekonomi', AchievementCategory.wealth),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Başarım Listesi
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final ach = filtered[index];
                  return _buildAchievementTile(context, provider, ach);
                },
              ),
            ),

            const SizedBox(height: 10),
            // Kapat Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SteamColors.cardBg,
                  foregroundColor: SteamColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white12),
                  ),
                ),
                child: const Text('Kapat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, AchievementCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amberAccent.withValues(alpha: 0.25) : SteamColors.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.amberAccent : Colors.white12,
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.amberAccent : Colors.white70,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementTile(BuildContext context, GameProvider provider, Achievement ach) {
    final current = provider.getAchievementProgress(ach.id);
    final isDone = provider.isAchievementCompleted(ach);
    final isClaimed = provider.isAchievementClaimed(ach.id);
    final canClaim = isDone && !isClaimed;
    final progress = (current / ach.targetValue).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SteamColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: canClaim
              ? Colors.amberAccent
              : isClaimed
                  ? Colors.green.withValues(alpha: 0.4)
                  : Colors.white10,
          width: canClaim ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Emoji Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: ach.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ach.accentColor.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(ach.iconEmoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),

          // Başlık & Açıklama & İlerleme
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ach.title,
                        style: TextStyle(
                          color: isDone ? Colors.white : Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Ödül
                    Row(
                      children: [
                        if (ach.rewardGold > 0) ...[
                          Text('${ach.rewardGold} 🪙', style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                        ],
                        if (ach.rewardDiamonds > 0)
                          Text('${ach.rewardDiamonds} 💎', style: const TextStyle(color: SteamColors.steamCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  ach.description,
                  style: const TextStyle(color: SteamColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 5),

                // İlerleme Barı
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDone ? Colors.amberAccent : ach.accentColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$current/${ach.targetValue}',
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Topla / Kazanıldı Butonu
          if (canClaim)
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                provider.claimAchievementReward(ach);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(60, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Topla', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
            )
          else if (isClaimed)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.verified_rounded, color: Colors.amberAccent, size: 22),
            )
          else
            const SizedBox(width: 4),
        ],
      ),
    );
  }
}
