import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/popular_games_catalog.dart';
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

  static String _normalize(String text) {
    var s = text.toLowerCase().trim();
    s = s
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return s;
  }

  static String _convertRomanNumerals(String text) {
    return text
        .replaceAll(RegExp(r'\bii\b'), '2')
        .replaceAll(RegExp(r'\biii\b'), '3')
        .replaceAll(RegExp(r'\biv\b'), '4')
        .replaceAll(RegExp(r'\bv\b'), '5')
        .replaceAll(RegExp(r'\bvi\b'), '6')
        .replaceAll(RegExp(r'\bvii\b'), '7')
        .replaceAll(RegExp(r'\bviii\b'), '8')
        .replaceAll(RegExp(r'\bix\b'), '9')
        .replaceAll(RegExp(r'\bx\b'), '10');
  }

  static int _levenshtein(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[s2.length];
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    final rawQuery = _textController.text.trim();

    if (rawQuery.isEmpty) {
      if (_showSuggestions || _filteredSuggestions.isNotEmpty) {
        setState(() {
          _filteredSuggestions = [];
          _showSuggestions = false;
        });
      }
      return;
    }

    // Akıllı Çoklu Kelime & Kısaltma (Alias) & Yazım Hatası Toleranslı Arama
    _debounceTimer = Timer(const Duration(milliseconds: 40), () {
      final normalizedQuery = _normalize(rawQuery);
      if (normalizedQuery.isEmpty) return;

      final normalizedRomanQuery = _convertRomanNumerals(normalizedQuery);
      final queryTokens = normalizedRomanQuery.split(' ').where((t) => t.isNotEmpty).toList();

      // Oyun havuzu (Aktif liste + Popüler katalog birleşimi)
      final candidateGames = widget.games.isNotEmpty ? widget.games : PopularGamesCatalog.defaultPopularGames;
      final int len = candidateGames.length;

      final List<MapEntry<GameItem, int>> scoredResults = [];
      final Set<int> addedAppIds = {};

      // 0. Takma Ad (Alias) Tam Eşleşme Kontrolü (Örn: "gta 5", "cs2", "rdr2", "witcher 3")
      final aliasMatch = PopularGamesCatalog.commonAliases[normalizedQuery] ??
          PopularGamesCatalog.commonAliases[normalizedRomanQuery];
      if (aliasMatch != null) {
        final normAlias = _normalize(aliasMatch);
        for (final game in candidateGames) {
          if (_normalize(game.name) == normAlias || game.name.toLowerCase().contains(aliasMatch.toLowerCase())) {
            scoredResults.add(MapEntry(game, 200));
            addedAppIds.add(game.appId);
            break;
          }
        }
      }

      for (int i = 0; i < len; i++) {
        final game = candidateGames[i];
        if (addedAppIds.contains(game.appId)) continue;

        final rawNormGame = _normalize(game.name);
        final normalizedGame = _convertRomanNumerals(rawNormGame);
        final gameTokens = normalizedGame.split(' ').where((t) => t.isNotEmpty).toList();

        // 1. Doğrudan Başlama (En Yüksek Öncelik)
        if (normalizedGame.startsWith(normalizedRomanQuery) || rawNormGame.startsWith(normalizedQuery)) {
          scoredResults.add(MapEntry(game, 120));
          addedAppIds.add(game.appId);
          continue;
        }

        // 2. Doğrudan İçerme
        if (normalizedGame.contains(normalizedRomanQuery) || rawNormGame.contains(normalizedQuery)) {
          scoredResults.add(MapEntry(game, 90));
          addedAppIds.add(game.appId);
          continue;
        }

        // 3. Çoklu Kelime & Harf Hatası Toleransı
        bool allTokensMatched = true;
        int totalDistance = 0;

        for (final qToken in queryTokens) {
          bool tokenMatched = false;
          int minTokenDist = 999;

          for (final gToken in gameTokens) {
            if (gToken.startsWith(qToken) || gToken.contains(qToken)) {
              tokenMatched = true;
              minTokenDist = 0;
              break;
            }

            // Yazım hatası toleransı (Kelime uzunluğuna göre 1-2 harf hatası)
            final maxAllowedDist = qToken.length >= 6 ? 2 : (qToken.length >= 4 ? 1 : 0);
            if (maxAllowedDist > 0) {
              final dist = _levenshtein(qToken, gToken);
              if (dist <= maxAllowedDist && dist < minTokenDist) {
                minTokenDist = dist;
                tokenMatched = true;
              }
            }
          }

          if (!tokenMatched) {
            allTokensMatched = false;
            break;
          }
          totalDistance += minTokenDist;
        }

        if (allTokensMatched) {
          final score = (60 - totalDistance * 10).clamp(10, 70);
          scoredResults.add(MapEntry(game, score));
          addedAppIds.add(game.appId);
        }
      }

      // Skorlarına göre sırala ve ilk 10 sonucu al
      scoredResults.sort((a, b) => b.value.compareTo(a.value));
      final results = scoredResults.take(10).map((e) => e.key).toList();

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
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final maxSuggestionsHeight = isKeyboardOpen ? 140.0 : 200.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Sabit Slot: Canlı Oyun Öneri Paneli
        AnimatedSize(
          key: const ValueKey('game_guess_animated_size'),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: (_showSuggestions && _filteredSuggestions.isNotEmpty)
              ? Container(
                  key: const ValueKey('game_guess_suggestions_panel'),
                  constraints: BoxConstraints(maxHeight: maxSuggestionsHeight),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: SteamColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SteamColors.steamBlue, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 14,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListView.separated(
                      key: const ValueKey('suggestions_list_view'),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                      padding: const EdgeInsets.symmetric(vertical: 2),
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
                          visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: SteamColors.cardSurface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.sports_esports_rounded,
                              size: 15,
                              color: SteamColors.steamCyan,
                            ),
                          ),
                          title: Text(
                            game.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(
                            Icons.north_west_rounded,
                            size: 14,
                            color: SteamColors.textMuted,
                          ),
                          onTap: () {
                            _submitGuess(game.name);
                          },
                        );
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // 2. Tahmin Yazma Alanı (Arama Çubuğu)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: SteamColors.navyBg,
            border: Border(
              top: BorderSide(color: SteamColors.cardBorder, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: SteamColors.cardSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _focusNode.hasFocus
                          ? SteamColors.steamBlue
                          : SteamColors.cardBorder,
                      width: 1.2,
                    ),
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    enabled: widget.isEnabled,
                    style: const TextStyle(
                      color: SteamColors.textPrimary,
                      fontSize: 14,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (val) => _submitGuess(),
                    decoration: InputDecoration(
                      hintText: 'Oyun adını yazın (örn: GTA 5, CS2, RDR2)...',
                      hintStyle: const TextStyle(
                        color: SteamColors.textMuted,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: SteamColors.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: _textController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              color: SteamColors.textMuted,
                              onPressed: () {
                                _textController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.isEnabled ? () => _submitGuess() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SteamColors.steamBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: const Icon(Icons.send_rounded, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
