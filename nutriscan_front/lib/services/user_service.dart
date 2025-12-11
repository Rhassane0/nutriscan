import 'api_service.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiService.get('/users/me');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.get('/users/profile');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/users/profile', data);
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/users/preferences', data);
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}

