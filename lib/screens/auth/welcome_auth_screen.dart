import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../services/auth_service.dart';
import '../../services/local_round_cache_service.dart';
import '../../theme/steam_theme.dart';
import '../../widgets/branding/app_logo_widget.dart';
import '../main_menu_screen.dart';

class WelcomeAuthScreen extends StatefulWidget {
  const WelcomeAuthScreen({super.key});

  @override
  State<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends State<WelcomeAuthScreen> {
  bool _isLoading = false;
  final TextEditingController _guestNameController = TextEditingController();
  final PageController _pageController = PageController();
  int _activePageIndex = 0;
  Timer? _carouselTimer;

  static const List<_GameModeHighlight> _highlights = [
    _GameModeHighlight(
      emoji: '⚔️',
      title: 'Canlı 1v1 Düello',
      tag: 'ONLINE & YEREL',
      subtitle: 'Arkadaşınla gerçek zamanlı kapış, skor tablosunda zirveye yerleş!',
      gradient: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
      accentColor: Colors.cyanAccent,
    ),
    _GameModeHighlight(
      emoji: '🏰',
      title: 'Roguelike Kule Tırmanışı',
      tag: '10 KATLI MACERA',
      subtitle: 'Her katta pasif yadigarları topla, boss katını geç ve zirveye ulaş!',
      gradient: [Color(0xFF2E0854), Color(0xFF1F103A), Color(0xFF100720)],
      accentColor: Color(0xFFD946EF),
    ),
    _GameModeHighlight(
      emoji: '🕵️',
      title: 'Sahtekar İnceleme Modu',
      tag: 'DEDEKTİF MODU',
      subtitle: 'Hangi oyuncu yorumu uydurma? Sahte incelemeyi tespit et ve oyunu bil!',
      gradient: [Color(0xFF3E2723), Color(0xFF1A120B), Color(0xFF120E0A)],
      accentColor: Colors.amberAccent,
    ),
    _GameModeHighlight(
      emoji: '⏱️',
      title: 'Zaman Yarışı (Time Attack)',
      tag: '60 SANİYE HEYECANI',
      subtitle: 'Süre bitmeden ardı ardına en yüksek doğru tahmin serisini yakala!',
      gradient: [Color(0xFF4A0E17), Color(0xFF2B090F), Color(0xFF140508)],
      accentColor: Colors.redAccent,
    ),
    _GameModeHighlight(
      emoji: '👑',
      title: 'Avatarlar & Şans Çarkı',
      tag: '10+ ÖZEL KOZMETİK',
      subtitle: 'Altın ve elmas kazan, 10 ışıltılı çerçeve ve avatarı koleksiyonuna ekle!',
      gradient: [Color(0xFF064E3B), Color(0xFF022C22), Color(0xFF011A14)],
      accentColor: Colors.greenAccent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLastGuestName();
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(milliseconds: 3200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final nextIndex = (_activePageIndex + 1) % _highlights.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Future<void> _loadLastGuestName() async {
    final authService = context.read<AuthService>();
    final lastName = await authService.getLastGuestName();
    if (lastName != null && lastName.trim().isNotEmpty) {
      _guestNameController.text = lastName.trim();
    } else {
      _guestNameController.text = 'Oyuncu_${DateTime.now().millisecond}';
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _guestNameController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final gameProvider = context.read<GameProvider>();

    try {
      final user = await authService.signInWithGoogle();
      if (user != null && mounted) {
        final hasExistingProfile = await LocalRoundCacheService.hasUserProfile(user.id);
        final hasGuest = await LocalRoundCacheService.hasGuestProgress();

        // Yalnızca kullanıcı YENİ ise ve gerçekte cihazda ZİYARETÇİ ilerlemesi varsa sor
        if (!hasExistingProfile && hasGuest) {
          final guestData = await LocalRoundCacheService.loadProfileData(userId: null);
          if (mounted) {
            final shouldMigrate = await _showMigrationDialog(context, guestData);
            if (shouldMigrate == true) {
              await gameProvider.migrateGuestToUser(user.id);
            } else {
              await gameProvider.initializeForUser(user);
            }
          }
        } else {
          // Mevcut Google kullanıcısı doğrudan kendi profilini yükler
          await gameProvider.initializeForUser(user);
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainMenuScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Giriş Hatası: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showMigrationDialog(BuildContext context, Map<String, dynamic> guestData) {
    final level = 1 + ((guestData['totalXp'] as int? ?? 0) ~/ 100);
    final coins = guestData['coins'] as int? ?? 50;
    final diamonds = guestData['diamonds'] as int? ?? 2;
    final wins = guestData['totalTowerWins'] as int? ?? 0;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131D29),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.amberAccent, width: 1.2),
        ),
        title: const Row(
          children: [
            Text('🔄 ', style: TextStyle(fontSize: 22)),
            Text(
              'İlerlemeyi Google\'a Aktar',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cihazda kayıtlı ziyaretçi (misafir) ilerlemeniz bulundu:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SteamColors.cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _buildStatRow('🎯 Seviye:', 'Lv.$level', Colors.amberAccent),
                  const SizedBox(height: 4),
                  _buildStatRow('🪙 Bakiye:', '$coins Altın • $diamonds Elmas', Colors.cyanAccent),
                  const SizedBox(height: 4),
                  _buildStatRow('🏆 Galibiyet:', '$wins Oyun', Colors.greenAccent),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bu veriler yeni Google hesabınıza bağlansın mı?',
              style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Sıfırdan Başla', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Aktar & Birleştir ✨', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String val, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11.5)),
        Text(val, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _handleGuestSignIn(BuildContext context) async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final gameProvider = context.read<GameProvider>();
    final guestName = _guestNameController.text.trim().isNotEmpty
        ? _guestNameController.text.trim()
        : (await authService.getLastGuestName() ?? 'Misafir_${DateTime.now().millisecond}');

    await authService.saveGuestName(guestName);
    final guestUser = await authService.signInAsGuest(customName: guestName);

    if (mounted) {
      await gameProvider.initializeForUser(guestUser);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
      );
    }
  }

  Future<void> _showGuestNameDialog(BuildContext context) async {
    final authService = context.read<AuthService>();
    final savedName = await authService.getLastGuestName();
    if (savedName != null && savedName.trim().isNotEmpty) {
      _guestNameController.text = savedName.trim();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131D29),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SteamColors.cardBorder),
        ),
        title: const Row(
          children: [
            Text('👤 ', style: TextStyle(fontSize: 20)),
            Text(
              'Ziyaretçi Olarak Başla',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Oyun içinde görünecek oyuncu adınızı belirleyin:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _guestNameController,
              style: const TextStyle(color: Colors.white),
              onChanged: (val) {
                authService.saveGuestName(val);
              },
              decoration: InputDecoration(
                labelText: 'Oyuncu Adı',
                labelStyle: const TextStyle(color: Colors.cyanAccent),
                prefixIcon: const Icon(Icons.badge_rounded, color: Colors.cyanAccent),
                filled: true,
                fillColor: SteamColors.cardBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final chosenName = _guestNameController.text.trim();
              if (chosenName.isNotEmpty) {
                authService.saveGuestName(chosenName);
              }
              Navigator.of(ctx).pop();
              _handleGuestSignIn(context);
            },
            child: const Text('Oyuna Başla 🎮', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F16),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Parlayan DualSense Tahmin Logosu
                const AppLogoWidget(size: 96),
                const SizedBox(height: 16),

                // 2. Başlık ve Açıklama (Catchphrase)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.35)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🕹️ ', style: TextStyle(fontSize: 12)),
                      Text(
                        'OYUN TUTKUNLARI İÇİN BİLGİ YARIŞMASI',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'OYUN TAHMİN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Binlerce gerçek oyuncu yorumu, gizli ipuçları\nve sınırsız rekabet seni bekliyor!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 22),

                // 3. DİNAMİK ANİMASYONLU OYUN MODLARI VİTRİNİ (CAROUSEL)
                SizedBox(
                  height: 110,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _highlights.length,
                    onPageChanged: (index) {
                      setState(() => _activePageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final item = _highlights[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: item.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: item.accentColor.withValues(alpha: 0.4), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: item.accentColor.withValues(alpha: 0.12),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                                border: Border.all(color: item.accentColor.withValues(alpha: 0.5)),
                              ),
                              child: Center(
                                child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: item.accentColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.tag,
                                          style: TextStyle(
                                            color: item.accentColor,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      height: 1.25,
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
                const SizedBox(height: 10),

                // Carousel Nokta Göstergeleri
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_highlights.length, (index) {
                    final isCurrent = index == _activePageIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isCurrent ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isCurrent ? Colors.cyanAccent : Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.amberAccent)
                else ...[
                  // 4. GOOGLE İLE GİRİŞ YAP BUTONU
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () => _handleGoogleSignIn(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(Icons.g_mobiledata_rounded, color: Colors.blueAccent, size: 26),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Google ile Giriş Yap',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('VEYA', style: TextStyle(color: Colors.white38, fontSize: 11)),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 5. ZİYARETÇİ / MİSAFİR OLARAK DEVAM ET BUTONU
                  OutlinedButton.icon(
                    icon: const Icon(Icons.person_outline_rounded, color: Colors.cyanAccent, size: 20),
                    label: const Text(
                      'Ziyaretçi Olarak Devam Et',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: Colors.cyanAccent, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _showGuestNameDialog(context),
                  ),
                ],
                const SizedBox(height: 16),

                const Text(
                  'Giriş yaparak ilerlemeni ve başarımlarını kaydedebilirsin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white30, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameModeHighlight {
  final String emoji;
  final String title;
  final String tag;
  final String subtitle;
  final List<Color> gradient;
  final Color accentColor;

  const _GameModeHighlight({
    required this.emoji,
    required this.title,
    required this.tag,
    required this.subtitle,
    required this.gradient,
    required this.accentColor,
  });
}
