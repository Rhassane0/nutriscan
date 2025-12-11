import 'package:flutter/foundation.dart';
import '../models/weight_entry.dart';
import '../services/weight_tracking_service.dart';

class WeightTrackingProvider with ChangeNotifier {
  final WeightTrackingService _service;

  List<WeightEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  WeightTrackingProvider(this._service);

  List<WeightEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEntries({String? startDate, String? endDate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await _service.getWeightHistory(
        startDate: startDate,
        endDate: endDate,
      );
      _entries.sort((a, b) => b.date.compareTo(a.date));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addEntry(double weight, DateTime date, {String? notes}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final entry = await _service.addWeightEntry({
        'weightKg': weight,  // Le backend attend 'weightKg'
        'date': date.toIso8601String().split('T')[0],
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });

      _entries.insert(0, entry);
      _entries.sort((a, b) => b.date.compareTo(a.date));
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

