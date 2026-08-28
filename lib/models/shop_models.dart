import 'package:flutter/material.dart';

enum ShopItemType {
  avatar,
  frame,
  title,
  boost,
  chest,
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final ShopItemType type;
  final int priceGold;
  final int priceDiamonds;
  final Color accentColor;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.type,
    this.priceGold = 0,
    this.priceDiamonds = 0,
    this.accentColor = const Color(0xFF66C0F4),
  });

  bool get isGoldPurchasable => priceGold > 0;
  bool get isDiamondPurchasable => priceDiamonds > 0;
}

class ShopCatalog {
  static const List<ShopItem> allItems = [
    // 🎭 ÖZEL AVATARLAR (Standart & Prestij)
    ShopItem(
      id: 'avatar_cyber_robot',
      name: 'Siber Robot',
      description: 'Yapay zeka analizli fütüristik siber robot avatarı.',
      iconEmoji: '🤖',
      type: ShopItemType.avatar,
      priceGold: 100,
      accentColor: Color(0xFF00E5FF),
    ),
    ShopItem(
      id: 'avatar_mage',
      name: 'Kadim Büyücü',
      description: 'Oyun dünyasının kadim sırlarını bilen bilge büyücü.',
      iconEmoji: '🧙‍♂️',
      type: ShopItemType.avatar,
      priceGold: 150,
      accentColor: Color(0xFFB388FF),
    ),
    ShopItem(
      id: 'avatar_cyber_cat',
      name: 'Neon Kedi',
      description: 'Siberpunk sokaklarının sevimli ama tehlikeli neon kedisi.',
      iconEmoji: '🐱',
      type: ShopItemType.avatar,
      priceGold: 200,
      accentColor: Color(0xFFFF4081),
    ),
    ShopItem(
      id: 'avatar_shadow_ninja',
      name: 'Gölge Ninja',
      description: 'İncelemeleri karanlıkta gizlice çözen sessiz gölge ninja.',
      iconEmoji: '🥷',
      type: ShopItemType.avatar,
      priceGold: 250,
      accentColor: Color(0xFF26A69A),
    ),
    ShopItem(
      id: 'avatar_gold_king',
      name: 'Altın Hükümdar',
      description: 'Tüm oyun kütüphanelerine hükmeden altın taçlı hükümdar.',
      iconEmoji: '👑',
      type: ShopItemType.avatar,
      priceGold: 350,
      accentColor: Color(0xFFFFD700),
    ),
    ShopItem(
      id: 'avatar_golden_phoenix',
      name: 'Altın Anka Kuşu',
      description: 'Küllerinden saf altın alevleriyle doğan efsanevi prestij kuşu.',
      iconEmoji: '🦅',
      type: ShopItemType.avatar,
      priceGold: 500,
      accentColor: Color(0xFFFFAB00),
    ),
    ShopItem(
      id: 'avatar_cyber_dragon',
      name: 'Siber Ejderha',
      description: 'Yüksek frekanslı neon alevler saçan siber ejderha.',
      iconEmoji: '🐲',
      type: ShopItemType.avatar,
      priceGold: 750,
      accentColor: Color(0xFF76FF03),
    ),
    ShopItem(
      id: 'avatar_diamond_champ',
      name: 'Elmas Şampiyon',
      description: 'Elmas gibi parıldayan yenilmez turnuva şampiyonu.',
      iconEmoji: '💎',
      type: ShopItemType.avatar,
      priceDiamonds: 10,
      accentColor: Color(0xFF00E5FF),
    ),
    ShopItem(
      id: 'avatar_dragon_rider',
      name: 'Ejderha Süvarisi',
      description: 'Alev fırtınalarında ejderhasıyla süzülen cesur süvari.',
      iconEmoji: '🐉',
      type: ShopItemType.avatar,
      priceDiamonds: 15,
      accentColor: Color(0xFFFF5252),
    ),
    ShopItem(
      id: 'avatar_cosmonaut',
      name: 'Kozmonot Gezgin',
      description: 'Bilinmeyen galaksilerde yeni oyunlar keşfeden astronot.',
      iconEmoji: '🚀',
      type: ShopItemType.avatar,
      priceDiamonds: 15,
      accentColor: Color(0xFF7C4DFF),
    ),
    ShopItem(
      id: 'avatar_cyber_pirate',
      name: 'Siber Korsan',
      description: 'Dijital denizlerin en zeki ve korkusuz siber korsanı.',
      iconEmoji: '💀',
      type: ShopItemType.avatar,
      priceDiamonds: 20,
      accentColor: Color(0xFF69F0AE),
    ),
    ShopItem(
      id: 'avatar_fire_fox',
      name: 'Alev Tilkisi',
      description: 'Hızlı, kurnaz ve alev saçan efsanevi siber tilki.',
      iconEmoji: '🦊',
      type: ShopItemType.avatar,
      priceDiamonds: 25,
      accentColor: Color(0xFFFF9100),
    ),

    // 🎨 ÖZEL ÇERÇEVELER (Altınlı, Elmaslı, Prestij)
    ShopItem(
      id: 'frame_gold',
      name: '👑 Saf Altın Taç',
      description: 'Saf altın işlemeli parlak efsanevi koleksiyoncu çerçevesi.',
      iconEmoji: '👑',
      type: ShopItemType.frame,
      priceGold: 300,
      accentColor: Color(0xFFFFD700),
    ),
    ShopItem(
      id: 'frame_neon',
      name: '⚡ Siberpunk Neon',
      description: 'Profil avatarınıza fütüristik neon siberpunk çerçevesi ekler.',
      iconEmoji: '⚡',
      type: ShopItemType.frame,
      priceGold: 150,
      accentColor: Color(0xFF18FFFF),
    ),
    ShopItem(
      id: 'frame_emerald',
      name: '❇️ Zümrüt Muhafız',
      description: 'Doğanın ve zenginliğin parlak zümrüt kristal çerçevesi.',
      iconEmoji: '❇️',
      type: ShopItemType.frame,
      priceGold: 250,
      accentColor: Color(0xFF00E676),
    ),
    ShopItem(
      id: 'frame_obsidian',
      name: '🖤 Karanlık Obsidyen',
      description: 'Gizemli koyu mor gölgeli dayanıklı obsidyen çerçeve.',
      iconEmoji: '🖤',
      type: ShopItemType.frame,
      priceGold: 350,
      accentColor: Color(0xFF9575CD),
    ),
    ShopItem(
      id: 'frame_royal_gold',
      name: '⚜️ Kraliyet Altını',
      description: 'Barok tarzda işlenmiş prestijli altın kraliyet çerçevesi.',
      iconEmoji: '⚜️',
      type: ShopItemType.frame,
      priceGold: 500,
      accentColor: Color(0xFFFFD54F),
    ),
    ShopItem(
      id: 'frame_hyper_cyber',
      name: '🌐 Hiper Matris',
      description: 'Holografik veri akışlarıyla parıldayan hiper matris çerçevesi.',
      iconEmoji: '🌐',
      type: ShopItemType.frame,
      priceGold: 600,
      accentColor: Color(0xFF00E5FF),
    ),
    ShopItem(
      id: 'frame_diamond',
      name: '💎 Kusursuz Elmas',
      description: 'Göz kamaştırıcı kristal elmas yansımalı elit profil çerçevesi.',
      iconEmoji: '💎',
      type: ShopItemType.frame,
      priceDiamonds: 20,
      accentColor: Color(0xFF00E5FF),
    ),
    ShopItem(
      id: 'frame_cosmic',
      name: '🌌 Kozmik Galaksi',
      description: 'Derin uzay nebulaları ve yıldız tozlarıyla parıldayan mor kozmik çerçeve.',
      iconEmoji: '🌌',
      type: ShopItemType.frame,
      priceDiamonds: 10,
      accentColor: Color(0xFFE040FB),
    ),
    ShopItem(
      id: 'frame_dragon',
      name: '🔥 Alevli Ejderha',
      description: 'Alev efektleriyle yanan elit ejderha çerçevesi.',
      iconEmoji: '🔥',
      type: ShopItemType.frame,
      priceDiamonds: 15,
      accentColor: Color(0xFFFF5252),
    ),
    ShopItem(
      id: 'frame_ruby',
      name: '🩸 Kan Yakutu',
      description: 'Derin ve asil yakut kristali parıltılı kırmızı çerçeve.',
      iconEmoji: '🩸',
      type: ShopItemType.frame,
      priceDiamonds: 12,
      accentColor: Color(0xFFFF1744),
    ),
    ShopItem(
      id: 'frame_plasma',
      name: '🔮 Mor Plazma',
      description: 'Yüksek enerjili elektro-mor plazma küresi çerçevesi.',
      iconEmoji: '🔮',
      type: ShopItemType.frame,
      priceDiamonds: 15,
      accentColor: Color(0xFFD500F9),
    ),
    ShopItem(
      id: 'frame_celestial',
      name: '🌟 İlahi Kutup Yıldızı',
      description: 'Kutup yıldızı altın-beyaz ışıltılı ilahi çerçeve.',
      iconEmoji: '🌟',
      type: ShopItemType.frame,
      priceDiamonds: 25,
      accentColor: Color(0xFFFFF176),
    ),

    // 👑 Kalıcı Prestij Unvanları
    ShopItem(
      id: 'title_detective',
      name: 'İnceleme Dedektifi',
      description: 'En karmaşık incelemelerden oyunu nokta atışı çıkaran dedektif unvanı.',
      iconEmoji: '🕵️',
      type: ShopItemType.title,
      priceGold: 100,
      accentColor: Color(0xFF81D4FA),
    ),
    ShopItem(
      id: 'title_gourmet',
      name: 'Oyun Gurmesi',
      description: 'Binlerce oyunun ruhunu tek cümleden anlayan bilge oyuncu unvanı.',
      iconEmoji: '☕',
      type: ShopItemType.title,
      priceGold: 250,
      accentColor: Color(0xFFFFB74D),
    ),
    ShopItem(
      id: 'title_gold_tycoon',
      name: 'Altın Zengini',
      description: 'Altınlarını nereye harcayacağını bilemeyen gerçek koleksiyoncu unvanı.',
      iconEmoji: '💰',
      type: ShopItemType.title,
      priceGold: 600,
      accentColor: Color(0xFFFFD700),
    ),
    ShopItem(
      id: 'title_grandmaster',
      name: 'Efsanevi Büyükusta',
      description: 'Tüm inceleme evreninin zirvesinde yer alan nihai prestij unvanı.',
      iconEmoji: '🏆',
      type: ShopItemType.title,
      priceGold: 1000,
      accentColor: Color(0xFFFF5722),
    ),
    ShopItem(
      id: 'title_mindreader',
      name: 'Zihin Okuyucu',
      description: 'İncelemeyi yazanın aklından geçenleri anında sezen elit unvan.',
      iconEmoji: '🔮',
      type: ShopItemType.title,
      priceDiamonds: 10,
      accentColor: Color(0xFFB388FF),
    ),
    ShopItem(
      id: 'title_conqueror',
      name: 'Kule Fatihi',
      description: 'Kule koşularını dize getiren yenilmez şampiyon unvanı.',
      iconEmoji: '🛡️',
      type: ShopItemType.title,
      priceDiamonds: 15,
      accentColor: Color(0xFF69F0AE),
    ),
    ShopItem(
      id: 'title_legend',
      name: 'Oyun Ansiklopedisi',
      description: 'Tüm oyun evrenine hakim, ulaşılabilecek en prestijli efsane unvanı.',
      iconEmoji: '👑',
      type: ShopItemType.title,
      priceDiamonds: 25,
      accentColor: Color(0xFFFFD54F),
    ),

    // ⚡ Kalıcı Güçlendirmeler
    ShopItem(
      id: 'boost_gold_15',
      name: 'Tüccar Lisansı',
      description: 'Tüm oyunlarda kazandığınız altın miktarını kalıcı olarak +%15 artırır.',
      iconEmoji: '💰',
      type: ShopItemType.boost,
      priceGold: 300,
      accentColor: Color(0xFFFFD700),
    ),
    ShopItem(
      id: 'boost_xp_15',
      name: 'Usta Çırağı',
      description: 'Tüm oyunlarda kazandığınız seviye XP miktarını kalıcı olarak +%15 artırır.',
      iconEmoji: '📈',
      type: ShopItemType.boost,
      priceDiamonds: 8,
      accentColor: Color(0xFF40C4FF),
    ),
    ShopItem(
      id: 'boost_joker_discount',
      name: 'Joker İndirimi',
      description: 'Harf ipuçları ve jokerlerin altın bedellerinde kalıcı %20 indirim sağlar.',
      iconEmoji: '🎟️',
      type: ShopItemType.boost,
      priceGold: 400,
      accentColor: Color(0xFFFFAB40),
    ),
    ShopItem(
      id: 'boost_lucky_diamonds',
      name: 'Elmas Madencisi',
      description: 'Her galibiyette +1 ekstra Elmas bulma şansınızı kalıcı olarak artırır.',
      iconEmoji: '💎',
      type: ShopItemType.boost,
      priceDiamonds: 12,
      accentColor: Color(0xFF00E5FF),
    ),

    // 🎡 Şans Çarkı Biletleri
    ShopItem(
      id: 'chest_gold_buy',
      name: 'Şans Çarkı Bileti',
      description: 'Şans Çarkında anında çevirebileceğiniz 1 adet bilet kazandırır.',
      iconEmoji: '🎡',
      type: ShopItemType.chest,
      priceGold: 100,
      accentColor: Color(0xFFFFB300),
    ),
    ShopItem(
      id: 'chest_gold_5x',
      name: '5x Çark Bileti Paketi',
      description: 'İndirimli 5 adet Şans Çarkı bileti kazandırır.',
      iconEmoji: '🎟️',
      type: ShopItemType.chest,
      priceGold: 400,
      accentColor: Color(0xFFFF9100),
    ),
    ShopItem(
      id: 'chest_diamond_buy',
      name: 'Süper Çark Paketi',
      description: 'Şans Çarkında anında çevirebileceğiniz 2 adet bilet kazandırır.',
      iconEmoji: '💎',
      type: ShopItemType.chest,
      priceDiamonds: 3,
      accentColor: Color(0xFF00E5FF),
    ),
  ];

  static List<ShopItem> get avatars => allItems.where((i) => i.type == ShopItemType.avatar).toList();
  static List<ShopItem> get frames => allItems.where((i) => i.type == ShopItemType.frame).toList();
  static List<ShopItem> get titles => allItems.where((i) => i.type == ShopItemType.title).toList();

  static ShopItem? findById(String id) {
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
