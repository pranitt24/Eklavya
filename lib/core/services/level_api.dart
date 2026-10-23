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
}
