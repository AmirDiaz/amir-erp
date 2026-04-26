// Amir ERP — Dio API client.
// Author: Amir Saoudi.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/token_store.dart';

class ApiConfig {
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
}

final dioProvider = Provider<Dio>((ref) {
  final tokenStore = ref.watch(tokenStoreProvider);
  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await tokenStore.accessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      final tenant = await tokenStore.tenantId();
      if (tenant != null) {
        options.headers['X-Tenant-Id'] = tenant;
      }
      handler.next(options);
    },
  ));
  return dio;
});
