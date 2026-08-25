import 'package:flutter/material.dart';
import '../../../theme/steam_theme.dart';

class DuelLobbyWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController roomCodeController;
  final int selectedTargetScore;
  final ValueChanged<int> onTargetScoreChanged;
  final int selectedTurnTime;
  final ValueChanged<int> onTurnTimeChanged;
  final bool censorProfanity;
  final ValueChanged<bool> onCensorProfanityChanged;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onCreateRoom;
  final VoidCallback onJoinRoom;

  const DuelLobbyWidget({
    super.key,
    required this.nameController,
    required this.roomCodeController,
    required this.selectedTargetScore,
    required this.onTargetScoreChanged,
    required this.selectedTurnTime,
    required this.onTurnTimeChanged,
    required this.censorProfanity,
    required this.onCensorProfanityChanged,
    required this.isLoading,
    this.errorMessage,
    required this.onCreateRoom,
    required this.onJoinRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hub_rounded, size: 54, color: Colors.amberAccent),
              ),
              const SizedBox(height: 16),
              const Text(
                'CANLI ÇOK OYUNCULU MOD',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Arkadaşınla gerçek zamanlı oyun tahmin kapışması!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // 1. Oyuncu Adı Girişi
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Oyuncu Adınız',
                  labelStyle: const TextStyle(color: Colors.cyanAccent),
                  prefixIcon: const Icon(Icons.person, color: Colors.cyanAccent),
                  filled: true,
                  fillColor: SteamColors.cardBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Hedef Skor Seçimi (Kaçta Bitsin?)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SteamColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('🎯 ', style: TextStyle(fontSize: 14)),
                        Text(
                          'Kazanma Şartı (Hedef Skor):',
                          style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildOptionChip(selectedTargetScore == 1, '⚡ 1 (Tek)', () => onTargetScoreChanged(1))),
                        const SizedBox(width: 5),
                        Expanded(child: _buildOptionChip(selectedTargetScore == 3, '🏆 İlk 3', () => onTargetScoreChanged(3))),
                        const SizedBox(width: 5),
                        Expanded(child: _buildOptionChip(selectedTargetScore == 5, '👑 İlk 5', () => onTargetScoreChanged(5))),
                        const SizedBox(width: 5),
                        Expanded(child: _buildOptionChip(selectedTargetScore >= 100, '♾️ Sonsuz', () => onTargetScoreChanged(999))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Tahmin Süre Sınırı Seçimi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SteamColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('⏱️ ', style: TextStyle(fontSize: 14)),
                        Text(
                          'Sıra Süresi (Tahmin Sınırı):',
                          style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildOptionChip(selectedTurnTime == 15, '⚡ 15 sn', () => onTurnTimeChanged(15))),
                        const SizedBox(width: 5),
                        Expanded(child: _buildOptionChip(selectedTurnTime == 30, '⏳ 30 sn', () => onTurnTimeChanged(30))),
                        const SizedBox(width: 5),
                        Expanded(child: _buildOptionChip(selectedTurnTime == 45, '⏱️ 45 sn', () => onTurnTimeChanged(45))),
                        const SizedBox(width: 5),
                        Expanded(child: _buildOptionChip(selectedTurnTime == 0, '♾️ Süresiz', () => onTurnTimeChanged(0))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Küfür / Argo Sansürü Switch
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: SteamColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('🛡️ ', style: TextStyle(fontSize: 16)),
                        Text(
                          'Küfür & Argo Sansürü',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Switch(
                      value: censorProfanity,
                      activeColor: Colors.amberAccent,
                      onChanged: onCensorProfanityChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (isLoading)
                const CircularProgressIndicator(color: Colors.amberAccent)
              else ...[
                // ODA OLUŞTUR BUTONU
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                  label: const Text(
                    'YENİ ODA OLUŞTUR',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onCreateRoom,
                ),
                const SizedBox(height: 16),

                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('VEYA', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 16),

                // ODA KODUNA KATIL
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: roomCodeController,
                        style: const TextStyle(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'Örn: 4821',
                          hintStyle: const TextStyle(color: Colors.white30),
                          filled: true,
                          fillColor: SteamColors.cardBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onJoinRoom,
                      child: const Text(
                        'KATIL',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],

              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionChip(bool isSelected, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.amberAccent.withValues(alpha: 0.25) : Colors.black26,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.amberAccent : Colors.white12,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.amberAccent : Colors.white70,
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
