import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../services/auth_service.dart';
import '../branding/app_logo_widget.dart';

class DuelInviteModal extends StatefulWidget {
  final String roomCode;

  const DuelInviteModal({
    super.key,
    required this.roomCode,
  });

  static Future<void> show(BuildContext context, {required String roomCode}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DuelInviteModal(roomCode: roomCode),
    );
  }

  @override
  State<DuelInviteModal> createState() => _DuelInviteModalState();
}

class _DuelInviteModalState extends State<DuelInviteModal> {
  final GlobalKey _inviteCardKey = GlobalKey();
  bool _isCopied = false;
  bool _isSaved = false;

  String _getInviteText(String hostName) {
    return '⚔️ $hostName seni Steam Tahmin 1v1 Düellosuna davet ediyor!\n\n'
        '📲 Oyunu İndir (APK):\n'
        '👉 https://github.com/MehmetKutlu32/SteamTahminFrontend/releases\n\n'
        '🔑 ODA KODU: ${widget.roomCode}\n'
        '1. Oyunu aç ve "1v1 Düello" sekmesine geç.\n'
        '2. "Online 1v1 Düello" seçeneğine bas ve "${widget.roomCode}" kodunu gir.\n'
        '3. Steam incelemelerinden oyunu ilk tahmin eden maçı kazansın!';
  }

  Future<void> _shareInvite(String hostName) async {
    final text = _getInviteText(hostName);
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    setState(() => _isCopied = true);

    try {
      const channel = MethodChannel('com.example.steam_tahmin_frontend/gallery');
      await channel.invokeMethod('shareText', {
        'text': text,
        'subject': '1v1 Steam Tahmin Düello Daveti',
      });
    } catch (e) {
      debugPrint('Native share failed: $e');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1B2838),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.amberAccent, width: 1.2),
        ),
        content: const Row(
          children: [
            Text('📋 ', style: TextStyle(fontSize: 18)),
            Expanded(
              child: Text(
                'Davet Linki Kopyalandı ve Paylaşım Ekranı Açıldı!',
                style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveInviteCardImage() async {
    HapticFeedback.heavyImpact();

    try {
      final boundary = _inviteCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _showSaveResult(false);
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showSaveResult(false);
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final title = 'duello_davet_${widget.roomCode}_${DateTime.now().millisecondsSinceEpoch}';

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
        setState(() => _isSaved = true);
        _showSaveResult(true);
      } else {
        _showSaveResult(false);
      }
    } catch (e) {
      debugPrint('Invite card save error: $e');
      if (mounted) _showSaveResult(false);
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
          side: BorderSide(color: success ? Colors.amberAccent : Colors.redAccent, width: 1),
        ),
        content: Row(
          children: [
            Text(success ? '📸 ' : '⚠️ ', style: const TextStyle(fontSize: 16)),
            Expanded(
              child: Text(
                success
                    ? 'Davet Afişi Galeriye Kaydedildi! WhatsApp/Instagram\'da Paylaşabilirsin!'
                    : 'Görsel kaydedilemedi, depolama izinlerini kontrol edin.',
                style: TextStyle(
                  color: success ? Colors.amberAccent : Colors.redAccent,
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
    final authService = context.watch<AuthService>();
    final gameProvider = context.watch<GameProvider>();
    final hostName = authService.currentUser?.displayName ?? 'Oyuncu';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF101824),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.amberAccent, width: 1.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sürükleme Çubuğu
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Başlık
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('⚔️ ', style: TextStyle(fontSize: 20)),
                Text(
                  '1v1 DÜELLOYA DAVET ET',
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Afişi veya davet linkini arkadaşına gönderip anında kapışın!',
              style: TextStyle(color: Colors.white60, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 📸 PAYLAŞILABİLİR GÖRSEL AFİŞ KARTI (RepaintBoundary)
            RepaintBoundary(
              key: _inviteCardKey,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF281C08), Color(0xFF121B28), Color(0xFF0D141E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.8), width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Üst Başlık & Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppLogoWidget(size: 32),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STEAM TAHMİN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              '1v1 CANLI ÇOK OYUNCULU DÜELLO',
                              style: TextStyle(
                                color: Colors.amberAccent.withValues(alpha: 0.9),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 22),

                    // Davet Eden Oyuncu
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('👑 ', style: TextStyle(fontSize: 14)),
                          Text(
                            hostName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Lv.${gameProvider.level}',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'seni maça çağırdı!',
                            style: TextStyle(color: Colors.white70, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Parlayan ODA KODU Kutusu
                    const Text(
                      '🔑 KATILIM ODA KODU',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF182332),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.amberAccent, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.roomCode,
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Açıklama Notu
                    const Text(
                      '🎮 Steam yorumlarından oyunu ilk tahmin eden maçı kazanır!',
                      style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🎯 EYLEM BUTONLARI
            // 1. Davet Metnini & Linkini Kopyala
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _shareInvite(hostName),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isCopied ? Icons.check_circle_rounded : Icons.share_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isCopied ? 'KOD PAYLAŞILDI & KOPYALANDI!' : 'DAVET LİNKİNİ & KODU PAYLAŞ',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 2. Afiş Görselini Kaydet
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _isSaved ? Colors.greenAccent : Colors.white24, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveInviteCardImage,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isSaved ? Icons.check_rounded : Icons.photo_camera_rounded,
                        color: _isSaved ? Colors.greenAccent : Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _isSaved ? 'AFİŞ GALERİYE KAYDEDİLDİ 📸' : 'DAVET AFİŞİNİ FOTOĞRAF OLARAK KAYDET',
                      style: TextStyle(
                        color: _isSaved ? Colors.greenAccent : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Kapat
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Odaya Dön & Rakibi Bekle', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
