// Amir ERP — secure token storage.
// Author: Amir Saoudi.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenStore {
  Future<String?> accessToken();
  Future<String?> refreshToken();
  Future<String?> tenantId();
  Future<void> save({required String access, required String refresh, required String tenantId});
  Future<void> clear();
}

class _SecureTokenStore implements TokenStore {
  final _storage = const FlutterSecureStorage();
  @override
  Future<String?> accessToken() => _storage.read(key: 'access');
  @override
  Future<String?> refreshToken() => _storage.read(key: 'refresh');
  @override
  Future<String?> tenantId() => _storage.read(key: 'tenant');
  @override
  Future<void> save({required String access, required String refresh, required String tenantId}) async {
    await _storage.write(key: 'access', value: access);
    await _storage.write(key: 'refresh', value: refresh);
    await _storage.write(key: 'tenant', value: tenantId);
  }
  @override
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}

class _PrefsTokenStore implements TokenStore {
  Future<SharedPreferences> get _p async => SharedPreferences.getInstance();
  @override
  Future<String?> accessToken() async => (await _p).getString('access');
  @override
  Future<String?> refreshToken() async => (await _p).getString('refresh');
  @override
  Future<String?> tenantId() async => (await _p).getString('tenant');
  @override
  Future<void> save({required String access, required String refresh, required String tenantId}) async {
    final p = await _p;
    await p.setString('access', access);
    await p.setString('refresh', refresh);
    await p.setString('tenant', tenantId);
  }
  @override
  Future<void> clear() async {
    final p = await _p;
    await p.remove('access');
    await p.remove('refresh');
    await p.remove('tenant');
  }
}

final tokenStoreProvider = Provider<TokenStore>((_) {
  // Web does not support flutter_secure_storage, fall back to SharedPreferences.
  return kIsWeb ? _PrefsTokenStore() : _SecureTokenStore();
});
