import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/player_progression.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';

class MysteryChestDialog extends StatefulWidget {
  const MysteryChestDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const MysteryChestDialog(),
    );
  }

  @override
  State<MysteryChestDialog> createState() => _MysteryChestDialogState();
}

class _MysteryChestDialogState extends State<MysteryChestDialog>
    with TickerProviderStateMixin {
  late AnimationController _wheelController;
  late Animation<double> _wheelAnimation;

  late AnimationController _rewardPopupController;
  late Animation<double> _rewardPopupScale;

  double _currentRotation = 0.0;
  double _targetRotation = 0.0;
  bool _isSpinning = false;
  ChestReward? _wonReward;

  @override
  void initState() {
    super.initState();
    // ⚡ 1.4 Saniyelik Ultra Hızlı & Akıcı Dönüş Animasyonu
    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _wheelAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _wheelController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _rewardPopupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _rewardPopupScale = CurvedAnimation(
      parent: _rewardPopupController,
      curve: Curves.elasticOut,
    );

    _wheelController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isSpinning = false;
          _currentRotation = _targetRotation % (2 * pi);
        });
        _rewardPopupController.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _wheelController.dispose();
    _rewardPopupController.dispose();
    super.dispose();
  }

  void _spinWheel(GameProvider provider) {
    if (_isSpinning || provider.unopenedChests <= 0) return;

    HapticFeedback.mediumImpact();
    _rewardPopupController.reset();

    // 1. Ödülü ve kazanan dilimi belirle
    final rand = Random().nextInt(100);
    int targetIndex;
    if (rand < 25) {
      targetIndex = 0; // 50 Altın
    } else if (rand < 45) {
      targetIndex = 1; // 2 Elmas
    } else if (rand < 65) {
      targetIndex = 2; // 100 Altın
    } else if (rand < 80) {
      targetIndex = 3; // 4 Elmas
    } else if (rand < 90) {
      targetIndex = 4; // 150 Altın
    } else if (rand < 95) {
      targetIndex = 5; // 6 Elmas
    } else if (rand < 98) {
      targetIndex = 6; // +1 Sandık
    } else {
      targetIndex = 7; // BÜYÜK İKRAMİYE
    }

    final reward = provider.spinMysteryWheel(targetIndex);
    if (reward == null) return;

    // 2. Çark Açısı Matematiği:
    // İbre tepede: 270 derece (3 * pi / 2)
    // Dilim i merkezi: i * sliceAngle + sliceAngle / 2
    const sliceCount = 8;
    const sliceAngle = 2 * pi / sliceCount;
    final sliceCenter = targetIndex * sliceAngle + (sliceAngle / 2);

    final currentNormalized = _currentRotation % (2 * pi);
    double targetMod = (3 * pi / 2 - sliceCenter) % (2 * pi);
    if (targetMod < 0) targetMod += 2 * pi;

    double diff = targetMod - currentNormalized;
    if (diff <= 0) diff += 2 * pi;

    // 4 tam tur + hedef fark açısı
    const extraSpins = 4 * 2 * pi;
    _targetRotation = _currentRotation + extraSpins + diff;

    setState(() {
      _isSpinning = true;
      _wonReward = reward;
    });

    _wheelAnimation = Tween<double>(
      begin: _currentRotation,
      end: _targetRotation,
    ).animate(CurvedAnimation(
      parent: _wheelController,
      curve: Curves.fastOutSlowIn,
    ));

    _wheelController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final chestsLeft = provider.unopenedChests;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1620),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.amberAccent.withValues(alpha: 0.7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.25),
              blurRadius: 28,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık & Sandık Sayısı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('🎡 ', style: TextStyle(fontSize: 22)),
                    Text(
                      'ŞANS ÇARKI',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: SteamColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Text('🎡', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        '$chestsLeft Çevirme',
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Çark Alanı (Stack ile GPU RepaintBoundary)
            SizedBox(
              width: 270,
              height: 270,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dönen Çark (RepaintBoundary ile GPU dokusu üzerinden süper akıcı dönüş)
                  AnimatedBuilder(
                    animation: _wheelAnimation,
                    builder: (context, _) {
                      return Transform.rotate(
                        angle: _isSpinning ? _wheelAnimation.value : _currentRotation,
                        child: const RepaintBoundary(
                          child: CustomPaint(
                            size: Size(260, 260),
                            painter: _LuckyWheelPainter(),
                          ),
                        ),
                      );
                    },
                  ),

                  // Merkez Göbeği (Tıklanabilir Çevir Butonu)
                  GestureDetector(
                    onTap: () => _spinWheel(provider),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF141E2D),
                        border: Border.all(
                          color: Colors.amberAccent,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amberAccent.withValues(alpha: 0.6),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _isSpinning ? '⚡' : 'ÇEVİR',
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tepedeki İbre (Pointer)
                  const Positioned(
                    top: 0,
                    child: CustomPaint(
                      size: Size(24, 22),
                      painter: _WheelPointerPainter(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Kazanç Alanı (Göz Alıcı Popover Efekti)
            if (_wonReward != null && !_isSpinning)
              ScaleTransition(
                scale: _rewardPopupScale,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A2006), Color(0xFF1B2838)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amberAccent, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🎉 KAZANDINIZ! 🎉',
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_wonReward!.iconEmoji} ${_wonReward!.rewardTitle}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Alt Butonlar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_isSpinning || chestsLeft <= 0) ? null : () => _spinWheel(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.white12,
                      disabledForegroundColor: Colors.white38,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _isSpinning
                          ? 'Çark Dönüyor...'
                          : chestsLeft > 0
                              ? '🎡 Çarkı Çevir ($chestsLeft Kalan)'
                              : 'Çevirme Hakkı Kalmadı',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSpinning ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  tooltip: 'Kapat',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 8 Dilimli Şans Çarkı Çizimi
class _LuckyWheelPainter extends CustomPainter {
  const _LuckyWheelPainter();

  static const sliceCount = 8;
  static const sliceAngle = 2 * pi / sliceCount;

  static const List<Map<String, dynamic>> sliceData = [
    {'title': '50 🪙', 'color1': Color(0xFFF57F17), 'color2': Color(0xFFFFB300)},
    {'title': '2 💎', 'color1': Color(0xFF00838F), 'color2': Color(0xFF00E5FF)},
    {'title': '100 🪙', 'color1': Color(0xFFFF8F00), 'color2': Color(0xFFFFD54F)},
    {'title': '4 💎', 'color1': Color(0xFF1565C0), 'color2': Color(0xFF40C4FF)},
    {'title': '150 🪙', 'color1': Color(0xFFE65100), 'color2': Color(0xFFFFAB40)},
    {'title': '6 💎', 'color1': Color(0xFF00B0FF), 'color2': Color(0xFF80D8FF)},
    {'title': '+1 🎡', 'color1': Color(0xFF2E7D32), 'color2': Color(0xFF69F0AE)},
    {'title': '👑 MEGA', 'color1': Color(0xFF6A1B9A), 'color2': Color(0xFFFFD700)},
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final outerPaint = Paint()
      ..color = const Color(0xFF1A2634)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, outerPaint);

    final rect = Rect.fromCircle(center: center, radius: radius - 6);

    for (int i = 0; i < sliceCount; i++) {
      final startAngle = i * sliceAngle;
      final data = sliceData[i];

      final slicePaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: startAngle,
          endAngle: startAngle + sliceAngle,
          colors: [data['color1'] as Color, data['color2'] as Color],
        ).createShader(rect);

      canvas.drawArc(rect, startAngle, sliceAngle, true, slicePaint);

      // Dilim Ayırıcı Çizgi
      final linePaint = Paint()
        ..color = Colors.black45
        ..strokeWidth = 1.5;
      final lineX = center.dx + (radius - 6) * cos(startAngle);
      final lineY = center.dy + (radius - 6) * sin(startAngle);
      canvas.drawLine(center, Offset(lineX, lineY), linePaint);

      // Dilim Metni (Okunabilir, radyal yönde düzgün yerleşim)
      canvas.save();
      final textAngle = startAngle + (sliceAngle / 2);
      canvas.translate(center.dx, center.dy);
      canvas.rotate(textAngle);

      final textSpan = TextSpan(
        text: data['title'] as String,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(radius * 0.52 - textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Dış Altın Çerçeve
    final borderPaint = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius - 4, borderPaint);

    // Çerçeve Üzerindeki Küçük LED Noktaları
    final ledPaint = Paint()..color = Colors.white;
    for (int i = 0; i < sliceCount * 2; i++) {
      final ledAngle = i * (2 * pi / (sliceCount * 2));
      final ledX = center.dx + (radius - 4) * cos(ledAngle);
      final ledY = center.dy + (radius - 4) * sin(ledAngle);
      canvas.drawCircle(Offset(ledX, ledY), 2.2, ledPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Tepedeki İbre Çizici
class _WheelPointerPainter extends CustomPainter {
  const _WheelPointerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF1744)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..moveTo(size.width / 2, size.height) // alt uç
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
