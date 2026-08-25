# 🎮 Steam Tahmin Oyunu (Frontend)

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SignalR](https://img.shields.io/badge/SignalR-Realtime-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![Shorebird](https://img.shields.io/badge/Shorebird-CodePush%20Enabled-1DB954?style=for-the-badge&logo=target&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

<p align="center">
  <b>Steam incelemelerini okuyup doğru oyunu tahmin etmeye dayalı, roguelike mekanikler ve gerçek zamanlı çok oyunculu (SignalR) düello modları içeren yeni nesil mobil tahmin oyunu.</b>
</p>

</div>

---

## 🌟 Öne Çıkan Özellikler

### 🕹️ Oyun Modları
- **🗼 Roguelike Kule Modu (Tower Run):** 
  - 10 katlı aşamalı kule tırmanışı.
  - Her katta rastgele açılan Steam incelemeleri, ipucu jokerleri ve can sistemi.
  - Kat sonlarında gizemli sandıklar, pasif relikler (kalıntılar) ve perk seçimleri.
- **⚡ Zamana Karşı (Time Attack):** 
  - Kısıtlı sürede en fazla doğru tahmini yaparak en yüksek skora ve seriye ulaşma yarışı.
- **⚔️ Çevrimiçi Düello (Realtime Multiplayer Duel):** 
  - **ASP.NET Core SignalR** altyapısıyla sıfır gecikmeli 1v1 canlı eşleşme.
  - Canlı skor tablosu, tur sonuçları, teslim olma ve oda kurma mekanikleri.
- **👥 Yerel 2 Kişilik Mod:** 
  - Tek cihaz üzerinden arkadaşınızla sıra tabanlı kapışma.

### 💎 Ekonomi ve İlerleme Sistemi
- **🪙 Altın & 💎 Elmas Ekonomisi:** Turlardan, günlük görevlerden ve başarılardan kazanılan bakiye.
- **🃏 Jokerler & Yetenekler:**
  - 🔤 Harf Açma (Vowel Reveal)
  - 🛡️ Koruma Kalkanı (Guardian Shield)
  - 🏷️ Tür Radarı (Genre Radar)
  - 💬 Ekstra İnceleme Satın Alma
- **📜 Günlük Görevler & Başarım Ağacı:** Sürekli güncellenen ödül sistemi.
- **🛍️ Mağaza & Kişiselleştirme:** Özel avatarlar, unvanlar ve profil çerçeveleri.

### 🚀 Canlı Kod Güncelleme (Shorebird Code Push)
- **Sıfır APK İndirme:** Dart/Arayüz güncellemeleri kullanıcıya yeni APK indirtmeden buluttan (OTA) sessizce uygulanır.

---

## 🛠️ Teknoloji Yığını & Mimari

| Katman | Teknoloji | Açıklama |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.x / Dart | Çapraz platform mobil arayüz |
| **Durum Yönetimi** | Provider | Reaktif UI state & Session yönetimi |
| **Gerçek Zamanlı Ağ** | SignalR Client | Online 1v1 WebSocket tabanlı düellolar |
| **HTTP İstemcisi** | `http` & `io_client` | REST API tüketimi ve otomatik yeniden deneme |
| **OTA Güncelleme** | Shorebird | Anında buluttan yama dağıtımı |
| **Yerel Depolama** | SharedPreferences | Profil, ayarlar ve önbellek yönetimi |
| **Tasarım Dili** | Özel Steam Dark Theme | Glassmorphism, neon Steam renk paleti & modern animasyonlar |

---

## 📂 Proje Dizin Yapısı

```bash
lib/
├── models/             # Veri modelleri (GameItem, Round, Relic, Quest, User vb.)
├── providers/          # Global durum yöneticisi (GameProvider, SessionProvider)
├── screens/            # Ana ekranlar
│   ├── auth/           # Giriş & Misafir oturum ekranları
│   ├── duel/           # Online ve yerel SignalR düello ekranları
│   ├── game/           # Oyun turları, yardımcı diyaloglar
│   ├── time_attack/    # Zamana karşı mod ekranı
│   └── main_menu_screen.dart # Ana menü
├── services/           # Servis katmanı
│   ├── api_service.dart          # REST API istemcisi
│   ├── auth_service.dart         # Google / Misafir kimlik doğrulama
│   ├── duel_signalr_service.dart # Canlı SignalR Hub yöneticisi
│   └── local_round_cache_service.dart # Çevrimdışı ve yerel profil önbelleği
├── theme/              # Steam renk paleti ve tipografi tanımları
├── utils/              # Küfür filtresi, yardımcı fonksiyonlar
└── widgets/            # Yeniden kullanılabilir UI bileşenleri (Kartlar, Jokerler, Modallar)
```

---

## 🚀 Başlangıç ve Kurulum

### Gereksinimler
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+ önerilir)
- [Shorebird CLI](https://docs.shorebird.dev) *(İsteğe bağlı - Code Push için)*
- Android Studio / VS Code

### 1. Depoyu Klonlayın
```bash
git clone https://github.com/MehmetKutlu32/SteamTahminFrontend.git
cd SteamTahminFrontend
```

### 2. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 3. Uygulamayı Çalıştırın
```bash
# Debug modunda başlat
flutter run
```

---

## 🔄 Shorebird ile Yayınlama ve Güncelleme

### İlk Release Sürümünü Oluşturma:
```powershell
shorebird release android
```

### APK Dağıtmadan Anında Canlı Güncelleme (Patch) Gönderme:
```powershell
shorebird patch android
```

---

## 👨‍💻 Geliştirici

- **Mehmet Kutlu** - [GitHub Profilim](https://github.com/MehmetKutlu32)

---

<div align="center">
  <sub>Steam® Valve Corporation'ın tescilli ticari markasıdır. Bu proje kâr amacı gütmeyen açık kaynaklı bir topluluk oyunudur.</sub>
</div>
