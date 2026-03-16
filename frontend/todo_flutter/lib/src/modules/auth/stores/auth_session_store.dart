import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:todo_flutter/src/shared/database/app_database.dart';

/// Global auth session state used by infrastructure layers (e.g. interceptors).
class AuthSessionStore extends ChangeNotifier {
  AuthSessionStore(this._database) {
    _subscription = _database.watchSession().listen(_onSessionChanged);
  }

  final AppDatabase _database;
  StreamSubscription<Session?>? _subscription;

  String? _token;
  String _tokenType = 'Bearer';
  DateTime? _expiresAt;

  String? get token => _token;
  String get tokenType => _tokenType;
  DateTime? get expiresAt => _expiresAt;

  bool get isAuthenticated {
    final token = _token;
    final expiresAt = _expiresAt;
    if (token == null || token.isEmpty) return false;
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt);
  }

  String? get authorizationHeader => isAuthenticated ? '$tokenType $token' : null;

  Future<void> clearSession() async {
    await _database.clearSession();
  }

  void _onSessionChanged(Session? session) {
    if (session == null) {
      _token = null;
      _tokenType = 'Bearer';
      _expiresAt = null;
      notifyListeners();
      return;
    }

    _token = session.token;
    _tokenType = session.tokenType;
    _expiresAt = session.expiresAt;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
