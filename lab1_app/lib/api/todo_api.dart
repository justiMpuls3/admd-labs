import 'dart:math';

import 'package:dio/dio.dart';

import '../models/todo.dart';

final _dio = Dio(BaseOptions(
  baseUrl: 'https://jsonplaceholder.typicode.com',
));

Future<T> withRetry<T>(
  Future<T> Function() op, {
  void Function(String)? onLog,
}) async {
  for (var i = 0; ; i++) {
    try {
      final result = await op();
      onLog?.call('Attempt ${i + 1}: success');
      return result;
    } catch (_) {
      if (i == 4) {
        onLog?.call('Attempt ${i + 1}: failed, giving up');
        rethrow;
      }
      final b = 400 * (1 << i);
      final delay = b + Random().nextInt(b);
      onLog?.call('Attempt ${i + 1}: failed, retrying in $delay ms');
      await Future.delayed(Duration(milliseconds: delay));
    }
  }
}

Future<List<Todo>> fetchTodos({
  String path = '/todos',
  void Function(String)? onLog,
}) {
  return withRetry(() async {
    final res = await _dio.get(path);
    final raw = res.data as List<dynamic>;
    return raw
        .map((j) => Todo.fromJson(j as Map<String, dynamic>))
        .toList();
  }, onLog: onLog);
}