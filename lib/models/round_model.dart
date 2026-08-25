import 'game_review_dto.dart';

class RoundModel {
  final int appId;
  final String oyunAdi;
  final List<GameReviewDto> yorumlar;
  final String? cikisTarihi;
  final List<String> turler;

  const RoundModel({
    required this.appId,
    required this.oyunAdi,
    required this.yorumlar,
    this.cikisTarihi,
    this.turler = const [],
  });

  factory RoundModel.fromJson(Map<String, dynamic> json) {
    var rawYorumlar = json['yorumlar'] as List<dynamic>? ?? [];
    List<GameReviewDto> parsedYorumlar = rawYorumlar
        .map((e) => GameReviewDto.fromJson(e as Map<String, dynamic>))
        .toList();

    var rawTurler = json['turler'] as List<dynamic>? ?? (json['genres'] as List<dynamic>? ?? []);
    List<String> parsedTurler = rawTurler.map((e) => e.toString()).toList();

    return RoundModel(
      appId: json['appId'] as int? ?? 0,
      oyunAdi: json['oyunAdi'] as String? ?? (json['name'] as String? ?? ''),
      yorumlar: parsedYorumlar,
      cikisTarihi: json['cikisTarihi'] as String? ?? (json['releaseDate'] as String?),
      turler: parsedTurler,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'oyunAdi': oyunAdi,
      'yorumlar': yorumlar.map((y) => y.toJson()).toList(),
      'cikisTarihi': cikisTarihi,
      'turler': turler,
    };
  }

  RoundModel copyWith({
    int? appId,
    String? oyunAdi,
    List<GameReviewDto>? yorumlar,
    String? cikisTarihi,
    List<String>? turler,
  }) {
    return RoundModel(
      appId: appId ?? this.appId,
      oyunAdi: oyunAdi ?? this.oyunAdi,
      yorumlar: yorumlar ?? this.yorumlar,
      cikisTarihi: cikisTarihi ?? this.cikisTarihi,
      turler: turler ?? this.turler,
    );
  }
}
