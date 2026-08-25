import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/quest_models.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';

class DailyQuestsModal extends StatelessWidget {
  const DailyQuestsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const DailyQuestsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final quests = provider.dailyQuests;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF101924),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: SteamColors.steamCyan.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: SteamColors.steamCyan.withValues(alpha: 0.15),
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
                const Row(
                  children: [
                    Text('📋 ', style: TextStyle(fontSize: 22)),
                    Text(
                      'GÜNLÜK GÖREVLER',
                      style: TextStyle(
                        color: SteamColors.steamCyan,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
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
              'Her gün gece 00:00\'da yenilenir. Görevleri tamamla, ödülleri kap!',
              style: TextStyle(color: SteamColors.textMuted, fontSize: 11.5),
            ),
            const SizedBox(height: 16),

            // Görev Listesi
            if (quests.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Bugün için görev bulunamadı.', style: TextStyle(color: Colors.white54)),
                ),
              )
            else
              ...quests.map((quest) => _buildQuestTile(context, provider, quest)),

            const SizedBox(height: 12),
            // Kapat Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SteamColors.cardBg,
                  foregroundColor: SteamColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildQuestTile(BuildContext context, GameProvider provider, DailyQuest quest) {
    final isDone = quest.isCompleted;
    final isClaimed = quest.isClaimed;
    final canClaim = isDone && !isClaimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Center(
              child: Text(quest.iconEmoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),

          // Başlık & İlerleme
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      quest.title,
                      style: const TextStyle(
                        color: SteamColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Ödül Rozeti
                    Row(
                      children: [
                        if (quest.rewardGold > 0) ...[
                          Text('${quest.rewardGold} 🪙', style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                        ],
                        if (quest.rewardDiamonds > 0)
                          Text('${quest.rewardDiamonds} 💎', style: const TextStyle(color: SteamColors.steamCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  quest.description,
                  style: const TextStyle(color: SteamColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 6),

                // İlerleme Çubuğu
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: quest.progress,
                          minHeight: 5,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDone ? Colors.greenAccent : SteamColors.steamCyan,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${quest.currentValue}/${quest.targetValue}',
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Topla / Tamamlandı Butonu
          if (canClaim)
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                provider.claimQuestReward(quest);
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
              child: Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 22),
            )
          else
            const SizedBox(width: 4),
        ],
      ),
    );
  }
}
