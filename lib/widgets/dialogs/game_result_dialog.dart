import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';
import 'mystery_chest_dialog.dart';
import 'share_card_modal.dart';

class GameResultDialog extends StatefulWidget {
  final bool isWon;
  final String gameName;
  final int appId;
  final int score;
  final int attemptsUsed;
  final int wonCoins;
  final int wonDiamonds;
  final int currentStreak;
  final String? releaseDate;
  final List<String> genres;
  final VoidCallback onNextRound;

  const GameResultDialog({
    super.key,
    required this.isWon,
    required this.gameName,
    required this.appId,
    required this.score,
    required this.attemptsUsed,
    this.wonCoins = 25,
    this.wonDiamonds = 0,
    this.currentStreak = 0,
    this.releaseDate,
    this.genres = const [],
    required this.onNextRound,
  });

  @override
  State<GameResultDialog> createState() => _GameResultDialogState();
}

class _GameResultDialogState extends State<GameResultDialog> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    if (widget.isWon) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWon = widget.isWon;
    final gameBannerUrl =
        'https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/${widget.appId}/header.jpg';

    return Stack(
      alignment: Alignment.center,
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: SteamColors.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isWon ? Colors.amberAccent : SteamColors.negativeReview,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isWon ? Colors.amber : SteamColors.negativeReview)
                      .withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Üst Kapatma Butonu
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close_rounded, color: SteamColors.textMuted, size: 20),
                    tooltip: 'İncelemeleri Görüntüle',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // Durum İkonu / Rozeti
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isWon
                        ? Colors.amber.withValues(alpha: 0.2)
                        : SteamColors.negativeReview.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    isWon
                        ? Icons.military_tech_rounded
                        : Icons.sentiment_very_dissatisfied_rounded,
                    size: 44,
                    color: isWon ? Colors.amberAccent : SteamColors.negativeReview,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isWon ? '🏆 TEBRİKLER, BİLDİNİZ!' : '💀 TUR TAMAMLANDI',
                  style: TextStyle(
                    color: isWon ? Colors.amberAccent : SteamColors.negativeReview,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.gameName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: SteamColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // Oyun Kapak Görseli
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    gameBannerUrl,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: double.infinity,
                        color: SteamColors.cardSurface,
                        alignment: Alignment.center,
                        child: const Icon(Icons.videogame_asset_rounded,
                            color: SteamColors.steamBlue, size: 30),
                      );
                    },
                  ),
                ),
                if ((widget.releaseDate != null && widget.releaseDate!.isNotEmpty) || widget.genres.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (widget.releaseDate != null && widget.releaseDate!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: SteamColors.cardBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4), width: 0.6),
                          ),
                          child: Text(
                            '📅 ${widget.releaseDate}',
                            style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ...widget.genres.take(3).map((g) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: SteamColors.cardBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: SteamColors.steamCyan.withValues(alpha: 0.4), width: 0.6),
                            ),
                            child: Text(
                              '🏷️ $g',
                              style: const TextStyle(color: SteamColors.steamCyan, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          )),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // 🎁 Zafer Ödül Kutusu (Loot Box)
                if (isWon) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E2614), Color(0xFF1E2638)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '+${widget.wonCoins} Altın',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        if (widget.wonDiamonds > 0)
                          Row(
                            children: [
                              const Text('💎', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                '+${widget.wonDiamonds} Elmas',
                                style: const TextStyle(
                                  color: SteamColors.steamCyan,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        if (widget.currentStreak > 1)
                          Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.currentStreak} Seri (${(1.0 + (widget.currentStreak - 1) * 0.25).toStringAsFixed(2)}x)',
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 🎖️ Seviye & XP İlerleme Çubuğu ve Sahtekar Bilgisi
                Consumer<GameProvider>(
                  builder: (context, provider, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Sahtekar Modu Sonuç Kartı
                        if (provider.isImposterMode && provider.imposterCardIndex != null) ...[
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: provider.isImposterFound
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.purple.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: provider.isImposterFound ? Colors.greenAccent : Colors.purpleAccent,
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      provider.isImposterFound
                                          ? '🎉 Sahtekar Yakalandı! (+2X Bonus)'
                                          : '🕵️ Sahte İnceleme Kartı:',
                                      style: TextStyle(
                                        color: provider.isImposterFound ? Colors.greenAccent : Colors.purpleAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Kart #${provider.imposterCardIndex! + 1}',
                                        style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (provider.imposterCardIndex! < provider.reviews.length)
                                  Text(
                                    '"${provider.reviews[provider.imposterCardIndex!].yorum}"',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: SteamColors.cardSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: provider.rankColor.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${provider.rankBadge} Seviye ${provider.level}: ${provider.rankTitle}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: provider.rankColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${provider.currentLevelXp} / ${provider.nextLevelRequiredXp} XP',
                                    style: const TextStyle(
                                      color: SteamColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: provider.levelProgress,
                                  minHeight: 5,
                                  backgroundColor: Colors.black38,
                                  valueColor: AlwaysStoppedAnimation<Color>(provider.rankColor),
                                ),
                              ),
                              if (provider.justEarnedChest) ...[
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    MysteryChestDialog.show(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.amberAccent, width: 0.8),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('🎡 ', style: TextStyle(fontSize: 12)),
                                        Flexible(
                                          child: Text(
                                            '+1 Şans Çarkı Hakkı Kazandın! (Çevir)',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Skor ve İstatistikler
                Consumer<GameProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Tur Skoru', '${widget.score}'),
                        _buildStatItem('🏆 Rekor', '${provider.highScore}'),
                        _buildStatItem(
                          isWon ? 'Tahmin' : 'Hak',
                          isWon ? '${widget.attemptsUsed}. Hak 🎯' : '${widget.attemptsUsed}/5',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 📋 Paylaş Butonu
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ShareCardModal.show(
                            context,
                            isTowerVictory: false,
                            gameName: widget.gameName,
                            attemptsUsed: widget.attemptsUsed,
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 15, color: SteamColors.steamCyan),
                        label: const Text(
                          'Skor Kartını Gör & Paylaş 📋',
                          style: TextStyle(color: SteamColors.steamCyan, fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: SteamColors.steamCyan.withValues(alpha: 0.6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 1. Aksiyon Butonu: Doğrudan Yeni Tur / Sonraki Oyun
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isWon
                          ? SteamColors.greenActionGradient
                          : SteamColors.steamButtonGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onNextRound();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isWon ? 'SONRAKİ TUR' : 'YENİ OYUNA BAŞLA',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 2. Aksiyon Butonu: Tüm İncelemeleri Oku & İncele
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.visibility_rounded, size: 16, color: SteamColors.steamCyan),
                    label: const Text(
                      'Tüm İncelemeleri Oku & İncele',
                      style: TextStyle(
                        color: SteamColors.steamCyan,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

        // 🎉 Konfeti Efekti
        if (isWon)
          Positioned(
            top: 40,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              gravity: 0.3,
              emissionFrequency: 0.05,
              colors: const [
                Colors.amberAccent,
                SteamColors.steamCyan,
                SteamColors.steamBlue,
                Colors.greenAccent,
                Colors.orangeAccent,
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: SteamColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: SteamColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
