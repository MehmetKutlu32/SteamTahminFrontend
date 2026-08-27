import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/roguelike_models.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';
import '../../widgets/inputs/game_autocomplete_input.dart';

class TimeAttackScreen extends StatefulWidget {
  const TimeAttackScreen({super.key});

  @override
  State<TimeAttackScreen> createState() => _TimeAttackScreenState();
}

class _TimeAttackScreenState extends State<TimeAttackScreen> {
  Timer? _timer;
  int _secondsLeft = 60;
  int _scoreGuessed = 0;
  int _combo = 0;
  int _currentReviewIndex = 0;
  bool _isGameOver = false;

  String? _feedbackMessage;
  Color _feedbackColor = Colors.greenAccent;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<GameProvider>();
      provider.setGameMode(GameMode.timeAttack);
      if (provider.gamesList.isEmpty) {
        await provider.initializeGame();
      } else if (provider.currentRound == null) {
        await provider.startNewRound();
      }
      _startNewTimeAttack();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _showFeedback(String message, Color color) {
    _feedbackTimer?.cancel();
    setState(() {
      _feedbackMessage = message;
      _feedbackColor = color;
    });
    _feedbackTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        setState(() {
          _feedbackMessage = null;
        });
      }
    });
  }

  void _startNewTimeAttack() {
    final provider = context.read<GameProvider>();
    provider.setGameMode(GameMode.timeAttack);
    setState(() {
      _secondsLeft = 60;
      _scoreGuessed = 0;
      _combo = 0;
      _currentReviewIndex = 0;
      _isGameOver = false;
      _feedbackMessage = null;
    });

    if (provider.currentRound == null) {
      provider.startNewRound();
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        _onTimeUp(provider);
      } else {
        setState(() {
          _secondsLeft -= 1;
        });
      }
    });
  }

  void _onTimeUp(GameProvider provider) {
    HapticFeedback.heavyImpact();
    setState(() {
      _secondsLeft = 0;
      _isGameOver = true;
      _feedbackMessage = null;
    });
    provider.recordTimeAttackResult(_scoreGuessed);
  }

  void _submitGuess(GameProvider provider, String guess) {
    if (guess.trim().isEmpty || _isGameOver) return;

    final isCorrect = provider.submitGuess(guess);

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      final bonusSeconds = _combo >= 1 ? 10 : 5; // 5 ya da 10 saniye bonus
      setState(() {
        _scoreGuessed += 1;
        _combo += 1;
        _currentReviewIndex = 0;
        _secondsLeft = (_secondsLeft + bonusSeconds).clamp(0, 99);
      });

      _showFeedback(
        '🎉 DOĞRU TAHMİN! (+$bonusSeconds s) ${_combo > 1 ? "🔥 $_combo x Kombo!" : ""}',
        Colors.greenAccent,
      );

      provider.startNewRound();
    } else {
      HapticFeedback.mediumImpact();
      setState(() {
        _combo = 0;
      });
      _showFeedback('❌ YANLIŞ TAHMİN!', Colors.redAccent);
    }
  }

  /// 💬 Yorumu Geç (Sıradaki İpucu): -2 saniye süre cezası
  void _skipReview(GameProvider provider) {
    if (_isGameOver || provider.isLoadingRound) return;
    final reviews = provider.reviews;
    if (_currentReviewIndex < reviews.length - 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentReviewIndex += 1;
        _secondsLeft = (_secondsLeft - 2).clamp(1, 99);
      });
      _showFeedback('💬 Yeni Yorum Açıldı (-2s)', Colors.amberAccent);
    } else {
      HapticFeedback.selectionClick();
      _showFeedback('⚠️ Bu oyunun tüm yorumları açık! Oyunu atlayabilirsiniz.', Colors.orangeAccent);
    }
  }

  /// ⏩ Oyunu Atla (Yeni Oyun): -5 saniye süre cezası
  void _skipGame(GameProvider provider) {
    if (_isGameOver || provider.isLoadingRound) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _combo = 0;
      _currentReviewIndex = 0;
      _secondsLeft = (_secondsLeft - 5).clamp(1, 99);
    });
    _showFeedback('⏩ Oyun Atlandı (-5s)! Sıradaki Oyun...', Colors.redAccent);
    provider.startNewRound();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final reviews = provider.reviews;

    return Scaffold(
      backgroundColor: SteamColors.darkBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF101822),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '⚡ ZAMAN YARIŞI (60s)',
          style: TextStyle(
            color: Colors.amberAccent,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: SteamColors.cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5)),
              ),
              child: Text(
                'Rekor: ${provider.timeAttackHighScore}',
                style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: _isGameOver
          ? _buildGameOverScreen(provider)
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    // Süre & Skor & Kombo Başlığı
                    Row(
                      children: [
                        // Kalan Süre
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _secondsLeft <= 10
                                ? Colors.red.withValues(alpha: 0.25)
                                : const Color(0xFF1B2838),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _secondsLeft <= 10 ? Colors.redAccent : SteamColors.steamCyan,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_rounded,
                                color: _secondsLeft <= 10 ? Colors.redAccent : SteamColors.steamCyan,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$_secondsLeft s',
                                style: TextStyle(
                                  color: _secondsLeft <= 10 ? Colors.redAccent : SteamColors.steamCyan,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Bildiğin Oyun Sayısı
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amberAccent),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🎯 ', style: TextStyle(fontSize: 14)),
                                Text(
                                  '$_scoreGuessed Oyun',
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Kombo Çarpanı
                        if (_combo > 1) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orangeAccent),
                            ),
                            child: Text(
                              '🔥 $_combo x',
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // İkili Pas / Atla Butonları
                    Row(
                      children: [
                        // 1. Buton: Yorumu Geç / Sıradaki İpucu (-2s)
                        Expanded(
                          child: InkWell(
                            onTap: () => _skipReview(provider),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B2838),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: SteamColors.steamCyan.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.speaker_notes_rounded, size: 15, color: SteamColors.steamCyan),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Yorumu Geç',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6)),
                                    ),
                                    child: const Text(
                                      '-2s',
                                      style: TextStyle(color: Colors.amberAccent, fontSize: 10.5, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 2. Buton: Oyunu Atla (-5s)
                        Expanded(
                          child: InkWell(
                            onTap: () => _skipGame(provider),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.skip_next_rounded, size: 17, color: Colors.redAccent),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Oyunu Atla',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.redAccent),
                                    ),
                                    child: const Text(
                                      '-5s',
                                      style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Canlı Geri Bildirim Banner'ı (Doğru / Yanlış / Pas Bildirimi)
                    if (_feedbackMessage != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _feedbackColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _feedbackColor, width: 1.5),
                        ),
                        child: Text(
                          _feedbackMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _feedbackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                    // İnceleme Kartı
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: SteamColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '💬 İpucu (${_currentReviewIndex + 1}/${reviews.isNotEmpty ? reviews.length : 1})',
                                  style: const TextStyle(
                                    color: SteamColors.steamCyan,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (reviews.isNotEmpty && _currentReviewIndex < reviews.length)
                                  Text(
                                    '⏳ ${reviews[_currentReviewIndex].oynamaSuresiSaati} Saat',
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  reviews.isNotEmpty && _currentReviewIndex < reviews.length
                                      ? reviews[_currentReviewIndex].yorum
                                      : (provider.isLoadingRound ? 'İnceleme yükleniyor...' : 'Açılacak inceleme bekleniyor...'),
                                  style: const TextStyle(
                                    color: SteamColors.textPrimary,
                                    fontSize: 15,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Otomatik Tamamlamalı Oyun Arama Popup Çubuğu (GameGuessInput)
                    GameGuessInput(
                      games: provider.gamesList,
                      isEnabled: !_isGameOver && !provider.isLoadingRound,
                      onSubmitted: (guess) => _submitGuess(provider, guess),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGameOverScreen(GameProvider provider) {
    final isNewRecord = _scoreGuessed >= provider.timeAttackHighScore && _scoreGuessed > 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF101924),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isNewRecord ? Colors.amberAccent : Colors.white12,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isNewRecord ? Colors.amber.withValues(alpha: 0.25) : Colors.black45,
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isNewRecord ? '👑 YENİ REKOR! 👑' : '⏱️ SÜRE DOLDU!',
                style: TextStyle(
                  color: isNewRecord ? Colors.amberAccent : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '60 Saniyede Toplam $_scoreGuessed Oyun Bildiniz!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: SteamColors.textSecondary, fontSize: 13.5),
              ),

              // Bilemediğiniz Son Oyun
              if (provider.currentRound != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SteamColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🔍 Süre Bittiğinde Çıkan Oyun:',
                        style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.currentRound!.oyunAdi,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: SteamColors.steamCyan, fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/${provider.currentRound!.appId}/header.jpg',
                          height: 85,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _startNewTimeAttack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Tekrar Yarış ⚡', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Menüye Dön'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
