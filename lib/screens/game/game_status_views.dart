import 'package:flutter/material.dart';
import '../../theme/steam_theme.dart';

class GameLoadingView extends StatelessWidget {
  const GameLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(SteamColors.steamBlue),
          ),
          SizedBox(height: 16),
          Text(
            'Oyuncu İncelemeleri Yükleniyor...',
            style: TextStyle(color: SteamColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class GameErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const GameErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: SteamColors.negativeReview,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: SteamColors.textPrimary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SteamColors.steamBlue,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
