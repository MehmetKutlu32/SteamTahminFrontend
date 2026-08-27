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
      final gameName = provider.currentRound?.oyunAdi ?? '';
      final maxReviews = provider.currentRound?.yorumlar.length ?? 5;
      setState(() {
        if (_currentTurnPlayer == 1) {
          _player1Score += 1;
        } else {
          _player2Score += 1;
        }
        _revealedCount = maxReviews;
        _roundResultMessage = '🎉 $currentName Doğru Bildi! (+1 Puan)\n🎮 Doğru Cevap: $gameName';
      });
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

  bool _isForcedDraw = false;

  bool get _isMatchOver =>
      _isForcedDraw || (_targetScore > 0 && (_player1Score >= _targetScore || _player2Score >= _targetScore));

  void _showSurrenderDialog() {
    if (_isMatchOver) return;

    final currentSurrenderer = _currentTurnPlayer;
    final currentSurrendererName = currentSurrenderer == 1 ? _p1Name : _p2Name;
    final opponentName = currentSurrenderer == 1 ? _p2Name : _p1Name;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131D29),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SteamColors.cardBorder),
        ),
        title: const Row(
          children: [
            Text('🏳️ ', style: TextStyle(fontSize: 20)),
            Text('Pes Et / Maç Seçenekleri', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sıra $currentSurrendererName\'de. Ne yapmak istiyorsunuz?',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),

            // 1. SADECE BU RAUNDU RAKİBE VER (Sonraki Raund)
            ElevatedButton.icon(
              icon: const Icon(Icons.skip_next_rounded, color: Colors.black, size: 18),
              label: Text(
                '⏭️ Bu Raundu Rakibe Ver (+1 Puan $opponentName\'e)',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 11),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _forfeitCurrentRound(currentSurrenderer);
              },
            ),
            const SizedBox(height: 8),

            // 2. TÜM MAÇI HÜKMEN KAYBET
            ElevatedButton.icon(
              icon: const Icon(Icons.flag_rounded, color: Colors.white, size: 16),
              label: Text(
                '🏳️ Tüm Maçtan Çekil ($opponentName Maçı Kazansın)',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _surrenderPlayer(currentSurrenderer);
              },
            ),
            const SizedBox(height: 8),

            // 3. DOSTÇA BERABERLİK (2 Taraf da Onaylamalı)
            ElevatedButton.icon(
              icon: const Icon(Icons.handshake_rounded, color: Colors.white, size: 16),
              label: const Text(
                '🤝 Dostça Beraberlik (İki Tarafın Onayıyla)',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E3A4B),
                side: const BorderSide(color: Colors.cyanAccent, width: 1),
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _showMutualDrawConfirmationDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç (Devam Et)', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _forfeitCurrentRound(int forfeiterPlayer) {
    _stopTurnTimer();
    final provider = context.read<GameProvider>();
    final winningPlayer = forfeiterPlayer == 1 ? 2 : 1;
    final winnerName = winningPlayer == 1 ? _p1Name : _p2Name;
    final forfeiterName = forfeiterPlayer == 1 ? _p1Name : _p2Name;
    final gameName = provider.currentRound?.oyunAdi ?? '';
    final maxReviews = provider.currentRound?.yorumlar.length ?? 5;

    setState(() {
      if (winningPlayer == 1) {
        _player1Score += 1;
      } else {
        _player2Score += 1;
      }
      _revealedCount = maxReviews;
      _roundResultMessage = '🏳️ $forfeiterName bu raundu geçti. (+1 Puan $winnerName)\n🎮 Doğru Cevap: $gameName';
    });
  }

  void _showMutualDrawConfirmationDialog() {
    bool p1Confirmed = false;
    bool p2Confirmed = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF131D29),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.cyanAccent),
            ),
            title: const Row(
              children: [
                Text('🤝 ', style: TextStyle(fontSize: 22)),
                Expanded(
                  child: Text(
                    'Dostça Beraberlik Onayı',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Maçın berabere bitmesi için her iki oyuncunun da kendi butonuna basarak onaylaması gerekmektedir.',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
                const SizedBox(height: 16),
                // P1 Onay
                ElevatedButton.icon(
                  icon: Icon(
                    p1Confirmed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: p1Confirmed ? Colors.black : Colors.cyanAccent,
                    size: 18,
                  ),
                  label: Text(
                    p1Confirmed ? '✓ $_p1Name Onayladı' : '$_p1Name: [ Onayla ]',
                    style: TextStyle(
                      color: p1Confirmed ? Colors.black : Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p1Confirmed ? Colors.cyanAccent : Colors.white10,
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setDialogState(() {
                      p1Confirmed = !p1Confirmed;
                    });
                  },
                ),
                const SizedBox(height: 8),
                // P2 Onay
                ElevatedButton.icon(
                  icon: Icon(
                    p2Confirmed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: p2Confirmed ? Colors.black : Colors.orangeAccent,
                    size: 18,
                  ),
                  label: Text(
                    p2Confirmed ? '✓ $_p2Name Onayladı' : '$_p2Name: [ Onayla ]',
                    style: TextStyle(
                      color: p2Confirmed ? Colors.black : Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p2Confirmed ? Colors.orangeAccent : Colors.white10,
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setDialogState(() {
                      p2Confirmed = !p2Confirmed;
                    });
                  },
                ),
                const SizedBox(height: 14),
                // Nihai Bitir Butonu
                ElevatedButton(
                  onPressed: (p1Confirmed && p2Confirmed)
                      ? () {
                          Navigator.of(ctx).pop();
                          _endMatchAsDraw();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white12,
                    disabledForegroundColor: Colors.white30,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    (p1Confirmed && p2Confirmed) ? '🏁 Maçı Dostça Bitir' : 'İki Tarafın Onayı Bekleniyor...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('İptal', style: TextStyle(color: Colors.white54)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _endMatchAsDraw() {
    _stopTurnTimer();
    setState(() {
      _isForcedDraw = true;
      _roundResultMessage = '🤝 Maç Dostça / Berabere Sonlandırıldı!';
    });
  }

  void _surrenderPlayer(int playerNum) {
    _stopTurnTimer();
    setState(() {
      if (playerNum == 1) {
        _player2Score = _targetScore;
        _roundResultMessage = '🏳️ $_p1Name pes etti! $_p2Name maçı kazandı!';
      } else {
        _player1Score = _targetScore;
        _roundResultMessage = '🏳️ $_p2Name pes etti! $_p1Name maçı kazandı!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          if (!_isMatchOver)
            IconButton(
              icon: const Icon(Icons.flag_rounded, color: Colors.redAccent),
              tooltip: 'Pes Et / Maçı Bitir',
              onPressed: _showSurrenderDialog,
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Skorları Sıfırla',
            onPressed: () {
              setState(() {
                _player1Score = 0;
                _player2Score = 0;
                _isForcedDraw = false;
                _roundResultMessage = null;
              });
              _startNewDuelRound();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              // 1. Skor Tablosu & Sıra Banner'ı (Klavye açıkken tek satır kompakt)
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
                isCompact: isKeyboardOpen,
                onPassTurn: (!_isMatchOver && !provider.isLoadingRound) ? _onPassTurn : null,
                onSurrender: (!_isMatchOver && !provider.isLoadingRound) ? _showSurrenderDialog : null,
              ),
              const SizedBox(height: 8),

              // 2. İncelemeler Listesi
              Expanded(
                child: LocalDuelReviewsList(
                  reviews: provider.currentRound?.yorumlar ?? [],
                  revealedCount: _revealedCount,
                  roundResultMessage: _roundResultMessage,
                ),
              ),
              const SizedBox(height: 8),

              // 3. Maç Sonu Kartı / Sıradaki Raund / %100 Ferah Tahmin Girişi
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
                      _isForcedDraw = false;
                      _roundResultMessage = null;
                    });
                    _startNewDuelRound();
                  },
                  onChangePlayers: () => _openSettingsModal(),
                )
              else if (_roundResultMessage != null && (_roundResultMessage!.contains('Doğru') || _roundResultMessage!.contains('geçti')))
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
                GameGuessInput(
                  games: provider.gamesList,
                  isEnabled: !_isMatchOver && !provider.isLoadingRound,
                  onSubmitted: (guess) => _submitDuelGuess(provider, guess),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
