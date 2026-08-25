class GameItem {
  final int appId;
  final String name;

  const GameItem({
    required this.appId,
    required this.name,
  });

  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      appId: json['appId'] as int? ?? 0,
      name: json['name'] as String? ?? (json['oyunAdi'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameItem &&
          runtimeType == other.runtimeType &&
          appId == other.appId;

  @override
  int get hashCode => appId.hashCode;

  @override
  String toString() => name;
}
