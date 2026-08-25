import 'dart:math' as math;
import 'package:flutter/material.dart';

/// PlayStation 5 DualSense İlhamlı, Ultra-Sade ve Profesyonel Vektörel Oyun Tahmin Logosu
class AppLogoWidget extends StatelessWidget {
  final double size;
  final bool showGlow;

  const AppLogoWidget({
    super.key,
    this.size = 80,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF070B12),
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
          width: math.max(1.0, size * 0.015),
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                  blurRadius: size * 0.3,
                  spreadRadius: size * 0.01,
                ),
              ]
            : null,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.74, size * 0.74),
          painter: _DualSenseGuessLogoPainter(),
        ),
      ),
    );
  }
}

class _DualSenseGuessLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeWidth = math.max(1.6, w * 0.042);

    const cyanColor = Color(0xFF00E5FF);
    const whiteColor = Color(0xFFE2E8F0);
    const goldColor = Color(0xFFFFD54F);

    // Neon Glow Katmanı (Buz Mavisi)
    final glowPaint = Paint()
      ..color = cyanColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 1.5);

    // DualSense Ana Gövde Çizgisi (Platin Beyaz)
    final bodyPaint = Paint()
      ..color = whiteColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // DualSense Lightbar / İç Vurgu (Neon Cyan)
    final cyanPaint = Paint()
      ..color = cyanColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.95
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Soru İşareti (Tahmin) Vurgu Çizgisi (Neon Altın)
    final questionPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final questionGlowPaint = Paint()
      ..color = goldColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.4
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 1.6);

    // ==========================================
    // 1. DUALSENSE DIŞ KAVİS GÖVDESİ (Ergonomic DualSense Silhouette)
    // ==========================================
    final bodyPath = Path();
    final topY = h * 0.28;
    final bottomY = h * 0.88;

    // Üst tepe merkezi
    bodyPath.moveTo(w * 0.36, topY);
    bodyPath.quadraticBezierTo(w * 0.50, topY * 0.88, w * 0.64, topY);

    // Sağ omuz (R1/R2 alanı)
    bodyPath.quadraticBezierTo(w * 0.84, topY * 0.95, w * 0.92, topY * 1.45);
    // Sağ tutacak (DualSense dış eğri)
    bodyPath.quadraticBezierTo(w * 1.02, h * 0.66, w * 0.82, bottomY);
    // Sağ tutacak altı
    bodyPath.quadraticBezierTo(w * 0.74, bottomY * 1.04, w * 0.66, bottomY * 0.92);
    // Sağ iç köprü (Analog altı)
    bodyPath.quadraticBezierTo(w * 0.58, h * 0.72, w * 0.50, h * 0.74);
    // Sol iç köprü
    bodyPath.quadraticBezierTo(w * 0.42, h * 0.72, w * 0.34, bottomY * 0.92);
    // Sol tutacak altı
    bodyPath.quadraticBezierTo(w * 0.26, bottomY * 1.04, w * 0.18, bottomY);
    // Sol tutacak dış eğri
    bodyPath.quadraticBezierTo(-w * 0.02, h * 0.66, w * 0.08, topY * 1.45);
    // Sol omuz (L1/L2 alanı)
    bodyPath.quadraticBezierTo(w * 0.16, topY * 0.95, w * 0.36, topY);

    canvas.drawPath(bodyPath, glowPaint);
    canvas.drawPath(bodyPath, bodyPaint);

    // ==========================================
    // 2. DUALSENSE TOUCHPAD (Dokunmatik Panel Çerçevesi)
    // ==========================================
    final touchPadPath = Path();
    touchPadPath.moveTo(w * 0.37, topY * 1.15);
    touchPadPath.lineTo(w * 0.63, topY * 1.15);
    touchPadPath.quadraticBezierTo(w * 0.62, h * 0.56, w * 0.58, h * 0.58);
    touchPadPath.lineTo(w * 0.42, h * 0.58);
    touchPadPath.quadraticBezierTo(w * 0.38, h * 0.56, w * 0.37, topY * 1.15);

    final touchPadPaint = Paint()
      ..color = cyanColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.75;
    canvas.drawPath(touchPadPath, touchPadPaint);

    // ==========================================
    // 3. PLAYSTATION DUALSENSE SİMETRİK ANALOG STICKLER
    // (PlayStation'a özgü alt orta paralel konum)
    // ==========================================
    final analogRadius = w * 0.082;
    final leftAnalogCenter = Offset(w * 0.37, h * 0.65);
    final rightAnalogCenter = Offset(w * 0.63, h * 0.65);

    // Sol Analog
    canvas.drawCircle(leftAnalogCenter, analogRadius, cyanPaint);
    canvas.drawCircle(leftAnalogCenter, analogRadius * 0.3, Paint()..color = cyanColor..style = PaintingStyle.fill);

    // Sağ Analog
    canvas.drawCircle(rightAnalogCenter, analogRadius, cyanPaint);
    canvas.drawCircle(rightAnalogCenter, analogRadius * 0.3, Paint()..color = cyanColor..style = PaintingStyle.fill);

    // ==========================================
    // 4. SOL D-PAD (PlayStation Yön Butonları)
    // ==========================================
    final dpadCenter = Offset(w * 0.24, h * 0.46);
    final dpadLen = w * 0.065;
    canvas.drawLine(
      Offset(dpadCenter.dx - dpadLen, dpadCenter.dy),
      Offset(dpadCenter.dx + dpadLen, dpadCenter.dy),
      cyanPaint,
    );
    canvas.drawLine(
      Offset(dpadCenter.dx, dpadCenter.dy - dpadLen),
      Offset(dpadCenter.dx, dpadCenter.dy + dpadLen),
      cyanPaint,
    );

    // ==========================================
    // 5. SAĞ PLAYSTATION GEOMETRİK BUTONLARI (△ ○ ✕ □)
    // ==========================================
    final btnCenter = Offset(w * 0.76, h * 0.46);
    final btnGap = w * 0.065;
    final dotR = math.max(1.2, w * 0.016);
    final psDotPaint = Paint()..color = cyanColor..style = PaintingStyle.fill;

    // Üçgen (Üst)
    canvas.drawCircle(Offset(btnCenter.dx, btnCenter.dy - btnGap), dotR, psDotPaint);
    // Daire (Sağ)
    canvas.drawCircle(Offset(btnCenter.dx + btnGap, btnCenter.dy), dotR, psDotPaint);
    // Çarpı (Alt)
    canvas.drawCircle(Offset(btnCenter.dx, btnCenter.dy + btnGap), dotR, psDotPaint);
    // Kare (Sol)
    canvas.drawCircle(Offset(btnCenter.dx - btnGap, btnCenter.dy), dotR, psDotPaint);

    // ==========================================
    // 6. TOUCHPAD MERKEZİNDE ZARİF TAHMİN SORU İŞARETİ (?)
    // ==========================================
    final qPath = Path();
    final qX = w * 0.50;
    final qY = h * 0.32;

    // Soru işareti başı
    qPath.moveTo(qX - w * 0.055, qY + h * 0.03);
    qPath.cubicTo(
      qX - w * 0.055, qY - h * 0.018,
      qX + w * 0.065, qY - h * 0.018,
      qX + w * 0.065, qY + h * 0.04,
    );
    qPath.quadraticBezierTo(
      qX + w * 0.065, qY + h * 0.09,
      qX, qY + h * 0.12,
    );
    qPath.lineTo(qX, qY + h * 0.165);

    // Soru işareti çizimi
    canvas.drawPath(qPath, questionGlowPaint);
    canvas.drawPath(qPath, questionPaint);

    // Soru işareti alt noktası
    final dotCenter = Offset(qX, qY + h * 0.22);
    final qDotR = math.max(1.4, w * 0.02);
    canvas.drawCircle(
      dotCenter,
      qDotR * 1.6,
      Paint()
        ..color = goldColor.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 1.5),
    );
    canvas.drawCircle(dotCenter, qDotR, Paint()..color = goldColor..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
