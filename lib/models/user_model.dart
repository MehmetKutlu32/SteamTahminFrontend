class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final bool isGuest;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.isGuest = false,
  });

  factory UserModel.guest({String? name}) {
    final randId = DateTime.now().millisecond;
    return UserModel(
      id: 'guest_$randId',
      displayName: name ?? 'Misafir_$randId',
      email: '',
      isGuest: true,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Oyuncu',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      isGuest: json['isGuest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'isGuest': isGuest,
    };
  }
}
