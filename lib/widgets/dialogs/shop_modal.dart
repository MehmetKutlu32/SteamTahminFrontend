import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/shop_models.dart';
import '../../providers/game_provider.dart';
import '../../theme/steam_theme.dart';

class ShopModal extends StatelessWidget {
  const ShopModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ShopModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF101923),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: SteamColors.cardBorder, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SteamColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Başlık & Bakiye
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🛍️ ', style: TextStyle(fontSize: 22)),
                  Text(
                    'Tahmin Dükkanı',
                    style: TextStyle(
                      color: SteamColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Bakiye Rozetleri
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: SteamColors.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.coins}',
                          style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: SteamColors.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Text('💎', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.diamonds}',
                          style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Sekmeler (Avatarlar, Çerçeveler, Unvanlar, Güçlendirme, Şans Çarkı)
          Flexible(
            child: DefaultTabController(
              length: 5,
              child: Column(
                children: [
                  const TabBar(
                    isScrollable: true,
                    indicatorColor: SteamColors.steamCyan,
                    labelColor: SteamColors.steamCyan,
                    unselectedLabelColor: SteamColors.textMuted,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(text: '🎭 Avatarlar'),
                      Tab(text: '🎨 Çerçeveler'),
                      Tab(text: '👑 Unvanlar'),
                      Tab(text: '⚡ Güçlendirme'),
                      Tab(text: '🎡 Şans Çarkı'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildCategoryList(context, provider, ShopItemType.avatar),
                        _buildCategoryList(context, provider, ShopItemType.frame),
                        _buildCategoryList(context, provider, ShopItemType.title),
                        _buildCategoryList(context, provider, ShopItemType.boost),
                        _buildCategoryList(context, provider, ShopItemType.chest),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, GameProvider provider, ShopItemType type) {
    final items = ShopCatalog.allItems.where((i) => i.type == type).toList();

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = provider.hasShopItem(item.id);
        final isEquippedAvatar = type == ShopItemType.avatar && provider.equippedAvatarId == item.id;
        final isEquippedFrame = type == ShopItemType.frame && provider.equippedFrameId == item.id;
        final isEquippedTitle = type == ShopItemType.title && provider.equippedTitleId == item.id;
        final isEquipped = isEquippedAvatar || isEquippedFrame || isEquippedTitle;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SteamColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEquipped
                  ? Colors.amberAccent
                  : isOwned
                      ? item.accentColor.withValues(alpha: 0.5)
                      : Colors.white10,
              width: isEquipped ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // İkon / Avatar / Çerçeve Önizleme
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.accentColor.withValues(alpha: 0.18),
                  border: Border.all(
                    color: item.accentColor,
                    width: type == ShopItemType.frame ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.accentColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    item.iconEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Detay
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              color: isEquipped ? Colors.amberAccent : SteamColors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isEquipped) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'KUŞANILDI',
                              style: TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: SteamColors.textMuted,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Eylem Butonu
              _buildActionButton(context, provider, item, isOwned, isEquipped),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    GameProvider provider,
    ShopItem item,
    bool isOwned,
    bool isEquipped,
  ) {
    if (item.type == ShopItemType.boost) {
      if (isOwned) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, color: Colors.greenAccent, size: 14),
              SizedBox(width: 3),
              Text(
                'AKTİF',
                style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }
    } else if (item.type == ShopItemType.avatar ||
        item.type == ShopItemType.frame ||
        item.type == ShopItemType.title) {
      if (isOwned) {
        if (isEquipped) {
          return OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(60, 32),
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (item.type == ShopItemType.avatar) {
                provider.equipAvatar(null);
              } else if (item.type == ShopItemType.frame) {
                provider.equipFrame(null);
              } else {
                provider.equipTitle(null);
              }
            },
            child: const Text('Çıkar', style: TextStyle(color: Colors.white70, fontSize: 11)),
          );
        } else {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SteamColors.steamCyan,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(60, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              if (item.type == ShopItemType.avatar) {
                provider.equipAvatar(item.id);
              } else if (item.type == ShopItemType.frame) {
                provider.equipFrame(item.id);
              } else {
                provider.equipTitle(item.id);
              }
            },
            child: const Text('Kuşan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          );
        }
      }
    }

    // Satın Alma Butonu (Altın veya Elmas)
    final isGold = item.isGoldPurchasable;
    final priceText = isGold ? '🪙 ${item.priceGold}' : '💎 ${item.priceDiamonds}';
    final canAfford = isGold ? provider.coins >= item.priceGold : provider.diamonds >= item.priceDiamonds;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: canAfford ? (isGold ? const Color(0xFFFFB300) : const Color(0xFF00E5FF)) : Colors.white12,
        foregroundColor: canAfford ? Colors.black : Colors.white38,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(70, 34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        HapticFeedback.mediumImpact();
        final success = provider.buyShopItem(item, payWithDiamonds: !isGold);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                item.type == ShopItemType.chest
                    ? '🎡 Çark çevirme hakkı hesabınıza eklendi!'
                    : '🎉 "${item.name}" kalıcı olarak açıldı!',
              ),
              backgroundColor: Colors.green[800],
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Text(
        priceText,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5),
      ),
    );
  }
}
