import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/roguelike_models.dart';
import '../providers/game_provider.dart';
import '../theme/steam_theme.dart';
import '../widgets/branding/app_logo_widget.dart';
import '../widgets/dialogs/achievements_modal.dart';
import '../widgets/dialogs/daily_quests_modal.dart';
import '../widgets/dialogs/debug_panel.dart';
import '../widgets/dialogs/mystery_chest_dialog.dart';
import '../widgets/dialogs/player_profile_modal.dart';
import '../widgets/dialogs/relic_collection_modal.dart';
import '../widgets/dialogs/shop_modal.dart';
import 'duel/duel_game_screen.dart';
import 'duel/online_duel_screen.dart';
import 'game_screen.dart';
import 'time_attack/time_attack_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final chests = provider.unopenedChests;
    final level = provider.level;
    final rankBadge = provider.rankBadge;
    final rankColor = provider.rankColor;
    final claimableQuests = provider.claimableDailyQuestsCount;
    final claimableAchievements = provider.claimableAchievementsCount;

    return Scaffold(
      backgroundColor: SteamColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Üst Header (Cüzdan, Profil & Butonlar)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: SteamColors.navyBg,
                border: Border(
                  bottom: BorderSide(color: SteamColors.cardBorder, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // App Mini DualSense Vector Logo
                  const AppLogoWidget(size: 30, showGlow: false),
                  const SizedBox(width: 8),

                  // Cüzdan
                  _buildHeaderChip('🪙', '${provider.coins}', Colors.amberAccent),
                  const SizedBox(width: 6),
                  _buildHeaderChip('💎', '${provider.diamonds}', SteamColors.steamCyan),
                  if (chests > 0) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => MysteryChestDialog.show(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amberAccent),
                        ),
                        child: Row(
                          children: [
                            const Text('🎡', style: TextStyle(fontSize: 12)),
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
                  const Spacer(),

                  // Dükkan
                  IconButton(
                    icon: const Text('🛍️', style: TextStyle(fontSize: 18)),
                    tooltip: 'Dükkan',
                    onPressed: () => ShopModal.show(context),
                  ),

                  // Profil Butonu
                  InkWell(
                    onTap: () => PlayerProfileModal.show(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: rankColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: rankColor.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        children: [
                          Text(rankBadge, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            'Lv.$level',
                            style: TextStyle(
                              color: rankColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.bug_report_rounded, color: Colors.amberAccent, size: 19),
                    tooltip: 'Geliştirici Paneli',
                    onPressed: () => DebugPanelModal.show(context),
                  ),
                ],
              ),
            ),

            // 2. Kompakt Günlük Görevler Şeridi
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: InkWell(
                onTap: () => DailyQuestsModal.show(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: SteamColors.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: claimableQuests > 0
                          ? Colors.amberAccent
                          : SteamColors.steamCyan.withValues(alpha: 0.4),
                      width: claimableQuests > 0 ? 1.5 : 1,
                    ),
                    boxShadow: [
                      if (claimableQuests > 0)
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.2),
                          blurRadius: 10,
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('📋', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GÜNLÜK GÖREVLER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${provider.completedDailyQuestsCount}/${provider.dailyQuests.length} Tamamlandı',
                              style: const TextStyle(color: SteamColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (claimableQuests > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amberAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$claimableQuests Ödül Hazır!',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      else
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Mod Kategorileri Sekmesi (Tab Bar)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: SteamColors.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SteamColors.steamCyan, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: SteamColors.steamCyan.withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, letterSpacing: 0.2),
                unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: '🏰 Solo'),
                  Tab(text: '⚡ Meydan Oku'),
                  Tab(text: '🥊 1v1 Düello'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 4. Mod Kartları İçerik Alanı
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Sekme 1: Tek Oyunculu (Kule & Sonsuz)
                  _buildSoloTab(context, provider),

                  // Sekme 2: Meydan Okuma (Zaman Yarışı & Sahtekar İnceleme)
                  _buildChallengeTab(context, provider),

                  // Sekme 3: 1v1 Düello (Yerel Çok Oyunculu)
                  _buildPartyTab(context, provider),
                ],
              ),
            ),

            // 5. Alt Sabit Panel (Başarımlar, Yadigarlar, Dükkan)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: SteamColors.navyBg,
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  // Kupa Odası
                  Expanded(
                    child: _buildBottomNavBtn(
                      title: 'Kupa Odası',
                      icon: '🏆',
                      badgeCount: claimableAchievements,
                      onTap: () => AchievementsModal.show(context),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Yadigarlar
                  Expanded(
                    child: _buildBottomNavBtn(
                      title: 'Yadigarlar',
                      icon: '🎒',
                      onTap: () => RelicCollectionModal.show(context),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Dükkan
                  Expanded(
                    child: _buildBottomNavBtn(
                      title: 'Dükkan',
                      icon: '🛍️',
                      onTap: () => ShopModal.show(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tek Oyunculu Modlar
  Widget _buildSoloTab(BuildContext context, GameProvider provider) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // 🏰 Kule Koşusu
        _buildModeCard(
          context: context,
          title: provider.hasOngoingRoguelikeRun ? 'KULE KOŞUSUNA DEVAM ET' : 'ROGUELIKE KULE KOŞUSU',
          subtitle: provider.hasOngoingRoguelikeRun
              ? 'Kat ${provider.currentFloor} / 10 • ${provider.activePerks.length} Aktif Yadigar'
              : '10 Katlık Stratejik Macera, Boss Savaşı & Yadigarlar',
          badge: provider.hasOngoingRoguelikeRun ? 'DEVAM ET' : 'YADİGARLI',
          badgeColor: provider.hasOngoingRoguelikeRun ? Colors.greenAccent : SteamColors.steamCyan,
          borderColor: provider.hasOngoingRoguelikeRun ? Colors.greenAccent : SteamColors.steamCyan,
          iconEmoji: provider.hasOngoingRoguelikeRun ? '🗡️' : '🏰',
          gradient: provider.hasOngoingRoguelikeRun
              ? const LinearGradient(colors: [Color(0xFF0D2E24), Color(0xFF141D28)])
              : const LinearGradient(colors: [Color(0xFF132838), Color(0xFF191B28)]),
          onTap: () {
            HapticFeedback.mediumImpact();
            if (provider.hasOngoingRoguelikeRun) {
              provider.resumeRoguelikeRun();
            } else {
              provider.startNewRoguelikeRun();
            }
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GameScreen()));
          },
        ),
        const SizedBox(height: 12),

        // ♾️ Sonsuz Klasik
        _buildModeCard(
          context: context,
          title: 'SONSUZ KLASİK TAHMİN',
          subtitle: 'Sınırsız Oyun, Seri Rekoru & Rahat Tahmin Deneyimi',
          badge: 'KLASİK',
          badgeColor: Colors.amberAccent,
          borderColor: Colors.amberAccent.withValues(alpha: 0.6),
          iconEmoji: '♾️',
          gradient: const LinearGradient(colors: [Color(0xFF282414), Color(0xFF1A1D24)]),
          onTap: () {
            HapticFeedback.mediumImpact();
            provider.setGameMode(GameMode.endless);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GameScreen()));
          },
        ),
        const SizedBox(height: 16),

        // 📊 Solo Kariyer Özeti
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SteamColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('📊 ', style: TextStyle(fontSize: 15)),
                  Text(
                    'SOLO KARİYER DURUMU',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5, letterSpacing: 0.8),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatBox('🏰 Kule Zaferleri', '${provider.totalTowerWins}', Colors.deepOrangeAccent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniStatBox('🔥 En İyi Seri', '${provider.bestStreak}', Colors.orangeAccent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatBox('🎒 Yadigarlar', '${provider.discoveredPerkIds.length}/19', SteamColors.steamCyan),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniStatBox('🎯 Toplam Galibiyet', '${provider.totalWins}', Colors.greenAccent),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 💡 Kule Modu İpucu Kartı
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E2C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SteamColors.steamCyan.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kule Koşusunda her 5. katta Boss karşılaşması bulunur. Boss yendiğinizde ekstra Şans Çarkı ve Elmas kazanırsınız!',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Meydan Okuma Modları
  Widget _buildChallengeTab(BuildContext context, GameProvider provider) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // ⚡ Zaman Yarışı
        _buildModeCard(
          context: context,
          title: 'ZAMAN YARIŞI (60s)',
          subtitle: '60 Saniye Geri Sayım! Seri oyun bil, ekstra süre ve kombo kazan',
          badge: 'ADRENALİN',
          badgeColor: Colors.redAccent,
          borderColor: Colors.redAccent,
          iconEmoji: '⚡',
          gradient: const LinearGradient(colors: [Color(0xFF2E1214), Color(0xFF191B28)]),
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TimeAttackScreen()));
          },
        ),
        const SizedBox(height: 12),

        // 🕵️ Sahtekar İnceleme
        _buildModeCard(
          context: context,
          title: 'SAHTEKAR İNCELEME MODU',
          subtitle: '5 İncelemeden 1 tanesi sahte! Sahtekarı yakala ve turu kazan!',
          badge: 'DEDEKTİF MODU',
          badgeColor: Colors.purpleAccent,
          borderColor: Colors.purpleAccent,
          iconEmoji: '🕵️',
          gradient: const LinearGradient(colors: [Color(0xFF251333), Color(0xFF141924)]),
          onTap: () {
            HapticFeedback.mediumImpact();
            provider.setGameMode(GameMode.imposter);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GameScreen()));
          },
        ),
        const SizedBox(height: 16),

        // ⚡ Meydan Okuma İstatistikleri
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SteamColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('⚡ ', style: TextStyle(fontSize: 15)),
                  Text(
                    'MEYDAN OKUMA REKORLARI',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5, letterSpacing: 0.8),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatBox('⏱️ 60s Hız Rekoru', '${provider.timeAttackHighScore} Oyun', Colors.redAccent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniStatBox('🕵️ Yakalanan', '${provider.getAchievementProgress("imposter_hunter")} Sahtekar', Colors.purpleAccent),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 🕵️ Sahtekar Modu Rehberi
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF21132B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Text('🔍', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sahtekar modunda 5 inceleme aynı anda açıktır! Sahte olan incelemeyi doğru tespit edip turu kazanabilir, oyun adını bilerek ekstra bonus altın kazanabilirsin.',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Çok Oyunculu / Parti Modu
  Widget _buildPartyTab(BuildContext context, GameProvider provider) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // 🌐 Online 1v1 Düello (SignalR)
        _buildModeCard(
          context: context,
          title: 'ONLINE 1v1 DÜELLO',
          subtitle: 'Arkadaşınla oda kur veya koda bağlanarak canlı yarış!',
          badge: 'CANLI MULTIPLAYER',
          badgeColor: Colors.amberAccent,
          borderColor: Colors.amberAccent,
          iconEmoji: '🌐',
          gradient: const LinearGradient(colors: [Color(0xFF2E220D), Color(0xFF141A24)]),
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnlineDuelScreen()));
          },
        ),
        const SizedBox(height: 12),

        // 🥊 Yerel 1v1 Düello (Pass-and-Play)
        _buildModeCard(
          context: context,
          title: 'YEREL 1v1 DÜELLO',
          subtitle: 'Arkadaşınla aynı ekranda sıra tabanlı kıyasıya tahmin kapışması!',
          badge: 'AYNI CİHAZDA',
          badgeColor: Colors.orangeAccent,
          borderColor: Colors.orangeAccent,
          iconEmoji: '🥊',
          gradient: const LinearGradient(colors: [Color(0xFF2A1B0E), Color(0xFF141A24)]),
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DuelGameScreen()));
          },
        ),
        const SizedBox(height: 14),

        // 📜 Düello Kuralları & Özellikler Rehberi
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF221610),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.35)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('🥊', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    '1v1 Düello Kuralları & Ayarlar',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.white12, height: 16),
              Text(
                '• İsim & Kural Ayarlama: Oyuna girmeden önce her iki oyuncu kendi ismini belirleyebilir ve hedef skor seçebilir.\n\n'
                '• Sıra Tabanlı Kapışma: Oyuncular sırayla tahmin yapar. Yapılan her yanlış tahminde 1 yeni ipucu açılır ve sıra rakibe geçer.\n\n'
                '• Hızlı & Kesintisiz: Doğru tahmin yapan oyuncu puanı hanesine yazdırır ve hedef puana ilk ulaşan şampiyon olur!',
                style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMiniStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF101924),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: SteamColors.textMuted, fontSize: 10.5), maxLines: 1),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required Color borderColor,
    required String iconEmoji,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.7), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // İkon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(iconEmoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),

                // Başlık & Açıklama
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: SteamColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: badgeColor.withValues(alpha: 0.5), width: 0.8),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: SteamColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: SteamColors.textMuted,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBtn({
    required String title,
    required String icon,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: SteamColors.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: badgeCount > 0 ? Colors.amberAccent : Colors.white10,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (badgeCount > 0)
              Positioned(
                top: 0,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderChip(String emoji, String amount, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: SteamColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10.5)),
          const SizedBox(width: 3.5),
          Text(
            amount,
            style: TextStyle(
              color: textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
