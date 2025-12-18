import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Connexion
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(username, password);
      if (response['user'] != null) {
        _user = User.fromJson(response['user']);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Inscription
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(username, email, password);
      if (response['user'] != null) {
        _user = User.fromJson(response['user']);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  // Vérifier si l'utilisateur est connecté
  void checkAuthStatus() {
    if (_authService.isLoggedIn()) {
      // L'utilisateur a un token sauvegardé
      // On pourrait faire une requête pour récupérer les infos utilisateur
      notifyListeners();
    }
  }

  // Rafraîchir les informations utilisateur
  Future<void> refreshUser() async {
    try {
      final userData = await _authService.getCurrentUser();
      if (userData != null) {
        _user = User.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  // Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

