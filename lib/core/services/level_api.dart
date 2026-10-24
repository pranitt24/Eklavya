import 'dart:convert';
import 'package:http/http.dart' as http;

/// Client for the NOVA backend level generation and catalog service.
/// Endpoints:
///   GET  `/levels?grade=...&skill_id=...`
///   GET  `/levels/<level_id>`
///   POST `/generate`
class LevelApi {
  final String baseUrl;
  final http.Client _client;

  LevelApi({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? 'http://127.0.0.1:8000',
        _client = client ?? http.Client();

  /// GET `/levels?grade=...&skill_id=...`
  Future<List<Map<String, dynamic>>> listLevels({
    int? grade,
    String? skillId,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final params = <String, String>{};
    if (grade != null) params['grade'] = grade.toString();
    if (skillId != null) params['skill_id'] = skillId;
    final uri = Uri.parse('$baseUrl/levels')
        .replace(queryParameters: params.isEmpty ? null : params);
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is List) {
          return data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    } catch (_) {
      // Unreachable server or timeout: caller falls back to demo assets
    }
    return <Map<String, dynamic>>[];
  }

  /// GET `/levels/<level_id>`
  Future<Map<String, dynamic>?> getLevel(
    String levelId, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final uri = Uri.parse('$baseUrl/levels/$levelId');
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
    } catch (_) {}
    return null;
  }

  /// POST `/generate`
  Future<Map<String, dynamic>?> generate({
    required String skillId,
    required int grade,
    required int tier,
    String? kind,
    String? prop,
    int? seed,
    bool useLlm = true,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = Uri.parse('$baseUrl/generate');
    final body = jsonEncode({
      'skill_id': skillId,
      'grade': grade,
      'tier': tier,
      'kind': ?kind,
      'prop': ?prop,
      'seed': ?seed,
      'use_llm': useLlm,
    });
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: body,
      ).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
    } catch (_) {}
    return null;
  }

  /// POST `/students`
  Future<Map<String, dynamic>?> createStudent(
    Map<String, dynamic> data, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final uri = Uri.parse('$baseUrl/students');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(data),
      ).timeout(timeout);
      if (response.statusCode == 200) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        if (res is Map) return Map<String, dynamic>.from(res);
      }
    } catch (_) {}
    return null;
  }

  /// GET `/students`
  Future<List<Map<String, dynamic>>> listStudents({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final uri = Uri.parse('$baseUrl/students');
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is List) {
          return data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    } catch (_) {}
    return <Map<String, dynamic>>[];
  }

  /// GET `/students/<id>`
  Future<Map<String, dynamic>?> getStudent(
    int id, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final uri = Uri.parse('$baseUrl/students/$id');
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map) return Map<String, dynamic>.from(data);
      }
    } catch (_) {}
    return null;
  }

  /// GET `/students/<id>/levels`
  Future<List<Map<String, dynamic>>> getStudentLevels(
    int id, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final uri = Uri.parse('$baseUrl/students/$id/levels');
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is List) {
          return data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    } catch (_) {}
    return <Map<String, dynamic>>[];
  }

  /// POST `/students/<id>/placement`
  Future<Map<String, dynamic>?> recordPlacement(
    int id, {
    required int correct,
    required int total,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final uri = Uri.parse('$baseUrl/students/$id/placement');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'correct': correct, 'total': total}),
      ).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map) return Map<String, dynamic>.from(data);
      }
    } catch (_) {}
    return null;
  }

  /// POST `/students/<id>/progress`
  Future<Map<String, dynamic>?> recordProgress(
    int id, {
    required String levelId,
    required int correct,
    required int total,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final uri = Uri.parse('$baseUrl/students/$id/progress');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'level_id': levelId,
          'correct': correct,
          'total': total,
        }),
      ).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map) return Map<String, dynamic>.from(data);
      }
    } catch (_) {}
    return null;
  }

  /// GET `/duel/questions?seed=...&n=...&grade=...`
  Future<List<Map<String, dynamic>>> getDuelQuestions({
    int seed = 1,
    int n = 5,
    int grade = 1,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final uri = Uri.parse('$baseUrl/duel/questions?seed=$seed&n=$n&grade=$grade');
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is List) {
          return data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    } catch (_) {}
    return <Map<String, dynamic>>[];
  }
}
