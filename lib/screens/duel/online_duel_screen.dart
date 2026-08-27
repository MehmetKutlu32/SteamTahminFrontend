import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_item.dart';
import '../../providers/game_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/duel_signalr_service.dart';
import '../../theme/steam_theme.dart';
import '../../widgets/inputs/game_autocomplete_input.dart';
import 'widgets/duel_game_over_widget.dart';
import 'widgets/duel_lobby_widget.dart';
import 'widgets/duel_reviews_list.dart';
import 'widgets/duel_round_result_widget.dart';
import 'widgets/duel_scoreboard.dart';
import 'widgets/duel_waiting_room_widget.dart';

enum OnlineDuelPhase { lobby, waitingOpponent, playing, roundResult, gameOver }

class OnlineDuelScreen extends StatefulWidget {
  final String? initialRoomCode;

  const OnlineDuelScreen({super.key, this.initialRoomCode});

  @override
  State<OnlineDuelScreen> createState() => _OnlineDuelScreenState();
}

class _OnlineDuelScreenState extends State<OnlineDuelScreen> {
  DuelSignalRService? _signalRService;
  OnlineDuelPhase _phase = OnlineDuelPhase.lobby;

  String? _myRoomCode;
  String _player1Name = 'Oyuncu 1';
  String _player2Name = 'Oyuncu 2';
  int _player1Score = 0;
  int _player2Score = 0;
  int _currentRound = 1;
  int _targetScore = 3;
  int _turnTimeLimit = 30; // 15, 30, 45, 0 (süresiz)
  int _remainingSeconds = 30;
  Timer? _turnCountdownTimer;

  bool _censorProfanity = true;
  int _revealedReviewCount = 1;

  bool _isHost = false;
  String _myRegisteredName = '';
  String _currentTurnPlayer = '';
  String? _turnStatusBanner;

  bool get _isMyTurn {
    if (_currentTurnPlayer.isEmpty) return _isHost;
    if (_myRegisteredName.isEmpty) return _isHost;
    return _currentTurnPlayer.trim().toLowerCase() == _myRegisteredName.trim().toLowerCase();
  }

  DuelRoundEvent? _currentRoundData;
  DuelResultEvent? _lastRoundResult;
  String? _gameOverMessage;

  bool _isMyGuessSubmitted = false;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _roomCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Oyuncu_${DateTime.now().millisecond}';
    if (widget.initialRoomCode != null && widget.initialRoomCode!.isNotEmpty) {
      _roomCodeController.text = widget.initialRoomCode!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_signalRService == null) {
      final authService = context.read<AuthService>();
      if (authService.isLoggedIn && authService.currentUser != null) {
        _nameController.text = authService.currentUser!.displayName;
      }

      final apiService = context.read<ApiService>();
      final hubUrl = '${apiService.baseUrl}/duelHub';
      _signalRService = DuelSignalRService(customUrl: hubUrl);
      _setupSignalRListeners();

      final provider = context.read<GameProvider>();
      if (provider.gamesList.isEmpty) provider.initializeGame();

      if (widget.initialRoomCode != null && widget.initialRoomCode!.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted && _phase == OnlineDuelPhase.lobby) {
            _joinRoom();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _stopTurnTimer();
    _signalRService?.disconnect();
    _roomCodeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _startTurnTimer() {
    _stopTurnTimer();
    if (_turnTimeLimit <= 0) return;
    setState(() => _remainingSeconds = _turnTimeLimit);
    _turnCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 1) {
        setState(() => _remainingSeconds--);
      } else {
        _stopTurnTimer();
        setState(() => _remainingSeconds = 0);
        // Süre bittiğinde sırası olan oyuncu otomatik pas geçer
        if (_isMyTurn && !_isMyGuessSubmitted && _phase == OnlineDuelPhase.playing) {
          _passTurn();
        }
      }
    });
  }

  void _stopTurnTimer() {
    _turnCountdownTimer?.cancel();
    _turnCountdownTimer = null;
  }

  void _setupSignalRListeners() {
    if (_signalRService == null) return;

    _signalRService!.onRoomCreated = (code) {
      if (!mounted) return;
      setState(() {
        _myRoomCode = code;
        _phase = OnlineDuelPhase.waitingOpponent;
        _isLoading = false;
      });
    };

    _signalRService!.onJoinFailed = (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    };

    _signalRService!.onMatchFound = (p1, p2) {
      if (!mounted) return;
      setState(() {
        _player1Name = p1;
        _player2Name = p2;
        if (_myRegisteredName.isEmpty) {
          _myRegisteredName = _isHost ? p1 : p2;
        }
        _player1Score = 0;
        _player2Score = 0;
        _revealedReviewCount = 1;
        _currentTurnPlayer = p1;
        _turnStatusBanner = null;
        _phase = OnlineDuelPhase.playing;
        _isLoading = false;
      });
    };

    _signalRService!.onNewRoundStarted = (round) {
      if (!mounted) return;
      if (round.turnTimeLimit != null) {
        _turnTimeLimit = round.turnTimeLimit!;
      }
      setState(() {
        _currentRoundData = round;
        _currentRound = round.round;
        _revealedReviewCount = round.revealedCount;
        _currentTurnPlayer = round.currentTurnPlayer.isNotEmpty ? round.currentTurnPlayer : _player1Name;
        _turnStatusBanner = null;
        _isMyGuessSubmitted = false;
        _phase = OnlineDuelPhase.playing;
      });
      _startTurnTimer();
    };

    _signalRService!.onTurnChanged = (turn) {
      if (!mounted) return;
      if (turn.turnTimeLimit != null) {
        _turnTimeLimit = turn.turnTimeLimit!;
      }
      setState(() {
        _currentTurnPlayer = turn.currentTurnPlayer;
        _revealedReviewCount = turn.revealedCount;
        if (turn.message != null && turn.message!.isNotEmpty) {
          _turnStatusBanner = turn.message;
        } else if (turn.lastGuesserName != null) {
          _turnStatusBanner = '${turn.lastGuesserName} "${turn.lastGuess}" dedi (Yanlış!). Sıradaki ipucu açıldı.';
        }
        _isMyGuessSubmitted = false;
      });
      _startTurnTimer();
    };

    _signalRService!.onRoundResult = (result) {
      if (!mounted) return;
      _stopTurnTimer();
      setState(() {
        _lastRoundResult = result;
        _player1Score = result.player1Score;
        _player2Score = result.player2Score;
        _phase = OnlineDuelPhase.roundResult;
      });
    };

    _signalRService!.onGameOver = (winnerId, finalScore) {
      if (!mounted) return;
      _stopTurnTimer();

      final bool isP1 = _isHost;
      final winnerStr = winnerId.toString();
      final bool iWon = (isP1 && (_player1Score > _player2Score || winnerStr == 'Player1' || winnerStr == '1')) ||
          (!isP1 && (_player2Score > _player1Score || winnerStr == 'Player2' || winnerStr == '2'));

      if (iWon) {
        context.read<GameProvider>().recordOnlineDuelWin();
      }

      setState(() {
        _gameOverMessage = iWon ? '🏆 TEBRİKLER! Maçı Kazandınız!\nSkor: $finalScore' : 'Oyun Bitti! Skor: $finalScore';
        _phase = OnlineDuelPhase.gameOver;
      });
    };

    _signalRService!.onSurrenderOffered = (fromUser) {
      if (!mounted) return;
      _showSurrenderProposalDialog(fromUser);
    };

    _signalRService!.onSurrenderRejected = (byUser) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ $byUser pes etme teklifini reddetti. Oyun devam ediyor!'), backgroundColor: Colors.orangeAccent),
      );
    };

    _signalRService!.onOpponentDisconnected = () {
      if (!mounted) return;
      _stopTurnTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Rakip oyundan ayrıldı.'), backgroundColor: Colors.redAccent),
      );
      setState(() => _phase = OnlineDuelPhase.lobby);
    };
  }

  void _showSurrenderProposalDialog(String fromUser) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        title: const Row(
          children: [
            Text('🏳️ ', style: TextStyle(fontSize: 22)),
            Text('Pes Etme / Bitirme Teklifi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '$fromUser oyunu sonlandırmayı (pes etmeyi) teklif ediyor. Kabul ediyor musun?',
          style: const TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _signalRService?.respondSurrender(roomCode: _myRoomCode ?? '', accepted: false);
            },
            child: const Text('Reddet / Devam Et', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(ctx).pop();
              _signalRService?.respondSurrender(roomCode: _myRoomCode ?? '', accepted: true);
            },
            child: const Text('Kabul Et & Bitir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _createRoom() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    _isHost = true;
    _myRegisteredName = name;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      if (_signalRService == null) {
        final apiService = context.read<ApiService>();
        final hubUrl = '${apiService.baseUrl}/duelHub';
        _signalRService = DuelSignalRService(customUrl: hubUrl);
        _setupSignalRListeners();
      }
      await _signalRService!.createRoom(
        userId: 1,
        userName: name,
        targetScore: _targetScore,
        turnTimeLimit: _turnTimeLimit,
      );
    } catch (e) {
      debugPrint('Create room error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Oda oluşturulamadı. Lütfen tekrar deneyin.';
        });
      }
    }
  }

  Future<void> _joinRoom() async {
    final name = _nameController.text.trim();
    final code = _roomCodeController.text.trim().toUpperCase();
    if (name.isEmpty || code.isEmpty) return;
    _isHost = false;
    _myRegisteredName = name;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      if (_signalRService == null) {
        final apiService = context.read<ApiService>();
        final hubUrl = '${apiService.baseUrl}/duelHub';
        _signalRService = DuelSignalRService(customUrl: hubUrl);
        _setupSignalRListeners();
      }
      _myRoomCode = code;
      await _signalRService!.joinRoom(roomCode: code, userId: 2, userName: name);
    } catch (e) {
      debugPrint('Join room error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Odaya bağlanılamadı. Kodu kontrol edin.';
        });
      }
    }
  }

  Future<void> _submitGuess(String guess) async {
    if (_myRoomCode == null || _isMyGuessSubmitted || _signalRService == null) return;
    setState(() => _isMyGuessSubmitted = true);
    await _signalRService!.submitGuess(roomCode: _myRoomCode!, guess: guess);
  }

  Future<void> _passTurn() async {
    if (_myRoomCode == null || _isMyGuessSubmitted || _signalRService == null) return;
    setState(() => _isMyGuessSubmitted = true);
    await _signalRService!.passTurn(roomCode: _myRoomCode!);
  }

  Future<void> _offerSurrender() async {
    if (_myRoomCode == null || _signalRService == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('🏳️ ', style: TextStyle(fontSize: 20)),
            Text('Oyunu Bitir (Pes Et)?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Rakibe oyunu sonlandırma teklifi gönderilecek. Rakip kabul ederse maç tamamlanacaktır.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Vazgeç', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Teklifi Gönder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _signalRService!.offerSurrender(roomCode: _myRoomCode!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🏳️ Pes etme teklifi rakibe iletildi.'), backgroundColor: Colors.orangeAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E141D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131A26),
        title: const Row(
          children: [
            Text('⚔️ ', style: TextStyle(fontSize: 20)),
            Text(
              'ONLINE 1v1 DÜELLO',
              style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        ),
        actions: [
          if (_phase == OnlineDuelPhase.playing)
            IconButton(
              icon: const Icon(Icons.flag_rounded, color: Colors.redAccent),
              tooltip: 'Oyunu Bitir (Pes Et Teklifi)',
              onPressed: _offerSurrender,
            ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case OnlineDuelPhase.lobby:
        return DuelLobbyWidget(
          nameController: _nameController,
          roomCodeController: _roomCodeController,
          selectedTargetScore: _targetScore,
          onTargetScoreChanged: (val) => setState(() => _targetScore = val),
          selectedTurnTime: _turnTimeLimit,
          onTurnTimeChanged: (val) => setState(() => _turnTimeLimit = val),
          censorProfanity: _censorProfanity,
          onCensorProfanityChanged: (val) => setState(() => _censorProfanity = val),
          isLoading: _isLoading,
          errorMessage: _errorMessage,
          onCreateRoom: _createRoom,
          onJoinRoom: _joinRoom,
        );
      case OnlineDuelPhase.waitingOpponent:
        return DuelWaitingRoomWidget(
          roomCode: _myRoomCode,
          onCancel: () {
            _signalRService?.disconnect();
            setState(() => _phase = OnlineDuelPhase.lobby);
          },
        );
      case OnlineDuelPhase.playing:
        return _buildPlayingView();
      case OnlineDuelPhase.roundResult:
        return DuelRoundResultWidget(
          result: _lastRoundResult,
          player1Name: _player1Name,
          player2Name: _player2Name,
        );
      case OnlineDuelPhase.gameOver:
        return DuelGameOverWidget(
          gameOverMessage: _gameOverMessage,
          onReturnToMenu: () {
            _signalRService?.disconnect();
            Navigator.of(context).pop();
          },
        );
    }
  }

  Widget _buildPlayingView() {
    final provider = context.watch<GameProvider>();
    final List<GameItem> gameList = provider.gamesList;
    final reviews = _currentRoundData?.yorumlar ?? [];
    final isMyTurn = _isMyTurn;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Column(
      children: [
        DuelScoreboard(
          player1Name: _player1Name,
          player1Score: _player1Score,
          player2Name: _player2Name,
          player2Score: _player2Score,
          currentRound: _currentRound,
          targetScore: _targetScore,
          p1AvatarEmoji: _isHost ? (provider.equippedAvatar?.iconEmoji ?? '🤖') : '🧙‍♂️',
          p1FrameId: _isHost ? (provider.equippedFrameId ?? 'frame_gold') : 'frame_gold',
          p2AvatarEmoji: !_isHost ? (provider.equippedAvatar?.iconEmoji ?? '🦊') : '🐱',
          p2FrameId: !_isHost ? (provider.equippedFrameId ?? 'frame_diamond') : 'frame_diamond',
          isCompact: isKeyboardOpen,
        ),

        // Sıra, Sayaç & Pas Geç Banner'ı
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          color: isMyTurn
              ? Colors.amberAccent.withValues(alpha: 0.18)
              : const Color(0xFF161F2E),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(isMyTurn ? '🎯 ' : '⏳ ', style: const TextStyle(fontSize: 14)),
                  Text(
                    isMyTurn
                        ? 'SIRA SENDE!'
                        : 'Sıra: $_currentTurnPlayer',
                    style: TextStyle(
                      color: isMyTurn ? Colors.amberAccent : Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_turnTimeLimit > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _remainingSeconds <= 5
                            ? Colors.redAccent.withValues(alpha: 0.25)
                            : Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _remainingSeconds <= 5 ? Colors.redAccent : Colors.white24,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            size: 12,
                            color: _remainingSeconds <= 5 ? Colors.redAccent : Colors.amberAccent,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${_remainingSeconds}s',
                            style: TextStyle(
                              color: _remainingSeconds <= 5 ? Colors.redAccent : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isMyTurn && !_isMyGuessSubmitted) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _passTurn,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6)),
                        ),
                        child: const Text(
                          '⏭️ Pas',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        if (_turnStatusBanner != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            color: Colors.orangeAccent.withValues(alpha: 0.15),
            child: Text(
              _turnStatusBanner!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
            ),
          ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Oyun Tür İpuçları (Hemen çıkmaz, 3. ipucunda açılır)
                if (_revealedReviewCount >= 3 && (_currentRoundData?.turler.isNotEmpty ?? false)) ...[
                  const Row(
                    children: [
                      Text('🏷️ ', style: TextStyle(fontSize: 12)),
                      Text(
                        'Açılan Tür İpuçları:',
                        style: TextStyle(color: Colors.amberAccent, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _currentRoundData!.turler
                        .map((t) => Chip(
                              label: Text(t, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                              backgroundColor: SteamColors.cardBg,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ] else if (_currentRoundData?.turler.isNotEmpty ?? false) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 13, color: Colors.white38),
                        SizedBox(width: 6),
                        Text(
                          'Tür İpuçları (3. İpucunda Açılır)',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                DuelReviewsList(
                  reviews: reviews,
                  revealedCount: _revealedReviewCount,
                  censorProfanity: _censorProfanity,
                ),
              ],
            ),
          ),
        ),

        // %100 Ferah Tam Genişlikte Tahmin Girişi
        if (isMyTurn && !_isMyGuessSubmitted)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: GameGuessInput(
              games: gameList,
              onSubmitted: (name) => _submitGuess(name),
            ),
          )
        else if (!isMyTurn)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: SteamColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38),
                ),
                const SizedBox(width: 10),
                Text(
                  '$_currentTurnPlayer tahmin yapıyor...',
                  style: const TextStyle(color: Colors.white54, fontSize: 12.5),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
