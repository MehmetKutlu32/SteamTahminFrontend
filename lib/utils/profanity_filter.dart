/// Client-side yüksek performanslı, Türkçe büyük/küçük harf duyarlı ve masum kelimeleri (çocuk, normal, deneme vb.) koruyan küfür filtreleme servisi
class ProfanityFilter {
  // 1. Kökten türeyebilen belirgin küfürler (Örn: orospular, siktirler, şerefsizler, yavşaklar)
  static final List<String> _inflectionalProfanities = [
    "orospuçocuğu",
    "orospucocugu",
    "orospuluk",
    "orospu",
    "siktirgit",
    "siktir",
    "sikeyim",
    "sikerim",
    "siktim",
    "sikik",
    "sikko",
    "sik",
    "yarrakkafa",
    "yarakkafa",
    "dalyarrak",
    "dalyarak",
    "yarrak",
    "yarak",
    "amınakoyayım",
    "aminakoyayim",
    "amınagoyim",
    "amkoyim",
    "amına",
    "amina",
    "amcık",
    "amcik",
    "amguard",
    "ananısikeyim",
    "ananisikeyim",
    "ananı",
    "anani",
    "bacını",
    "bacini",
    "götveren",
    "gotveren",
    "götlek",
    "gotlek",
    "götoş",
    "gotos",
    "göt",
    "got",
    "taşşak",
    "tassak",
    "daşşak",
    "dassak",
    "taşak",
    "tasak",
    "yavşak",
    "yavsak",
    "pezevenk",
    "şerefsiz",
    "serefsiz",
    "kahpe",
    "puşt",
    "pust",
    "gavat",
    "kavat",
    "ibne",
    "kancık",
    "kancik",
    "kerane",
    "kerhane",
    "dölisrafı",
    "dolisrafi",
    "gerizekalı",
    "gerizekali",
    "beyinsiz",
    "haysiyetsiz",
    "namussuz",
    "cibiliyetsiz",
    "sürtük",
    "surtuk",
    "fahişe",
    "fahise",
    "hırbo",
    "hirbo",
    "boktan",
    "bokum",
    "boku",
    "bok",
    "sidik",
    "dingil",
    // İngilizce
    "motherfucker",
    "fucking",
    "fuck",
    "asshole",
    "bitch",
    "pussy",
    "cunt",
    "dick",
    "shit",
  ];

  // 2. Tamlama/Boşluklu/Noktalı Kalıplar (Tam eşleşir)
  static final List<String> _phraseProfanities = [
    "am kafalı",
    "am kafali",
    "sik kırığı",
    "sik kirigi",
    "göt lalesi",
    "got lalesi",
    "döl israfı",
    "dol israfi",
    "o.ç",
    "o.c",
    "o.e",
    "ö.e",
    "o ç",
    "o c",
    "o e",
    "a.m.k",
    "a.q",
    "a m k",
    "a q",
    "p.i.ç",
    "p.i.c",
    "p i ç",
    "p i c",
  ];

  // 3. Masum kelimelerle karışmaması için SADECE TAM KELİME olarak eşleşmesi gereken kısa argo/kısaltmalar
  // (Örn: 'oç', 'aq', 'mal', 'it', 'meme', 'çük' tek başına eşleşir; 'çocuk', 'normal', 'deneme', 'çeşit' etkilenmez!)
  static final List<String> _exactWordProfanities = [
    "oç",
    "oc",
    "oe",
    "öe",
    "oçlar",
    "oclar",
    "amk",
    "amq",
    "aq",
    "piç",
    "pic",
    "piçler",
    "picler",
    "çük",
    "döl",
    "dol",
    "meme",
    "salak",
    "aptal",
    "ahmak",
    "mal",
    "mallar",
    "it",
    "itler",
    "köpek",
    "kopek",
  ];

  /// Türkçe karakterleri (İ, I, Ş, Ç, Ğ, Ü, Ö) 1:1 uzunlukta küçük harfe çevirir
  static String normalizeTurkish(String str) {
    return str
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .replaceAll('Ş', 'ş')
        .replaceAll('Ç', 'ç')
        .replaceAll('Ğ', 'ğ')
        .replaceAll('Ü', 'ü')
        .replaceAll('Ö', 'ö')
        .toLowerCase();
  }

  // Regex Motoru
  static final RegExp _profaneRegex = RegExp(
    r'(?:' +
        [
          // Boşluklu/noktalı kalıplar
          ...(_phraseProfanities.map(normalizeTurkish).toSet().toList()
                ..sort((a, b) => b.length.compareTo(a.length)))
              .map((w) => r'(?<![a-z0-9ıışğüöç])' + RegExp.escape(w) + r'(?![a-z0-9ıışğüöç])'),

          // Tam kelime eşleşmesi gerekenler (çocuk, normal, deneme gibi kelimeleri korur)
          ...(_exactWordProfanities.map(normalizeTurkish).toSet().toList()
                ..sort((a, b) => b.length.compareTo(a.length)))
              .map((w) => r'(?<![a-z0-9ıışğüöç])' + RegExp.escape(w) + r'(?![a-z0-9ıışğüöç])'),

          // Belirgin kökler ve ekleri
          ...(_inflectionalProfanities.map(normalizeTurkish).toSet().toList()
                ..sort((a, b) => b.length.compareTo(a.length)))
              .map((w) => r'(?<![a-z0-9ıışğüöç])' + RegExp.escape(w) + r'[a-z0-9ıışğüöç]*'),
        ].join('|') +
        r')',
    caseSensitive: false,
  );

  /// Metindeki tüm küfürleri sansürler, Türkçe masum kelimelere (çocuk, normal, deneme vb.) asla dokunmaz
  static String censor(String text) {
    if (text.isEmpty) return text;

    final normalized = normalizeTurkish(text);
    final matches = _profaneRegex.allMatches(normalized).toList();
    if (matches.isEmpty) return text;

    final buffer = StringBuffer();
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start < lastEnd) continue; // Çakışan eşleşmeleri önle

      // Eşleşme öncesindeki temiz metni ekle
      buffer.write(text.substring(lastEnd, match.start));

      // Orijinal metindeki büyük/küçük harf yapısını koruyarak maskele
      final originalWord = text.substring(match.start, match.end);
      if (originalWord.length <= 2) {
        buffer.write('**');
      } else if (originalWord.length == 3) {
        buffer.write('${originalWord[0]}*${originalWord[2]}');
      } else {
        buffer.write(
          '${originalWord[0]}${'*' * (originalWord.length - 2)}${originalWord[originalWord.length - 1]}',
        );
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      buffer.write(text.substring(lastEnd));
    }

    return buffer.toString();
  }
}
