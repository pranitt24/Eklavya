import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:majhe_gaon/core/services/level_api.dart';

void main() {
  group('LevelApi tests', () {
    test('listLevels parses JSON array on 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/levels');
        expect(request.url.queryParameters['grade'], '1');
        return http.Response(
          jsonEncode([
            {'level_id': 'lvl_1', 'grade': 1, 'skill_id': 'M1_COUNT'},
            {'level_id': 'lvl_2', 'grade': 1, 'skill_id': 'M1_ADD'},
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = LevelApi(client: mockClient);
      final levels = await api.listLevels(grade: 1);
      expect(levels.length, 2);
      expect(levels.first['level_id'], 'lvl_1');
    });

    test('listLevels returns empty list on network error', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Connection refused');
      });

      final api = LevelApi(client: mockClient);
      final levels = await api.listLevels(grade: 1);
      expect(levels, isEmpty);
    });

    test('getLevel parses single level on 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/levels/lvl_1');
        return http.Response(
          jsonEncode({'level_id': 'lvl_1', 'title': {'mr': 'चाचणी'}}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = LevelApi(client: mockClient);
      final level = await api.getLevel('lvl_1');
      expect(level, isNotNull);
      expect(level!['level_id'], 'lvl_1');
    });

    test('generate sends POST and returns level data', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/generate');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['skill_id'], 'M1_COUNT');
        expect(body['grade'], 1);
        return http.Response(
          jsonEncode({
            'level': {'level_id': 'gen_1', 'grade': 1},
            'info': {'source': 'template'},
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = LevelApi(client: mockClient);
      final res = await api.generate(skillId: 'M1_COUNT', grade: 1, tier: 1);
      expect(res, isNotNull);
      expect(res!['level']['level_id'], 'gen_1');
    });
  });
}
