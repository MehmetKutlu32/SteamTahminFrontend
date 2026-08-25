import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/roguelike_models.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';
import '../../widgets/inputs/game_autocomplete_input.dart';
import 'widgets/local_duel_header.dart';
import 'widgets/local_duel_reviews_list.dart';
import 'widgets/local_duel_settings_modal.dart';
import 'widgets/local_duel_victory_card.dart';

class DuelGameScreen extends StatefulWidget {
  const DuelGameScreen({super.key});

  @override
  State<DuelGameScreen> createState() => _DuelGameScreenState();
}

class _DuelGameScreenState extends State<DuelGameScreen> {
  String _p1Name = '1. Oyuncu';
  String _p2Name = '2. Oyuncu';
  int _player1Score = 0;
  int _player2Score = 0;
  int _currentTurnPlayer = 1;
  int _targetScore = 3;
  int _turnTimeLimit = 30; // 0 = Süresiz
  int _remainingTurnSeconds = 30;
  int _revealedCount = 1;
  Timer? _turnTimer;
  String? _roundResultMessage;

  final TextEditingController _p1Controller = TextEditingController(text: '1. Oyuncu');
  final TextEditingController _p2Controller = TextEditingController(text: '2. Oyuncu');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<GameProvider>();
      provider.setGameMode(GameMode.duel);
      if (provider.gamesList.isEmpty) {
        await provider.initializeGame();
      } else if (provider.currentRound == null) {
        await provider.startNewRound();
      }
      _openSettingsModal(isFirstLaunch: true);
    });
  }

  @override
  void dispose() {
    _stopTurnTimer();
    _p1Controller.dispose();
    _p2Controller.dispose();
    super.dispose();
  }

  void _stopTurnTimer() {
    _turnTimer?.cancel();
    _turnTimer = null;
  }

  void _startTurnTimer() {
    _stopTurnTimer();
    if (_turnTimeLimit <= 0 || _isMatchOver) return;

    setState(() {
      _remainingTurnSeconds = _turnTimeLimit;
    });

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingTurnSeconds > 1) {
        setState(() {
          _remainingTurnSeconds -= 1;
        });
      } else {
        timer.cancel();
        _onTurnTimeout();
      }
    });
  }

  void _onTurnTimeout() {
    if (_isMatchOver) return;
    HapticFeedback.heavyImpact();
    final nextPlayer = _currentTurnPlayer == 1 ? 2 : 1;
    final nextName = nextPlayer == 1 ? _p1Name : _p2Name;
    final timedOutName = _currentTurnPlayer == 1 ? _p1Name : _p2Name;

    final provider = context.read<GameProvider>();
    final maxReviews = provider.currentRound?.yorumlar.length ?? 5;

    setState(() {
      if (_revealedCount < maxReviews) _revealedCount++;
      _currentTurnPlayer = nextPlayer;
      _roundResultMessage = '⏱️ $timedOutName için süre doldu! Sıra $nextName\'de.';
    });

    _startTurnTimer();
  }

  void _onPassTurn() {
    if (_isMatchOver) return;
    HapticFeedback.mediumImpact();
    final nextPlayer = _currentTurnPlayer == 1 ? 2 : 1;
    final nextName = nextPlayer == 1 ? _p1Name : _p2Name;
    final passedName = _currentTurnPlayer == 1 ? _p1Name : _p2Name;

    final provider = context.read<GameProvider>();
    final maxReviews = provider.currentRound?.yorumlar.length ?? 5;

    setState(() {
      if (_revealedCount < maxReviews) _revealedCount++;
      _currentTurnPlayer = nextPlayer;
      _roundResultMessage = '⏭️ $passedName pas geçti. Sıra $nextName\'de.';
    });

    _startTurnTimer();
  }

  void _openSettingsModal({bool isFirstLaunch = false}) {
    _stopTurnTimer();
    LocalDuelSettingsModal.show(
      context: context,
      p1Controller: _p1Controller,
      p2Controller: _p2Controller,
      initialTargetScore: _targetScore,
      initialTurnTimeLimit: _turnTimeLimit,
      isFirstLaunch: isFirstLaunch,
      onStartMatch: (p1, p2, target, timeLimit) {
        setState(() {
          _p1Name = p1;
          _p2Name = p2;
          _targetScore = target;
          _turnTimeLimit = timeLimit;
          _player1Score = 0;
          _player2Score = 0;
        });
        _startNewDuelRound();
      },
    );
  }

  void _startNewDuelRound() {
    final provider = context.read<GameProvider>();
    provider.setGameMode(GameMode.duel);
    setState(() {
      _revealedCount = 1;
      _roundResultMessage = null;
      _currentTurnPlayer = 1;
    });
    provider.startNewRound();
    _startTurnTimer();
  }

  void _submitDuelGuess(GameProvider provider, String guess) {
    if (guess.trim().isEmpty || _isMatchOver) return;

    final isCorrect = provider.submitGuess(guess);

    if (isCorrect) {
      _stopTurnTimer();
      HapticFeedback.heavyImpact();
      final currentName = _currentTurnPlayer == 1 ? _p1Name : _p2Name;
      setState(() {
        if (_currentTurnPlayer == 1) {
          _player1Score += 1;
        } else {
          _player2Score += 1;
        }
        _roundResultMessage = '🎉 $currentName Doğru Bildi! (+1 Puan)';
      });

      if (_isMatchOver) {
        final winner = _player1Score >= _targetScore ? 1 : 2;
        provider.recordDuelWin(winner);
      }
    } else {
      HapticFeedback.mediumImpact();
      final nextPlayer = _currentTurnPlayer == 1 ? 2 : 1;
      final nextName = nextPlayer == 1 ? _p1Name : _p2Name;
      final maxReviews = provider.currentRound?.yorumlar.length ?? 5;

      setState(() {
        if (_revealedCount < maxReviews) _revealedCount++;
        _currentTurnPlayer = nextPlayer;
        _roundResultMessage = '❌ Yanlış! Sıra $nextName\'de.';
      });
      _startTurnTimer();
    }
  }

  bool get _isMatchOver =>
      _targetScore > 0 && (_player1Score >= _targetScore || _player2Score >= _targetScore);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: SteamColors.darkBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF101822),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          onPressed: () {
            _stopTurnTimer();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          '🥊 1v1 DÜELLO',
          style: TextStyle(
            color: Colors.amberAccent,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.orangeAccent),
            tooltip: 'Maç Ayarları, Süre & İsimler',
            onPressed: () => _openSettingsModal(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Skorları Sıfırla',
            onPressed: () {
              setState(() {
                _player1Score = 0;
                _player2Score = 0;
              });
              _startNewDuelRound();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              // 1. Skor Tablosu & Sıra Banner'ı (Süre Sayacı Dahil)
              LocalDuelHeader(
                player1Name: _p1Name,
                player1Score: _player1Score,
                player2Name: _p2Name,
                player2Score: _player2Score,
                currentTurnPlayer: _currentTurnPlayer,
                targetScore: _targetScore,
                remainingTurnSeconds: _remainingTurnSeconds,
                turnTimeLimit: _turnTimeLimit,
                isMatchOver: _isMatchOver,
              ),
              const SizedBox(height: 10),

              // 2. İncelemeler Listesi
              Expanded(
                child: LocalDuelReviewsList(
                  reviews: provider.currentRound?.yorumlar ?? [],
                  revealedCount: _revealedCount,
                  roundResultMessage: _roundResultMessage,
                ),
              ),
              const SizedBox(height: 10),

              // 3. Maç Sonu Kartı / Sıradaki Raund / Tahmin Girişi & Pas Geç
              if (_isMatchOver)
                LocalDuelVictoryCard(
                  player1Name: _p1Name,
                  player1Score: _player1Score,
                  player2Name: _p2Name,
                  player2Score: _player2Score,
                  targetScore: _targetScore,
                  onRematch: () {
                    setState(() {
                      _player1Score = 0;
                      _player2Score = 0;
                    });
                    _startNewDuelRound();
                  },
                  onChangePlayers: () => _openSettingsModal(),
                )
              else if (_roundResultMessage != null && _roundResultMessage!.contains('Doğru'))
                ElevatedButton(
                  onPressed: _startNewDuelRound,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Sıradaki Raund ➡️', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GameGuessInput(
                            games: provider.gamesList,
                            isEnabled: !_isMatchOver && !provider.isLoadingRound,
                            onSubmitted: (guess) => _submitDuelGuess(provider, guess),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Sırayı Rakibe Devret ve İpucu Aç',
                          child: InkWell(
                            onTap: (!_isMatchOver && !provider.isLoadingRound) ? _onPassTurn : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Row(
                                children: [
                                  Text('⏭️', style: TextStyle(fontSize: 16)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Pas',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
