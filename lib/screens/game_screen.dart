import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../theme/steam_theme.dart';
import '../widgets/dialogs/perk_selection_dialog.dart';
import '../widgets/dialogs/run_victory_dialog.dart';
import '../widgets/widgets.dart';
import 'game/game_app_bar.dart';
import 'game/game_dialog_helper.dart';
import 'game/game_status_views.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GameProvider>();
      if (provider.currentRound == null) {
        provider.initializeGame();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToCard(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleGuessSubmission(BuildContext context, String guess) {
    final gameProvider = context.read<GameProvider>();
    final isCorrect = gameProvider.submitGuess(guess);

    if (isCorrect) {
      // 🏆 Doğru Tahmin: Haptik titreşim + Konfetili Zafer Penceresi
      HapticFeedback.heavyImpact();
      final attemptsCount = gameProvider.maxAttempts - gameProvider.attemptsRemaining + 1;

      if (gameProvider.isRunCompleted && gameProvider.currentFloor == 10) {
        // 👑 10. Kat Koşu Zaferi!
        RunVictoryDialog.show(
          context,
          totalScore: gameProvider.score,
          onContinue: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          onContinueAscension: () async {
            gameProvider.continueTowerAscension();
            if (gameProvider.offeredPerks.isNotEmpty) {
              await PerkSelectionDialog.show(context, gameProvider.offeredPerks);
            }
            if (_pageController.hasClients) {
              _pageController.jumpToPage(0);
            }
            await gameProvider.startNewRound();
          },
        );
      } else {
        GameDialogHelper.showResultDialog(
          context: context,
          isWon: true,
          gameName: gameProvider.currentRound?.oyunAdi ?? guess,
          appId: gameProvider.currentRound?.appId ?? 0,
          score: gameProvider.score,
          attemptsUsed: attemptsCount,
          wonCoins: gameProvider.lastWonCoins,
          wonDiamonds: gameProvider.lastWonDiamonds,
          currentStreak: gameProvider.streak,
          releaseDate: gameProvider.currentRound?.cikisTarihi,
          genres: gameProvider.currentRound?.turler ?? const [],
          onNextRound: () async {
            if (gameProvider.isRoguelike && gameProvider.offeredPerks.isNotEmpty) {
              await PerkSelectionDialog.show(context, gameProvider.offeredPerks);
            }
            if (_pageController.hasClients) {
              _pageController.jumpToPage(0);
            }
            await gameProvider.startNewRound();
          },
        );
      }
    } else {
      // ❌ Yanlış Tahmin: Shake sarsıntı efekti + Haptik bildirim
      _shakeKey.currentState?.shake();
      HapticFeedback.mediumImpact();

      // Sıradaki yeni açılan karta yumuşakça kaydır
      _animateToCard(gameProvider.revealedReviewCount - 1);

      if (gameProvider.isRoundLost) {
        // Canlar bitti: Oyun cevabını göstermeden önce "Son Şans" penceresini aç
        GameDialogHelper.showSecondChanceDialog(
          context: context,
          streak: gameProvider.streak,
          diamonds: gameProvider.diamonds,
          onContinue: () {
            // 💎 1 Elmas harcayarak +1 canla oyuna devam eder (Cevap GİZLİ kalır!)
            gameProvider.useExtraLifeJoker();
          },
          onGiveUp: () {
            // 🏳️ Pes etti: Tüm yorumlar açılır, doğru cevap ve kapak görseli gösterilir
            gameProvider.giveUpAndRevealAnswer();
            GameDialogHelper.showResultDialog(
              context: context,
              isWon: false,
              gameName: gameProvider.currentRound?.oyunAdi ?? 'Bilinmeyen Oyun',
              appId: gameProvider.currentRound?.appId ?? 0,
              score: gameProvider.score,
              attemptsUsed: 5,
              releaseDate: gameProvider.currentRound?.cikisTarihi,
              genres: gameProvider.currentRound?.turler ?? const [],
              onNextRound: () {
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(0);
                }
                gameProvider.startNewRound();
              },
            );
          },
        );
      } else {
        // Yanlış tahmin geri bildirimi
        GameDialogHelper.showWrongGuessSnackBar(
          context,
          guess: guess,
          revealedReviewCount: gameProvider.revealedReviewCount,
        );
      }
    }
  }

  void _handleSkipClue(BuildContext context) {
    final provider = context.read<GameProvider>();
    if (provider.attemptsRemaining > 1 &&
        provider.revealedReviewCount < provider.reviews.length) {
      provider.submitGuess('Pas');
      _animateToCard(provider.revealedReviewCount - 1);
    }
  }

  void _handleGiveUp(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    if (gameProvider.isRoundFinished || gameProvider.currentRound == null) return;

    GameDialogHelper.showGiveUpConfirmationDialog(
      context: context,
      isRoguelike: gameProvider.isRoguelike,
      currentFloor: gameProvider.currentFloor,
      onConfirmGiveUp: () {
        gameProvider.giveUpAndRevealAnswer();
        GameDialogHelper.showResultDialog(
          context: context,
          isWon: false,
          gameName: gameProvider.currentRound?.oyunAdi ?? 'Bilinmeyen Oyun',
          appId: gameProvider.currentRound?.appId ?? 0,
          score: gameProvider.score,
          attemptsUsed: 5,
          releaseDate: gameProvider.currentRound?.cikisTarihi,
          genres: gameProvider.currentRound?.turler ?? const [],
          onNextRound: () {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(0);
            }
            gameProvider.startNewRound();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: SteamColors.darkBg,
            resizeToAvoidBottomInset: true,
            appBar: GameAppBar(
              isRoundFinished: provider.isRoundFinished,
              onGiveUp: () => _handleGiveUp(context),
            ),
            body: Builder(
              builder: (innerContext) {
                // Bilgilendirme Toast Mesajı (Joker kullanımı vb.)
                if (provider.infoToast != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    GameDialogHelper.showInfoSnackBar(context, provider.infoToast!);
                    provider.clearInfoToast();
                  });
                }

                if (provider.isLoadingRound && provider.currentRound == null) {
                  return const GameLoadingView();
                }

                if (provider.errorMessage != null && provider.currentRound == null) {
                  return GameErrorView(
                    errorMessage: provider.errorMessage!,
                    onRetry: () => provider.initializeGame(),
                  );
                }

                final visibleReviews = provider.visibleReviews;
                final totalReviewsCount = provider.displayTotalReviewsCount;

                return SafeArea(
                  child: Column(
                    children: [
                      // 1. Üst Durum Çubuğu: Cüzdan (🪙, 💎), Skor ve Canlar (❤️❤️❤️❤️❤️)
                      RoundHeader(
                        score: provider.score,
                        streak: provider.streak,
                        attemptsRemaining: provider.attemptsRemaining,
                      ),

                      // 2. İpucu İlerleme Çubuğu (Stepper / Progress Dots)
                      ClueStepperIndicator(
                        totalCount: totalReviewsCount,
                        unlockedCount: provider.revealedReviewCount,
                        activeIndex: provider.activeCardIndex,
                        onStepSelected: (index) {
                          provider.setActiveCardIndex(index);
                          _animateToCard(index);
                        },
                      ),

                      // 3. Odak İnceleme Kartı Alanı (Swipeable PageView)
                      Expanded(
                        child: visibleReviews.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : PageView.builder(
                                key: ValueKey('round_pageview_${provider.currentRound?.appId}_${provider.totalGamesPlayed}'),
                                controller: _pageController,
                                physics: const BouncingScrollPhysics(),
                                itemCount: visibleReviews.length,
                                onPageChanged: (index) {
                                  provider.setActiveCardIndex(index);
                                },
                                itemBuilder: (context, index) {
                                  if (index < 0 || index >= visibleReviews.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return SwipeableReviewCard(
                                    review: visibleReviews[index],
                                    index: index,
                                    totalCount: totalReviewsCount,
                                  );
                                },
                              ),
                      ),

                      // 4. Kelime Kutucukları / Harf İpucu Görselleştiricisi (Word Slots)
                      if (provider.currentRound != null)
                        WordSlotVisualizer(
                          targetName: provider.currentRound!.oyunAdi,
                          revealedIndices: provider.revealedLetterIndices,
                          isUnlocked: provider.isWordSlotUnlocked,
                          isRoundFinished: provider.isRoundFinished,
                        ),

                      // 5. Joker Aksiyon Çubuğu (Harf Aç, Ekstra Yorum, Pas Geç)
                      if (!provider.isRoundFinished)
                        JokerActionBar(
                          onSkipClue: () => _handleSkipClue(context),
                          onExtraReviewUsed: (idx) => _animateToCard(idx),
                        ),

                      // 6. Tahmin Giriş Çubuğu veya Tur Tamamlandı Aksiyon Çubuğu
                      if (provider.isRoundFinished)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: const BoxDecoration(
                            color: SteamColors.navyBg,
                            border: Border(
                              top: BorderSide(color: SteamColors.cardBorder, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      provider.isRoundWon
                                          ? '🏆 ${provider.currentRound?.oyunAdi ?? ""}'
                                          : '💀 ${provider.currentRound?.oyunAdi ?? ""}',
                                      style: const TextStyle(
                                        color: SteamColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Text(
                                      'Tüm incelemeleri kaydırarak okuyabilirsiniz',
                                      style: TextStyle(
                                        color: SteamColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (_pageController.hasClients) {
                                    _pageController.jumpToPage(0);
                                  }
                                  context.read<GameProvider>().startNewRound();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SteamColors.steamBlue,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                label: const Text(
                                  'SONRAKİ TUR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        // Sarsıntı Animasyonlu Tahmin Arama Çubuğu (Shake on Error)
                        ShakeWidget(
                          key: _shakeKey,
                          child: GameGuessInput(
                            games: provider.gamesList,
                            isEnabled: !provider.isLoadingRound,
                            onSubmitted: (guess) => _handleGuessSubmission(context, guess),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
