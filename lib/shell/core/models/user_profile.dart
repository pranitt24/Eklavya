import 'package:flutter/material.dart';

class AvatarItem {
  final String id;
  final String nameMarathi;
  final String nameEnglish;
  final String assetPath;
  final Color accentColor;
  final String emoji;

  const AvatarItem({
    required this.id,
    required this.nameMarathi,
    required this.nameEnglish,
    required this.assetPath,
    required this.accentColor,
    required this.emoji,
  });
}

/// UserProfile maintains student details and provides ChangeNotifier
/// state management across screens.
class UserProfile extends ChangeNotifier {
  UserProfile._internal();
  static final UserProfile instance = UserProfile._internal();

  String _name = 'आरव';
  int _age = 6;
  String _selectedAvatar = 'chintu';
  int _stars = 12;
  int _coins = 170;
  int _streakDays = 5;

  String get name => _name;
  int get age => _age;
  String get selectedAvatar => _selectedAvatar;
  int get stars => _stars;
  int get coins => _coins;
  int get streakDays => _streakDays;

  void setStreakDays(int days) {
    _streakDays = days;
    notifyListeners();
  }

  static const List<int> availableAges = [5, 6, 7, 8];

  static const List<AvatarItem> availableAvatars = [
    AvatarItem(
      id: 'chintu',
      nameMarathi: 'चिंटू',
      nameEnglish: 'Chintu',
      assetPath: 'assets/images/characters/chintu.png',
      accentColor: Color(0xFFFBBF24),
      emoji: '👦🏽',
    ),
    AvatarItem(
      id: 'nova',
      nameMarathi: 'नोव्हा',
      nameEnglish: 'NOVA',
      assetPath: 'assets/images/characters/nova.png',
      accentColor: Color(0xFF38BDF8),
      emoji: '🤖',
    ),
    AvatarItem(
      id: 'meena',
      nameMarathi: 'मीना',
      nameEnglish: 'Meena',
      assetPath: 'assets/images/characters/chintu.png',
      accentColor: Color(0xFFF472B6),
      emoji: '👧🏽',
    ),
    AvatarItem(
      id: 'sheru',
      nameMarathi: 'शेरू',
      nameEnglish: 'Sheru',
      assetPath: 'assets/images/characters/chintu.png',
      accentColor: Color(0xFFFB923C),
      emoji: '🐶',
    ),
    AvatarItem(
      id: 'chiu',
      nameMarathi: 'चिऊ',
      nameEnglish: 'Chiu',
      assetPath: 'assets/images/characters/chintu.png',
      accentColor: Color(0xFF34D399),
      emoji: '🐦',
    ),
    AvatarItem(
      id: 'ganya',
      nameMarathi: 'गण्या',
      nameEnglish: 'Ganya',
      assetPath: 'assets/images/characters/chintu.png',
      accentColor: Color(0xFFA78BFA),
      emoji: '🧒🏽',
    ),
  ];

  AvatarItem get activeAvatarItem =>
      availableAvatars.firstWhere(
        (a) => a.id == _selectedAvatar,
        orElse: () => availableAvatars.first,
      );

  void setName(String newName) {
    if (newName.trim().isEmpty) return;
    _name = newName.trim();
    notifyListeners();
  }

  void setAge(int newAge) {
    if (_age == newAge) return;
    _age = newAge;
    notifyListeners();
  }

  void setAvatar(String avatarId) {
    if (_selectedAvatar == avatarId) return;
    _selectedAvatar = avatarId;
    notifyListeners();
  }

  void addStars(int count) {
    _stars += count;
    notifyListeners();
  }

  void addCoins(int count) {
    _coins += count;
    notifyListeners();
  }
}
