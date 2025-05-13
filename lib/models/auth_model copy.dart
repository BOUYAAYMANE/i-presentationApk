import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:i_presence/utils/constante.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthModel extends ChangeNotifier {
  String? _token;
  String? _role;
  int? _userId;
  DateTime? _tokenExpiry;
  final _storage = const FlutterSecureStorage();
  final _prefs = SharedPreferences.getInstance();

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  String? get role => _role;
  int? get userId => _userId;
  DateTime? get tokenExpiry => _tokenExpiry;

  Future<void> loadStoredAuth() async {
    _token = await _storage.read(key: 'token');
    _role = await _storage.read(key: 'role');
    final userId = await _storage.read(key: 'userId');

    final expiryStr = await _storage.read(key: 'tokenExpiry');

    if (_token != null && expiryStr != null) {
      _tokenExpiry = DateTime.parse(expiryStr);
      if (_tokenExpiry!.isBefore(DateTime.now())) {
        await logout(); // Token expiré → déconnexion
        return;
      }
    }

    _userId = userId != null ? int.parse(userId) : null;
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    try {
      // If running on an emulator, may need to use special IP instead of localhost
      String baseUrl = 'http://localhost:8000';
      
      // For Android emulator, localhost of your dev machine is 10.0.2.2
      if (Platform.isAndroid) {
        try {
          baseUrl = 'http://10.0.2.2:8000';
          print('Using Android emulator URL: $baseUrl');
        } catch (e) {
          // If we can't detect platform, stick with original URL
          print('Could not determine platform: $e');
        }
      }
      
      final url = '$baseUrl/api/login';
      print('Connecting to: $url');
      print('Login data: email=$email, password=${password.isNotEmpty ? '(provided)' : '(empty)'}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email, 
          'password': password
        }),
      );
      
      print('Response status: ${response.statusCode}');
      
      // Print response body but handle potential errors
      try {
        print('Response body: ${response.body}');
      } catch (e) {
        print('Could not print response body: $e');
      }
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('JSON decoded successfully');
          
          // Extract token using correct key from API response
          _token = data['access_token'];
          if (_token == null) {
            print('Token was null in response');
            return false;
          }
          
          print('Token received: ${_token!.substring(0, 10)}...');
          
          // Make sure these match the actual structure in your API response
          if (data['user'] != null) {
            _role = data['user']['role'];
            _userId = data['user']['id'];
            print('User info extracted: role=$_role, id=$_userId');
          } else {
            print('User object was null in response');
          }
          
          // Lecture de expires_in depuis l'API
          int expiresIn = data['expires_in'] ?? 3600; // fallback 1h
          _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

          // Store values in secure storage
          await _storage.write(key: 'token', value: _token);
          await _storage.write(key: 'role', value: _role);
          await _storage.write(key: 'userId', value: _userId?.toString());
          print('Credentials saved to secure storage');
          await _storage.write(key: 'tokenExpiry', value: _tokenExpiry!.toIso8601String());

          notifyListeners();
          return true;
        } catch (e) {
          print('Error parsing response JSON: $e');
          return false;
        }
      } else {
        print('Authentication failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    _userId = null;
    _tokenExpiry = null;
    await _storage.deleteAll();
    notifyListeners();
  }

  Future<bool> validateToken() async {
    if (_token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$KbaseUrl/api/user'), // ou une route protégée
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Token invalide ou expiré');
        await logout(); // on efface le token si invalide
        return false;
      }
    } catch (e) {
      print('Erreur de validation du token: $e');
      return false;
    }
  }
}