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

    test('createStudent sends POST and returns student profile', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/students');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['name'], 'आरव');
        return http.Response(
          jsonEncode({'id': 1, 'name': 'आरव', 'age': 7, 'grade': 2, 'tier': 1}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = LevelApi(client: mockClient);
      final res = await api.createStudent({'name': 'आरव', 'age': 7});
      expect(res, isNotNull);
      expect(res!['id'], 1);
      expect(res['name'], 'आरव');
    });

    test('recordPlacement sends POST and returns grade and tier', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/students/1/placement');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['correct'], 4);
        expect(body['total'], 5);
        return http.Response(
          jsonEncode({'student_id': 1, 'grade': 2, 'tier': 1, 'score': 4, 'total': 5}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = LevelApi(client: mockClient);
      final res = await api.recordPlacement(1, correct: 4, total: 5);
      expect(res, isNotNull);
      expect(res!['grade'], 2);
    });

    test('recordProgress sends POST and returns stars', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/students/1/progress');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['level_id'], 'lvl_1');
        return http.Response(
          jsonEncode({'student_id': 1, 'level_id': 'lvl_1', 'stars': 3}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = LevelApi(client: mockClient);
      final res = await api.recordProgress(1, levelId: 'lvl_1', correct: 3, total: 3);
      expect(res, isNotNull);
      expect(res!['stars'], 3);
    });

    test('getDuelQuestions fetches 5 questions with options and answer', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/duel/questions');
        expect(request.url.queryParameters['n'], '5');
        return http.Response(
          jsonEncode([
            {
              'id': 'd1',
              'type': 'fill_blanks',
              'prompt': {'mr': '3 + 4 = ?', 'en': '3 + 4 = ?'},
              'options': [7, 5, 8, 9],
              'answer': 7,
            }
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = LevelApi(client: mockClient);
      final qList = await api.getDuelQuestions(n: 5, grade: 1);
      expect(qList.length, 1);
      expect(qList.first['answer'], 7);
    });
  });
}
