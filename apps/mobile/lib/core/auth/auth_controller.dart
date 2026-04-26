// Amir ERP — auth state controller (Riverpod).
// Author: Amir Saoudi.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import 'token_store.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? email;
  final String? error;
  final bool loading;
  const AuthState({
    this.status = AuthStatus.unknown,
    this.email,
    this.error,
    this.loading = false,
  });

  AuthState copy({AuthStatus? status, String? email, String? error, bool? loading}) =>
      AuthState(
        status: status ?? this.status,
        email: email ?? this.email,
        error: error,
        loading: loading ?? this.loading,
      );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._dio, this._store) : super(const AuthState()) {
    _bootstrap();
  }
  final Dio _dio;
  final TokenStore _store;

  Future<void> _bootstrap() async {
    final t = await _store.accessToken();
    state = state.copy(status: t != null ? AuthStatus.authenticated : AuthStatus.unauthenticated);
  }

  Future<void> login({required String email, required String password, String? tenant}) async {
    state = state.copy(loading: true, error: null);
    try {
      final res = await _dio.post('/api/v1/auth/login', data: {
        'email': email,
        'password': password,
        if (tenant != null && tenant.isNotEmpty) 'tenantSlug': tenant,
      });
      final data = (res.data is Map && res.data['data'] != null) ? res.data['data'] : res.data;
      await _store.save(
        access: data['accessToken'] as String,
        refresh: data['refreshToken'] as String,
        tenantId: data['tenantId'] as String? ?? '',
      );
      state = state.copy(status: AuthStatus.authenticated, email: email, loading: false);
    } on DioException catch (e) {
      state = state.copy(loading: false, error: e.response?.data?.toString() ?? e.message);
    } catch (e) {
      state = state.copy(loading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _store.clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(dioProvider), ref.watch(tokenStoreProvider));
});
