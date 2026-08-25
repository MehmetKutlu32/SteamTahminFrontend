import 'package:flutter/material.dart';
import '../../theme/steam_theme.dart';

class WordSlotVisualizer extends StatelessWidget {
  final String targetName;
  final Set<int> revealedIndices;
  final bool isUnlocked;
  final bool isRoundFinished;

  const WordSlotVisualizer({
    super.key,
    required this.targetName,
    required this.revealedIndices,
    this.isUnlocked = false,
    this.isRoundFinished = false,
  });

  @override
  Widget build(BuildContext context) {
    if (targetName.isEmpty) return const SizedBox.shrink();

    // 🔒 Eğer tablo kilitliyse ve tur henüz bitmediyse, yer kaplamadan gizle (Joker çubuğundaki Tabloyu Aç butonu yönetir)
    if (!isUnlocked && !isRoundFinished) {
      return const SizedBox.shrink();
    }

    // 🔓 Tablo açık veya tur tamamlandı: Harf kutularını çiz
    final words = <List<_LetterInfo>>[];
    var currentWord = <_LetterInfo>[];

    for (int i = 0; i < targetName.length; i++) {
      final char = targetName[i];
      if (char == ' ') {
        if (currentWord.isNotEmpty) {
          words.add(currentWord);
          currentWord = [];
        }
      } else {
        currentWord.add(_LetterInfo(
          char: char,
          globalIndex: i,
          isRevealed: isRoundFinished ||
              revealedIndices.contains(i) ||
              !RegExp(r'[a-zA-Z0-9]').hasMatch(char),
        ));
      }
    }
    if (currentWord.isNotEmpty) {
      words.add(currentWord);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int w = 0; w < words.length; w++) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final letter in words[w])
                    _buildLetterBox(letter),
                ],
              ),
              if (w < words.length - 1)
                const SizedBox(width: 14), // Kelimeler arası boşluk
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLetterBox(_LetterInfo letter) {
    final isSymbol = !RegExp(r'[a-zA-Z0-9]').hasMatch(letter.char);

    if (isSymbol) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 16,
        height: 36,
        alignment: Alignment.center,
        child: Text(
          letter.char,
          style: const TextStyle(
            color: SteamColors.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      width: 28,
      height: 36,
      decoration: BoxDecoration(
        color: letter.isRevealed
            ? const Color(0xFF16324F)
            : SteamColors.cardBg.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: letter.isRevealed
              ? SteamColors.steamCyan
              : SteamColors.cardBorder.withValues(alpha: 0.6),
          width: letter.isRevealed ? 1.5 : 1.0,
        ),
        boxShadow: letter.isRevealed
            ? [
                BoxShadow(
                  color: SteamColors.steamCyan.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Text(
          letter.isRevealed ? letter.char.toUpperCase() : '_',
          key: ValueKey<bool>(letter.isRevealed),
          style: TextStyle(
            color: letter.isRevealed ? Colors.white : SteamColors.textMuted,
            fontSize: letter.isRevealed ? 16 : 14,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

class _LetterInfo {
  final String char;
  final int globalIndex;
  final bool isRevealed;

  const _LetterInfo({
    required this.char,
    required this.globalIndex,
    required this.isRevealed,
  });
}
