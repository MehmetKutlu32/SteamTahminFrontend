import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../screens/auth/welcome_auth_screen.dart';
import '../../services/auth_service.dart';
import '../../services/update_service.dart';
import '../../theme/steam_theme.dart';
import 'shop_modal.dart';

class PlayerProfileModal extends StatelessWidget {
  const PlayerProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) => const PlayerProfileModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final level = provider.level;
    final effectiveTitle = provider.effectiveRankTitle;
    final rankBadge = provider.rankBadge;
    final rankColor = provider.rankColor;
    final equippedAvatar = provider.equippedAvatar;
    final equippedFrame = provider.equippedFrame;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        decoration: const BoxDecoration(
          color: Color(0xFF131D29),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: SteamColors.cardBorder, width: 1.5),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 12),

              // Profil Avatarı & Seviye (Kuşanılan Çerçeve Efekti ile)
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: equippedFrame?.accentColor.withValues(alpha: 0.18) ?? rankColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: equippedFrame?.accentColor ?? rankColor,
                    width: equippedFrame != null ? 3.5 : 2.0,
                  ),
                  boxShadow: equippedFrame != null
                      ? [
                          BoxShadow(
                            color: equippedFrame.accentColor.withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    equippedAvatar?.iconEmoji ?? rankBadge,
                    style: const TextStyle(fontSize: 34),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Rütbe & Özel Unvan Başlığı
              Column(
                children: [
                  Text(
                    'Seviye $level',
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: SteamColors.cardBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: provider.equippedTitle != null
                            ? provider.equippedTitle!.accentColor.withValues(alpha: 0.6)
                            : rankColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      effectiveTitle,
                      style: TextStyle(
                        color: provider.equippedTitle?.accentColor ?? SteamColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // XP İlerleme Çubuğu
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: SteamColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SteamColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Seviye İlerlemesi (XP)',
                          style: TextStyle(color: SteamColors.textSecondary, fontSize: 11.5),
                        ),
                        Text(
                          '${provider.currentLevelXp} / 1000 XP',
                          style: const TextStyle(
                            color: SteamColors.textPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: provider.levelProgress,
                        minHeight: 6,
                        backgroundColor: Colors.black38,
                        valueColor: AlwaysStoppedAnimation<Color>(rankColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Google Hesap & Ziyaretçi Durum Kartı
              Consumer<AuthService>(
                builder: (context, authService, _) {
                  final user = authService.currentUser;
                  final isGoogleUser = authService.isLoggedIn;
                  final isGuest = user != null && user.isGuest;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: SteamColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isGoogleUser
                            ? Colors.greenAccent.withValues(alpha: 0.4)
                            : (isGuest ? Colors.cyanAccent.withValues(alpha: 0.4) : Colors.white12),
                      ),
                    ),
                    child: isGoogleUser
                        ? Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                                backgroundColor: Colors.amberAccent.withValues(alpha: 0.2),
                                child: user?.photoUrl == null
                                    ? Text(
                                        user?.displayName.isNotEmpty == true ? user!.displayName.substring(0, 1).toUpperCase() : 'G',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user?.displayName ?? 'Kullanıcı',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 14),
                                      ],
                                    ),
                                    Text(
                                      user?.email ?? '',
                                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                                tooltip: 'Çıkış Yap (Giriş Ekranına Dön)',
                                onPressed: () async {
                                  await authService.signOut();
                                  if (context.mounted) {
                                    await context.read<GameProvider>().initializeForUser(null);
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (_) => const WelcomeAuthScreen()),
                                      (route) => false,
                                    );
                                  }
                                },
                              ),
                            ],
                          )
                        : (isGuest
                            ? Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2),
                                    child: const Icon(Icons.person, color: Colors.cyanAccent, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                user.displayName,
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.white12,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text('MİSAFİR', style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        const Text('Ziyaretçi Oturumu', style: TextStyle(color: Colors.white38, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () async {
                                      try {
                                        final loggedInUser = await authService.signInWithGoogle();
                                        if (loggedInUser != null && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('🎉 Google hesabına bağlandı: ${loggedInUser.displayName}!'),
                                              backgroundColor: Colors.green[800],
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Giriş hatası: $e'), backgroundColor: Colors.redAccent),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text('Google\'a Bağla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const Icon(Icons.restart_alt_rounded, color: Colors.redAccent, size: 22),
                                    tooltip: 'Sıfırla (Giriş Ekranına Dön)',
                                    onPressed: () async {
                                      await authService.signOut();
                                      if (context.mounted) {
                                        await context.read<GameProvider>().initializeForUser(null);
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (_) => const WelcomeAuthScreen()),
                                          (route) => false,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.account_circle, color: Colors.blueAccent, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Google ile Bağlan',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
                                        ),
                                        Text(
                                          'Profilini kaydet & liderlik tablosuna katıl',
                                          style: TextStyle(color: Colors.white38, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () async {
                                      try {
                                        final loggedInUser = await authService.signInWithGoogle();
                                        if (loggedInUser != null && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('🎉 Hoş geldin, ${loggedInUser.displayName}!'),
                                              backgroundColor: Colors.green[800],
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Giriş hatası: $e'), backgroundColor: Colors.redAccent),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text('Giriş Yap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                  ),
                                ],
                              )),
                  );
                },
              ),

              // İstatistik Kartları (2x2 Grid)
              Row(
                children: [
                  Expanded(
                    child: _buildStatTile('🎯 Toplam Galibiyet', '${provider.totalWins} Oyun', SteamColors.steamCyan),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatTile('🔥 En İyi Seri', '${provider.bestStreak} Seri', Colors.orangeAccent),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildStatTile('🏆 En Yüksek Rekor', '${provider.highScore}', Colors.amberAccent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatTile('👑 Kule Zaferleri', '${provider.totalTowerWins}', Colors.deepOrangeAccent),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildStatTile('🔥 En Yüksek Seri', '${provider.bestStreak}', Colors.orangeAccent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatTile('🎯 Toplam Galibiyet', '${provider.totalWins}', SteamColors.steamCyan),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildStatTile('⚡ Zaman Yarışı', '${provider.timeAttackHighScore} Oyun', Colors.redAccent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatTile('🥊 Düello Galibiyet', 'P1: ${provider.duelP1Wins} • P2: ${provider.duelP2Wins}', Colors.cyanAccent),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildStatTile('🎡 Çevrilen Çarklar', '${provider.totalChestsOpened}', Colors.purpleAccent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatTile('💰 Bakiye', '${provider.coins} 🪙 • ${provider.diamonds} 💎', Colors.greenAccent),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Butonlar (Dükkan & Kapat)
              // Shorebird Canlı Güncelleme Durumu
              Consumer<UpdateService>(
                builder: (context, updateService, _) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101924),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: updateService.isUpdateReady ? Colors.greenAccent : Colors.white12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          updateService.isDownloading
                              ? Icons.downloading_rounded
                              : (updateService.isUpdateReady ? Icons.check_circle_rounded : Icons.system_update_rounded),
                          size: 18,
                          color: updateService.isUpdateReady ? Colors.greenAccent : SteamColors.steamCyan,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Sürüm ${UpdateService.appVersion}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                updateService.statusMessage ?? 'En güncel sürümdesiniz',
                                style: TextStyle(
                                  color: updateService.isUpdateReady ? Colors.greenAccent : Colors.white60,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (updateService.isChecking)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.amberAccent),
                          )
                        else
                          InkWell(
                            onTap: updateService.isDownloading ? null : () => updateService.checkForUpdates(),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Denetle',
                                style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ShopModal.show(context);
                      },
                      icon: const Icon(Icons.shopping_bag_rounded, size: 16, color: Colors.black),
                      label: const Text('Dükkan 🛍️', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SteamColors.cardSurface,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Kapat', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: SteamColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SteamColors.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: SteamColors.textMuted, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
