import 'package:flutter/material.dart';
import '../../theme/steam_theme.dart';

class ClueStepperIndicator extends StatelessWidget {
  final int totalCount;
  final int unlockedCount;
  final int activeIndex;
  final ValueChanged<int> onStepSelected;

  const ClueStepperIndicator({
    super.key,
    required this.totalCount,
    required this.unlockedCount,
    required this.activeIndex,
    required this.onStepSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(totalCount, (index) {
            final isUnlocked = index < unlockedCount;
            final isActive = index == activeIndex;

            return GestureDetector(
              onTap: isUnlocked ? () => onStepSelected(index) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 24,
                width: isActive ? 40 : 28,
                decoration: BoxDecoration(
                  color: isActive
                      ? SteamColors.steamBlue
                      : (isUnlocked
                          ? const Color(0xFF1E2D3D)
                          : SteamColors.cardBg.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? SteamColors.steamCyan
                        : (isUnlocked
                            ? SteamColors.steamBlue.withValues(alpha: 0.5)
                            : SteamColors.cardBorder.withValues(alpha: 0.4)),
                    width: isActive ? 1.5 : 1.0,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: SteamColors.steamCyan.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(
                          '#${index + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.black : Colors.white70,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(
                          Icons.lock_rounded,
                          size: 11,
                          color: SteamColors.textMuted,
                        ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
