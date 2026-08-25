import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../models/game_review_dto.dart';

class DuelRoundEvent {
  final int round;
  final int? appId;
  final String? cikisTarihi;
  final List<String> turler;
  final List<GameReviewDto> yorumlar;
  final int revealedCount;
  final String currentTurnPlayer;
  final int? turnTimeLimit;

  DuelRoundEvent({
    required this.round,
    this.appId,
    this.cikisTarihi,
    this.turler = const [],
    this.yorumlar = const [],
    this.revealedCount = 1,
    this.currentTurnPlayer = '',
    this.turnTimeLimit,
  });

  factory DuelRoundEvent.fromJson(Map<dynamic, dynamic> json) {
    final dynamic rawYorumlar = json['Yorumlar'] ??
        json['yorumlar'] ??
        json['Reviews'] ??
        json['reviews'] ??
        [];

    final List<GameReviewDto> parsedYorumlar = [];
    if (rawYorumlar is List) {
      for (var item in rawYorumlar) {
        if (item is Map) {
          parsedYorumlar.add(GameReviewDto.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final dynamic rawTurler = json['Turler'] ??
        json['turler'] ??
        json['Genres'] ??
        json['genres'] ??
        [];

    final List<String> parsedTurler = [];
    if (rawTurler is List) {
      for (var item in rawTurler) {
        parsedTurler.add(item.toString());
      }
    }

    return DuelRoundEvent(
      round: (json['Round'] ?? json['round'] ?? 1) as int,
      appId: (json['AppId'] ?? json['appId']) as int?,
      cikisTarihi: (json['CikisTarihi'] ?? json['cikisTarihi'])?.toString(),
      turler: parsedTurler,
      yorumlar: parsedYorumlar,
      revealedCount: (json['RevealedCount'] ?? json['revealedCount'] ?? 1) as int,
      currentTurnPlayer: (json['CurrentTurnPlayer'] ?? json['currentTurnPlayer'] ?? '').toString(),
      turnTimeLimit: (json['TurnTimeLimit'] ?? json['turnTimeLimit']) as int?,
    );
  }
}

class DuelTurnEvent {
  final String currentTurnPlayer;
  final String? lastGuesserName;
  final String? lastGuess;
  final bool isCorrect;
  final int revealedCount;
  final String? message;
  final int? turnTimeLimit;

  DuelTurnEvent({
    required this.currentTurnPlayer,
    this.lastGuesserName,
    this.lastGuess,
    this.isCorrect = false,
    this.revealedCount = 1,
    this.message,
    this.turnTimeLimit,
  });

  factory DuelTurnEvent.fromJson(Map<dynamic, dynamic> json) {
    return DuelTurnEvent(
      currentTurnPlayer: (json['CurrentTurnPlayer'] ?? json['currentTurnPlayer'] ?? '').toString(),
      lastGuesserName: (json['LastGuesserName'] ?? json['lastGuesserName'])?.toString(),
      lastGuess: (json['LastGuess'] ?? json['lastGuess'])?.toString(),
      isCorrect: (json['IsCorrect'] ?? json['isCorrect'] ?? false) as bool,
      revealedCount: (json['RevealedCount'] ?? json['revealedCount'] ?? 1) as int,
      message: (json['Message'] ?? json['message'])?.toString(),
      turnTimeLimit: (json['TurnTimeLimit'] ?? json['turnTimeLimit']) as int?,
    );
  }
}

class DuelResultEvent {
  final String correctGameName;
  final String? player1Guess;
  final String? player2Guess;
  final int player1Score;
  final int player2Score;
  final String winner;

  DuelResultEvent({
    required this.correctGameName,
    this.player1Guess,
    this.player2Guess,
    required this.player1Score,
    required this.player2Score,
    required this.winner,
  });

  factory DuelResultEvent.fromJson(Map<dynamic, dynamic> json) {
    return DuelResultEvent(
      correctGameName: (json['CorrectGameName'] ??
              json['correctGameName'] ??
              json['OyunAdi'] ??
              json['oyunAdi'] ??
              json['GameName'] ??
              json['gameName'] ??
              '')
          .toString(),
      player1Guess: (json['Player1Guess'] ?? json['player1Guess'])?.toString(),
      player2Guess: (json['Player2Guess'] ?? json['player2Guess'])?.toString(),
      player1Score: (json['Player1Score'] ?? json['player1Score'] ?? 0) as int,
      player2Score: (json['Player2Score'] ?? json['player2Score'] ?? 0) as int,
      winner: (json['Winner'] ?? json['winner'] ?? '').toString(),
    );
  }
}

class DuelSignalRService {
  HubConnection? _hubConnection;
  final String _serverUrl;

  // Event Callbacks
  Function(String roomCode)? onRoomCreated;
  Function(String errorMessage)? onJoinFailed;
  Function(String p1Name, String p2Name)? onMatchFound;
  Function(DuelRoundEvent round)? onNewRoundStarted;
  Function(DuelTurnEvent turn)? onTurnChanged;
  Function()? onOpponentSubmittedGuess;
  Function(DuelResultEvent result)? onRoundResult;
  Function(int winnerUserId, String finalScore)? onGameOver;
  Function()? onOpponentDisconnected;
  Function(String fromUserName)? onSurrenderOffered;
  Function(String rejectedByUserName)? onSurrenderRejected;

  DuelSignalRService({String? customUrl})
      : _serverUrl = customUrl ?? _getDefaultHubUrl();

  static const String liveHubUrl = 'https://steamtahminbackend.onrender.com/duelHub';

  static String _getDefaultHubUrl() {
    return liveHubUrl;
  }

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  /// Hub Bağlantısını Başlat
  Future<void> connect() async {
    if (isConnected) return;

    _hubConnection = HubConnectionBuilder()
        .withUrl(_serverUrl)
        .withAutomaticReconnect()
        .build();

    _registerHandlers();

    try {
      await _hubConnection!.start();
      debugPrint('SignalR DuelHub Connected to $_serverUrl');
    } catch (e) {
      debugPrint('SignalR Connection Error: $e');
      rethrow;
    }
  }

  void _registerHandlers() {
    if (_hubConnection == null) return;

    void handleRoomCreated(List<dynamic>? arguments) {
      debugPrint('[SignalR] RoomCreated: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final arg = arguments[0];
        String roomCode;
        if (arg is Map) {
          roomCode = arg['roomCode']?.toString() ?? arg['RoomCode']?.toString() ?? arg.toString();
        } else {
          roomCode = arg.toString();
        }
        onRoomCreated?.call(roomCode);
      }
    }

    _hubConnection!.on('RoomCreated', handleRoomCreated);
    _hubConnection!.on('roomCreated', handleRoomCreated);

    void handleJoinFailed(List<dynamic>? arguments) {
      debugPrint('[SignalR] JoinFailed: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final error = arguments[0].toString();
        onJoinFailed?.call(error);
      }
    }

    _hubConnection!.on('JoinFailed', handleJoinFailed);
    _hubConnection!.on('joinFailed', handleJoinFailed);

    _hubConnection!.on('MatchFound', (arguments) {
      debugPrint('[SignalR] MatchFound: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map;
        final p1 = data['Player1']?.toString() ?? data['player1']?.toString() ?? 'P1';
        final p2 = data['Player2']?.toString() ?? data['player2']?.toString() ?? 'P2';
        onMatchFound?.call(p1, p2);
      }
    });

    _hubConnection!.on('NewRoundStarted', (arguments) {
      debugPrint('[SignalR] NewRoundStarted: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map;
        final roundEvent = DuelRoundEvent.fromJson(Map<dynamic, dynamic>.from(data));
        onNewRoundStarted?.call(roundEvent);
      }
    });

    _hubConnection!.on('TurnChanged', (arguments) {
      debugPrint('[SignalR] TurnChanged: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map;
        final turnEvent = DuelTurnEvent.fromJson(Map<dynamic, dynamic>.from(data));
        onTurnChanged?.call(turnEvent);
      }
    });

    _hubConnection!.on('OpponentSubmittedGuess', (arguments) {
      debugPrint('[SignalR] OpponentSubmittedGuess');
      onOpponentSubmittedGuess?.call();
    });

    _hubConnection!.on('RoundResult', (arguments) {
      debugPrint('[SignalR] RoundResult: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map;
        final resultEvent = DuelResultEvent.fromJson(Map<dynamic, dynamic>.from(data));
        onRoundResult?.call(resultEvent);
      }
    });

    _hubConnection!.on('GameOver', (arguments) {
      debugPrint('[SignalR] GameOver: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map;
        final winnerId = data['WinnerUserId'] as int? ?? (data['winnerUserId'] as int? ?? 0);
        final finalScore = data['FinalScore'] as String? ?? (data['finalScore'] as String? ?? '');
        onGameOver?.call(winnerId, finalScore);
      }
    });

    _hubConnection!.on('SurrenderOffered', (arguments) {
      debugPrint('[SignalR] SurrenderOffered: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final fromUser = arguments[0].toString();
        onSurrenderOffered?.call(fromUser);
      }
    });

    _hubConnection!.on('SurrenderRejected', (arguments) {
      debugPrint('[SignalR] SurrenderRejected: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final byUser = arguments[0].toString();
        onSurrenderRejected?.call(byUser);
      }
    });

    _hubConnection!.on('OpponentDisconnected', (arguments) {
      debugPrint('[SignalR] OpponentDisconnected');
      onOpponentDisconnected?.call();
    });
  }

  /// 1. Oda Oluştur
  Future<void> createRoom({
    required int userId,
    required String userName,
    int targetScore = 3,
    int turnTimeLimit = 30,
  }) async {
    await _ensureConnected();
    dynamic result;
    try {
      result = await _hubConnection!.invoke('CreateRoom', args: [userId, userName, targetScore, turnTimeLimit]);
    } catch (_) {
      try {
        result = await _hubConnection!.invoke('CreateRoom', args: [userId, userName, targetScore]);
      } catch (_) {
        result = await _hubConnection!.invoke('CreateRoom', args: [userId, userName]);
      }
    }
    if (result != null) {
      String code;
      if (result is Map) {
        code = result['roomCode']?.toString() ?? result['RoomCode']?.toString() ?? result.toString();
      } else {
        code = result.toString();
      }
      if (code.isNotEmpty) {
        onRoomCreated?.call(code);
      }
    }
  }

  /// 2. Odaya Katıl
  Future<void> joinRoom({
    required String roomCode,
    required int userId,
    required String userName,
  }) async {
    await _ensureConnected();
    await _hubConnection!.invoke('JoinRoom', args: [roomCode, userId, userName]);
  }

  /// 3. Tahmin Gönder
  Future<void> submitGuess({
    required String roomCode,
    required String guess,
  }) async {
    await _ensureConnected();
    await _hubConnection!.invoke('SubmitGuess', args: [roomCode, guess]);
  }

  /// 4. Pas Geç (Tur Sırasını Devret)
  Future<void> passTurn({required String roomCode}) async {
    await _ensureConnected();
    try {
      await _hubConnection!.invoke('PassTurn', args: [roomCode]);
    } catch (_) {
      await submitGuess(roomCode: roomCode, guess: 'PAS_GECTI');
    }
  }

  /// 5. Pes Etme / Oyunu Bitirme Teklifi Gönder
  Future<void> offerSurrender({required String roomCode}) async {
    await _ensureConnected();
    try {
      await _hubConnection!.invoke('OfferSurrender', args: [roomCode]);
    } catch (_) {}
  }

  /// 6. Pes Etme Teklifine Yanıt Ver
  Future<void> respondSurrender({
    required String roomCode,
    required bool accepted,
  }) async {
    await _ensureConnected();
    try {
      await _hubConnection!.invoke('RespondSurrender', args: [roomCode, accepted]);
    } catch (_) {}
  }

  Future<void> _ensureConnected() async {
    if (!isConnected) {
      await connect();
    }
  }

  /// Bağlantıyı Kapat
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _hubConnection = null;
    }
  }
}
