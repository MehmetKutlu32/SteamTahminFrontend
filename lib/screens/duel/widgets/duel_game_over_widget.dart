import 'package:flutter/material.dart';

class DuelGameOverWidget extends StatelessWidget {
  final String? gameOverMessage;
  final VoidCallback onReturnToMenu;

  const DuelGameOverWidget({
    super.key,
    required this.gameOverMessage,
    required this.onReturnToMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            const Text(
              'OYUN BİTTİ',
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              gameOverMessage ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onReturnToMenu,
              child: const Text(
                'ANA MENÜYE DÖN',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
