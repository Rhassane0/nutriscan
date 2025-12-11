import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'email': username,  // Le backend attend 'email', pas 'username'
        'password': password,
      });

      if (response['token'] != null) {
        await _apiService.saveToken(response['token']);
      }

      // Le backend retourne les données utilisateur directement dans la réponse
      // On les met dans une clé 'user' pour compatibilité
      return {
        'token': response['token'],
        'user': {
          'id': response['userId'],
          'email': response['email'],
          'fullName': response['fullName'],
          'role': response['role'],
        },
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await _apiService.post('/auth/register', {
        'fullName': username,  // Le backend attend 'fullName', pas 'username'
        'email': email,
        'password': password,
      });

      if (response['token'] != null) {
        await _apiService.saveToken(response['token']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    // Pas de logout côté serveur, on nettoie juste le token local
    await _apiService.clearToken();
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/users/me');
      return response as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  bool isLoggedIn() {
    return _apiService.token != null;
  }
}

