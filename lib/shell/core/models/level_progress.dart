import 'package:flutter/material.dart';

/// LevelProgress represents the individual level status and star ratings.
class LevelInfo {
  final int levelNumber;
  final String titleMarathi;
  final String titleEnglish;
  final String descriptionMarathi;
  final String iconEmoji;

  const LevelInfo({
    required this.levelNumber,
    required this.titleMarathi,
    required this.titleEnglish,
    required this.descriptionMarathi,
    required this.iconEmoji,
  });
}

/// GameState holds the player's level progression, stars, coins, and streak.
class GameState extends ChangeNotifier {
  GameState._internal();
  static final GameState instance = GameState._internal();

  int _currentLevelIndex = 1;
  final Map<int, int> _unlockedLevels = {
    1: 0, // Level 1 Unlocked by default
  };

  List<Map<String, dynamic>> _studentLevels = [];
  Map<String, dynamic>? _selectedLevelData;

  int _coins = 170;
  int _streakDays = 3;
  bool _isStreakFrozen = false;

  // Getters
  int get currentLevelIndex => _currentLevelIndex;
  Map<int, int> get unlockedLevels => Map.unmodifiable(_unlockedLevels);
  List<Map<String, dynamic>> get studentLevels => _studentLevels;
  Map<String, dynamic>? get selectedLevelData => _selectedLevelData;
  int get coins => _coins;
  int get streakDays => _streakDays;
  bool get isStreakFrozen => _isStreakFrozen;

  void setStudentLevels(List<Map<String, dynamic>> levels) {
    _studentLevels = levels;
    notifyListeners();
  }

  void setSelectedLevelData(Map<String, dynamic>? data) {
    _selectedLevelData = data;
    notifyListeners();
  }

  void setStreakDays(int days) {
    _streakDays = days;
    notifyListeners();
  }

  int get totalStars {
    return _unlockedLevels.values.fold(0, (sum, stars) => sum + stars);
  }

  static const List<LevelInfo> villageLevels = [
    LevelInfo(
      levelNumber: 1,
      titleMarathi: 'गोठा व वासरू',
      titleEnglish: 'Cattle Shed & Calf',
      descriptionMarathi: 'मोठे आणि छोटे वासरू ओळखा',
      iconEmoji: '🐮',
    ),
    LevelInfo(
      levelNumber: 2,
      titleMarathi: 'नदीकाठचा शोध',
      titleEnglish: 'Riverbank Tap & Find',
      descriptionMarathi: 'लपलेले बदक व मासे शोधा',
      iconEmoji: '🌊',
    ),
    LevelInfo(
      levelNumber: 3,
      titleMarathi: 'चिंटूची गाणी',
      titleEnglish: 'Sing & Speak Mic',
      descriptionMarathi: 'गाणे ऐका आणि बोला',
      iconEmoji: '🎙️',
    ),
    LevelInfo(
      levelNumber: 4,
      titleMarathi: 'शाळा व जत्रा',
      titleEnglish: 'School & Village Fair',
      descriptionMarathi: 'चित्रे जोडा आणि जत्रेत खेळा',
      iconEmoji: '🎪',
    ),
    LevelInfo(
      levelNumber: 5,
      titleMarathi: 'आंब्याची बाग',
      titleEnglish: 'Mango Orchard',
      descriptionMarathi: 'पिकलेले गोड आंबे मोजा',
      iconEmoji: '🥭',
    ),
    LevelInfo(
      levelNumber: 6,
      titleMarathi: 'आठवडी बाजार',
      titleEnglish: 'Weekly Bazaar',
      descriptionMarathi: 'भाजीपाला खरेदी करा',
      iconEmoji: '🛒',
    ),
    LevelInfo(
      levelNumber: 7,
      titleMarathi: 'जत्रेचा पाळणा',
      titleEnglish: 'Ferris Wheel Party',
      descriptionMarathi: 'भव्य ट्रॉफी उत्सव!',
      iconEmoji: '🎡',
    ),
  ];

  LevelInfo get currentLevelInfo {
    return villageLevels.firstWhere(
      (l) => l.levelNumber == _currentLevelIndex,
      orElse: () => villageLevels[3], // default Level 4
    );
  }

  bool isLevelUnlocked(int level) {
    return _unlockedLevels.containsKey(level);
  }

  bool isLevelCompleted(int level) {
    return (_unlockedLevels[level] ?? 0) > 0;
  }

  int getStarsForLevel(int level) {
    return _unlockedLevels[level] ?? 0;
  }

  /// Triggered after diagnostic placement to reward the student
  /// and place them on their assigned starting level.
  void completeDiagnosticPlacement({int startingLevel = 1}) {
    for (int i = 1; i < startingLevel; i++) {
      _unlockedLevels[i] = 3;
    }
    _unlockedLevels[startingLevel] = 0;
    _currentLevelIndex = startingLevel;
    _coins += 30; // +10 per quiz question
    notifyListeners();
  }

  void setCurrentLevel(int level) {
    if (isLevelUnlocked(level)) {
      _currentLevelIndex = level;
      notifyListeners();
    }
  }

  void addCoins(int amount) {
    _coins += amount;
    notifyListeners();
  }

  void toggleStreakFreeze() {
    _isStreakFrozen = !_isStreakFrozen;
    notifyListeners();
  }

  void completeLevel(int level, int stars, int coinsEarned) {
    _unlockedLevels[level] = stars;
    _coins += coinsEarned;
    // Unlock next level if available
    final nextLevel = level + 1;
    if (nextLevel <= villageLevels.length && !_unlockedLevels.containsKey(nextLevel)) {
      _unlockedLevels[nextLevel] = 0;
      _currentLevelIndex = nextLevel;
    }
    notifyListeners();
  }
}
