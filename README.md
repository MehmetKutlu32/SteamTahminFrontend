# 🎮 Steam Guessr (Frontend)

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Version](https://img.shields.io/badge/Release-v1.0.5-orange?style=for-the-badge&logo=github)
![SignalR](https://img.shields.io/badge/SignalR-Realtime-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![Shorebird](https://img.shields.io/badge/Shorebird-CodePush%20Enabled-1DB954?style=for-the-badge&logo=target&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

<p align="center">
  <b>A next-generation mobile game built with Flutter where players guess Steam games based on real user reviews, featuring roguelike progression, imposter investigation, time attack, and real-time multiplayer duels via SignalR.</b>
</p>

</div>

---

## 🌟 Key Features

### 🕹️ Game Modes
- **🕵️ Imposter (Sahtekar) Review Mode:**
  - 5 review cards are displayed with 1 fake review hidden among 4 real ones.
  - Read carefully, spot the imposter from a 70+ rich Steam review pool, and claim double bonus rewards.
- **🗼 Roguelike Tower Run:** 
  - Climb through a 10-floor dynamic challenge.
  - Unlock user reviews progressively, utilize life-saving jokers, and manage health points.
  - Open mystery chests, discover passive relics, and select strategic perks between floors.
- **⚡ Time Attack:** 
  - Race against the clock to make as many correct guesses as possible to achieve high score streaks.
- **⚔️ Real-Time Online Duel:** 
  - Ultra-low latency 1v1 live multiplayer powered by **ASP.NET Core SignalR**.
  - Live synchronized scoreboard, round transitions, forfeit mechanism, and lobby room matchmaking.
- **👥 Local 2-Player Mode:** 
  - Turn-based pass-and-play gameplay on a single device.

### 💎 Economy & Progression System
- **🪙 Gold & 💎 Diamonds Economy:** Earn currency from completed runs, daily quests, and achievements.
- **🃏 Jokers & Power-ups:**
  - 🔤 Vowel Reveal (*Uncovers vowels in the title*)
  - 🛡️ Guardian Shield (*Protects against the next incorrect guess*)
  - 🏷️ Genre Radar (*Reveals official Steam tags and genres*)
  - 💬 Extra Review (*Purchases additional clues*)
- **📜 Daily Quests & Achievement Tree:** Rewarding daily active player milestones.
- **🛍️ Customization Shop:** Collect unique avatars, player titles, and neon profile borders.

### 🚀 Over-The-Air Updates (Shorebird Code Push)
- **Zero APK Reinstallations:** Instant cloud patch deployments (OTA) for UI and game logic updates without forcing users to download new APKs.

---

## 🛠️ Architecture & Tech Stack

| Layer | Technology | Details |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.x / Dart | Cross-platform mobile client |
| **State Management** | Provider | Reactive state management & session controllers |
| **Real-time Networking** | SignalR Client | WebSocket-based 1v1 multiplayer duels |
| **HTTP Client** | `http` & `io_client` | Robust REST API consumer with auto-retry logic |
| **Code Push / OTA** | Shorebird | Cloud-based background patch updater |
| **Local Persistence** | SharedPreferences | Local offline round caching, user progression & settings |
| **UI / UX Design** | Custom Steam Dark Theme | Glassmorphism, cyber-steam neon palette & micro-animations |

---

## 📂 Project Structure

```bash
lib/
├── models/             # Data models (GameItem, Round, Relic, Quest, User, etc.)
├── providers/          # Global state management (GameProvider, SessionProvider)
├── screens/            # Application views & game screens
│   ├── auth/           # Login & Guest authentication screens
│   ├── duel/           # Online & Local SignalR duel screens
│   ├── game/           # Core gameplay, round controllers, dialogs
│   ├── time_attack/    # Time attack mode screen
│   └── main_menu_screen.dart # Main navigation hub
├── services/           # Network and storage service abstractions
│   ├── api_service.dart          # Production REST API client
│   ├── auth_service.dart         # Google & Guest session management
│   ├── duel_signalr_service.dart # Real-time SignalR Hub manager
│   └── local_round_cache_service.dart # Offline cache & persistent player profiles
├── theme/              # Steam color palette & typography tokens
├── utils/              # Text utilities, profanity filtering
└── widgets/            # Reusable UI components (Cards, Jokers, Modals)
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+ recommended)
- [Shorebird CLI](https://docs.shorebird.dev) *(Optional - for code push releases)*
- Android Studio / VS Code

### 1. Clone the Repository
```bash
git clone https://github.com/MehmetKutlu32/SteamTahminFrontend.git
cd SteamTahminFrontend
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
```bash
# Run in debug mode
flutter run
```

---

## 🔄 Building & Updating with Shorebird

### Build Release Artifact:
```powershell
shorebird release android
```

### Deploy Instant Over-The-Air Patch:
```powershell
shorebird patch android
```

---

## 👨‍💻 Author

- **Mehmet Kutlu** - [GitHub Profile](https://github.com/MehmetKutlu32)

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```text
MIT License

Copyright (c) 2026 Mehmet Kutlu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## ⚠️ Disclaimer & Legal Notice

This project is an independent, non-profit community project and is **not affiliated with, associated with, authorized, endorsed by, or in any way officially connected with Valve Corporation, Steam, or any of their subsidiaries or affiliates.**

- **Steam** and the **Steam logo** are trademarks and/or registered trademarks of **Valve Corporation** in the U.S. and/or other countries.
- All game titles, images, descriptions, reviews, and related media referenced within this application are the property and copyright of their respective owners and publishers.
- This application is developed strictly for educational and trivia purposes under fair use.

---

<div align="center">
  <sub>Steam® is a registered trademark of Valve Corporation. This project is an independent open-source trivia game.</sub>
</div>
