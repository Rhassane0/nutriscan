import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/calorie_calculator.dart';

class ProfileProvider with ChangeNotifier {
  UserProfile? _profile;

  UserProfile? get profile => _profile;

  set profile(UserProfile? p) {
    _profile = p;
    // Persister le profil immédiatement
    _saveToPrefs();
    notifyListeners();
  }

  bool get isProfileComplete {
    if (_profile == null) return false;
    // Assume the UserProfile will be extended with these fields later; we check by keys
    try {
      final json = _profile!.toJson();
      return json.containsKey('age') && json.containsKey('weightKg') && json.containsKey('heightCm') && json.containsKey('goalType') && json.containsKey('activityLevel');
    } catch (_) {
      return false;
    }
  }

  double? get dailyCalories {
    if (!isProfileComplete) return null;
    final json = _profile!.toJson();
    final weight = (json['weightKg'] as num).toDouble();
    final height = (json['heightCm'] as num).toDouble();
    final age = (json['age'] as num).toInt();
    final gender = (json['gender'] as String?) ?? 'female';
    final activity = (json['activityLevel'] as String?) ?? 'sedentary';
    final goal = (json['goalType'] as String?) ?? 'maintain';

    final bmr = CalorieCalculator.calculateBmr(weightKg: weight, heightCm: height, age: age, gender: gender);
    return CalorieCalculator.calculateDailyCalories(bmr: bmr, activityLevel: activity, goalType: goal);
  }

  void updateProfileFields(Map<String, dynamic> updates) {
    final json = _profile?.toJson() ?? {};
    json.addAll(updates);
    _profile = UserProfile.fromJson(json);
    // Sauvegarder en local
    _saveToPrefs();
    notifyListeners();
  }

  // Charger le profil depuis SharedPreferences
  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString('user_profile');
      if (s != null && s.isNotEmpty) {
        final jsonMap = json.decode(s) as Map<String, dynamic>;
        _profile = UserProfile.fromJson(jsonMap);
        notifyListeners();
      }
    } catch (_) {
      // Ignorer les erreurs de parsing
    }
  }

  // Sauvegarder le profil en SharedPreferences
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_profile == null) {
        await prefs.remove('user_profile');
        return;
      }
      final s = json.encode(_profile!.toJson());
      await prefs.setString('user_profile', s);
    } catch (_) {
      // Ignorer les erreurs d'I/O
    }
  }
}
