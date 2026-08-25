import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/steam_theme.dart';
import '../../../widgets/dialogs/duel_invite_modal.dart';

class DuelWaitingRoomWidget extends StatelessWidget {
  final String? roomCode;
  final VoidCallback onCancel;

  const DuelWaitingRoomWidget({
    super.key,
    required this.roomCode,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.amberAccent),
            const SizedBox(height: 24),
            const Text(
              'Rakip Bekleniyor...',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Arkadaşına aşağıdaki oda kodunu göndererek maça çağır:',
              style: TextStyle(color: Colors.white60, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // ODA KODU KARTI
            InkWell(
              onTap: () {
                if (roomCode != null) {
                  Clipboard.setData(ClipboardData(text: roomCode!));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📋 Oda kodu panoya kopyalandı!')),
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: SteamColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amberAccent, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withValues(alpha: 0.25),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      roomCode ?? '',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.5,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.content_copy_rounded, color: Colors.amberAccent, size: 15),
                          SizedBox(width: 4),
                          Text(
                            'KOPYALA',
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🌟 DAVET KARTINI & AFİŞİ PAYLAŞ BUTONU
            if (roomCode != null)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 320),
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    DuelInviteModal.show(context, roomCode: roomCode!);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share_rounded, color: Colors.black, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'KODU & DAVET AFİŞİNİ PAYLAŞ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // İptal Butonu
            TextButton(
              onPressed: onCancel,
              child: const Text('İptal Et & Lobiye Dön', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
