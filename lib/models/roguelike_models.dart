import 'dart:math';
import 'package:flutter/material.dart';

/// Oyun Modu Seçimi
enum GameMode {
  /// Sonsuz / Klasik Tahmin Modu (Kesintisiz seri kastığınız mod)
  endless,

  /// Roguelike Kule Koşusu (10 Katlık, Boss'lu, Yadigarlı mod)
  roguelike,

  /// Sahtekar İnceleme Modu (4 İncelemeden 1'i sahte, sahteyi bul 2x ödül al)
  imposter,

  /// Zaman Yarışı Modu (60 Saniyelik Hızlı Tahmin)
  timeAttack,

  /// 1v1 Arkadaş Düellosu (Aynı telefondan sıra tabanlı)
  duel,
}

/// Nadirlik Derecesi
enum PerkRarity {
  common,
  rare,
  legendary,
}

/// Roguelike Koşusunda Seçilen Kalıcı Pasif Yadigar (Perk / Relic)
class RoguelikePerk {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final PerkRarity rarity;

  const RoguelikePerk({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    this.rarity = PerkRarity.common,
  });

  Color get rarityColor {
    switch (rarity) {
      case PerkRarity.common:
        return const Color(0xFF4FC3F7); // Cyan
      case PerkRarity.rare:
        return const Color(0xFFBA68C8); // Mor
      case PerkRarity.legendary:
        return const Color(0xFFFFD54F); // Altın
    }
  }

  String get rarityTitle {
    switch (rarity) {
      case PerkRarity.common:
        return 'Sıradan';
      case PerkRarity.rare:
        return 'Nadir';
      case PerkRarity.legendary:
        return 'Efsanevi';
    }
  }
}

/// Tüm Roguelike Yadigarlarının Kataloğu
class PerkCatalog {
  static const List<RoguelikePerk> allPerks = [
    RoguelikePerk(
      id: 'genre_radar',
      name: 'Tür Radarı',
      description: 'Oyunun tür ve kategori etiketlerini üst bilgi panelinde rozet olarak gösterir.',
      iconEmoji: '🏷️',
      rarity: PerkRarity.common,
    ),
    RoguelikePerk(
      id: 'guardian_shield',
      name: 'Koruyucu Kalkan',
      description: 'Her oyundaki İLK yanlış tahmininiz canınızı götürmez.',
      iconEmoji: '🛡️',
      rarity: PerkRarity.rare,
    ),
    RoguelikePerk(
      id: 'xray_vowel',
      name: 'X-Ray Harf',
      description: 'Harf tablosunda ilk sesli harf her oyunda bedava açılır.',
      iconEmoji: '👓',
      rarity: PerkRarity.common,
    ),
    RoguelikePerk(
      id: 'gold_merchant',
      name: 'Tüccar Pazarlığı',
      description: 'Doğru tahminlerde +%50 daha fazla Altın kazanırsınız.',
      iconEmoji: '💰',
      rarity: PerkRarity.common,
    ),
    RoguelikePerk(
      id: 'free_diamond_joker',
      name: 'Elmas Rezervi',
      description: 'Her oyundaki ilk "Ekstra Yorum" jokeri elmas harcamaz.',
      iconEmoji: '💎',
      rarity: PerkRarity.rare,
    ),
    RoguelikePerk(
      id: 'sharpshooter',
      name: 'Keskin Nişancı',
      description: '1. denemede bilirseniz 2 KAT Altın ve Elmas kazanırsınız.',
      iconEmoji: '🎯',
      rarity: PerkRarity.legendary,
    ),
    RoguelikePerk(
      id: 'vitality',
      name: 'Can Tazeleme',
      description: 'Maksimum canınızı 5\'ten 6\'ya çıkarır ve +1 can doldurur.',
      iconEmoji: '💖',
      rarity: PerkRarity.rare,
    ),
    RoguelikePerk(
      id: 'lucky_start',
      name: 'Şanslı Başlangıç',
      description: 'Her yeni tura başlarken anında fazladan +15 Altın kazanırsınız.',
      iconEmoji: '🍀',
      rarity: PerkRarity.common,
    ),
    RoguelikePerk(
      id: 'letter_discount',
      name: 'İndirim Kuponu',
      description: 'Harf tablosu ipuçları %50 daha az altın harcar.',
      iconEmoji: '🏷️',
      rarity: PerkRarity.common,
    ),
    RoguelikePerk(
      id: 'second_wind',
      name: 'İkinci Rüzgar',
      description: 'Canlarınız bittiğinde koşu başına 1 kez +2 canla hayatta kalırsınız.',
      iconEmoji: '🌪️',
      rarity: PerkRarity.legendary,
    ),
    RoguelikePerk(
      id: 'veteran_eye',
      name: 'Kıdemli Oyuncu',
      description: 'Turun ilk kartı her zaman 300+ saat oynamış birinin incelemesi olur.',
      iconEmoji: '🎖️',
      rarity: PerkRarity.rare,
    ),
    RoguelikePerk(
      id: 'first_letter_free',
      name: 'Başlangıç Harfi',
      description: 'Her turun başında oyun adının İLK harfi otomatik ve bedava açılır.',
      iconEmoji: '🔤',
      rarity: PerkRarity.common,
    ),
    RoguelikePerk(
      id: 'time_traveler',
      name: 'Çıkış Tarihi Dedektifi',
      description: 'Oyunun resmi çıkış tarihini üst bilgi panelinde rozet olarak gösterir.',
      iconEmoji: '📅',
      rarity: PerkRarity.common,
    ),
    RoguelikePerk(
      id: 'gamblers_dice',
      name: 'Kumarbazın Zarı',
      description: '1. kart açıkken bilirseniz +100 Altın verir; yanlış tahminde 2 can götürür.',
      iconEmoji: '🎲',
      rarity: PerkRarity.legendary,
    ),
    RoguelikePerk(
      id: 'streak_master',
      name: 'Seri Katili',
      description: 'Seri kazanç çarpanı normalin iki katı hızla artarak devasa altın kazandırır.',
      iconEmoji: '🔥',
      rarity: PerkRarity.rare,
    ),
    RoguelikePerk(
      id: 'recycler',
      name: 'İnceleme Öğütücü',
      description: 'Beğenmediğiniz bir yorumu tur başına 1 kez yenisiyle değiştirebilirsiniz.',
      iconEmoji: '♻️',
      rarity: PerkRarity.common,
    ),
    RoguelikePerk(
      id: 'length_checker',
      name: 'Kelime Sayacı',
      description: 'Oyun adının kaç kelime ve kaç harften oluştuğu üstte açık görünür.',
      iconEmoji: '📏',
      rarity: PerkRarity.common,
    ),
    RoguelikePerk(
      id: 'consonant_crusher',
      name: 'Sessiz Harf Avcısı',
      description: 'Harf tablosundan rastgele 2 sessiz harfi tur başında ücretsiz açar.',
      iconEmoji: '🔨',
      rarity: PerkRarity.rare,
    ),
    RoguelikePerk(
      id: 'boss_slayer',
      name: 'Boss Avcısı',
      description: 'Her 5 katta bir gelen tüm Boss oyunlarında (5, 10, 15, 20. katlar...) +2 başlangıç ipucu ve +1 can kazandırır.',
      iconEmoji: '👑',
      rarity: PerkRarity.legendary,
    ),
  ];

  /// Henüz sahip olunmayan yadigarlar arasından 3 adet rastgele kart seçer
  static List<RoguelikePerk> getThreeRandomPerks(Set<String> ownedPerkIds) {
    final available = allPerks.where((p) => !ownedPerkIds.contains(p.id)).toList();
    if (available.isEmpty) return [];

    available.shuffle(Random());
    return available.take(min(3, available.length)).toList();
  }

  static RoguelikePerk? findById(String id) {
    try {
      return allPerks.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
