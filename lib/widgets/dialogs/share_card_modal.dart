import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';

class ShareCardModal extends StatefulWidget {
  final bool isTowerVictory;
  final String? gameName;
  final int? attemptsUsed;

  const ShareCardModal({
    super.key,
    this.isTowerVictory = false,
    this.gameName,
    this.attemptsUsed,
  });

  static Future<void> show(
    BuildContext context, {
    bool isTowerVictory = false,
    String? gameName,
    int? attemptsUsed,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareCardModal(
        isTowerVictory: isTowerVictory,
        gameName: gameName,
        attemptsUsed: attemptsUsed,
      ),
    );
  }

  @override
  State<ShareCardModal> createState() => _ShareCardModalState();
}

class _ShareCardModalState extends State<ShareCardModal> {
  final GlobalKey _cardBoundaryKey = GlobalKey();
  bool _isCopied = false;
  bool _isSaved = false;

  void _copyShareText(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    setState(() {
      _isCopied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1B2838),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: SteamColors.steamCyan, width: 1),
        ),
        content: const Row(
          children: [
            Text('📋 ', style: TextStyle(fontSize: 16)),
            Expanded(
              child: Text(
                'Skor Kartı Metni Panoya Kopyalandı!',
                style: TextStyle(color: Colors.white, fontSize: 12.5),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveCard() async {
    HapticFeedback.heavyImpact();

    try {
      final boundary = _cardBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) _showSaveResult(false);
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (mounted) _showSaveResult(false);
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final title = 'oyun_tahmin_${DateTime.now().millisecondsSinceEpoch}';

      bool saved = false;
      try {
        const channel = MethodChannel('com.example.steam_tahmin_frontend/gallery');
        final result = await channel.invokeMethod<bool>('saveImageToGallery', {
          'imageBytes': pngBytes,
          'title': title,
        });
        saved = result == true;
      } catch (e) {
        debugPrint('MethodChannel save failed, using file fallback: $e');
      }

      if (!saved) {
        final List<String> candidatePaths = [
          '/storage/emulated/0/Pictures/OyunTahmin',
          '/storage/emulated/0/Pictures',
          '/storage/emulated/0/DCIM',
          '/storage/emulated/0/Download',
        ];

        for (final path in candidatePaths) {
          try {
            final dir = Directory(path);
            if (!dir.existsSync()) dir.createSync(recursive: true);
            final file = File('${dir.path}/$title.png');
            await file.writeAsBytes(pngBytes);
            saved = true;
            break;
          } catch (_) {}
        }
      }

      if (!mounted) return;

      if (saved) {
        setState(() {
          _isSaved = true;
        });
        _showSaveResult(true);
      } else {
        _showSaveResult(false);
      }
    } catch (e) {
      debugPrint('Card capture error: $e');
      if (mounted) {
        _showSaveResult(false);
      }
    }
  }

  void _showSaveResult(bool success) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? const Color(0xFF132838) : const Color(0xFF381414),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: success ? Colors.greenAccent : Colors.redAccent, width: 1),
        ),
        content: Row(
          children: [
            Text(success ? '💾 ' : '⚠️ ', style: const TextStyle(fontSize: 16)),
            Expanded(
              child: Text(
                success
                    ? 'Zafer Kartı Galeriye Kaydedildi! 📸'
                    : 'Görsel kaydedilemedi, izinleri kontrol edin.',
                style: TextStyle(
                  color: success ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final shareText = provider.generateShareSummary(isTowerVictory: widget.isTowerVictory);
    final activePerks = provider.activePerks;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: Color(0xFF121B28),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: SteamColors.steamCyan, width: 1.5),
        ),
      ),
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
          const SizedBox(height: 14),

          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.share_rounded, color: SteamColors.steamCyan, size: 20),
              const SizedBox(width: 6),
              Text(
                widget.isTowerVictory ? 'KULE ZAFER KARTI' : 'SKOR PAYLAŞIM KARTI',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🎴 Görsel Kart Önizlemesi (RepaintBoundary ile gerçek PNG olarak yakalanır)
          RepaintBoundary(
            key: _cardBoundaryKey,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A2638), Color(0xFF111923)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isTowerVictory ? Colors.amberAccent : SteamColors.steamCyan,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isTowerVictory ? Colors.amber : SteamColors.steamCyan).withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kart Üst Başlık
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.videogame_asset_rounded, color: SteamColors.steamCyan, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'OYUN TAHMİN',
                            style: TextStyle(
                              color: SteamColors.steamCyan,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${provider.rankBadge} Lv.${provider.level}',
                        style: TextStyle(
                          color: provider.rankColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Başarı Metni
                  if (widget.isTowerVictory) ...[
                    const Row(
                      children: [
                        Text('👑 ', style: TextStyle(fontSize: 22)),
                        Expanded(
                          child: Text(
                            '10/10 KULE FATİHİ',
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (activePerks.isNotEmpty) ...[
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: activePerks.map((p) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: SteamColors.cardBorder),
                            ),
                            child: Text(
                              '${p.iconEmoji} ${p.name}',
                              style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const Text(
                      'KAT İLERLEMESİ (10/10 TAMAMLANDI)',
                      style: TextStyle(
                        color: SteamColors.textMuted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(10, (index) {
                        final floorNum = index + 1;
                        final isBoss = floorNum == 10;
                        return Expanded(
                          child: Container(
                            height: 24,
                            margin: EdgeInsets.only(right: index < 9 ? 3 : 0),
                            decoration: BoxDecoration(
                              color: isBoss
                                  ? Colors.amberAccent.withValues(alpha: 0.3)
                                  : Colors.greenAccent.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: isBoss ? Colors.amberAccent : Colors.greenAccent,
                                width: 1.2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                isBoss ? '👑' : '$floorNum',
                                style: TextStyle(
                                  color: isBoss ? Colors.amberAccent : Colors.greenAccent,
                                  fontSize: isBoss ? 11 : 9.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Text(
                          provider.isRoguelike
                              ? '🏰 ${provider.lastPlayedFloor}. KAT ${provider.lastPlayedFloor == 10 ? "(BOSS)" : ""}: '
                              : '',
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            provider.isRoundWon
                                ? '🏆 ${widget.gameName ?? "Oyunu Bildi!"}'
                                : '💀 ${widget.gameName ?? "Bilinmeyen Oyun"}',
                            style: TextStyle(
                              color: provider.isRoundWon ? Colors.amberAccent : SteamColors.negativeReview,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.isRoundWon
                          ? '${widget.attemptsUsed ?? 1}. Hakta Başarıyla Tahmin Edildi! 🎯'
                          : 'Bu turda oyun bulunamadı.',
                      style: const TextStyle(color: SteamColors.textSecondary, fontSize: 12),
                    ),
                    if (provider.isRoguelike) ...[
                      const SizedBox(height: 8),
                      Text(
                        'KULE İLERLEMESİ (${provider.lastPlayedFloor}/10 KAT)',
                        style: const TextStyle(
                          color: SteamColors.textMuted,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: List.generate(10, (index) {
                          final floorNum = index + 1;
                          final isBoss = floorNum == 10;
                          final isCurrent = floorNum == provider.lastPlayedFloor;
                          final isPast = floorNum < provider.lastPlayedFloor;

                          Color color;
                          Color bg;
                          if (isPast) {
                            color = Colors.greenAccent;
                            bg = Colors.greenAccent.withValues(alpha: 0.22);
                          } else if (isCurrent) {
                            color = provider.isRoundWon ? Colors.greenAccent : SteamColors.negativeReview;
                            bg = (provider.isRoundWon ? Colors.greenAccent : SteamColors.negativeReview).withValues(alpha: 0.3);
                          } else {
                            color = SteamColors.cardBorder.withValues(alpha: 0.5);
                            bg = Colors.black26;
                          }

                          return Expanded(
                            child: Container(
                              height: 20,
                              margin: EdgeInsets.only(right: index < 9 ? 3 : 0),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: color, width: isCurrent ? 1.4 : 0.8),
                              ),
                              child: Center(
                                child: Text(
                                  isBoss ? '👑' : '$floorNum',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: isBoss ? 9.5 : 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Text(
                      'TAHMİN GEÇMİŞİ',
                      style: TextStyle(
                        color: SteamColors.textMuted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Builder(builder: (_) {
                      final attempts = widget.attemptsUsed ?? 1;
                      return Row(
                        children: List.generate(provider.maxAttempts, (i) {
                          final isUsed = i < attempts;
                          final isCorrect = provider.isRoundWon && i == attempts - 1;
                          final color = !isUsed
                              ? SteamColors.cardBorder
                              : (isCorrect ? Colors.greenAccent : Colors.redAccent);
                          final bg = !isUsed
                              ? Colors.black26
                              : (isCorrect
                                  ? Colors.greenAccent.withValues(alpha: 0.25)
                                  : Colors.redAccent.withValues(alpha: 0.2));

                          return Expanded(
                            child: Container(
                              height: 24,
                              margin: EdgeInsets.only(right: i < provider.maxAttempts - 1 ? 4 : 0),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: color, width: 1.2),
                              ),
                              child: Center(
                                child: Text(
                                  !isUsed
                                      ? '${i + 1}'
                                      : (isCorrect ? '✓' : '✗'),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ],
                  const SizedBox(height: 10),

                  // Alt Bilgi Şeridi
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('🔥 Seri: ${provider.streak}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('🏆 Skor: ${provider.score}', style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('🪙 ${provider.coins}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 2 Büyük Aksiyon Butonu: [ 💾 Galeriye Kaydet ] ve [ 📋 Metni Kopyala ]
          Row(
            children: [
              // 💾 Kaydet Butonu
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _saveCard,
                    icon: Icon(
                      _isSaved ? Icons.check_circle_rounded : Icons.save_alt_rounded,
                      color: Colors.black87,
                      size: 18,
                    ),
                    label: Text(
                      _isSaved ? 'Kaydedildi!' : 'Kartı Kaydet',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // 📋 Metni Kopyala Butonu
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _copyShareText(context, shareText),
                    icon: Icon(
                      _isCopied ? Icons.check_circle_rounded : Icons.copy_all_rounded,
                      color: Colors.black87,
                      size: 18,
                    ),
                    label: Text(
                      _isCopied ? 'Kopyalandı!' : 'Metni Kopyala',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SteamColors.steamCyan,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Kapat Butonu
          SizedBox(
            width: double.infinity,
            height: 38,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat', style: TextStyle(color: SteamColors.textMuted, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
