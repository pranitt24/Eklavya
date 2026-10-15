import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nova_schema_models.dart';
import '../data/nova_seed_catalog.dart';

/// Riverpod provider for the standalone Nova Schema Repository.
/// Strictly decoupled from legacy AppState / Drift tables to avoid regressions.
final novaSchemaRepositoryProvider =
    Provider<NovaSchemaRepository>((ref) => NovaSchemaRepository());

/// Standalone repository managing user profiles, BKT mastery probabilities,
/// asset unlock state, telemetry logs, and dynamic level contract dispatching.
class NovaSchemaRepository extends ChangeNotifier {
  // Current Student Profile
  late NovaUser _currentUser;

  // BKT Latent Mastery State map: skillId -> UserBktState
  final Map<String, UserBktState> _bktStates = {};

  // Unlocked Assets set
  final Set<String> _unlockedAssetIds = {};

  // Telemetry logs queue
  final List<GameplayLogRecord> _logs = [];

  NovaSchemaRepository() {
    _initializeDefaultState();
  }

  void _initializeDefaultState() {
    // Default player matching system specs
    _currentUser = NovaUser(
      userId: 'usr_default_01',
      username: 'आरव',
      currentLevel: 1,
      coinsBalance: 120,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Initialize P(L_0) for each curriculum skill at default 0.1000
    for (final skill in NovaSeedCatalog.skills) {
      _bktStates[skill.skillId] = UserBktState(
        userId: _currentUser.userId,
        skillId: skill.skillId,
        pLearned: 0.1000,
        updatedAt: DateTime.now(),
      );
    }

    // Default unlock all zero-cost assets
    for (final asset in NovaSeedCatalog.gameAssets) {
      if (asset.unlockCost == 0) {
        _unlockedAssetIds.add(asset.assetId);
      }
    }
  }

  // ===========================================================================
  // USER PROFILE
  // ===========================================================================

  NovaUser get currentUser => _currentUser;

  void updateUser(NovaUser updatedUser) {
    _currentUser = updatedUser.copyWith(updatedAt: DateTime.now());
    notifyListeners();
  }

  void addCoins(int coinsToAdd) {
    _currentUser = _currentUser.copyWith(
      coinsBalance: _currentUser.coinsBalance + coinsToAdd,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void setCurrentLevel(int level) {
    if (level > _currentUser.currentLevel) {
      _currentUser = _currentUser.copyWith(
        currentLevel: level,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // ===========================================================================
  // BKT MASTERY ENGINE (Local client shadow of Cloud BKT)
  // ===========================================================================

  UserBktState getBktState(String skillId) {
    return _bktStates[skillId] ??
        UserBktState(
          userId: _currentUser.userId,
          skillId: skillId,
          pLearned: 0.1000,
          updatedAt: DateTime.now(),
        );
  }

  Map<String, UserBktState> getAllBktStates() {
    return Map.unmodifiable(_bktStates);
  }

  /// Updates P(L_t) Bayesian Knowledge Tracing probability given observation.
  /// Formula from system architecture:
  /// P(L | correct)   = (P(L) * (1 - P(S))) / (P(L) * (1 - P(S)) + (1 - P(L)) * P(G))
  /// P(L | incorrect) = (P(L) * P(S)) / (P(L) * P(S) + (1 - P(L)) * (1 - P(G)))
  /// P(L_{t+1})       = P(L | obs) + (1 - P(L | obs)) * P(T)
  void recordObservation(String skillId, {required bool isCorrect}) {
    final skill = NovaSeedCatalog.getSkillById(skillId) ??
        SkillRecord(skillId: skillId, skillName: skillId, subject: 'General');

    final double prior = (_bktStates[skillId]?.pLearned ?? 0.1000).clamp(0.001, 0.999);
    final double pG = skill.pGuess;
    final double pS = skill.pSlip;
    final double pT = skill.pTransit;

    double pPosterior;
    if (isCorrect) {
      final double numerator = prior * (1.0 - pS);
      final double denominator = numerator + ((1.0 - prior) * pG);
      pPosterior = denominator > 0 ? (numerator / denominator) : prior;
    } else {
      final double numerator = prior * pS;
      final double denominator = numerator + ((1.0 - prior) * (1.0 - pG));
      pPosterior = denominator > 0 ? (numerator / denominator) : prior;
    }

    // Transit to learned state
    final double nextPLearned = (pPosterior + ((1.0 - pPosterior) * pT)).clamp(0.01, 0.99);

    _bktStates[skillId] = UserBktState(
      userId: _currentUser.userId,
      skillId: skillId,
      pLearned: nextPLearned,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
  }

  /// Sets BKT latent mastery probability for a specific skill.
  void setBktMastery(String skillId, double pLearned) {
    _bktStates[skillId] = UserBktState(
      userId: _currentUser.userId,
      skillId: skillId,
      pLearned: pLearned.clamp(0.01, 0.99),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Sets BKT latent mastery probability for all curriculum skills.
  void setAllBktMastery(double pLearned) {
    for (final skill in NovaSeedCatalog.skills) {
      _bktStates[skill.skillId] = UserBktState(
        userId: _currentUser.userId,
        skillId: skill.skillId,
        pLearned: pLearned.clamp(0.01, 0.99),
        updatedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  // ===========================================================================
  // ASSET UNLOCK INVENTORY
  // ===========================================================================

  bool isAssetUnlocked(String assetId) => _unlockedAssetIds.contains(assetId);

  List<String> get unlockedAssetIds => List.unmodifiable(_unlockedAssetIds);

  bool unlockAsset(String assetId) {
    if (_unlockedAssetIds.contains(assetId)) return true;

    final asset = NovaSeedCatalog.getAssetById(assetId);
    if (asset == null) return false;

    if (_currentUser.coinsBalance >= asset.unlockCost) {
      _currentUser = _currentUser.copyWith(
        coinsBalance: _currentUser.coinsBalance - asset.unlockCost,
        updatedAt: DateTime.now(),
      );
      _unlockedAssetIds.add(assetId);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ===========================================================================
  // TELEMETRY & GAMEPLAY LOGS
  // ===========================================================================

  List<GameplayLogRecord> get logs => List.unmodifiable(_logs);

  void logGameplay({
    required String questionId,
    required String skillId,
    required bool isCorrect,
    required int attempts,
    required int timeTakenSec,
  }) {
    final log = GameplayLogRecord(
      logId: 'log_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser.userId,
      questionId: questionId,
      isCorrect: isCorrect,
      attempts: attempts,
      timeTakenSec: timeTakenSec,
      timestamp: DateTime.now(),
    );

    _logs.add(log);

    // Update BKT state on observation
    recordObservation(skillId, isCorrect: isCorrect);

    // Reward coins on first-try success
    if (isCorrect && attempts <= 1) {
      addCoins(10);
    }

    notifyListeners();
  }

  // ===========================================================================
  // LEVEL CONTRACT DISPATCHER (Factory)
  // ===========================================================================

  GeneratedLevelContract getLevelContract(int levelId) {
    switch (levelId) {
      case 1:
        return NovaSeedCatalog.level1VillageMorningContract;
      case 2:
        return NovaSeedCatalog.level2BanyanGroveContract;
      default:
        return NovaSeedCatalog.level1VillageMorningContract;
    }
  }

  // ===========================================================================
  // STATE EXPORT / IMPORT
  // ===========================================================================

  Map<String, dynamic> exportStateToJson() {
    return {
      'user': _currentUser.toJson(),
      'bkt_states': _bktStates.map((k, v) => MapEntry(k, v.toJson())),
      'unlocked_assets': _unlockedAssetIds.toList(),
      'logs': _logs.map((l) => l.toJson()).toList(),
    };
  }

  void importStateFromJson(Map<String, dynamic> json) {
    if (json['user'] != null) {
      _currentUser = NovaUser.fromJson(Map<String, dynamic>.from(json['user']));
    }
    if (json['bkt_states'] != null) {
      final map = Map<String, dynamic>.from(json['bkt_states']);
      _bktStates.clear();
      map.forEach((k, v) {
        _bktStates[k] = UserBktState.fromJson(Map<String, dynamic>.from(v));
      });
    }
    if (json['unlocked_assets'] != null) {
      _unlockedAssetIds.clear();
      _unlockedAssetIds.addAll(List<String>.from(json['unlocked_assets']));
    }
    if (json['logs'] != null) {
      _logs.clear();
      _logs.addAll(
        (json['logs'] as List).map((l) => GameplayLogRecord.fromJson(Map<String, dynamic>.from(l))),
      );
    }
    notifyListeners();
  }
}
