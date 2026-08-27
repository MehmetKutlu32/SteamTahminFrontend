import 'dart:math';
import '../models/game_review_dto.dart';

/// Sahtekar (Imposter) modu için genişletilmiş, gerçekçi ve tür bakımından zengin sahte Steam incelemeleri havuzu.
/// Tekrarları önleyen akıllı sıra ve geçmiş (history) mekanizmasına sahiptir.
class ImposterCatalog {
  ImposterCatalog._();

  static final List<int> _recentlyUsedIndices = [];

  static const List<GameReviewDto> fakePool = [
    // 🧟 Zombi, Hayatta Kalma ve Zanaat
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'ZombiAvcisi',
      oynamaSuresiSaati: 520,
      yorum: 'Envanter yönetimi ve zanaat sistemi inanılmaz derin. Arkadaşlarla üs kurup zombi dalgalarına karşı hayatta kalmak çok keyifli.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KalasUstadı',
      oynamaSuresiSaati: 134,
      yorum: 'Balta bulmak için 3 saat harcadım, tam buldum derken enfeksiyon kapıp öldüm. 10/10 bir daha oynarım.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'Radyasyonzede',
      oynamaSuresiSaati: 78,
      yorum: 'Radyasyon seviyesi çok hızlı artıyor ve su arıtma filtresi bulmak imkansız gibi. Açlıktan ağaç kabuğu kemiriyoruz.',
      tavsiye: false,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'DogadaTekBasina',
      oynamaSuresiSaati: 210,
      yorum: 'Barınak inşa edip kışın donmamak için odun stoklarken ayı bastı. Panikle meşaleyi çadıra attım her şey yandı.',
      tavsiye: true,
    ),

    // ⚔️ Souls-like, Boss ve Zorlu Aksiyon
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'BossHunter',
      oynamaSuresiSaati: 310,
      yorum: 'Piksel sanat tasarımı ve boss dövüşlerindeki zorluk dengesi şahane. Souls-like türünü sevenler kaçırmasın.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'ParryTanrisi',
      oynamaSuresiSaati: 415,
      yorum: 'Aynı boss beni 47 defa kesti. 48. denemede parry zamanlamasını çözüp tek canla aldım, ellerim titriyor.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'RageQuitter',
      oynamaSuresiSaati: 62,
      yorum: 'Dodge atıyorum ama hitboxlar o kadar bozuk ki havadaki kılıç rüzgarı bile tek atıyor. Kolumu ısırdım sinirden.',
      tavsiye: false,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KaranlikRuh',
      oynamaSuresiSaati: 195,
      yorum: 'İksir şişesi bittiğinde haritanın öbür ucundaki kayıt noktasına koşmak resmen kalp krizi sebebi.',
      tavsiye: true,
    ),

    // 🏎️ Yarış, Sürüş ve Araç Simülasyonu
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'DriftKrali',
      oynamaSuresiSaati: 45,
      yorum: 'Fizik motoru aşırı eğlenceli ve komik. Arabayla virajı alamayıp uçurumdan yuvarlanırken kahkahalara boğulduk.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'AsfaltFirtinasi',
      oynamaSuresiSaati: 640,
      yorum: 'Direksiyon setiyle oynayınca bambaşka bir seviye. Lastik aşınması ve pit-stop taktikleri birebir aktarılmış.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KamyoncuReis',
      oynamaSuresiSaati: 890,
      yorum: 'Tırla viyadükten aşağı uçtum yüküm paramparça oldu, sigorta da karşılamadı. Gerçek hayat simülasyonu resmen.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'PistonKupasi',
      oynamaSuresiSaati: 28,
      yorum: 'Gecikme süresi yüzünden vites geçişleri takılıyor. Çevrimiçi lobilerde herkes birbirine çarpıyor yarış falan yok.',
      tavsiye: false,
    ),

    // 📜 RYO, Hikaye ve Diyaloglar
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'HikayeSever',
      oynamaSuresiSaati: 88,
      yorum: 'Hikayesi ve müzikleri insanı büyülüyor. Karakterler arası diyaloglar ve seçimlerin sonuca etkisi harika işlenmiş.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'Gorevkolik',
      oynamaSuresiSaati: 142,
      yorum: 'Yan görev yapmaktan ana görevi unuttum. 80 saattir köydeki kayıp tavukları arıyorum.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'DuygusalOyuncu',
      oynamaSuresiSaati: 95,
      yorum: 'Verdiğim bir diyalog kararı yüzünden en sevdiğim yoldaşım beni terk etti. 3 gündür vicdan azabı çekiyorum.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'SonKurban',
      oynamaSuresiSaati: 54,
      yorum: 'Bütün oyun boyunca yaptığım kritik seçimlerin sadece finaldeki ışığın rengini değiştirdiğini görmek hayal kırıklığı.',
      tavsiye: false,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KarakterUzmani',
      oynamaSuresiSaati: 12,
      yorum: 'Karakter yaratma ekranında tam 4 saat harcadım, sonra oyuna girip kask takınca yüzü hiç görünmedi.',
      tavsiye: true,
    ),

    // 🏰 Strateji, Şehir Kurma ve Otomasyon
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'StratejiDehasi',
      oynamaSuresiSaati: 1250,
      yorum: 'Tek bir tur daha deyip sabah ezanını duydum. Komşu krallığa casus sokup tahtı içeriden devirdim.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'SehirPlanlamaci',
      oynamaSuresiSaati: 380,
      yorum: 'Trafik tıkanıklığını çözeceğim diye 6 katlı viyadük ve köprü yaptım, ambulanslar yine de kavşakta sıkıştı.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'Otomasyoncu',
      oynamaSuresiSaati: 560,
      yorum: 'Konveyör bantlarını o kadar karmaşık bağladım ki demir madeni yerine yanlışlıkla bakır fırınına kömür basmışım.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'BarisciKral',
      oynamaSuresiSaati: 72,
      yorum: 'Yapay zeka en kolay zorlukta bile durduk yere savaş ilan edip 50 bin askerle başkentime dayandı, denge sıfır.',
      tavsiye: false,
    ),

    // 👻 Korku ve Psikolojik Gerilim
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KorkakTavsan',
      oynamaSuresiSaati: 8,
      yorum: 'Fenerimin pili bittiğinde koridorun sonundaki nefes sesini duydum ve Alt+F4 çektim. Kulaklıkla oynamayın.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'GeceNobetcisi',
      oynamaSuresiSaati: 34,
      yorum: 'Güvenlik kameralarına bakarken canavarın doğrudan ekrana gözünü diktiği an sandalyeden düştüm.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KorkusuzEleştirmen',
      oynamaSuresiSaati: 2,
      yorum: 'Sadece ucuz ani ses patlaması koymuşlar. Ne atmosfer var ne hikaye, 20 dakikada iade ettim.',
      tavsiye: false,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'SessizGolge',
      oynamaSuresiSaati: 46,
      yorum: 'Telsizden gelen cızırtılı yardım çağrısını takip edip terk edilmiş sığınağa girdim, keşke girmeseydim.',
      tavsiye: true,
    ),

    // 🔫 FPS ve Rekabetçi Nişancı
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'GamerX',
      oynamaSuresiSaati: 145,
      yorum: 'Grafikleri fena değil ama sunucu çökmeleri ve eşleştirme sistemi oyunu mahvetmiş. Kesinlikle tavsiye etmiyorum.',
      tavsiye: false,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'SniperGozu',
      oynamaSuresiSaati: 780,
      yorum: 'Silahların geri tepme hissiyatı ve ses dizaynı muazzam. Her kurşunun ağırlığını hissediyorsunuz.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'TemizOyunYok',
      oynamaSuresiSaati: 230,
      yorum: 'Duman bombasının içinden tek mermiyle kafamdan vurdular. Hilecilerden geçilmiyor, güvenlik yazılımı yetersiz.',
      tavsiye: false,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'ClutchKrali',
      oynamaSuresiSaati: 910,
      yorum: 'Bomba kurma alanına sis atıp bıçakla arkalarından dolandım, tüm takım alkışladı efsane andı.',
      tavsiye: true,
    ),

    // 🃏 Deste Oluşturma ve Kart Oyunları
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'DesteMimari',
      oynamaSuresiSaati: 290,
      yorum: 'Zehir ve kalkan sinerjisi yakalayınca nihai bossu tek turda erittim. Deste oluşturma mekaniği çok bağımlılık yapıyor.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'SanssizZar',
      oynamaSuresiSaati: 67,
      yorum: 'Şans faktörü tamamen size karşı çalışıyor. 10 tur boyunca tek bir saldırı kartı çekemedim ve kaybettim.',
      tavsiye: false,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'ZindanKasıfi',
      oynamaSuresiSaati: 340,
      yorum: 'Her koşuda farklı bir kalıntı ve büyü kombinasyonu çıkıyor. 100 saat oldu hala görmediğim kartlar var.',
      tavsiye: true,
    ),

    // 🌾 Çiftçilik, Cozy ve Balıkçılık
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KoyluCiftci',
      oynamaSuresiSaati: 430,
      yorum: 'Patates ekip sulamaktan, kasabadaki demirciyle arkadaş olmaktan gerçek hayattaki sorumluluklarımı unuttum.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'OltaciDede',
      oynamaSuresiSaati: 175,
      yorum: 'Efsanevi balığı yakalamak için yağmurlu günde 4 saat olta salladım, sonunda oltaya eski bir çizme takıldı.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'YorgunIsci',
      oynamaSuresiSaati: 19,
      yorum: 'Enerji barı çok çabuk bitiyor, 3 ağaç kesince karakter yorulup bayılıyor. Günler çok kısa sürdüğü için yetişmiyor.',
      tavsiye: false,
    ),

    // 🚀 Uzay, Keşif ve Bilim Kurgu
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'AstronotMehmet',
      oynamaSuresiSaati: 320,
      yorum: 'Kara deliğin etrafında turlarken yerçekimi sapanıyla diğer galaksiye fırladım, manzara nefes kesici.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'YildizGezgini',
      oynamaSuresiSaati: 155,
      yorum: 'Gemi yakıtı uzayın ortasında bitti. Oksijen tüpü tükenirken yıldızları izledim, hem hüzünlü hem harika.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'SıkılanKaptan',
      oynamaSuresiSaati: 31,
      yorum: 'Gezegenler arası seyahat bomboş. 20 dakika boyunca sadece düz çizgide uçuyorsunuz, hiçbir etkinlik yok.',
      tavsiye: false,
    ),

    // 🍳 Kaos Partisi ve Fizik Sandboxing
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'SefAhmet',
      oynamaSuresiSaati: 85,
      yorum: 'Arkadaşımın kafasına tencere fırlatıp mutfaktan kaçtım, sonra siparişi yetiştiremeyince restoran yandı.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'RagdollSever',
      oynamaSuresiSaati: 60,
      yorum: 'Karakterin kemikleri jelibondan yapılmış gibi. Merdivenden inerken ayağı takılıp 50 metre yuvarlandı.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'YalnizKalan',
      oynamaSuresiSaati: 15,
      yorum: 'Arkadaşlarla oynamak için aldık ama lobi kurma ekranında sürekli bağlantı kopuyor. Tek başınıza almayın.',
      tavsiye: false,
    ),

    // 🕵️ Gizlilik ve Suikast
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'GolgeAjan',
      oynamaSuresiSaati: 160,
      yorum: 'Kutunun içine saklanıp nöbetçinin geçmesini bekledim, tam suikast yapacakken karakter hapşırdı ve alarm çaldı.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KaranlikAvci',
      oynamaSuresiSaati: 41,
      yorum: 'Düşman yapay zekası ya kör ya da duvarın arkasından görüyor, ortası yok. Gizlilik mekaniği tamamen kırık.',
      tavsiye: false,
    ),

    // 🧩 Bulmaca ve Portal Fiziği
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KupUstasi',
      oynamaSuresiSaati: 92,
      yorum: 'Duvara portal açıp tavandan düşerek hız kazandım ve karşı platforma uçtum. Bölüm tasarımları dahi seviyesinde.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'TirnakKiran',
      oynamaSuresiSaati: 38,
      yorum: 'Zıplama mesafesi milimetrik ayarlanmış. 3 saattir aynı sütuna tutunmaya çalışıyorum, klavyeyi kırmamak için çıktım.',
      tavsiye: false,
    ),

    // 🛡️ MMO ve Pazar Ekonomisi
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'TuccarReis',
      oynamaSuresiSaati: 1600,
      yorum: 'Pazar yerinde ucuza aldığım madenleri gece işleyip sabah 3 katı fiyata sattım. Oyunu borsa simülatörüne çevirdim.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KlanLideri',
      oynamaSuresiSaati: 2100,
      yorum: 'Klan savaşı için 40 kişi toplandık ama sunucu çöktü ve herkes öldü. Yılların emeği 1 saniyede buhar oldu.',
      tavsiye: false,
    ),

    // 😂 Efsanevi Steam Topluluk İncelemeleri & Mizah
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'SteamDedesi',
      oynamaSuresiSaati: 2450,
      yorum: 'Oyunu 2450 saat oynadım, hiç beğenmedim tavsiye etmiyorum.',
      tavsiye: false,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KopekSever',
      oynamaSuresiSaati: 110,
      yorum: 'Oyundaki köpeği sevebiliyorsunuz. Başka bir incelemeye gerek yok, doğrudan satın alın.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'SobaGamer',
      oynamaSuresiSaati: 14,
      yorum: 'Optimizasyon o kadar kötü ki bilgisayar kışın evi ısıtma görevini üstlendi, doğalgaz faturası sıfır geldi.',
      tavsiye: false,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'MuzikDelisi',
      oynamaSuresiSaati: 180,
      yorum: 'Müzikleri için aldım, oynanış da fena değilmiş meğerse. Spotify yerine oyunu açıp menüde bekliyorum.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'EskiEvli',
      oynamaSuresiSaati: 350,
      yorum: 'Eşime bu oyunu öğretirken boşandık. 10/10 boşanma avukatım da oyunu çok beğendi.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'MasohistOyuncu',
      oynamaSuresiSaati: 85,
      yorum: 'Öğretici kısmında 2 saat boyunca öldüm. Oyun beni resmen aşağıladı ama bırakamıyorum.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'OgrenciDostu',
      oynamaSuresiSaati: 310,
      yorum: 'Fiyatı bir döner parası bile değilken indirimde aldım, 300 saat gömdüm. Yapımcıya helal olsun.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'CeneDusen',
      oynamaSuresiSaati: 76,
      yorum: 'Hikaye öyle bir yerde bitti ki devam oyunu çıkana kadar uyuyamam herhalde. Kesinlikle bir başyapıt.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'SitemkarOyuncu',
      oynamaSuresiSaati: 40,
      yorum: 'Arkadaşım hediye etti, 5 dakika sonra oynamayı bıraktı beni tek bıraktı. Oyun güzel ama arkadaşım değil.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'NostaljiAsigi',
      oynamaSuresiSaati: 520,
      yorum: 'Grafikleri 1998 yılından kalma gibi ama atmosferi son 10 yılda çıkan hiçbir yapımda bulamadım.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'UykusuzGece',
      oynamaSuresiSaati: 640,
      yorum: 'Oyunu açıyorum saat 21:00 oluyor, bir bakıyorum sabah 06:30. Zaman algısını yok eden bir kara delik.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KupaAvcisi',
      oynamaSuresiSaati: 890,
      yorum: 'Tüm başarımları açana kadar uyumadım. Son başarım için 10.000 odun kesmem gerekti ama değdi.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'ToplulukUyesi',
      oynamaSuresiSaati: 130,
      yorum: 'Yorumları okuyup gaza gelip aldım. Haklılarmış, hayatımda oynadığım en iyi bağımsız oyunlardan biri.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KaosTemsilcisi',
      oynamaSuresiSaati: 240,
      yorum: 'NPC bana laf attı diye tüm kasabayı ateşe verdim. Özgürlük hissi harika işlenmiş.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'SabirliGamer',
      oynamaSuresiSaati: 470,
      yorum: 'İlk 10 saat hiçbir şey anlamıyorsunuz, sonra bir aydınlanma geliyor ve bağımlısı oluyorsunuz.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'FanSesiSever',
      oynamaSuresiSaati: 95,
      yorum: 'Ekran kartı fanı helikopter pervanesi gibi ses çıkarmaya başladı, oda 40 derece oldu ama değdi.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'DLCKarsiti',
      oynamaSuresiSaati: 45,
      yorum: 'Ek paket almadan oyunun yarısı kilitli kalıyor resmen. Ana oyunu yarım satıp parça parça kakalamışlar.',
      tavsiye: false,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'AdimSayar',
      oynamaSuresiSaati: 22,
      yorum: 'Karakterin yürüme hızı o kadar yavaş ki haritanın başına dönmek için taksi çağırasım geldi.',
      tavsiye: false,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KadersizOyuncu',
      oynamaSuresiSaati: 65,
      yorum: 'Otomatik kayıt koymamışlar, elektrikler kesilince 3 saatlik ilerlemem çöpe gitti.',
      tavsiye: false,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'DersCikaran',
      oynamaSuresiSaati: 360,
      yorum: 'Her ölümde yeni bir şey öğreniyorsunuz. Asla haksız yere ölmüş hissetmiyorsunuz, tamamen sizin hatanız.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'YerliOyuncu',
      oynamaSuresiSaati: 150,
      yorum: 'Oyunun Türkçe dil desteği olması bile tek başına olumlu inceleme vermeme yeterli.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KulaklikUzmani',
      oynamaSuresiSaati: 225,
      yorum: 'Seslendirmeler ve ortam sesleri o kadar kaliteli ki sinemada gibi hissettiriyor.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'KapiyaSikisan',
      oynamaSuresiSaati: 36,
      yorum: 'Yapay zeka yoldaşlar sürekli kapı eşiğinde sıkışıp yolu kapatıyor, geçemiyorum.',
      tavsiye: false,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'PikselAsigi',
      oynamaSuresiSaati: 105,
      yorum: 'Piksel grafiklere önyargılıydım ama hikayesi ağlattı. Kesinlikle bir şans verin.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'TrolUstadı',
      oynamaSuresiSaati: 270,
      yorum: 'Arkadaşınızı trollemenin 50 farklı yolu var. Dostluk bitirir ama çok eğlenceli.',
      tavsiye: true,
    ),
    GameReviewDto(
      sira: 99,
      kullaniciAdi: 'HuzurArayan',
      oynamaSuresiSaati: 185,
      yorum: 'Günde 1 saat kafa dağıtmak için giriyorum, terapi gibi geliyor müzikleri ve akışı.',
      tavsiye: true,
    ),
  ];

  /// Tekrarları engelleyerek havuzdan rastgele ve taze bir sahte inceleme seçer.
  /// En son kullanılan incelemeleri hafızada tutar ve en az 40+ tur boyunca aynı incelemeyi tekrar göstermez.
  static const List<String> _realisticUsernames = [
    'kaan1907', 'ShadowGamer', 'mert_34', 'TheDarkKnight', 'berke.exe',
    'emir_k', 'Cpt.Price', 'noobmaster69', 'batuhan_y', 'deniz.oz',
    'Vortex', 'can_99', 'Slayer_TR', 'yigit_10', 'baris.kaya',
    'Hyperion', 'alperen06', 'Tolga_X', 'CyberWolf', 'eren_fb',
    'NightRider', 'kerem_gs', 'FrostByte', 'burak.dev', 'serkan_b',
    'Nexus', 'oguzhan_k', 'Echo_99', 'arda.b', 'DarkMatter',
    'patates_adam', 'caykolik', 'alt_f4_ustasi', 'son_samuray', 'lag_spikes',
    'GhostRider', 'zero_cool', 'IronClad', 'Thunder_TR', 'murat.35',
    'ege_yldz', 'selim_pro', 'onur_can', 'taha_98', 'furkan.k',
    'mehmet_e', 'koray_x', 'samet_tr', 'dogukan.07', 'volkan_b',
    'X_Sniper_X', 'LordCommander', 'Captain_Jack', 'DragonSlayer', 'Speedy_06',
    'Kaan_K', 'Emre.Arslan', 'Utku_99', 'Yasin_B', 'BarisMancho',
    'Kuzey_Ruzgari', 'Ragnar', 'Kratos_TR', 'Geralt_06', 'Snake_Eater',
    'NeonRider', 'PixelHunter', 'RetroGamer', 'DoomGuy_TR', 'MasterChief_99',
    'cihan_34', 'tayfun_tr', 'ozgur_k', 'bilal_99', 'cem.kara',
    'berk_y', 'ayberk_06', 'alihan_tr', 'boran_k', 'tarik_x',
  ];

  static GameReviewDto getRandomFakeReview() {
    if (fakePool.isEmpty) {
      return const GameReviewDto(
        sira: 99,
        kullaniciAdi: 'kaan1907',
        oynamaSuresiSaati: 100,
        yorum: 'Harika bir deneyimdi, kesinlikle tavsiye ediyorum.',
        tavsiye: true,
      );
    }

    // Kullanılmayan indeksleri filtrele
    List<int> availableIndices = [];
    for (int i = 0; i < fakePool.length; i++) {
      if (!_recentlyUsedIndices.contains(i)) {
        availableIndices.add(i);
      }
    }

    // Eğer kalan havuz azaldıysa (örneğin 15'ten az kaldıysa), eski geçmişi temizle ve döngüyü tazele
    if (availableIndices.length < 15) {
      if (_recentlyUsedIndices.length > 20) {
        _recentlyUsedIndices.removeRange(0, _recentlyUsedIndices.length - 20);
      }
      availableIndices = [
        for (int i = 0; i < fakePool.length; i++)
          if (!_recentlyUsedIndices.contains(i)) i,
      ];
      if (availableIndices.isEmpty) {
        _recentlyUsedIndices.clear();
        availableIndices = List.generate(fakePool.length, (i) => i);
      }
    }

    final random = Random();
    final chosenIndex = availableIndices[random.nextInt(availableIndices.length)];
    _recentlyUsedIndices.add(chosenIndex);

    final baseReview = fakePool[chosenIndex];
    final naturalUsername = _realisticUsernames[random.nextInt(_realisticUsernames.length)];
    final variation = random.nextInt(15) - 7;
    final naturalPlaytime = max(5, baseReview.oynamaSuresiSaati + variation);

    return baseReview.copyWith(
      kullaniciAdi: naturalUsername,
      oynamaSuresiSaati: naturalPlaytime,
    );
  }

  /// Testler veya oturum sıfırlamaları için geçmişi temizleme metodu
  static void resetHistory() {
    _recentlyUsedIndices.clear();
  }

  /// Mevcut geçmişteki kullanılan indeks sayısı
  static int get recentHistoryCount => _recentlyUsedIndices.length;
}
