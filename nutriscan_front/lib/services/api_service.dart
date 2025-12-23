import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;

  ApiService._internal();

  static const String baseUrl = 'http://localhost:8082/api';
  String? _token;

  // Mode debug activé pour diagnostic - à désactiver en production
  static const bool _debugMode = true;

  // Log uniquement en mode debug
  void _log(String message) {
    if (_debugMode && kDebugMode) {
      print('🔍 [API] $message');
    }
  }

  // Log des erreurs (toujours affichées)
  void _logError(String message) {
    if (kDebugMode) {
      print('❌ [API ERROR] $message');
    }
  }

  // Log de debug détaillé
  void _logDebug(String endpoint, String method, {dynamic data, int? statusCode, String? response}) {
    if (_debugMode && kDebugMode) {
      print('═══════════════════════════════════════════');
      print('🌐 $method $endpoint');
      if (data != null) print('📤 Data: $data');
      if (statusCode != null) print('📥 Status: $statusCode');
      if (response != null && response.length < 500) print('📦 Response: $response');
      print('═══════════════════════════════════════════');
    }
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  String? get token => _token;

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String endpoint) async {
    try {
      _log('🔵 GET: $endpoint');

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      _log('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return <String, dynamic>{};
        }
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Non autorisé');
      } else if (response.statusCode == 404) {
        throw Exception('Ressource non trouvée');
      } else {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      _logError('GET $endpoint: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {Duration? timeout}) async {
    try {
      _logDebug(endpoint, 'POST', data: data);

      // Timeout plus long pour les opérations d'IA (génération de plan)
      final requestTimeout = timeout ?? (endpoint.contains('generate')
          ? const Duration(minutes: 3)
          : const Duration(seconds: 30));

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      ).timeout(requestTimeout, onTimeout: () {
        _logError('POST $endpoint: TIMEOUT après ${requestTimeout.inSeconds}s');
        throw Exception('La requête a expiré. La génération du plan prend trop de temps.');
      });

      _logDebug(endpoint, 'POST RESPONSE', statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Non autorisé');
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        _logError('POST $endpoint 400: ${response.body}');
        throw Exception(errorBody['message'] ?? 'Requête invalide');
      } else if (response.statusCode == 403) {
        _logError('POST $endpoint 403: CORS ou accès refusé');
        throw Exception('Accès refusé - Vérifiez CORS côté backend');
      } else if (response.statusCode == 500) {
        _logError('POST $endpoint 500 - Server error: ${response.body}');
        String errorMsg = 'Erreur serveur: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody['message'] != null) {
            errorMsg = errorBody['message'];
          }
        } catch (_) {}
        throw Exception(errorMsg);
      } else {
        _logError('POST $endpoint ${response.statusCode}: ${response.body}');
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      _logError('POST $endpoint ClientException: $e');
      throw Exception('Impossible de se connecter au serveur. Vérifiez que le backend est lancé et que CORS est configuré.');
    } catch (e) {
      _logError('POST $endpoint: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Non autorisé');
      } else {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Non autorisé');
      } else {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Non autorisé');
      } else if (response.statusCode >= 400) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
