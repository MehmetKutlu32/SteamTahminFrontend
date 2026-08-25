import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/steam_theme.dart';

class GameGuessInput extends StatefulWidget {
  final List<GameItem> games;
  final ValueChanged<String> onSubmitted;
  final bool isEnabled;

  const GameGuessInput({
    super.key,
    required this.games,
    required this.onSubmitted,
    this.isEnabled = true,
  });

  @override
  State<GameGuessInput> createState() => _GameGuessInputState();
}

class _GameGuessInputState extends State<GameGuessInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<GameItem> _filteredSuggestions = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    final query = _textController.text.trim().toLowerCase();

    if (query.isEmpty) {
      if (_showSuggestions || _filteredSuggestions.isNotEmpty) {
        setState(() {
          _filteredSuggestions = [];
          _showSuggestions = false;
        });
      }
      return;
    }

    // Arama debouncing & hızlı arama (Maksimum 6 öneri)
    _debounceTimer = Timer(const Duration(milliseconds: 60), () {
      final List<GameItem> results = [];
      final games = widget.games;
      final int len = games.length;

      for (int i = 0; i < len; i++) {
        final game = games[i];
        if (game.name.toLowerCase().contains(query)) {
          results.add(game);
          if (results.length >= 6) break;
        }
      }

      if (mounted) {
        setState(() {
          _filteredSuggestions = results;
          _showSuggestions = results.isNotEmpty && _focusNode.hasFocus;
        });
      }
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted && !_focusNode.hasFocus) {
          setState(() {
            _showSuggestions = false;
          });
        }
      });
    } else {
      if (_textController.text.trim().isNotEmpty && _filteredSuggestions.isNotEmpty) {
        setState(() {
          _showSuggestions = true;
        });
      }
    }
  }

  void _submitGuess([String? explicitGuess]) {
    final guess = explicitGuess ?? _textController.text.trim();
    if (guess.isNotEmpty && widget.isEnabled) {
      widget.onSubmitted(guess);
      _textController.clear();
      _focusNode.unfocus();
      setState(() {
        _showSuggestions = false;
        _filteredSuggestions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Sabit Slot: Canlı Oyun Öneri Paneli (AnimatedSize sayesinde TextField asla unmount olmaz)
        AnimatedSize(
          key: const ValueKey('game_guess_animated_size'),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: (_showSuggestions && _filteredSuggestions.isNotEmpty)
              ? Container(
                  key: const ValueKey('game_guess_suggestions_panel'),
                  constraints: const BoxConstraints(maxHeight: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: SteamColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SteamColors.steamBlue, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListView.separated(
                      key: const ValueKey('suggestions_list_view'),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shrinkWrap: true,
                      itemCount: _filteredSuggestions.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: SteamColors.cardBorder,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final game = _filteredSuggestions[index];
                        return ListTile(
                          dense: true,
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: SteamColors.cardSurface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.videogame_asset_rounded,
                              color: SteamColors.steamBlue,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            game.name,
                            style: const TextStyle(
                              color: SteamColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.north_west_rounded,
                            color: SteamColors.textSecondary,
                            size: 16,
                          ),
                          onTap: () {
                            _textController.text = game.name;
                            _textController.selection = TextSelection.fromPosition(
                              TextPosition(offset: game.name.length),
                            );
                            setState(() {
                              _showSuggestions = false;
                              _filteredSuggestions = [];
                            });
                          },
                        );
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty_suggestions_slot')),
        ),

        // 2. Sabit Slot: Alt Giriş ve Tahmin Çubuğu
        Container(
          key: const ValueKey('game_guess_input_bar_container'),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: SteamColors.navyBg,
            border: Border(
              top: BorderSide(color: SteamColors.cardBorder, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('game_guess_text_field'),
                  controller: _textController,
                  focusNode: _focusNode,
                  enabled: widget.isEnabled,
                  style: const TextStyle(
                    color: SteamColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.isEnabled
                        ? 'Oyun adı yazın (örn: Witcher, Portal)...'
                        : 'Tur tamamlandı',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: SteamColors.steamBlue,
                      size: 22,
                    ),
                    suffixIcon: _textController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: SteamColors.textSecondary,
                            onPressed: () {
                              _textController.clear();
                            },
                          )
                        : null,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => _submitGuess(),
                ),
              ),
              const SizedBox(width: 10),
              // Tahmin Butonu
              Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: widget.isEnabled
                      ? SteamColors.steamButtonGradient
                      : null,
                  color: widget.isEnabled ? null : SteamColors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: widget.isEnabled
                      ? [
                          BoxShadow(
                            color: SteamColors.steamBlue.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: widget.isEnabled ? () => _submitGuess() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TAHMİN ET',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
