import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/steam_theme.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.amberAccent),
            const SizedBox(height: 28),
            const Text(
              'Rakip Bekleniyor...',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Arkadaşına aşağıdaki oda kodunu gönder:',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // ODA KODU KARTI
            GestureDetector(
              onTap: () {
                if (roomCode != null) {
                  Clipboard.setData(ClipboardData(text: roomCode!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📋 Oda kodu panoya kopyalandı!')),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: SteamColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amberAccent, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      roomCode ?? '',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.copy, color: Colors.amberAccent, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: onCancel,
              child: const Text('İptal Et & Geri Dön', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }
}
