import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/roguelike_models.dart';
import '../../providers/game_provider.dart';
import '../../services/auth_service.dart';
import '../../services/local_round_cache_service.dart';
import '../../theme/steam_theme.dart';

class DebugPanelModal {
  static void show(BuildContext context) {
    final authService = context.read<AuthService>();
    if (!authService.isAdmin) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131B26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: Colors.amber, width: 1),
      ),
      builder: (modalContext) {
        return Consumer<GameProvider>(
          builder: (context, provider, child) {
            final round = provider.currentRound;

            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık ve Kapat Butonu
                      Row(
                        children: [
                          const Icon(Icons.bug_report_rounded, color: Colors.amber, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            'TÜM MODLAR İÇİN TEST PANELİ',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFF2A3A4D)),
                      const SizedBox(height: 6),

                      // 1. Aktif Oyun & Cevap
                      if (round != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: SteamColors.cardSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: SteamColors.steamCyan.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Text('🎯 Aktif Cevap: ', style: TextStyle(color: SteamColors.textSecondary, fontSize: 12.5)),
                              Expanded(
                                child: Text(
                                  '${round.oyunAdi} (ID: ${round.appId})',
                                  style: const TextStyle(
                                    color: SteamColors.steamCyan,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // 2. Mod Değiştirici Hızlı Butonlar
                      _buildSectionHeader('🎮 MOD SEÇİCİ & AKTİF MOD'),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildModeChip(context, provider, '🏰 Kule', GameMode.roguelike),
                          _buildModeChip(context, provider, '♾️ Sonsuz', GameMode.endless),
                          _buildModeChip(context, provider, '🕵️ Sahtekar', GameMode.imposter),
                          _buildModeChip(context, provider, '⚡ Zaman', GameMode.timeAttack),
                          _buildModeChip(context, provider, '🥊 Düello', GameMode.duel),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 3. Her Modun Ayrı Cache / Kuyruk Durumu
                      _buildSectionHeader('📦 TÜM MODLARIN YEREL CACHE KUYRUKLARI'),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: SteamColors.cardSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Kuyruk Yönetimi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        await provider.debugClearAllCaches();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.redAccent, width: 0.8),
                                        ),
                                        child: const Text('Tümünü Sıfırla', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    InkWell(
                                      onTap: () async {
                                        await provider.debugFillAllCaches();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.greenAccent.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.greenAccent, width: 0.8),
                                        ),
                                        child: const Text('Kuyrukları Doldur', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 12),
                            _buildQueueStatusRow('🏰 Kule Koşusu', GameMode.roguelike),
                            _buildQueueStatusRow('♾️ Sonsuz Klasik', GameMode.endless),
                            _buildQueueStatusRow('🕵️ Sahtekar Modu', GameMode.imposter),
                            _buildQueueStatusRow('⚡ Zaman Yarışı', GameMode.timeAttack),
                            _buildQueueStatusRow('🥊 1v1 Düello', GameMode.duel),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 4. Moda Özel Hızlı Test Eylemleri
                      _buildSectionHeader('🧪 MODA ÖZEL TEST EYLEMLERİ'),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          // Kule Eylemleri
                          _buildActionBtn('🏰 Kat 5 Boss', Colors.deepOrangeAccent, () => provider.debugSetFloor(5)),
                          _buildActionBtn('👑 Kat 10 Boss', Colors.amberAccent, () => provider.jumpToBossFloor()),
                          _buildActionBtn('🎒 +1 Yadigar Al', Colors.tealAccent, () {
                            final perk = provider.addDebugPerk();
                            if (perk != null) {
                              _showPerkGrantedDialog(context, perk, provider.activePerks.length);
                            }
                          }),
                          _buildActionBtn('🗑️ Yadigarları Temizle', Colors.redAccent, () => provider.clearActivePerks()),

                          // Sahtekar Eylemleri
                          if (provider.isImposterMode) ...[
                            _buildActionBtn('🕵️ Sahtekarı Seç (#${(provider.imposterCardIndex ?? 0) + 1})', Colors.purpleAccent, () {
                              if (provider.imposterCardIndex != null) {
                                provider.selectImposterCard(provider.imposterCardIndex!);
                              }
                            }),
                          ],

                          // Zaman Yarışı & Düello Eylemleri
                          _buildActionBtn('⚡ 60s Skoru: 10', Colors.redAccent, () => provider.recordTimeAttackResult(10)),
                          _buildActionBtn('🌐 Online Düello Kazan', Colors.cyanAccent, () => provider.recordOnlineDuelWin()),

                          // Oyun Akışı
                          _buildActionBtn('🎯 Doğru Bildir', Colors.green, () {
                            if (round != null) provider.submitGuess(round.oyunAdi);
                          }),
                          _buildActionBtn('❌ Yanlış Tahmin', Colors.red, () {
                            provider.submitGuess('Yanlış Deneme');
                          }),
                          _buildActionBtn('⏩ Yeni Tura Geç', SteamColors.steamBlue, () => provider.startNewRound()),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 5. Ekonomi & Cüzdan Hileleri
                      _buildSectionHeader('💰 EKONOMİ & SEVİYE HİLELERİ'),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildActionBtn('+250 🪙 Altın', Colors.amberAccent, () => provider.debugSetCoins(provider.coins + 250)),
                          _buildActionBtn('+10 💎 Elmas', SteamColors.steamCyan, () => provider.debugSetDiamonds(provider.diamonds + 10)),
                          _buildActionBtn('+5 🎡 Çark Hakkı', Colors.purpleAccent, () => provider.debugSetChests(provider.unopenedChests + 5)),
                          _buildActionBtn('+1000 XP 🎖️', Colors.tealAccent, () => provider.addDebugXp(xp: 1000)),
                          _buildActionBtn('✨ Sıfır Hesap Başlangıcı (50🪙 2💎 0XP)', Colors.cyanAccent, () {
                            provider.debugResetProfileToFactoryDefault();
                          }),
                          _buildActionBtn('🧹 Sıfır Bakiye (0🪙 0💎)', Colors.redAccent, () {
                            provider.debugSetCoins(0);
                            provider.debugSetDiamonds(0);
                            provider.debugSetChests(0);
                          }),
                          _buildActionBtn('Küfür Sansürü Aç/Kapat', Colors.white70, () => provider.toggleCensorProfanity(!provider.censorProfanity)),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  static Widget _buildModeChip(BuildContext context, GameProvider provider, String label, GameMode mode) {
    final isSelected = provider.gameMode == mode;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        provider.setGameMode(mode);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withValues(alpha: 0.25) : SteamColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.amberAccent : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.amberAccent : Colors.white70,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  static Widget _buildQueueStatusRow(String modeName, GameMode mode) {
    return FutureBuilder<int>(
      future: LocalRoundCacheService.getCachedRoundCount(mode),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        final maxCount = (mode == GameMode.roguelike) ? 10 : 5;
        final hasCache = count > 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(modeName, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: hasCache ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: hasCache ? Colors.greenAccent : Colors.redAccent, width: 0.8),
                ),
                child: Text(
                  '$count / $maxCount Hazır',
                  style: TextStyle(
                    color: hasCache ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildActionBtn(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: const Size(40, 32),
        side: BorderSide(color: color.withValues(alpha: 0.6), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  static void _showPerkGrantedDialog(BuildContext context, RoguelikePerk perk, int totalPerks) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF132838),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Text(perk.iconEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${perk.name} eklendi! (Toplam: $totalPerks)',
                style: const TextStyle(color: SteamColors.steamCyan, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
