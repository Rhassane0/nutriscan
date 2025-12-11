import 'api_service.dart';

class GoalsService {
  final ApiService _apiService;

  GoalsService(this._apiService);

  Future<Map<String, dynamic>> getGoals() async {
    try {
      final response = await _apiService.get('/goals');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateGoals(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/goals', data);
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> recalculateGoals() async {
    try {
      final response = await _apiService.post('/goals/recalculate', {});
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGoals() async {
    try {
      await _apiService.delete('/goals');
    } catch (e) {
      rethrow;
    }
  }
}

