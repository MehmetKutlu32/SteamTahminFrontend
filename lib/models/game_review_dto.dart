class GameReviewDto {
  final int sira;
  final String kullaniciAdi;
  final int oynamaSuresiSaati;
  final String yorum;
  final bool tavsiye;
  final String? tarih;

  const GameReviewDto({
    required this.sira,
    required this.kullaniciAdi,
    required this.oynamaSuresiSaati,
    required this.yorum,
    required this.tavsiye,
    this.tarih,
  });

  factory GameReviewDto.fromJson(Map<String, dynamic> json) {
    // Tarih alanını farklı isimlendirmelere ve Unix timestamp formatlarına göre akıllıca parse et
    String? parsedDate;
    if (json['incelemeTarihi'] != null && json['incelemeTarihi'].toString().isNotEmpty) {
      parsedDate = _formatDateString(json['incelemeTarihi'].toString());
    } else if (json['tarih'] != null && json['tarih'].toString().isNotEmpty) {
      parsedDate = _formatDateString(json['tarih'].toString());
    } else if (json['yazilmaTarihi'] != null) {
      parsedDate = _formatDateString(json['yazilmaTarihi'].toString());
    } else if (json['date'] != null) {
      parsedDate = _formatDateString(json['date'].toString());
    } else if (json['timestamp_created'] != null || json['timestampCreated'] != null) {
      final ts = json['timestamp_created'] as int? ?? json['timestampCreated'] as int? ?? 0;
      if (ts > 0) {
        final dt = DateTime.fromMillisecondsSinceEpoch(ts > 10000000000 ? ts : ts * 1000);
        parsedDate = '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      }
    }

    final rawYorum = json['yorum'] ??
        json['Yorum'] ??
        json['reviewText'] ??
        json['ReviewText'] ??
        json['review'] ??
        json['Review'] ??
        json['text'] ??
        '';

    final rawSira = json['sira'] ?? json['Sira'] ?? 0;
    final rawKullanici = json['kullaniciAdi'] ??
        json['KullaniciAdi'] ??
        json['userName'] ??
        json['UserName'] ??
        json['author'] ??
        'Oyuncu';

    final rawOynama = json['oynamaSuresiSaati'] ??
        json['OynamaSuresiSaati'] ??
        json['playtimeHours'] ??
        json['PlaytimeHours'] ??
        0;

    final rawTavsiye = json['tavsiye'] ??
        json['Tavsiye'] ??
        json['isPositive'] ??
        json['IsPositive'] ??
        true;

    return GameReviewDto(
      sira: rawSira is int ? rawSira : int.tryParse(rawSira.toString()) ?? 0,
      kullaniciAdi: rawKullanici.toString(),
      oynamaSuresiSaati: rawOynama is int ? rawOynama : (double.tryParse(rawOynama.toString())?.toInt() ?? 0),
      yorum: rawYorum.toString(),
      tavsiye: rawTavsiye is bool ? rawTavsiye : rawTavsiye.toString().toLowerCase() == 'true',
      tarih: parsedDate,
    );
  }

  static String _formatDateString(String input) {
    // Eğer ISO 8601 tarih geldiyse (örn: 2023-05-14T10:20:00Z) sadeleştir
    try {
      final dt = DateTime.tryParse(input);
      if (dt != null) {
        return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      }
    } catch (_) {}
    return input;
  }

  Map<String, dynamic> toJson() {
    return {
      'sira': sira,
      'kullaniciAdi': kullaniciAdi,
      'oynamaSuresiSaati': oynamaSuresiSaati,
      'yorum': yorum,
      'tavsiye': tavsiye,
      if (tarih != null) 'tarih': tarih,
    };
  }
}
