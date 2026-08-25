import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/steam_theme.dart';

class LocalDuelSettingsModal {
  static void show({
    required BuildContext context,
    required TextEditingController p1Controller,
    required TextEditingController p2Controller,
    required int initialTargetScore,
    int initialTurnTimeLimit = 30,
    required bool isFirstLaunch,
    required Function(String p1, String p2, int target, int turnTimeLimit) onStartMatch,
  }) {
    int selectedTarget = initialTargetScore;
    int selectedTimeLimit = initialTurnTimeLimit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131A26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Colors.orangeAccent, width: 1.2),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🥊 ', style: TextStyle(fontSize: 22)),
                          const Text(
                            '1v1 DÜELLO AYARLARI',
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Spacer(),
                          if (!isFirstLaunch)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white70),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                        ],
                      ),
                      const Divider(color: Colors.white12, height: 16),

                      // Oyuncu 1 İsim Girişi
                      const Text(
                        '🔵 1. Oyuncu Adı:',
                        style: TextStyle(color: Colors.cyanAccent, fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: p1Controller,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _inputDecoration('Örn: Ahmet', Colors.cyanAccent),
                      ),
                      const SizedBox(height: 14),

                      // Oyuncu 2 İsim Girişi
                      const Text(
                        '🟠 2. Oyuncu Adı:',
                        style: TextStyle(color: Colors.orangeAccent, fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: p2Controller,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _inputDecoration('Örn: Mehmet', Colors.orangeAccent),
                      ),
                      const SizedBox(height: 16),

                      // Hedef Skor
                      const Text(
                        '🎯 Kazanma Şartı (Hedef Skor):',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(1, '⚡ Tek Maç (1)', selectedTarget, (v) => setModalState(() => selectedTarget = v), Colors.orangeAccent),
                          _buildChip(3, '🏆 İlk 3 Alan (Best of 5)', selectedTarget, (v) => setModalState(() => selectedTarget = v), Colors.orangeAccent),
                          _buildChip(5, '👑 İlk 5 Alan (Şampiyonluk)', selectedTarget, (v) => setModalState(() => selectedTarget = v), Colors.orangeAccent),
                          _buildChip(0, '♾️ Sonsuz / Serbest', selectedTarget, (v) => setModalState(() => selectedTarget = v), Colors.orangeAccent),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sıra Süresi Seçimi
                      const Text(
                        '⏱️ Sıra Süre Sınırı:',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(15, '⚡ 15 Saniye (Hızlı)', selectedTimeLimit, (v) => setModalState(() => selectedTimeLimit = v), Colors.cyanAccent),
                          _buildChip(30, '⏱️ 30 Saniye (Standart)', selectedTimeLimit, (v) => setModalState(() => selectedTimeLimit = v), Colors.cyanAccent),
                          _buildChip(45, '🧘 45 Saniye (Taktik)', selectedTimeLimit, (v) => setModalState(() => selectedTimeLimit = v), Colors.cyanAccent),
                          _buildChip(0, '♾️ Süresiz', selectedTimeLimit, (v) => setModalState(() => selectedTimeLimit = v), Colors.cyanAccent),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Başlat Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            final p1 = p1Controller.text.trim().isEmpty ? '1. Oyuncu' : p1Controller.text.trim();
                            final p2 = p2Controller.text.trim().isEmpty ? '2. Oyuncu' : p2Controller.text.trim();
                            Navigator.of(context).pop();
                            onStartMatch(p1, p2, selectedTarget, selectedTimeLimit);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            isFirstLaunch ? '🥊 Maçı Başlat' : '🔄 Yeni Maçı Başlat',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static InputDecoration _inputDecoration(String hint, Color borderColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: SteamColors.cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
    );
  }

  static Widget _buildChip(int value, String label, int currentSelected, ValueChanged<int> onSelected, Color activeColor) {
    final isSelected = value == currentSelected;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onSelected(value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.25) : SteamColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : Colors.white70,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
