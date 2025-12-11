import 'api_service.dart';
import '../models/weight_entry.dart';

class WeightTrackingService {
  final ApiService _apiService;

  WeightTrackingService(this._apiService);

  Future<List<WeightEntry>> getWeightHistory({
    String? startDate,
    String? endDate,
  }) async {
    try {
      var url = '/tracking/weight';
      final params = <String>[];

      if (startDate != null) {
        params.add('from=$startDate');
      }
      if (endDate != null) {
        params.add('to=$endDate');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await _apiService.get(url);

      if (response is List) {
        return (response as List<dynamic>).map((e) => WeightEntry.fromJson(e as Map<String, dynamic>)).toList();
      } else if (response is Map<String, dynamic> && response['data'] != null) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        return data.map((e) => WeightEntry.fromJson(e as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<WeightEntry> addWeightEntry(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/tracking/weight', data);
      return WeightEntry.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}

