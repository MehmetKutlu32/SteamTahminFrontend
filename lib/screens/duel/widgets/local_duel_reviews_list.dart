import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/steam_theme.dart';

class LocalDuelReviewsList extends StatefulWidget {
  final List<GameReviewDto> reviews;
  final int revealedCount;
  final String? roundResultMessage;

  const LocalDuelReviewsList({
    super.key,
    required this.reviews,
    required this.revealedCount,
    this.roundResultMessage,
  });

  @override
  State<LocalDuelReviewsList> createState() => _LocalDuelReviewsListState();
}

class _LocalDuelReviewsListState extends State<LocalDuelReviewsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void didUpdateWidget(covariant LocalDuelReviewsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revealedCount != widget.revealedCount ||
        oldWidget.roundResultMessage != widget.roundResultMessage) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101924),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Açılan İpuçları (${widget.revealedCount}/${widget.reviews.length}):',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              if (widget.roundResultMessage != null)
                Flexible(
                  child: Text(
                    widget.roundResultMessage!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const Divider(color: Colors.white10, height: 12),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.revealedCount,
              itemBuilder: (context, idx) {
                final rev = idx < widget.reviews.length ? widget.reviews[idx] : null;
                if (rev == null) return const SizedBox.shrink();

                final isLatest = idx == widget.revealedCount - 1;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: isLatest ? const Color(0xFF182535) : SteamColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isLatest ? SteamColors.steamCyan.withValues(alpha: 0.6) : Colors.white10,
                      width: isLatest ? 1.2 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'İpucu #${idx + 1} (${rev.oynamaSuresiSaati} Saat):',
                            style: const TextStyle(color: SteamColors.steamCyan, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          if (isLatest && widget.revealedCount > 1)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'YENİ',
                                style: TextStyle(color: Colors.amberAccent, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rev.yorum,
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
